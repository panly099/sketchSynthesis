function [ lineGroups ] = perceptualGrouping( lines, avgWidth, avgHeight, maxSize, pixelRatio, nGroups, sampleStep, strokeNumPerGroup, weights)
%This function groups the input lines into semantic groups 
%   Input :
%       lines : the given lines needed to be grouped, and each line is
%       represented by pixel locations with its order in the sketch. 
%       avgWidth : the average width of the category.
%       avgHeight : the average height of the category.
%       maxSize : the maximum semantic stroke size.
%       pixelRatio : the ratio of current sketch pixels to the average pixels.
%       nGroups : the number of average groups in a sketch.
%       strokeNumPerGroup : the stroke number in one group.
%       sampleStep : the sampling step for shape context.
%       weights : the weights for proximity, continuity and size.
%   Output :
%       lineGroups : the group of the lines.
%   Author :
%       panly099@gmail.com
%   Version :
%       1.0 27/02/15

errorMax = 1;
%% construct the edge graph (pairwise relationships between edges)
numLine = length(lines);
edgeGraphMx = ones(numLine, numLine);
lineGroups = zeros(length(lines),1);

for i = 1 : numLine
    tmpLine = lines{i};
    parfor j = i+1 : numLine
        error = errorMetric(errorMax, tmpLine, lines{j}, avgWidth, avgHeight, maxSize, pixelRatio, nGroups, strokeNumPerGroup, numLine, sampleStep, weights);
        if error < errorMax
            edgeGraphMx(i,j) = error;
        end
    end
end

%% greedy grouping
groupId = 1;

while 1
    % 1. find out the smallest error
    minError = min(edgeGraphMx(:));
    if minError == errorMax
        break;
    end
    [r,c] = find(edgeGraphMx==minError, 1);
    %    crtGroup = [r c];
    edgeGraphMx(r,c) = errorMax;
    
    % 2. check if they are already grouped
    if lineGroups(r)*lineGroups(c) ~= 0
        % a) both are grouped already
        continue;
    else
        if lineGroups(r) + lineGroups(c) == 0
            % b) neither is grouped
            lineGroups(c) = groupId;
            lineGroups(r) = groupId;
            groupId = groupId + 1;
        else
            if lineGroups(r) == 0
                % c) line r is not grouped yet
                lineGroups(r) = lineGroups(c);
            else
                % d) line c is not grouped yet
                lineGroups(c) = lineGroups(r);
            end
        end
                
        % update the grouped edges' errors to all the edges
        groupSize = 0;
        crtGroup = find(lineGroups == lineGroups(r));
        for i = 1 : length(crtGroup)
            idx = crtGroup(i);
            groupSize = groupSize + size(lines{idx}{1},1);
        end

        for i = 1 : length(crtGroup)
            tmpR = crtGroup(i);
            tmpLine = lines{tmpR};
            parfor j = 1 : length(lines)
                if edgeGraphMx(tmpR, j) ~= errorMax;
                    edgeGraphMx(tmpR, j) = errorMetric(errorMax, tmpLine, lines{j}, avgWidth, avgHeight, maxSize, pixelRatio, nGroups, strokeNumPerGroup, numLine, sampleStep, weights, groupSize);
                end
            end
        end
    end
end

idx = find(lineGroups == 0);
if ~isempty(idx)
    for i = 1 : length(idx)
        lineGroups(idx(i)) = groupId;
        groupId = groupId + 1;
    end
end

% group quality check
% addpath('/homes/yl303/Documents/MATLAB/synthesis/libs/ModHausdorffDist');
% flag = 1;
% minBbox = avgWidth*avgHeight/nGroups/10;
% while flag
%       uGroups = unique(lineGroups);
%       numUGroups = length(uGroups);
%       pixelGroup = zeros(1,numUGroups);
%       sampleGroup = cell(1,numUGroups);
%       
%       for i = 1 : numUGroups
%           idx = (lineGroups == uGroups(i));
%           groupLines = lines(idx);
%           for j = 1 : length(groupLines)
%               curSample = groupLines{j}{1};
%               
%               strokeImg = zeros(avgHeight, avgWidth);
%               for tt = 1 : length(curSample)
%                   strokeImg(curSample(tt,1),curSample(tt,2)) = 1;
%               end
%               bdBox = getBoundingBox(strokeImg, 0);
%               pixelGroup(i) = max(pixelGroup(i), (bdBox(3)-bdBox(1))*(bdBox(4)-bdBox(2))) ;
%               sampleGroup{i} = [sampleGroup{i}; curSample];
%           end   
%       end
%       [pixelGroup, idxGroup] = sort(pixelGroup, 'descend');
%       sampleGroup = sampleGroup(idxGroup);
%       uGroups = uGroups(idxGroup);
%       
%       if pixelGroup(end) < minBbox;
%             minGroupId = uGroups(end);
%             groupDist = zeros(1,numUGroups-1);
%             for i = 1 : numUGroups - 1
%                 allCorrDists = pdist2(sampleGroup{end}, sampleGroup{i});
%                 groupDist(i) = min(allCorrDists(:));
%             end
%             [~, minIdx] = min(groupDist);
%             lineGroups(lineGroups == minGroupId) = uGroups(minIdx);
%       else
%           flag = 0;
%       end
% end
end

