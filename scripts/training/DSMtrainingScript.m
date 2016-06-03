%--------------------------------------------------------------------------
% This script includes the whole pipeline to train the deformable stroke
% model (DSM). Change the cateId to train DSM for different categories.
%--------------------------------------------------------------------------
%% Pre-settings
% manual session
clear;
close all;

addpath('../');
configureScript;

type = 'training';
paramSettingScript;


% for indication only
% cates = {'horse', 'bicycle', 'face','shark','duck','teapot','Artistic faceA90', 
% 'Artistic faceE90','Artistic faceA30','Artistic faceE30'};

cateId =1;
cate = cates{cateId};

catePath = [DSMRoot, '/data/supervised poses/',cate,'_png'];
cateResultPath = [DSMRoot, '/results/',cate];

if ~exist(cateResultPath, 'dir')
    mkdir(cateResultPath);
end

lPose = 'pose 1l';
rPose = 'pose 1r';

% auto session
if isempty(lPose)
    lPosePath ='';
else
    lPosePath = [catePath, '/', lPose];
end
numL = length(dir([lPosePath,'/*.png']));


if isempty(rPose)
    rPosePath ='';
else
    rPosePath = [catePath, '/', rPose];
end
numR = length(dir([rPosePath,'/*.png']));

numAll = numL + numR;
if numAll == 0
    disp('No data to learn!'); 
    return;
end

%% the statistics of the category
cateInfoPath = [cateResultPath, '/cateInfo'];
if ~exist(cateInfoPath, 'dir')
    mkdir(cateInfoPath);
end

cateNormSketchPath = [cateResultPath, '/normSketches'];
if ~exist(cateNormSketchPath, 'dir')
    mkdir(cateNormSketchPath);
    samePoseSketchNormalization(lPosePath, rPosePath, cateInfoPath, cateNormSketchPath);
end

trainingPaths{1} = [cateNormSketchPath,'/pose 1l'];
trainingPaths{2} = [cateNormSketchPath,'/pose 1r'];

if ~exist('avgWidth', 'var')
    load([cateResultPath,'/cateInfo/dim.mat']);
end

if ~exist([cateInfoPath, '/stats.mat'], 'file')
    [strokeNums, strokeLengths, sketchStrLenOrd] = strokeStats(trainingPaths);
    save([cateInfoPath, '/stats.mat'], 'strokeNums', 'strokeLengths','sketchStrLenOrd');
else
    load([cateInfoPath, '/stats.mat']);
end

sortedStrokeLength = sort(strokeLengths);
minSize = sortedStrokeLength(ceil(length(sortedStrokeLength)/2));
midSize = ceil(mean(sortedStrokeLength));
maxSize = sortedStrokeLength(ceil(length(sortedStrokeLength) * overSizePortion(cateId)));

oneThird = sortedStrokeLength(ceil(length(sortedStrokeLength)/3));
twoThirds = sortedStrokeLength(ceil(2*length(sortedStrokeLength)/3));

sketchPixels = zeros(1, length(sketchStrLenOrd));
sketchStrokeNums = zeros(1, length(sketchStrLenOrd));
for i = 1 : length(sketchStrLenOrd)
    curStrLenOrd = sketchStrLenOrd{i};
    sketchStrokeNums(i) = length(curStrLenOrd);
    sketchPixels(i) = sum(curStrLenOrd);
end
avgSketchPixels = ceil(sum(sketchPixels)/length(sketchPixels));
nGroups = sum(strokeNums)/length(strokeNums)/strokeNumPerGroup(cateId);
maxLength = max(sketchStrokeNums);


%% Iterative Model Training 
% params
display = 1;
fConverge = 0;
iteration = 0;
strokeLabel = {};
lastVar = Inf;
numExemplars = ceil(numAll/3);
varNum = varNums(cateId);
strokeStatisticsScript;

poolobj = parpool(4);
while ~fConverge
    iteration = iteration + 1;
    %% stroke grouping
    if ~exist([cateInfoPath, '/strokeInfo_it',num2str(iteration),'.mat'], 'file')
        [ strokeInfo, perSketchStrokeNum ] = partStrokeGrouping(trainingPaths, cateResultPath, strokeLabel, avgWidth, avgHeight, iteration, ...
                maxSize, avgSketchPixels, nGroups, sampleStep, strokeNumPerGroup(cateId), weights(cateId,:), display);
        save([cateInfoPath, '/strokeInfo_it',num2str(iteration),'.mat'], 'strokeInfo', 'perSketchStrokeNum');
    else
        load([cateInfoPath, '/strokeInfo_it',num2str(iteration),'.mat']);
    end
    
    breakFlag = 0;
    convergenceScript;
    if breakFlag == 1
        break
    end
    %% element learning
    if ~exist([cateInfoPath, '/elements_it',num2str(iteration),'.mat'], 'file')
        perSketchStrokeNum = perSketchStrokeNum(~cellfun('isempty',perSketchStrokeNum));
        
        numStrokes = zeros(1, length(perSketchStrokeNum));

        for i = 1 : length(perSketchStrokeNum)
            numStrokes(i) = length(perSketchStrokeNum{i});
        end
        
        nGroups = round(mean(numStrokes));
        
        [ elements ] = elementLearning(strokeInfo, nGroups, avgWidth, avgHeight, cateResultPath, iteration);
        save([cateInfoPath, '/elements_it',num2str(iteration),'.mat'], 'elements', 'nGroups');
    else
        load([cateInfoPath, '/elements_it',num2str(iteration),'.mat']);
    end
    
    %% stroke model learning
    if ~exist([cateInfoPath, '/strokeModel_it',num2str(iteration),'.mat'], 'file')
        [ strokeModel ] = modelLearning(elements, numExemplars, avgWidth, avgHeight, angleTrain(cateId), varNum);
        save([cateInfoPath, '/strokeModel_it',num2str(iteration),'.mat'], 'strokeModel');
    else
        load([cateInfoPath, '/strokeModel_it',num2str(iteration),'.mat']);
    end
    
    %% model visualization
    fOutputGroup = 0;
    if display
        modelVisScript;
    end
    
    close all;
    %% re-detection on training set
    if ~exist([cateInfoPath, '/strokeLabel_it',num2str(iteration),'.mat'], 'file')
        [ strokeLabel ] = redetect(trainingPaths, strokeModel, avgWidth, avgHeight, minSize, maxSize, ...
            detScale(cateId), refineCircle(cateId), refineStep(cateId), iteration);
        save([cateInfoPath, '/strokeLabel_it',num2str(iteration),'.mat'], 'strokeLabel');
    else
        load([cateInfoPath, '/strokeLabel_it',num2str(iteration),'.mat']);
    end
end

%% learning the final model
iteration = iteration - 1;
angle = angleFinal(cateId);
varNum = varNumFinal(cateId);
load([cateInfoPath, '/elements_it',num2str(iteration),'.mat']);
if ~exist([cateInfoPath, '/strokeModel_final.mat'], 'file')
    [ strokeModel ] = modelLearning(elements, numExemplars, avgWidth, avgHeight, angle, varNum);
    save([cateInfoPath, '/strokeModel_final.mat'], 'strokeModel');
else
    load([cateInfoPath, '/strokeModel_final.mat']);
end
if display == 1
    close all;
    fOutputGroup =0;
    modelVisScript;
end
delete(poolobj);

%% Output the grouping if it is not done during training
% iteration = iteration + 1;
% groupingVisualizationScript;