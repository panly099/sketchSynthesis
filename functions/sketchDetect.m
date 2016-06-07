function [ detection ] = sketchDetect(sample, strokeModel, configurations, searchRatio, threshold, appGeoWeight)
% This function anchors the stroke model on the given input sketch or edge
% map sample via a dynamic programming process.
%   Input :
%       sample : the input sketch or edge map sample.
%       strokeModel : the stroke model.
%       configurations : the sampled configurations of the object.
%       searchRatio : the search ratio of the original stroke bounding box.
%       threshold : the chamfer matching threshold.
%       appGeoWeight : the balance between the appearance and the geometry.
%   Output :
%       detection : the detected model instance.
%   Author :
%       panly099@gmail.com
%   Version :
%       1.1 07/06/2016

if nargin < 5
    threshold = 0.5;
end
if nargin < 6
    appGeoWeight = 0.5;
end

baseScale = 1;
baseAspect = 1;
overlapWeight = 0.001;

mst = strokeModel.mst;
avgWidth = strokeModel.avgWidth;
avgHeight = strokeModel.avgHeight;
clusterBbox = strokeModel.clusterBbox;

[height, width] = size(sample);
numConf = length(configurations);
detections = cell(1, numConf);
energy = zeros(1,numConf);

for a = 1 : numConf
    configuration = configurations{a};
    %% sampling by fast directional chamfer matching (fdcm)
    numCluster = length(configuration);
    strokeCandidates = cell(1, numCluster);
    
    parfor j = 1 : numCluster
        fprintf('current stroke id: %d\n', j);
        strokeImg = configuration{j};
        
        strBbox = getBoundingBox(strokeImg,0);
        strokeImg = strokeImg(strBbox(2):strBbox(4), strBbox(1):strBbox(3));
        
        % compute the search region
        curBbox = clusterBbox(:,j)';
        %         curBbox = strBbox;
        curWidth = curBbox(3) - curBbox(1);
        curHeight = curBbox(4) - curBbox(2);
        searchRegion = [curBbox(1) - ceil((searchRatio - 1) / 2 * curWidth), curBbox(2) - ceil((searchRatio - 1) / 2 * curHeight), ...
            curBbox(3) + ceil((searchRatio - 1) / 2 * curWidth), curBbox(4) + ceil((searchRatio - 1) / 2 * curHeight)];
        if searchRegion(1) < 1
            searchRegion(1) = 1;
        end
        if searchRegion(2) < 1
            searchRegion(2) = 1;
        end
        if searchRegion(3) > width
            searchRegion(3) = width;
        end
        if searchRegion(4) > height
            searchRegion(4) = height;
        end
        
        img = sample(searchRegion(2):searchRegion(4), searchRegion(1):searchRegion(3));
        
        % fdcm anchoring
        [strokeMatched, cost] = chamferLocate(img, strokeImg, baseScale, baseAspect, threshold);
        
        
        %                 figure;imshow(~strokeImg);figure;imshow(~img);
        if size(strokeMatched,1) > 1000
            stop = 1;
        end
        for s = 1 : length(strokeMatched)
            tmpSample = zeros(height, width);
            tmpSample(searchRegion(2):searchRegion(4), searchRegion(1):searchRegion(3)) = strokeMatched{s};
            
            if cost(s) <= 0
                cost(s) = 1;
            end
            strokeCandidates{j}(s,:) = [{tmpSample}, cost(s)];
            %                          figure;imshow(~strokeMatched{s});
            
        end
        
        %         figure;imshow(sample);
    end
    
    %% energy minimization by dynamic programming
    % backward
    fprintf('Backward propogation\n');
    for i = length(mst) : -1 : 2
        fprintf('Scanning MST layer: %d\n', i);
        curLayer = mst{i};
        for j = 1 : length(curLayer)
%             parents = [];
            curEdge = curLayer{j};
            curParent = curEdge{1}(2);
