function [ strokeLabel] = redetect(trainingPaths, strokeModel, avgWidth, avgHeight, minSize, maxSize, detScale, refineCricle, refineStep, iteration)
% This function apply the learned stroke model onto training sketches to
% offer the stroke group label for each stroke.
%    Input :
%       trainingPaths : the folders contains the sketches of the same pose, including left-heading and right-heading ones.
%       strokeModel : the learned stroke model.
%       avgWidth : the average width of the category.
%       avgHeight : the average height of the category.
%       minSize : the minimum sematic meaningful size.
%       maxSize : the maximum sematic meaningful size.
%       detScale : the sampling scale.
%       refineCricle : the refinement circle number.
%       refineStep : the refinement step fraction.
%       iteration : current iteration of model learning.
%    Output :
%       strokeLabel : the stroke group label for each storke in the sketch.
%    Author :
%       panly099@gmail.com
%    Version :
%       1.0 24/03/15
countSketch = 0;
strokeLabel = {};

%% traverse all the sketches
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

            % detect on the training sketch
            sketchFile = [poseFolder, '/', files(i).name,'_n.png'];
            sketch = imread(sketchFile);
            sketch = sketch < 255;

            fprintf('\nSampling on sketch: %s\n', files(i).name);
            configurations = strokeSampling(sketch, strokeModel, detScale, 1.1, 1.1, 0.7, 5);
            fprintf('\nEnergy minimization on sketch: %s\n', files(i).name);
            detection = sketchDetect(sketch, strokeModel, configurations, detScale, 0.7, 0.5);
            fprintf('\nRefining the sketch: %s\n', files(i).name);
            detection = detRefinePureLocation( detection, strokeModel, refineCricle, refineStep);
            
            % obtain stroke label from detection
            strokeFolder = [poseFolder, '/', files(i).name];
            strokeFiles = dir([strokeFolder, '/*.png']);
            iterStrokeFolder = [strokeFolder, '/it', num2str(iteration)];
            if exist(iterStrokeFolder, 'dir')
                rmdir(iterStrokeFolder,'s');
            end
            mkdir(iterStrokeFolder);
            
            strokeImgs = {};
            strImgCount = 1;
            for j = 1 : length(strokeFiles)
                if ~isempty(strfind(strokeFiles(j).name,'_'))
                    someStrokeFile = [strokeFolder, '/', strokeFiles(j).name];
                    img = imread(someStrokeFile);
                    img = double(img<255);
                    
                    strokeId = strokeFiles(j).name;
                    strokeId = strtok(strokeId, '_');
                    strokeId = str2double(strokeId);
                    
                    strokeImgs(:,strImgCount) = {img;strokeId};
                    strImgCount = strImgCount + 1;
                end
            end
            strokeIds = cell2mat(strokeImgs(2,:));
            [~, strIdx] = sort(strokeIds);
            strokeImgs = strokeImgs(:, strIdx);
            
            % greedy assignment
            iterStrokes = {};
            iterStrCount = 1;
            for j = 1 : length(strokeImgs)
                img = strokeImgs{1,j};
                strokeId = strokeImgs{2,j};
                fprintf('Processing stroke %d', strokeId);
                
                curStrokeLabel = [];
                curStrokeFinal = {};
                if sum(img(:)) > 0
                    [curStrokeLabel, curStrokeFinal] = detectionAssign(img, detection, [], {}, avgWidth, avgHeight, minSize, maxSize, 1);
                end
                fprintf('\n');
                
                if ~isempty(curStrokeFinal)
                    iterStrokes(iterStrCount : iterStrCount + length(curStrokeFinal) - 1) = curStrokeFinal;
                    strokeLabel{countSketch}(iterStrCount : iterStrCount + length(curStrokeFinal) - 1)  = curStrokeLabel;
                    iterStrCount = iterStrCount + length(curStrokeFinal);
                end
            end

            % output the newly generated strokes of this iteration
            for j = 1 : length(iterStrokes)
                strokePath = [ iterStrokeFolder, '/', num2str(j), '_n.png'];
                imwrite(~iterStrokes{j}, strokePath);
            end
            
            % for visualization
