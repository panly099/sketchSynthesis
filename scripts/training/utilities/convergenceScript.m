%--------------------------------------------------------------------------
% This script displays the stroke size stats and decide if the algorithm
% converges
%--------------------------------------------------------------------------
tmp = perSketchStrokeNum(~cellfun(@isempty,perSketchStrokeNum));
maxStrokes = 0;
for i = 1 : length(tmp)
    tmpSize = length(tmp{i});
    if tmpSize > maxStrokes
        maxStrokes = tmpSize;
    end
end

showMx = ones(length(tmp), maxStrokes) * 0;
strokeNums = [];
count = 1;
for i = 1 : length(tmp)
    tmpSketch = tmp{i};
    
    % long vs short demonstration
%     tmpSketch(tmpSketch<=midSize) = 0.275;
%     tmpSketch(tmpSketch>midSize) = 0.65;
    
    % sematic demonstration
    showSketch = tmpSketch;
    showSketch(tmpSketch>1) = 0.95;
    showSketch(tmpSketch<=minSize) = 0.275;
    showSketch(tmpSketch>ceil(maxSize*1.5)) = 0.65;
    
   showMx(count, 1 : length(showSketch)) = showSketch;
    strokeNums(count) = length(tmp{i});
    count = count + 1;
end
variance = var(strokeNums)
[~,idx] = sort(strokeNums);
showMx = showMx(idx, :);

if display
    figure; imagesc(showMx,[0,1]); colormap jet;
    set(gca, 'FontSize', 20);
    xlabel('Stroke Order') % x-axis label
    ylabel('Sketch Sample') % y-axis label
end

if variance < lastVar
    lastVar = variance;
elseif iteration > 2
    break;
else
    lastVar = variance;
end
