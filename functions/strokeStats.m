function [strokeNums, strokeLengths, sketchStrLenOrd] = strokeStats(trainingPaths)
% This functions obtains the basic stroke statistics for a given category
% Input :
%    trainingPaths : the folders that store the skectches and strokes of
%    the given category.
% Output :
%    strokeNums : the stroke number of each sketch.
%    strokeLengths : the length of each stroke.
%    sketchStrLenOrd : the real stroke sequence and each stroke's length
%    in the sketches.
% Author :
%    panly099@gmail.com
% Version :
%    1.0 07/04/15

strokeNums = [];
sketchStrLenOrd = {};
countStrNums = 0;
strokeLengths = [];
countStrLen = 0;
maxLength = 0;

disp('Summerizing the sketch stroke info :');
for f = 1 : length(trainingPaths)
    poseFolder = trainingPaths{f};
    files = dir(poseFolder);
    
    if isempty(files)
        fprintf('no data to learn for folder: %s ', poseFolder);
        continue;
    end

    for i = 3 : length(files)
        folderPath = [poseFolder, '/', files(i).name];
        if isdir(folderPath)
            fprintf('sketch: %s\n', files(i).name);
            strokeFiles = dir([folderPath, '/*_n.png']);
            countStrNums = countStrNums + 1;
            strokeNums(countStrNums) = length(strokeFiles);
            
            if length(strokeFiles) > maxLength
                maxLength = length(strokeFiles);
            end

            tmpStrokeLength = zeros(2, length(strokeFiles));
            for j = 1 : length(strokeFiles)
                someStrokeFile = [folderPath, '/', strokeFiles(j).name];
                img = imread(someStrokeFile);
                pxs = find(255-img);
                
                countStrLen = countStrLen + 1;
                strokeLengths(countStrLen) = length(pxs);
                
                tmpName = strokeFiles(j).name;
                tmpName = strtok(tmpName,'_');
                
                tmpStrokeLength(1,j) = length(pxs);
                tmpStrokeLength(2,j) = str2double(tmpName);
            end
            
            [~, idx] = sort(tmpStrokeLength(2,:));
            sketchStrLenOrd{countStrNums} = tmpStrokeLength(1,idx);
        end
    end
end