function error = errorMetric(errorMax, line1, line2, avgWidth, avgHeight, maxSize, pixelRatio, nGroups, strokeNumPerGroup, numLine, sampleStep, weights, line1GroupSize)
%This function calculates the error score between two input lines
%   Input : 
%       errorMax : the max error score.
%       line1 : the first line
%       line2 : the second line
%       avgWidth : the average width of the category.
%       avgHeight : the average height of the category.
%       maxSize : the maximum semantic stroke size.
%       pixelRatio : the ratio of current sketch pixels to the average pixels.
%       nGroups : the number of average groups in a sketch.
%       strokeNumPerGroup : the stroke number in one group.
%       numLine : the number of total strokes in the sketch.
%       sampleStep : the sampling step for shape context.
%       weights : the weights for proximity, continuity and size.
%       line1GroupSize : the group size which line1 belonging to.
%   Output :
%       error : the error score of the two lines
%   Author : 
%       yi.li@qmul.ac.uk
%   Version :
%       1.0 27/02/15
sample1 = line1{1};
sample2 = line2{1};

if nargin < 13
    line1GroupSize = size(sample1, 1);
end

order1 = line1{2};
order2 = line2{2};


extr1 = line1{3};
extr2 = line2{3};

label1 = line1{4};
label2 = line2{4};

error = 0;
debug =0;

% display the strokes
if debug == 1;
    h1 = figure;
    exImg = zeros(avgHeight, avgWidth);
    for tt = 1 : length(sample1)
        exImg(sample1(tt,1),sample1(tt,2)) = 1;
    end
    imshow(exImg);
    
    h2 = figure;
    exImg = zeros(avgHeight, avgWidth);
    for tt = 1 : length(sample2)
        exImg(sample2(tt,1),sample2(tt,2)) = 1;
    end
    imshow(exImg);
end

%% the proximity error
epsilon1 = sqrt((avgWidth * avgHeight)/nGroups)/2;


dH = ModHausdorffDist(sample1(1:sampleStep:end,:), sample2(1:sampleStep:end,:));
Ep = dH/epsilon1;
error = error + Ep * weights(1);


%% the continuity error  
epsilon2 = epsilon1 / 4;

[dE, I] = pdist2(extr1(1:2,:),extr2(1:2,:), 'euclidean','Smallest', 1);
[dE,min2] = min(dE);
min1 = I(min2);
v1 = extr1(min1,:) - extr1(min1 + 2,:);
v2 = extr2(min2 + 2,:) - extr2(min2,:);
angle = atan2(abs(det([v1',v2'])),dot(v1',v2'));
angle = angle / pi;
dE = dE / epsilon2;
Ec = dE * (1 + angle);

error = error + Ec * weights(2);


%% the scope error
gamma = maxSize * pixelRatio * strokeNumPerGroup * 1.5;
Es = (line1GroupSize + size(sample2,1)) / gamma;
error = error + Es * weights(3);


%% the similarity bonus
sigma = 15;
Bs = 0;
eps_dum = 1;

Bsamp1 = [sample1(1:sampleStep:end,2) sample1(1:sampleStep:end,1)];
pointNum1 = size(Bsamp1,1);
Bsamp2 = [sample2(1:sampleStep:end,2) sample2(1:sampleStep:end,1)];
pointNum2 = size(Bsamp2,1);

if pointNum1 > 5 && pointNum2 > 5 && pointNum1 < 300 && pointNum1 < 300
    [scFeatures1, ~] = sc_compute(Bsamp1',zeros(1,pointNum1),[],12,5,1/8,2,zeros(1, pointNum1));
    [scFeatures2, ~] = sc_compute(Bsamp2',zeros(1,pointNum2),[],12,5,1/8,2,zeros(1, pointNum2));
    
    costmat=hist_cost_2(scFeatures1,scFeatures2);
    % pad the cost matrix with costs for dummies
    
    if pointNum1 < pointNum2
        costmat2=eps_dum*ones(pointNum2,pointNum2);
    else
        costmat2=eps_dum*ones(pointNum1,pointNum1);
    end
    
    costmat2(1:pointNum1,1:pointNum2)=costmat;
    [~, T] =munkres(costmat2);
    Bs = exp(-T^2/sigma^2);
end
error = error - Bs * 0.33;
if error < 0
    error = 0;
end

newError = error;
%% the temporal adjustment
delta = ceil(numLine/nGroups);

if abs(order1 - order2) <= delta
    newError = newError - error*0.33;
else
    newError = newError + error*0.33;
end


%% the label adjustment
if label1 + label2 ~= 0
    if label1 == label2
        newError = newError - error*0.33;
    else
        newError = newError + error*0.33;
    end
end

error = newError;
if error < 0
    error = 0;
end
if error > errorMax 
    error = errorMax;
end

% close the figures;
if debug == 1;
    close(h1); close(h2);
end

end
