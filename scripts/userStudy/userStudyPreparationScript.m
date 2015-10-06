%--------------------------------------------------------------------------
% This script prepares the data for user study
%--------------------------------------------------------------------------
numParti = 10;
resultPath = '../../results';
dataPath = '../../data/supervised poses';

cates = {'horse', 'bicycle', 'face','shark','duck','teapot'...
         'Artistic faceA30','Artistic faceE30',...
         'Artistic faceA90','Artistic faceE90'};

numCate = length(cates);
%% Make the data folder for each participant
evalPath = [resultPath, '/EvaluationCR'];
if exist(evalPath, 'dir')
    rmdir(evalPath, 's');
end
mkdir(evalPath);

for i = 1 : numParti
    partiFolder = [evalPath,'/', num2str(i)];
    if ~exist(partiFolder, 'dir')
        mkdir(partiFolder);
        recogPath = [partiFolder, '/recognition'];
        mkdir(recogPath);
        linkPath = [partiFolder, '/linking'];
        mkdir(linkPath);
        ratePath = [partiFolder, '/rating'];
        mkdir(ratePath);
    end
end

%% Task 1
% obtain random permutations for each category
disp('Starting task 1 assignment.');
allPerms = zeros(numCate, numParti);
for i = 1 : numCate
    allPerms(i,:) = randperm(numParti);
end

% assign the corresponding sketches
for i = 1 : numCate
    curCate = cates{i};
    curCatePath = [resultPath, '/', curCate, '/final syntheses'];
    sketchList = dir(curCatePath);
    for j = 1 : numParti
        curIndex = allPerms(i,j) + 2;
        curSketchPath = [curCatePath, '/', sketchList(curIndex).name, '/refinement.png'];
        destPath = [evalPath, '/', num2str(j), '/recognition/', num2str(i), '.png' ];
        copyfile(curSketchPath, destPath);
    end
end

%% Task 2
% obtain the combinations
disp('Starting task 2 assignment.');
comb = nchoosek((1:1:10),2);
numOfComb = nchoosek(10,2);
numOfComb = randperm(numOfComb);

for j = 1 : numCate
    fprintf('category id : %d\n', j);
    % rand permutate the orders
    tmpPerm1 = randperm(numParti);
    tmpPerm2 = randperm(numParti);
    
    for i = 1 : numParti
        fprintf('participant id : %d\n', i);
        
        
        curCatePath = [resultPath,'/',cates{j},'/final syntheses'];
        curCatePairList = dir(curCatePath);
        
        % assgin 10 pairs to the participant
        for k = 1 : 10
            curLinkPath = [evalPath, '/', num2str(i), '/linking/', num2str((j-1)*10 + k)];
            if ~exist(curLinkPath, 'dir')
                mkdir(curLinkPath);
            end
            
            curPerm = comb(numOfComb(k),:);
            
            for v = 1 : 2
                curIdx = curPerm(v);
                curImgPath = [curCatePath, '/', curCatePairList(curIdx+2).name, '/image.png'];
                curSketchPath = [curCatePath, '/', curCatePairList(curIdx+2).name, '/refinement.png'];
                
                curLinkPairPath = [curLinkPath, '/', num2str(v)];
                if ~exist(curLinkPairPath, 'dir')
                    mkdir(curLinkPairPath);
                end
                destImgPath = [curLinkPairPath, '/image.png'];
                destSketchPath = [curLinkPairPath, '/refinement.png'];
                
                copyfile( curImgPath, destImgPath );
                copyfile( curSketchPath, destSketchPath );
            end
        end
      
    end
end

%% Task 3
% assign the synthesized sketches
disp('Starting task 3 assignment.');
for i = 1 : numCate
    curCate = cates{i};
    curCatePath = [resultPath, '/', curCate, '/final syntheses'];
    sketchList = dir(curCatePath);
    for j = 1 : numParti
        curIndex = rem((allPerms(i,j) + 1),10) + 3;
        curSketchPath = [curCatePath, '/', sketchList(curIndex).name, '/refinement.png'];
        destPath = [evalPath, '/', num2str(j), '/rating/', num2str(i), '.png' ];
        copyfile(curSketchPath, destPath);
    end
end

% assgin the real sketches
for i = 1 : numCate
    curCate = cates{i};
    curCatePath = [dataPath, '/', curCate, '_png/pose 1l'];
    sketchList = dir([curCatePath, '/*.png']);
    curPerm = randperm(length(sketchList));
    curPerm = curPerm(1:numParti);
    for j = 1 : numParti
        curIndex = curPerm(j);
        curSketchPath = [curCatePath, '/', sketchList(curIndex).name];
        destPath = [evalPath, '/', num2str(j), '/rating/', num2str(i+numCate), '.png' ];
        copyfile(curSketchPath, destPath);
    end
end