function samePoseSketchNormalization(lPosePath, rPosePath, cateInfoPath, cateNormSketchPath)
% This function normalizes the png files of the same pose into an average
% size.
% Input :
%   lPosePath : the folder for the training data of the pose heading left.
%   rPosePath : the folder for the training data of the pose heading right.
%   cateInfoPath : the place to store the statistic results.
%   cateNormSketchPath : the place to store the normalized sketch data.
% Author :
%   panly099@gmail.com
% Version :
%   1.0 06/04/2015

filesL = dir(lPosePath);
filesR = dir(rPosePath);

%% obtain average bbox size
disp('Calculating average size');
bCount = 1;
bboxAll = [];

if ~isempty(filesL)
    for i = 3 : length(filesL)
        folderPath = [lPosePath, '/', filesL(i).name];
        if isdir(folderPath)
            realSketchPath = [lPosePath, '/', filesL(i).name, '.png'];
            [A,~,sketch] = imread(realSketchPath);
            if isempty(sketch)
                sketch = A(:,:,1);
                sketch = 255 - sketch;
            end
            bbox = getBoundingBox(sketch,0);
            bboxAll(bCount,:) = bbox;
            bCount = bCount + 1;
         end
    end
end

if ~isempty(filesR)
     for i = 3 : length(filesR)
        folderPath = [rPosePath, '/', filesR(i).name];
        if isdir(folderPath)
            realSketchPath = [rPosePath, '/', filesR(i).name, '.png'];
            [A,~,sketch] = imread(realSketchPath);    
            if isempty(sketch)
                sketch = A(:,:,1);
                sketch = 255 - sketch;
            end
            sketch = flip(sketch, 2);
            
            bbox = getBoundingBox(sketch,0);
            bboxAll(bCount,:) = bbox;
            bCount = bCount + 1;
        end
    end
end

avgBbox = ceil( sum(bboxAll)/size(bboxAll,1) );
avgWidth = avgBbox(3) - avgBbox(1);
avgHeight = avgBbox(4) - avgBbox(2);

save([cateInfoPath,'/dim.mat'], 'avgWidth', 'avgHeight');

%% normalize the training data
lNormPath = [cateNormSketchPath, '/pose 1l'];
if ~exist(lNormPath,'dir')
    mkdir(lNormPath);
end
rNormPath = [cateNormSketchPath,'/pose 1r'];
if ~exist(rNormPath,'dir')
    mkdir(rNormPath);
end

count = 0;
disp('Normalizing the left-oriented training data:');
for i = 3 : length(filesL)
    if isdir([lPosePath, '/', filesL(i).name])
          fprintf('sketch : %s\n',filesL(i).name);  
          count = count + 1;
          strokeFolder = [lPosePath, '/', filesL(i).name];
          sketchFile = [lPosePath, '/', filesL(i).name, '.png'];
          [A,~,sketch] = imread(sketchFile);
          if isempty(sketch)
              sketch = A(:,:,1);
              sketch = 255 - sketch;
          end
          bbox = getBoundingBox(sketch,0);
          reSketch = sketch(bbox(2):bbox(4), bbox(1):bbox(3));
          reSketch = imresize(reSketch, [avgHeight, avgWidth]);
          imwrite(255-reSketch, [lNormPath, '/', filesL(i).name, '_n.png']);
          
          strokeFiles = dir([strokeFolder, '/*.png']);
          lNormStrokeFolderPath = [lNormPath,'/',filesL(i).name];
          if ~exist(lNormStrokeFolderPath,'dir')
              mkdir(lNormStrokeFolderPath);
          end
          for j = 1 : length(strokeFiles)
              if isempty(strfind(strokeFiles(j).name,'_'))
                  someStrokeFile = [strokeFolder, '/', strokeFiles(j).name];
                  [A, ~, img] = imread(someStrokeFile);
                  if isempty(img)
                      img = A(:,:,1);
                      img = 255 - img;
                  end
                  reImg = img(bbox(2):bbox(4), bbox(1):bbox(3));
                  reImg = imresize(reImg, [avgHeight, avgWidth]);
                  tmpName = strokeFiles(j).name;
                  tmpName = strtok(tmpName,'.');
                  
                  imwrite(255-reImg, [lNormStrokeFolderPath, '/', tmpName, '_n.png']);
              end
          end
    end
end

disp('Normalizing the right-oriented training data:');
for i = 3 : length(filesR)
    if isdir([rPosePath, '/', filesR(i).name])
          fprintf('sketch : %s\n',filesR(i).name);  
          count = count + 1;
          strokeFolder = [rPosePath, '/', filesR(i).name];
          sketchFile = [rPosePath, '/', filesR(i).name, '.png'];
          [A,~,sketch] = imread(sketchFile);
          if isempty(sketch)
              sketch = A(:,:,1);
              sketch = 255 - sketch;
          end
          sketch = flip(sketch,2);
          bbox = getBoundingBox(sketch,0);
          reSketch = sketch(bbox(2):bbox(4), bbox(1):bbox(3));
          reSketch = imresize(reSketch, [avgHeight, avgWidth]);
          imwrite(255-reSketch, [rNormPath, '/', filesR(i).name, '_n.png']);
            
          strokeFiles = dir([strokeFolder, '/*.png']);
          rNormStrokeFolderPath = [rNormPath,'/',filesR(i).name];
          if ~exist(rNormStrokeFolderPath,'dir')
              mkdir(rNormStrokeFolderPath);
          end
          
          for j = 1 : length(strokeFiles)
              if isempty(strfind(strokeFiles(j).name,'_'))
                  someStrokeFile = [strokeFolder, '/', strokeFiles(j).name];
                  [A, ~, img] = imread(someStrokeFile);
                  if isempty(img)
                      img = A(:,:,1);
                      img = 255 - img;
                  end
                  img = flip(img,2);
                  reImg = img(bbox(2):bbox(4), bbox(1):bbox(3));
                  reImg = imresize(reImg, [avgHeight, avgWidth]);
                  tmpName = strokeFiles(j).name;
                  tmpName = strtok(tmpName,'.');
                  imwrite(255-reImg,[rNormStrokeFolderPath, '/', tmpName, '_n.png']);
              end
          end
    end
end

fprintf('%d training sketches in total.\n', count);