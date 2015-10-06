function strokeSVGfileGeneration(catePath)
% This function decomposes the sketch svg files of the given path into a set of svg files, each of
% which contains only one stroke of the sketch. Each stroke svg file is named by the id of the stroke
% Input :
%     catePath : the folder that stores the svg files.
% Author :
%     panly099@gmail.com
% Version :
%     1.0 15/01/2015

poseFolder = dir(catePath);

for l =  3 : length(poseFolder)
    
    if isdir([catePath,'/',poseFolder(l).name])
        files = dir([catePath,'/',poseFolder(l).name,'/*.svg']);
        fileNum = length(files);
        
        % file loop
        for j = 1 : fileNum
            if isempty(strfind(files(j).name, 'colored'))
                filePath = [catePath, '/', poseFolder(l).name, '/', files(j).name];
                fid = fopen(filePath, 'rt');
                if fid > 0
                else
                    fprintf('loading svg file error!');
                    return;
                end
                
                % make a file folder to contain all the svg files generated from
                % this file
                fileID = strtok(files(j).name, '.');
                fileFolderPath = [catePath, '/', poseFolder(l).name, '/', fileID];
                mkdir(fileFolderPath);
                
                % reading line loop
                tline = fgets(fid);
                lines = [];
                count = 0;
                while ischar(tline)
                    count = count + 1;
                    lines{count} = tline;
                    tline = fgets(fid);
                end
                fclose(fid);
                
                % writing line loop
                lastLine = count - 3;
                firstLine = 6;
                
                for k = firstLine : lastLine
                    strokeFilePath = [fileFolderPath, '/', num2str(k - firstLine + 1), '.svg'];
                    fid = fopen(strokeFilePath,'w');
                    if fid > 0
                    else
                        fprintf('writing stroke svg file error!');
                        return;
                    end
                    
                    fprintf(fid, '%s',lines{1});
                    fprintf(fid, '%s',lines{2});
                    fprintf(fid, '%s',lines{3});
                    fprintf(fid, '%s',lines{4});
                    fprintf(fid, '%s',lines{5});
                    
                    fprintf(fid, '%s',lines{k});
                    
                    fprintf(fid, '%s',lines{count - 2});
                    fprintf(fid, '%s',lines{count - 1});
                    fprintf(fid, '%s',lines{count});
                    
                    fclose(fid);
                end
            end
        end
    end
end
end