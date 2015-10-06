function [ elements ] = elementLearning(strokeInfo, nGroups, avgWidth, avgHeight, cateResultPath, iteration )
%This function learns the basic elements out given the grouped stroke sets.
% Input :
%   strokeInfo : the grouped strokes of each part.
%   nGroups : the number of clusters needed.
%   avgWidth : the normalized width of the sketch.
%   avgHeight : the normalized height of the sketch.
%   cateResultPath : the folder to save intermedian results.
%   iteration : the current iteration of the learning circle.
% Output :
%   elements : the learned basic elements for each part.
% Author :
%   panly099@gmail.com
% Version :
%   1.0 28/02/15 

%% 1. calculate the shape context distance matrix
elements = cell(1,nGroups);

h = ceil(sqrt(avgWidth^2+avgHeight^2)/sqrt(nGroups));

sample = strokeInfo(:,1);
scFeatures = strokeInfo(:,2);
scLoc = strokeInfo(:,3);
origSketch = strokeInfo(:,4);

numStrokes = size(scFeatures,1);
scLocPairWiseMatrix = zeros(numStrokes,numStrokes);
scPairWiseMatrix = zeros(numStrokes,numStrokes);
eps_dum = 1;
path = [cateResultPath, '/cateInfo' ];
path = [path, '/scMatrix_it',num2str(iteration),'.mat'];

if exist(path,'file')
    load(path);
else
    disp('Calculating the shape context cost matrix.');
    for i = 1 : numStrokes
        fprintf('stroke: %d\n', i);
        sample1 = sample{i};
        BH1 = scFeatures{i};
        Loc1 = scLoc{i};
        
        parfor j = i : numStrokes
            Loc2 = scLoc{j};
            L = norm(Loc1-Loc2);
            if L < h
                sample2 = sample{j};
                BH2 =scFeatures{j};
                
                
                % compute pairwise cost between all shape contexts
                costmat=hist_cost_2(BH1,BH2);
                % pad the cost matrix with costs for dummies
                nsamp1 = size(BH1,1);
                nsamp2 = size(BH2,1);
                
                if nsamp1 < nsamp2
                    costmat2=eps_dum*ones(nsamp2,nsamp2);
                else
                    costmat2=eps_dum*ones(nsamp1,nsamp1);
                end
                
                costmat2(1:nsamp1,1:nsamp2)=costmat;
                [~, T] =munkres(costmat2);
            else
                T = 1000000;
            end
            
            scLocPairWiseMatrix(i,j)=L*T;
            scPairWiseMatrix(i,j) = T;
        end
    end
    
    scLocPairWiseMatrix = scLocPairWiseMatrix + scLocPairWiseMatrix';
    scPairWiseMatrix = scPairWiseMatrix + scPairWiseMatrix';
    save(path,'scPairWiseMatrix','scLocPairWiseMatrix','-v7.3');
end


%% 2. clustering
disp('Clustering the strokes.');
neighbor_num = 15;
[~,A_LS,~] = scale_dist(scLocPairWiseMatrix,floor(neighbor_num/2));

ZERO_DIAG = ~eye(size(scLocPairWiseMatrix,1));
A_LS = A_LS.*ZERO_DIAG;

clustsScLoc = gcut(A_LS,nGroups);

%% 3. stroke complexity ordering
for i = 1 : nGroups
    indices = clustsScLoc{i};

    % sort the cluster
    clusterMx = scPairWiseMatrix(indices, indices);
    tmpDist = sum(clusterMx);
    [~, sortedId ] = sort(tmpDist);
    selectedRange = indices(sortedId);
    elements{i} = [sample(selectedRange) origSketch(selectedRange)];
end

end