%             parents = [parents curParent];
            curChild = curEdge{1}(1);
            curParam = curEdge{2};
            
            curParentChildIdx = size(strokeCandidates{curParent},2) + 1;
            curParentCandidates = strokeCandidates{curParent}(:,1);
            curChildCandidates = strokeCandidates{curChild};
            
            for p = 1 : length(curParentCandidates)
                tmpBbox = getBoundingBox(curParentCandidates{p}, 0);
                curParentCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
                
                childCosts = ones(1, size(curChildCandidates, 1))*Inf;
                for c = 1 : size(curChildCandidates, 1)
                    tmpBbox = getBoundingBox(curChildCandidates{c,1},0);
                    curChildCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
                    geoNorm = 1/40;
                    curCost = appGeoWeight * curChildCandidates{c,2} - (1-appGeoWeight) * geoNorm * log(mvnpdf(curChildCenter-curParentCenter, ...
                        curParam{2},curParam{3}));
                    
                    for gc = 3 : size(curChildCandidates,2)
                        curCost = curCost + curChildCandidates{c,gc}(2);
                    end
                    
                    childCosts(c) = curCost;
                end
                [minCost, minIdx] = min(childCosts);
                if minCost == Inf
                    stop = 1;
                end
                strokeCandidates{curParent}{p, curParentChildIdx} = [curChild, minCost, minIdx];
            end
            
%             % adding overlapping penalty
%             parents = unique(parents);
%             for u = 1 : length(parents)
%                 curParent = parents(u);
%                 for p = 1 : size(strokeCandidates{curParent}, 1)
%                     curParentImg = strokeCandidates{curParent}{p,1};
%                     overlapCost = 0;
%                     for c = 3 : size(strokeCandidates{curParent}, 2)
%                         curChild = strokeCandidates{curParent}{p,c}(1);
%                         curChildIdx = strokeCandidates{curParent}{p,c}(3);
%                         curChildImg = strokeCandidates{curChild}{curChildIdx,1};
%                         curOverlap = curParentImg.*curChildImg;
%                         overlapCost = overlapCost + sum(curOverlap(:)) * overlapWeight;
%                     end
%                     strokeCandidates{curParent}{p,2} = strokeCandidates{curParent}{p,2} + overlapCost;
%                 end
%             end
        end
    end
    
    % forward
    fprintf('forward propogation\n');
    fprintf('Scanning MST layer: %d\n', 1);
    detection = cell(1, numCluster);
    root = mst{1};
    
    rootCosts = [];
    for i = 1 : size(strokeCandidates{root},1)
        cost = strokeCandidates{root}{i,2};
        for j = 3 : size(strokeCandidates{root},2)
            cost = cost + strokeCandidates{root}{i,j}(2);
        end
        rootCosts(end+1) = cost;
    end
    [~,rootSelected] = min(rootCosts);
    minCost = rootCosts(rootSelected);

    detection{root} = strokeCandidates{root}{rootSelected, 1};
    
    for i = 2 : length(mst)
        fprintf('Scanning MST layer: %d\n', i);
        curLayer = mst{i};
        
        for j = 1 : length(curLayer)
            curEdge = curLayer{j};
            curParent = curEdge{1}(2);
            curChild = curEdge{1}(1);
            curParam = curEdge{2};
            
            curParentCandidate = detection{curParent};
            curChildCandidates = strokeCandidates{curChild};
            
            tmpBbox = getBoundingBox(curParentCandidate, 0);
            curParentCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
            
            childCosts = ones(1, size(curChildCandidates, 1))*Inf;
            for c = 1 : size(curChildCandidates, 1)
                tmpBbox = getBoundingBox(curChildCandidates{c,1},0);
                curChildCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
                
                geoNorm = 1/40;
                curCost = appGeoWeight * curChildCandidates{c,2} - (1-appGeoWeight) * geoNorm * log(mvnpdf(curChildCenter-curParentCenter, ...
                    curParam{2},curParam{3}));
                
                for gc = 3 : size(curChildCandidates,2)
                    curCost = curCost + curChildCandidates{c,gc}(2);
                end
                
                childCosts(c) = curCost;
            end
            [~, minId] = min(childCosts);
            detection{curChild} = curChildCandidates{minId,1};
        end
    end

    
    detections{a} = detection;
    energy(a) = minCost;
    
end
[~,minIdx] = min(energy);
detection = detections{minIdx};

% visualize the detection
% synthesized = zeros(height, width);
% for i = 1 : length(detection)
%     if sum(detection{i}(:))>1
%         synthesized = synthesized + detection{i};
%     end
% end
% figure;imshow(~sample);
% figure;imshow(~synthesized);

end

