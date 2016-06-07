function [ newDetection ] = detRefinePureLocation( newDetection, strokeModel, numCircle, stepFraction )
%This function refines the detection by minimizing the gaps between
%strokes.
%   Input :
%       detection : the synthesized sketch strokes.
%       strokeModel : the learned stroke model of the given category.
%       numCircle : the number of circles to shift around the original
%       position.
%       stepFraction : the fraction of the step of each circle upon the
%       image dimension.
%   Output :
%       newDetection : the refined sketch synthesis.
%   Author :
%       panly099@gmail.com
%   Version :
%       1.0 07/06/2016
disp('Refining sketch:');

%% sampling by shifting
nClusters = length(newDetection);
[height, width] = size(newDetection{1});
strokeCandidates = cell(1, nClusters);

disp('Shifting the strokes');
step = ceil(min(height,width)/stepFraction);
weightShift = 0.0004;
overlapWeight = 0;
for i = 1 : nClusters
    curDetection = newDetection{i};
    curBbox = getBoundingBox(curDetection, 0);
    
    for u = -numCircle : numCircle % y axis shifting
        for v = -numCircle : numCircle % x axis shifting
            tmpImg = zeros(height,width);
            shitfedBbox = curBbox + [v*step u*step v*step u*step];
            if shitfedBbox(1) < 1 || shitfedBbox(2) < 1 || shitfedBbox(3) > width || shitfedBbox(4) > height
                continue;
            end
            tmpImg(shitfedBbox(2):shitfedBbox(4), shitfedBbox(1):shitfedBbox(3)) = ...
                curDetection(curBbox(2):curBbox(4), curBbox(1):curBbox(3));
            
            if sum(tmpImg(:)) > 0
                strokeCandidates{i}(end+1,:) = [{tmpImg}, weightShift * norm([v*step u*step])];
            end
        end
    end
end
%% optimization by dynamic programming
disp('Optimizing the stroke locations');
mst = strokeModel.mst;
for i = length(mst) : -1 : 2
    fprintf('Scanning MST layer: %d\n', i);
    curLayer = mst{i};
    for j = 1 : length(curLayer)
%         parents = [];
        curEdge = curLayer{j};
        curParent = curEdge{1}(2);
%         parents = [parents curParent];
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
                curCost = curChildCandidates{c,2} - geoNorm * log(mvnpdf(curChildCenter-curParentCenter, ...
                    curParam{2},curParam{3}));
                
                for gc = 3 : size(curChildCandidates,2)
                    curCost = curCost + curChildCandidates{c,gc}(2);
                end
                
                childCosts(c) = curCost;
            end
            [minCost, minIdx] = min(childCosts);
            strokeCandidates{curParent}{p, curParentChildIdx} = [curChild, minCost, minIdx];
        end
        
        % adding overlapping penalty
%         parents = unique(parents);
%         for u = 1 : length(parents)
%             curParent = parents(u);
%             for p = 1 : size(strokeCandidates{curParent}, 1)
%                 curParentImg = strokeCandidates{curParent}{p,1};
%                 overlapCost = 0;
%                 for c = 3 : size(strokeCandidates{curParent}, 2)
%                     curChild = strokeCandidates{curParent}{p,c}(1);
%                     curChildIdx = strokeCandidates{curParent}{p,c}(3);
%                     curChildImg = strokeCandidates{curChild}{curChildIdx,1};
%                     curOverlap = curParentImg.*curChildImg;
%                     overlapCost = overlapCost + sum(curOverlap(:)) * overlapWeight;
%                 end
%                 strokeCandidates{curParent}{p,2} = strokeCandidates{curParent}{p,2} + overlapCost;
%             end
%         end
    end
end
% forward
fprintf('forward propogation\n');
fprintf('Scanning MST layer: %d\n', 1);
newDetection = cell(1, nClusters);
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
newDetection{root} = strokeCandidates{root}{rootSelected, 1};

for i = 2 : length(mst)
    fprintf('Scanning MST layer: %d\n', i);
    curLayer = mst{i};
    
    for j = 1 : length(curLayer)
        curEdge = curLayer{j};
        curParent = curEdge{1}(2);
        curChild = curEdge{1}(1);
        curParam = curEdge{2};
        
        curParentCandidate = newDetection{curParent};
        curChildCandidates = strokeCandidates{curChild};
        
        tmpBbox = getBoundingBox(curParentCandidate, 0);
        curParentCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
        
        childCosts = ones(1, size(curChildCandidates, 1))*Inf;
        for c = 1 : size(curChildCandidates, 1)
            tmpBbox = getBoundingBox(curChildCandidates{c,1},0);
            curChildCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
            
            curCost = curChildCandidates{c,2} - geoNorm * log(mvnpdf(curChildCenter-curParentCenter, ...
                    curParam{2},curParam{3}));
            
            for gc = 3 : size(curChildCandidates,2)
                curCost = curCost + curChildCandidates{c,gc}(2);
            end
            
            childCosts(c) = curCost;
        end
        [~, minId] = min(childCosts);
        newDetection{curChild} = curChildCandidates{minId,1};
    end
end

% visualize the refined detection
% refined = zeros(height, width);
% for i = 1 : length(newDetection)
%    if ~isempty(newDetection{i})
%        refined = refined + newDetection{i};
%    end
% end
% figure;imshow(~refined);
end

