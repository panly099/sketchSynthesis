function [ strokeInfo, perSketchStrokeNum ] = partStrokeGrouping(trainingPaths, cateResultPath, strokeLabel, avgWidth, avgHeight, iteration, maxSize, avgSketchPixels, nGroups, sampleStep, strokeNumPerGroup, weights, display)
%This function groups the strokes, and the shape context feature for each stroke group is obtained afterwards.
%   Input :
%       trainingPaths : the folders contains the sketches of the same pose, including left-heading and right-heading ones.
%       cateResultPath : the place to store intermedian results.
%       strokeLabel : the stroke label obtained from the stroke model.
%       Empty in the first iteration.
%       avgWidth : the average width of the category.
%       avgHeight : the average height of the category.
%       iteration : current iteration of model learning.
%       maxSize : the maximum semantic stroke size.
%       avgSketchPixels : the average pixels in one sketch.
%       nGroups : the number of average groups in a sketch.
%       sampleStep : the sampling step for shape context.
%       strokeNumPerGroup : the stroke number in one group.
%       weights : the weights for proximity, continuity and size.
%       display : control if output debug info.
%   Output :
%       strokeInfo : the strokes for each part.
%       perSketchStrokeNum : the number of stroke groups of each sketch
%       after stroke grouping.
%   Author :
%       panly099@gmail.com
%   Version :
%       1.0 28/02/15 

%% 1. perceptual grouping & shape context computing
countSketch = 0;
outputGrouping =display;

% container stores the grouped stroke(1), its shape context feature(2) and
% its center location(3)
strokeInfo = {};
strokeCount = 0;
perSketchStrokeNum = {};

if outputGrouping == 1
    groupingPath = [cateResultPath, '/grouping/it_', num2str(iteration)];
    if exist(groupingPath, 'dir')
        rmdir(groupingPath, 's');
    end
    mkdir(groupingPath);
end

for f = 1 : length(trainingPaths)
    poseFolder = trainingPaths{f};
    files = dir(poseFolder);
    
    if isempty(files)
        fprintf('no data to learn for folder: %s', poseFolder);
        continue;
    end
    
    for i = 3 : length(files)
        if isdir([poseFolder, '/', files(i).name])
            countSketch = countSketch + 1;

            fprintf('Traversing sketch id: %d\n', countSketch);
          
            fprintf('Grouping sketch: %s\n', files(i).name);
            
            if iteration == 1
            strokeFolder = [poseFolder, '/', files(i).name];
            else
                strokeFolder = [poseFolder, '/', files(i).name, '/it', num2str(iteration-1)];
            end
            strokeFiles = dir([strokeFolder, '/*.png']);
            segList = {};
            sketchPixels = 0;
            
            % 1.1 stroke obtaining
            for j = 1 : length(strokeFiles)
                if ~isempty(strfind(strokeFiles(j).name,'_'))
                    someStrokeFile = [strokeFolder, '/', strokeFiles(j).name];
                    img = imread(someStrokeFile);
                    if iteration == 1
                        img = 255 - img;
                    else 
                        img = ~img;
                    end
                    img = img > 0;
                    
%                     imshow(~img);
                    if sum(img(:)) > 12000 || sum(img(:)) == 0% too long or no pixel
                        continue;
                    end
                    bBox = getBoundingBox(img,0);
                    if bBox(3) - bBox(1) < 3 || bBox(4) - bBox(2) < 3 % too narrow
                        continue;
                    end
                    
                    strokeId = strokeFiles(j).name;
                    strokeId = strtok(strokeId, '_');
                    strokeId = str2double(strokeId);
                    
                    % obtain the endpoints of the stroke
                    [endPoints,finalRoutes] = endPointFinder(img);
                    if isempty(endPoints)
                        continue;
                    end
                    [y,x] = find(finalRoutes{1});
                    [idx1,D1]= rangesearch([y x], endPoints(1,:), 10);
                    [idx2,D2]= rangesearch([y x], endPoints(2,:), 10);
                    endPoints = [endPoints; ...
                        y(idx1{1}(end)) x(idx1{1}(end));...
                        y(idx2{1}(end)) x(idx2{1}(end))];
                    
                    % display the endpoints of the stroke
%                     figure;imshow(sklImg);
%                     figure;imshow(~finalRoutes{1});
%                     hold on; 
%                     plot(endPoints(1,2),endPoints(1,1),'rx','LineWidth',2);
%                     plot(endPoints(2,2),endPoints(2,1),'bx','LineWidth',2);
%                     plot(endPoints(3,2),endPoints(3,1),'r+','LineWidth',2);
%                     plot(endPoints(4,2),endPoints(4,1),'b+','LineWidth',2);
%                     hold off;
                    
                    % original stroke
                    [y,x] = find(img);
                    sketchPixels = sketchPixels + length(y);
                    currentIdx = length(segList);
                    
                    segList{currentIdx+1}{1} = [y x];
                    segList{currentIdx+1}{2} = strokeId;
                    segList{currentIdx+1}{3} = endPoints;
                    if ~isempty(strokeLabel)
                        segList{currentIdx+1}{4} = strokeLabel{countSketch}(strokeId);
                    else
                        segList{currentIdx+1}{4} = 0;
                    end
                end
            end
            
            % 1.2 perceptual grouping
            if ~isempty(segList)
                labels = perceptualGrouping( segList, avgWidth, avgHeight, maxSize, sketchPixels/avgSketchPixels, nGroups, sampleStep, strokeNumPerGroup, weights);
                if outputGrouping == 1
                    h = showGrouping(segList,labels, avgWidth, avgHeight);
                    saveas(h, [groupingPath, '/', files(i).name, '.png']);
                    close(h);
                end
                uLabels = unique(labels);
                reCurSegList = cell(1,length(uLabels));
                for l = 1 : length(uLabels)
                    tmpIdx = labels==uLabels(l);
                    tmpSegList = cat(1,segList{tmpIdx});
                    tmpSegList = tmpSegList(:,1);
                    tmpSegList = cell2mat(tmpSegList);
                    reCurSegList{l} = tmpSegList;
                    
                    % Display the concatenated strokes
                    %                 exImg = zeros(avgHeight, avgWidth);
                    %                 for tt = 1 : size(tmpSegList,1)
                    %
                    %                     exImg(tmpSegList(tt,1),tmpSegList(tt,2)) = 1;
                    %                 end
                    %                 imshow(exImg);
                end
                segList = reCurSegList;
            end
            strGrpSize = zeros(1,length(segList));
            for sg = 1 : length(segList)
                strGrpSize(sg) = size(segList{sg},1);
            end
            perSketchStrokeNum{countSketch} = strGrpSize;
            
            % 1.3 obtain shape context
            for l = 1 : length(segList)
                sample = segList{l};
                Bsamp = [sample(1:sampleStep:end,2) sample(1:sampleStep:end,1)];
                pointNum = size(Bsamp,1);
                
                if pointNum > 5
                    [scFeatures, ~] = sc_compute(Bsamp',zeros(1,pointNum),[],12,5,1/8,2,zeros(1, pointNum));
                    scLoc = [sum(Bsamp(:,1)), sum(Bsamp(:,2))] / pointNum;
                    
                    strokeCount = strokeCount + 1;
                    
                    strokeInfo{strokeCount,1} = sample;
                    strokeInfo{strokeCount,2} = scFeatures;
                    strokeInfo{strokeCount,3} = scLoc;
                    tmp = str2double(files(i).name);
                    strokeInfo{strokeCount,4} = tmp;
                end
            end
        end
    end
end

end