%             labeledStrokes = {};
%             labeledLabel = [];
%             countLabeled = 0;
%             for j = 1 : length(iterStrokes)
%                 countLabeled = countLabeled + 1;
%                 [y,x] = find(iterStrokes{j});
%                 labeledStrokes{countLabeled} = {[y x] j};
%                 labeledLabel(countLabeled) = strokeLabel{countSketch}(j);
%             end
%             
%             showGrouping(labeledStrokes, labeledLabel, avgWidth, avgHeight);
%             pause(1)
%             close all;
        end
    end
end

end

function [strokeLabel, strokeFinal] = detectionAssign(strokeImg, detection, strokeLabel, strokeFinal, avgWidth, avgHeight, minSize, maxSize, depth)
% This function labels the input stroke according to the given detection
% and produce necessary new strokes for overlong input stroke.
%    Input :
%       strokeImg : the input stroke image.
%       detection : the stroke model detection.
%       strokeLabel : the container for stroke labels.
%       strokeFinal : the container for the input stroke and generated
%       stroke(s).
%       avgWidth : the average width of the category.
%       avgHeight : the average height of the category.
%       minSize : the minimum sematic meaningful size.
%       maxSize : the maximum sematic meaningful size.
%    Output :
%       strokeLabel : the stroke group label for the input stroke and new
%       generated stroke(s).
%       strokeFinal : the final genereted stroke(s) from the input stroke.
%    Author :
%       yi.li@qmul.ac.uk
%    Version :
%       1.0 24/03/15
addpath('/homes/yl303/Documents/MATLAB/synthesis/libs/pathFinder');
fprintf('.');

expectedOccupyRate = 0.5;

overlapRate = zeros(1, length(detection));
for m = 1 : length(detection)
    tmp = detection{m}.*strokeImg;
    overlapRate(m) = sum(tmp(:))/sum(strokeImg(:));
end
[overlapRate, idx] = sort(overlapRate,'descend');
numSeg = sum(overlapRate > 0);

if numSeg == 1 || (( depth > 3 || sum(strokeImg(:)) < maxSize) && numSeg > 1 )
    % 1. if the stroke overlaps with 1 stroke or rescursive depth is more than 1
    if overlapRate(1) > expectedOccupyRate
        strokeLabel(end+1) = idx(1);
        strokeFinal{end+1} = strokeImg;
    else
        strokeLabel(end+1) = obtainClosestDetection(strokeImg, detection);
%         strokeLabel(end+1) = 0;
        strokeFinal{end+1} = strokeImg;
    end
elseif numSeg > 1
    % 2. if the stroke overlaps more than 1 model stroke.
    numSeg = 2;
    dCenters = zeros(numSeg,2);
    for i = 1 : numSeg
        [y, x] = find(detection{idx(i)});
        dCenters(i,:) = mean([y x]);
    end
    
    [ endPoints, ~ ] = endPointFinder( strokeImg );
    sklImg = bwmorph(strokeImg, 'skel', Inf);
    
    if isempty(endPoints)
        strokeLabel(end+1) = obtainClosestDetection(strokeImg, detection);
        strokeFinal{end+1} = strokeImg;
        return; % when stroke contains too few pixels.
    end
    % sequantialize the contour points from end to end
    [Yin, Xin]= find(sklImg);
    
    for P = 1 : length(Yin)
        if Yin(P) == endPoints(1,1) && Xin(P) == endPoints(1,2)
            break;
        end
    end
    
    [Xout,Yout]=points2contour(Xin,Yin,P,'cw');
    
