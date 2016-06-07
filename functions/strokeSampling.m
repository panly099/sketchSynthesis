function [ configurations ] = strokeSampling(sample, strokeModel, searchRatio, baseScale, baseAspect, threshold, numConf)
% This function samples stroke model configurations on the given input sketch or edge
% map sample via a dynamic programming process.
%   Input :
%       sample : the input sketch or edge map sample.
%       strokeModel : the stroke model.
%       threshold : the chamfer matching threshold.
%       baseScale : the basic scale for chanmfer matching.
%       baseAspect : the basic aspect ratio for the template in chamfer
%       matching.
%       searchRatio : the search ratio of the original stroke bounding box.
%       numConf : the number of configurations wanted.
%   Output :
%       configuration : the sampled configuration of the object.
%   Author :
%       panly099@gmail.com
%   Version :
%       1.1 07/06/16

if nargin < 6
    threshold = 0.3;
end

clusterBbox = strokeModel.clusterBbox;
repStrokes = strokeModel.repStrokes;
mst = strokeModel.mst;

[height, width] = size(sample);


%% fully sampling by fast directional chamfer matching (fdcm)
numCluster = size(clusterBbox,2);
strokeCandidates = cell(numCluster, length(repStrokes{1}));

for i = 1 : numCluster
    fprintf('current cluster id: %d\n', i);
    curRepStrokes = repStrokes{i};
    parfor j = 1 : length(curRepStrokes)
        curRep = curRepStrokes{j};
        strokeImg = zeros(height,width);
        
        for p = 1 : size(curRep, 1)
            strokeImg(curRep(p,1), curRep(p,2))=1;
        end
        %         figure; imshow(strokeImg);
        %         close all;
        strBbox = getBoundingBox(strokeImg,0);
        strokeImg = strokeImg(strBbox(2):strBbox(4), strBbox(1):strBbox(3));
        
        % compute the search region
        curBbox = clusterBbox(:,i)';
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
        [strokeMatched, curCost] = chamferLocate(img, strokeImg, baseScale, baseAspect, threshold);
        
        
        %         figure;imshow(~strokeImg);figure;imshow(~img);
        for s = 1 : min(3, length(curCost))
            tmpSample = zeros(height, width);
            tmpSample(searchRegion(2):searchRegion(4), searchRegion(1):searchRegion(3)) = strokeMatched{s};
            
            if curCost(s) <= 0
                curCost(s) = 1;
            end
            
            strokeCandidates{i,j}(s,:) = [{tmpSample}, exp(-curCost(s))];
            %              figure;imshow(~strokeMatched{s});
            
        end
        
        %         figure;imshow(sample);
    end
end

newStrokeCandidates = cell(1, numCluster);
for i = 1 : numCluster
    newStrokeCandidates{i} = cat(1, strokeCandidates{i,:});
end
strokeCandidates = newStrokeCandidates;
%% sampling from the posterior by dynamic programming
% backward
fprintf('Backward propogation\n');
for i = length(mst) : -1 : 2
    fprintf('Scanning MST layer: %d\n', i);
    curLayer = mst{i};
    for j = 1 : length(curLayer)
        curEdge = curLayer{j};
        curParent = curEdge{1}(2);
        curChild = curEdge{1}(1);
        curParam = curEdge{2};
        
        curParentChildIdx = size(strokeCandidates{curParent},2) + 1;
        curParentCandidates = strokeCandidates{curParent}(:,1);
        curChildCandidates = strokeCandidates{curChild};
        
        for p = 1 : length(curParentCandidates)
            tmpBbox = getBoundingBox(curParentCandidates{p}, 0);
            curParentCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
            
            allProb = zeros(1, size(curChildCandidates, 1));
            for c = 1 : size(curChildCandidates, 1)
                tmpBbox = getBoundingBox(curChildCandidates{c,1},0);
                curChildCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
                
                tmpProb = curChildCandidates{c,2} * mvnpdf(curChildCenter-curParentCenter, curParam{2},curParam{3});
                
                for gc = 3 : size(curChildCandidates,2)
                    tmpProb = tmpProb * curChildCandidates{c,gc}(2);
                end
                allProb(c) = tmpProb;
            end
            
            strokeCandidates{curParent}{p, curParentChildIdx} = [curChild, sum(allProb)];
        end
    end
end

% forward
fprintf('forward propogation\n');

root = mst{1};
rootProbs = [];
for i = 1 : size(strokeCandidates{root},1)
    curProb = strokeCandidates{root}{i,2};
    for j = 3 : size(strokeCandidates{root},2)
        curProb = curProb * strokeCandidates{root}{i,j}(2);
    end
    rootProbs(end+1) = curProb;
end
[~,rootSelected] = sort(rootProbs,'descend');
numConf = min(numConf, length(rootProbs));
configurations = cell(1,numConf);

for f = 1 : numConf
    configuration = cell(1, numCluster);
    configuration{root} = strokeCandidates{root}{rootSelected(f), 1};
    
    for i = 2 : length(mst)
        fprintf('Scanning MST layer: %d\n', i);
        curLayer = mst{i};
        
        for j = 1 : length(curLayer)
            curEdge = curLayer{j};
            curParent = curEdge{1}(2);
            curChild = curEdge{1}(1);
            curParam = curEdge{2};
            
            curParentCandidate = configuration{curParent};
            curChildCandidates = strokeCandidates{curChild};
            
            tmpBbox = getBoundingBox(curParentCandidate, 0);
            curParentCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
            
            allProb = zeros(1, size(curChildCandidates, 1));
            for c = 1 : size(curChildCandidates, 1)
                tmpBbox = getBoundingBox(curChildCandidates{c,1},0);
                curChildCenter = ceil([(tmpBbox(2)+tmpBbox(4))/2, (tmpBbox(1)+tmpBbox(3))/2]);
                
                tmpProb = curChildCandidates{c,2} * mvnpdf(curChildCenter-curParentCenter, curParam{2},curParam{3});
                
                for gc = 3 : size(curChildCandidates,2)
                    tmpProb = tmpProb * curChildCandidates{c,gc}(2);
                end
                allProb(c) = tmpProb;
            end
            [~, maxId] = max(allProb);
            configuration{curChild} = curChildCandidates{maxId,1};
        end
    end
    configurations{f} = configuration;
    
    %         % visualize the sampling
    %         synthesized = zeros(height, width);
    %         for i = 1 : length(configuration)
    %             if sum(configuration{i}(:)) > 1
    %                 synthesized = synthesized + configuration{i};
    %             end
    %         end
    %         figure;imshow(~sample);
    %         figure;imshow(~synthesized);
end

end

