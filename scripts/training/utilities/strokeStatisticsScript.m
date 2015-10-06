%--------------------------------------------------------------------------
% This script produces the plots summarizing the stroke statistics of the 
% given category 
%--------------------------------------------------------------------------
color = { 'b', 'y', 'r', 'c', 'g', 'm','g', 'm', 'c', 'r'};
%% stroke length stat
sortedStrLens = sort(strokeLengths);
figure;

hist(sortedStrLens, 50);
grid off;
set(gca, 'FontSize', 35,'LineWidth',5, 'ticklength', [0.03,0.03] );
xbounds = xlim();
set(gca, 'xtick', xbounds(1):2000:xbounds(2));
ybounds = ylim();
set(gca, 'ytick', ybounds(1):50:ybounds(2))
set(gca,'box','off','color','none')
set(get(gca,'child'),'FaceColor',color{cateId},'EdgeColor',color{cateId});

%% stroke length by order stat
showMx = ones(numAll, maxLength) * 0;
lengthStat = zeros(1,numAll);
count = 1;
for i = 1 : numAll
    tmpSketch = sketchStrLenOrd{i};
    
    % show semantic distribution
%     showSketch = tmpSketch;
%     showSketch(tmpSketch>1) = 0.95;
%     showSketch(tmpSketch<=minSize) = 0.275;
%     showSketch(tmpSketch>ceil(maxSize*1.5)) = 0.65;
    
    % show long vs short distribution
    showSketch = tmpSketch;
    showSketch(tmpSketch<=midSize) = 0.275;
    showSketch(tmpSketch>midSize) = 0.65;
    
    showMx(count, 1 : length(showSketch)) = showSketch;
    count = count + 1;
    
end
[~,idx] = sort(strokeNums);
showMx = showMx(idx, :);
figure; imagesc(showMx,[0,1]); colormap jet;
set(gca, 'FontSize', 17);
% daspect([1,1/5,1]);  % for Disney portrait dataset
xlabel('Stroke Order') % x-axis label
ylabel('Sketch Sample') % y-axis label