%   visualize the trace    
%         for i = 1 : length(Xout)
%            tmp = zeros(avgHeight, avgWidth);
%            tmp(Yout(i), Xout(i)) = 1;
%            imshow(tmp);
%         end
    
    dist = zeros(1, length(Yout));
    for i = 1 : length(Yout)
        dist(i) = abs(norm([Yout(i) Xout(i)] - dCenters(1,:)) - ...
            norm([Yout(i) Xout(i)] - dCenters(2,:))) + ...
            abs(norm([Yout(i) Xout(i)] - endPoints(1,:)) - ...
            norm([Yout(i) Xout(i)] - endPoints(2,:)));
    end
    [~, minIdx] = min(dist);
    segPoints{1} = [Yout(1:minIdx)' Xout(1:minIdx)'];
    segPoints{2} = [Yout(minIdx:end)' Xout(minIdx:end)'];
    
    % segment the stroke by the middle point
    pixels = [];
    segs = {};
    segCount = 0;
    for i = 1 : numSeg
        tmpSeg = zeros(avgHeight, avgWidth);
        for j = 1 : size(segPoints{i},1)
            tmpSeg(segPoints{i}(j,1),segPoints{i}(j,2)) = 1;
        end
      
        % to get the connected strokes output by points2contour
        cc = bwconncomp(tmpSeg);
        subPixels = zeros(1,length(cc.PixelIdxList));
        for k = 1 : length(cc.PixelIdxList)
            segCount = segCount + 1;
            segs{segCount} = zeros(avgHeight, avgWidth);
            segs{segCount}(cc.PixelIdxList{k}) = 1;
            pixels(segCount) = sum(segs{segCount}(:));
        end
    end
    
    [~, segIdx] = sort(pixels,'descend');
    segs = segs(segIdx);
    
    % segment quality check
    restStrokeImg = strokeImg;
    segReCount = 0;
    pixels = [];
    for i = 1 : segCount
        segs{i} = imdilate(segs{i},strel('disk',10,8));
        curStroke = segs{i}.* restStrokeImg;
        restStrokeImg = ~segs{i} .* restStrokeImg;
        
        if sum(curStroke(:)) > 0
            segReCount = segReCount + 1;
            segs{segReCount} = curStroke;
            pixels(segReCount) = sum(curStroke(:));
        end
    end
    if sum(restStrokeImg(:)) > 0
        segReCount = segReCount + 1;
        segs{segReCount} = restStrokeImg;
        pixels(segReCount) = sum(restStrokeImg(:));
    end
    [pixels, segIdx] = sort(pixels,'descend');
    segs = segs(segIdx);
    
    flag = 1;
    while flag && segReCount > 1
        if pixels(segReCount) < minSize
            segs{segReCount-1} = segs{segReCount-1} + segs{segReCount};
            segs{segReCount} = {};
            pixels(segReCount-1) = pixels(segReCount-1) + pixels(segReCount);
            pixels(segReCount) = [];
            segReCount = segReCount - 1;
            [pixels, segIdx] = sort(pixels,'descend');
            segs = segs(segIdx);
        else 
            flag = 0;
        end
    end
    
    % new segment processing
    for i = 1 : segReCount
%                 figure;imshow(segs{i});
        [strokeLabel, strokeFinal] = detectionAssign(segs{i}, detection, strokeLabel, strokeFinal, avgWidth, avgHeight, minSize, maxSize, depth + 1);
    end
    
else
    strokeLabel(end+1) = obtainClosestDetection(strokeImg, detection);
%     strokeLabel(end+1) = 0;
    strokeFinal{end+1} = strokeImg;
end
end

function minIdx = obtainClosestDetection(strokeImg, detection)
% This function finds the closest model stroke for the input strokeImg,
% considering both geodesic distance and shape difference.
% Input :
%   strokeImg : the sketch stroke needed to be labeled.
%   detection : the model strokes.
% Output :
%   minIdx : the index of the nearest model stroke.
% Author :
%   yi.li@qmul.ac.uk
% Version :
%   1.0 13/04/2015

addpath('/homes/yl303/Documents/MATLAB/synthesis/libs/ModHausdorffDist');
addpath('/homes/yl303/Documents/MATLAB/Sketchlet/Libs/sc_demo');
minDist = Inf;
eps_dum = 1;
dist = zeros(1,length(detection));
[strokePoints(:,1), strokePoints(:,2)] = find(strokeImg);

for i = 1 : length(detection)
    detPoints = [];
    [detPoints(:,1), detPoints(:,2)] = find(detection{i});
    dist(i) = ModHausdorffDist(strokePoints(1:20:end,:), detPoints(1:20:end,:));
end
[~, closestIdx] = sort(dist);
closestIdx = closestIdx(1:3);
minIdx = closestIdx(1);
end
