%--------------------------------------------------------------------------
% This script synthesizes sketches for given images
%--------------------------------------------------------------------------
addpath('../');
configureScript;

type = 'testing';
paramSettingScript;

% for indication only
% cates = {'horse', 'bicycle', 'face','shark','duck','teapot', ...
%    'Artistic faceA90', 'Artistic faceE90',...
%    'Artistic faceA30', 'Artistic faceE30',...
%    };

for cateId = 1 : length(cates)
    cate = cates{cateId};
    catePath= [DSMRoot,'/results/',cate];
    load([catePath, '/cateInfo/strokeModel_final.mat']);
    allSynPath= [catePath, '/synthesis'];
    if exist(allSynPath, 'dir')
            rmdir(allSynPath, 's');
    end
    mkdir(allSynPath);
        
    for iter = 1 : 3
        itSynPath = [allSynPath, '/syntheses_it', num2str(iter)];
        mkdir(itSynPath);
        
        if  isempty(strfind(cate,'face'))
            imgPath = [DSMRoot, '/data/images/', cate, '_img'];
            xmlPath = [DSMRoot, '/data/images/', cate, '_xml'];
        else
            imgPath = [DSMRoot,'/data/images/face_img'];
            xmlPath = [DSMRoot, '/data/images/face_xml'];
            cate = 'face';
        end
        imgList = dir(imgPath);
        xmlList = dir(xmlPath);
        
        for i = 3 : length(imgList)
            imgFilePath = [imgPath, '/', imgList(i).name];
            tmpName = imgList(i).name;
            tmpName = fliplr(tmpName);
            [~, tmpName] = strtok(tmpName, '.');
            tmpName = strtok(tmpName, '.');
            tmpName = fliplr(tmpName);
            
            xmlFilePath = [xmlPath, '/', tmpName, '.xml'];
            synFileFolder = [itSynPath, '/', tmpName];
            if exist(synFileFolder, 'dir')
                rmdir(synFileFolder, 's');
            end
            mkdir(synFileFolder);
            
            im = imread(imgFilePath);
            rec = VOCreadxml(xmlFilePath);
            obj = rec.annotation.object;
            for o = 1 : length(obj)
                if strcmp(obj(o).name, cate)
                    if length(size(im)) > 2
                        I = rgb2gray(im);
                    end
                    bndBox = [str2double(obj(o).bndbox.xmin) str2double(obj(o).bndbox.ymin)...
                        str2double(obj(o).bndbox.xmax) str2double(obj(o).bndbox.ymax)];
                    
                    I = I(bndBox(2):bndBox(4), bndBox(1):bndBox(3));
                    colorI = im(bndBox(2):bndBox(4), bndBox(1):bndBox(3),:);
                    
                    if strcmp(obj(o).pose, 'Right')
                        I = flip(I,2);
                        colorI = flip(colorI,2);
                    end
                    I = imresize(I, [strokeModel.avgHeight, strokeModel.avgWidth]);
                    
                    if  isempty(strfind(cate,'face')) 
                        [edgeSoft] = pbCanny(double(I)/255);
                        edgeSecond = edgeSoft > 0.3;
                        se = strel('disk',2,8);
                        edgeSecond = imdilate(edgeSecond, se);
                    else
                        edgeSecond = I(:,:,1);
                        edgeSecond = edgeSecond < 255;
                    end
%                     figure;imshow(~edgeSecond);
                    
                    configuration = strokeSampling(edgeSecond, strokeModel,detScale(cateId), 1.1, 1.1, 0.7, 5);
                    detection = sketchDetect(edgeSecond, strokeModel, configuration, detScale(cateId), 0.7, 0.4);
                    
                    synthesized1 = zeros(strokeModel.avgHeight, strokeModel.avgWidth);
                    for d = 1 : length(detection)
                        if ~isempty(detection{d})
                            synthesized1 = synthesized1 + detection{d};
                        end
                    end
                    
                    refineDet = detRefinePureLocation(detection,strokeModel, refineCircle(cateId), refineStep(cateId));
                    
                    synthesized2 = zeros(strokeModel.avgHeight, strokeModel.avgWidth);
                    for d = 1 : length(refineDet)
                        if ~isempty(refineDet{d})
                            synthesized2 = synthesized2 + refineDet{d};
                        end
                    end
                    
                    imwrite(colorI, [synFileFolder, '/image.png']);
                    imwrite(~edgeSecond, [synFileFolder, '/edgeMap.png']);
                    imwrite(~synthesized1, [synFileFolder, '/synthesis.png'], 'png');
                    imwrite(~synthesized2, [synFileFolder, '/refinement.png'], 'png');
                    
                end
            end
        end
        
    end
end
