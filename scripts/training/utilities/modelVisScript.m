%--------------------------------------------------------------------------
% Visualize the learned sketch stroke model
%--------------------------------------------------------------------------
if fOutputGroup
    %% show all the elements in one group
    fprintf('Outputing clusters, iteration: %d\n', iteration);
    elemPath = [cateResultPath, '/elements/it', num2str(iteration)];
    if exist(elemPath, 'dir')
        rmdir(elemPath, 's');
    end
    mkdir(elemPath);
    
    for j = 1 : length(elements)
        disp('.');
        curElemList = elements{j};
        
        strokeGroupPath = [elemPath,'/strokeGroup',num2str(j)];
        if exist(strokeGroupPath,'dir')
            rmdir(strokeGroupPath, 's');
        end
        mkdir(strokeGroupPath);
        
        for k = 1 : size(curElemList, 1)
            curElemSample = curElemList{k,1};
            
            tmpSampleImg = zeros(avgHeight, avgWidth);
            
            for p = 1 : size(curElemSample,1)
                tmpSampleImg(curElemSample(p,1), curElemSample(p,2)) = 1;
            end
            bBox = getBoundingBox(tmpSampleImg, 0);
            bBoxImg = tmpSampleImg(bBox(2) : bBox(4),bBox(1) : bBox(3));
            imgPath = [strokeGroupPath, '/stroke', num2str(k), '.png'];
            imwrite( ~bBoxImg, imgPath, 'png');
        end
    end
    fprintf('done.\n');
else
    %% show example elements
    disp('Model demonstration.');
    pad = 30;
    % interpret the model
    clusterBbox = strokeModel.clusterBbox';
    repStrokes = strokeModel.repStrokes;
    mst = strokeModel.mst;
    
    % place the exemplars in the calculated centers
    clusterCenter = zeros(length(repStrokes),2);
    for k = 1 : length(repStrokes)
        clusterCenter(k,:) = [ceil((clusterBbox(k,2) + clusterBbox(k,4))/2) ceil((clusterBbox(k,1) + clusterBbox(k,3))/2)];
    end
    
  
    for s = 1 : 2 * varNum + 1 :length(repStrokes{1})
        modelImg = zeros(avgHeight + 2 * pad,avgWidth + 2 * pad);
        for k = 1 : length(repStrokes)
            
            curElemSample = repStrokes{k}{s};
            
            tmpSampleImg = zeros(avgHeight, avgWidth);
            
            for p = 1 : size(curElemSample,1)
                tmpSampleImg(curElemSample(p,1), curElemSample(p,2)) = 1;
            end
            
            
            expBbox = getBoundingBox(tmpSampleImg,0);
            expBboxSample = tmpSampleImg(expBbox(2):expBbox(4), expBbox(1):expBbox(3));
            
            expCenter = floor([(expBbox(2) + expBbox(4))/2, (expBbox(1) + expBbox(3))/2]);
            shift = expCenter - clusterCenter(k,:);
            expBbox(1) = expBbox(1) - shift(2);
            expBbox(2) = expBbox(2) - shift(1);
            expBbox(3) = expBbox(3) - shift(2);
            expBbox(4) = expBbox(4) - shift(1);
            
            expBbox = expBbox+[pad pad pad pad];
            
            cropBbox = [1 1 size(expBboxSample,2) size(expBboxSample,1)];
            if expBbox(1) < 1
                cropBbox(1) = 2 - expBbox(1);
                expBbox(1) = 1;
            end
            if expBbox(2) < 1
                cropBbox(2) = 2 - expBbox(2);
                expBbox(2) = 1;
            end
            if expBbox(3) > avgWidth + 2 * pad
                cropBbox(3) = size(expBboxSample,2) - (expBbox(3) - avgWidth);
                expBbox(3) = avgWidth;
            end
            if expBbox(4) > avgHeight + 2 * pad
                cropBbox(4) = size(expBboxSample,1) - (expBbox(4) - avgHeight);
                expBbox(4) = avgHeight;
            end
            
            normalExp = zeros(avgHeight+2*pad, avgWidth+2*pad);
            normalExp(expBbox(2):expBbox(4), expBbox(1):expBbox(3)) = ...
                expBboxSample(cropBbox(2):cropBbox(4), cropBbox(1):cropBbox(3));
            
            
            modelImg = modelImg + normalExp;
        end
        % display
        figure; imshow(~modelImg);
        
        % draw MST
        list=hsv(length(mst)-1);
        hold on;
        for k = 1 : length(mst)
            if k == 1
                plot(clusterCenter(mst{k},2)+pad, clusterCenter(mst{k},1)+pad, 'r*', 'LineWidth',4,'MarkerSize', 20);
            else
                for c = 1 : length(mst{k})
                    point1 =  clusterCenter(mst{k}{c}{1}(1),:)+[pad pad];
                    point2 = clusterCenter(mst{k}{c}{1}(2),:)+[pad pad];
                    plot(point1(2), point1(1), 'c+', 'LineWidth',4,'MarkerSize', 20);
                    line([point2(2),point1(2)],[point2(1),point1(1)],'Color','b','LineWidth',3,'LineStyle','-.')
                end
            end
        end
        hold off;
    end
    
end
