function [ strokeModel ] = modelLearning(elements, numExemplars, avgWidth, avgHeight, angle, varNum)
% This function learns the pictorial structure, given the stroke clusters.
% Input :
%   elements : the learned clusters from the sketches
%   numExemplars : the number of exemplars to choose from each cluster
%   avgWidth : the average width of the category.
%   avgHeight : the average height of the category.
%   angle : the angle step for the rotation variations.
%   varNum : the number of angle variations.
% Output :
%   strokeModel : the learned stroke model out of stroke clusters
% Author :
%   panly099@gmail.com
% Version :
%   1.0 16/03/15
disp('Learning the model MST.');
%% setup
numCluster = length(elements);
newElements = {};
for i = 1 : numCluster
    if length(elements{i}) >= numExemplars
        newElements(end+1) = elements(i);
    end
end
elements = newElements;
numCluster = length(elements);
% affinity matrix for the different clusters
qualityMx = zeros(numCluster, numCluster);
% the normal distribution parameters for each cluster pair
clusterParams = cell(numCluster, numCluster);

%% parameter calculation
for i = 1 : numCluster
    cluster1 = elements{i};
    origList1 = cell2mat(cluster1(:,2));
    for j = 1 : numCluster
        cluster2 = elements{j};
        origList2 = cell2mat(cluster2(:,2));
        
        comSketch = intersect(origList1,origList2);
        if length(comSketch) < 5
             clusterParams{i,j} = {};
             continue;
        end
        % mean
        summary = [];
        count = 0;
        for u = 1 : length(comSketch)
            stroke1 = cluster1{find(origList1 == comSketch(u), 1),1};
            stroke2 = cluster2{find(origList2 == comSketch(u), 1),1};
            count = count + 1;
            tmpImg = zeros(avgHeight, avgWidth);
            for p = 1 : size(stroke1, 1)
                tmpImg(stroke1(p,1),stroke1(p,2)) = 1;
            end
%             imshow(tmpImg);
            bBox = getBoundingBox(tmpImg, 0);
            center1 = ceil([(bBox(2)+bBox(4))/2, (bBox(1)+bBox(3))/2]);
            
            tmpImg = zeros(avgHeight, avgWidth);
            for p = 1 : size(stroke2, 1)
                tmpImg(stroke2(p,1),stroke2(p,2)) = 1;
            end
%             imshow(tmpImg);
            bBox = getBoundingBox(tmpImg, 0);
            center2 = ceil([(bBox(2)+bBox(4))/2, (bBox(1)+bBox(3))/2]);
            
            summary(count,1:2) = center1 - center2;
            summary(count,3) = 1 - norm(summary(count,1:2))/max(avgWidth,avgHeight);
            
        end
        
        mu = mean(summary(:,1:2), 1);
        
        % variance
        sigma = cov(summary(:,1:2));

        clusterParams{i,j} = {summary mu sigma};
        
    end
    
    strokeModel.repStrokes{i} = elements{i}(1:numExemplars,1);
    newRep = {};
    for n = 1 : length(strokeModel.repStrokes{i})
        curSample = strokeModel.repStrokes{i}{n};
        tmpImg = zeros(avgHeight,avgWidth);
        for p = 1 : size(curSample, 1)
            tmpImg(curSample(p,1), curSample(p,2)) = 1;
        end
        variations = rotationVariance(tmpImg,angle, varNum);
        for v = 1 : length(variations)
            r = [];
            c = [];
            [r, c] = find(variations{v});
            newRep{end+1} = [r c];
        end
    end
    strokeModel.repStrokes{i} = newRep';
end

%% affinity matrix calculation
for i = 1 : numCluster
    for j = 1 : numCluster
        if i == j
            qualityMx(i,j) = 0;
        else
            if ~isempty(clusterParams{i,j})
                data = clusterParams{i,j}{1};
                mu = clusterParams{i,j}{2};
                sigma = clusterParams{i,j}{3};
                
                array = zeros(1, size(data,1));
                for e = 1 : size(data,1)
                    %                                 array(e) = mvnpdf(data(e,1:2), mu, sigma);
                    array(e) = data(e,3);
                end
                qualityMx(i,j) = -log(prod(array));
            else
                qualityMx(i,j) = 0;
            end
        end
    end
end

%% MST & stroke bounding box computation
pixelsCluster = zeros(1, numCluster);
for i = 1 : numCluster
    curCluster = elements{i};
    pixels = 0;
    for j = 1 : size(curCluster, 1)
        curStroke = curCluster{j, 1};
        pixels = pixels + size(curStroke, 1);
    end
    pixelsCluster(i) = pixels / size(curCluster, 1);
end

[~, pred] = graphminspantree(sparse(qualityMx));
queCluster = zeros(2,1);
MST = {};


while ~isempty(queCluster)
    inds = find(queCluster(1,1) == pred);
    parentDepth = queCluster(2,1);
    parentNode = queCluster(1,1);
    queCluster(:,1) = [];
    
    if ~isempty(inds)
        curDepth = parentDepth + 1;
        nInds = length(inds);
        queCluster(:,end+1:end+nInds) = [inds; ones(1,length(inds)) * (parentDepth + 1)];
        
        maxLayer = length(MST);
        if curDepth > maxLayer
            MST{curDepth} = {};
        end
        
        for i = 1 : nInds
            curTreeIdx = length(MST{curDepth});
            curTreeIdx = curTreeIdx + 1;
            
            if parentNode ~= 0
                tmpPred = pred(1:inds(i));
                numNanBeforeInds = sum(uint8(isnan(tmpPred)));
                tmpPred = pred(1:parentNode);
                numNanBeforeParent = sum(uint8(isnan(tmpPred)));
                MST{curDepth}{curTreeIdx} = {[inds(i)-numNanBeforeInds, parentNode-numNanBeforeParent] clusterParams{inds(i), parentNode}};
            else
                tmpPred = pred(1:inds(i));
                numNanBeforeInds = sum(isnan(tmpPred));
                MST{curDepth} = inds(i)-numNanBeforeInds;
            end
            
            curElem = elements{inds(i)};
            curEndpoints = zeros(size(elements,1),4);
            for e = 1 : size(curElem, 1)
                curEndpoints(e, :) = [min(curElem{e,1}(:,2)) min(curElem{e,1}(:,1)) max(curElem{e,1}(:,2)) max(curElem{e,1}(:,1))];
            end
            
            clusterBbox(inds(i), :) = ceil(mean(curEndpoints));
        end          
    end
end

strokeModel.repStrokes(isnan(pred))=[];
clusterBbox(isnan(pred),:) = [];

%% Final model
strokeModel.mst = MST;
strokeModel.clusterBbox = clusterBbox';
strokeModel.avgWidth = avgWidth;
strokeModel.avgHeight = avgHeight;
end