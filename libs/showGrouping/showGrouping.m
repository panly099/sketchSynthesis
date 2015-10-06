function h = showGrouping(strokes, label, avgWidth, avgHeight)
% This function displays the grouping results with color encoded groups.
% Input :
%    strokes : the strokes.
%    label : the group label for each stroke.
%    avgWidth : the average width of the category.
%    avgHeight : the average height of the category.
% Output :
%    h : the handle of the figure.
% Author :
%    qiyongg@gmail.com & yi.li@qmul.ac.uk
% Version :
%    1.0 27/7/2015

load colors.mat;

img = ones(avgHeight, avgWidth);
img = logical(img);
h=figure('visible','on','Position',[10,10,size(img,1),size(img,2)]);imshow(img);

num_segs = size(strokes,2);
uLabel = unique(label);
num_groups = length(uLabel);

hold on;

for k=1:num_groups
    idx = find(label == uLabel(k));
    for i = 1 : length(idx)
        scatter(strokes{1,idx(i)}{1}(:,2),strokes{1,idx(i)}{1}(:,1), 10, colors(mod(label(idx(i)),15)+1,:));
        
        ind = floor(size(strokes{1,idx(i)}{1},1)/2);
        
        
        if ind == 0
            ind = 1;
        end
        
        % show group label
        %                 if i == 1
        %                 text(ConSegList{1,idx(i)}{1}(ind,2),ConSegList{1,idx(i)}{1}(ind,1),num2str(uLabel(k)),'FontSize',20);
        %                 %             text(ConSegList{1,idx(i)}(ind,2),ConSegList{1,idx(i)}(ind,1),num2str(idx(i)),'FontSize',20);
        %                 end
    end
end

set(gca,'ydir','reverse');
hold off;

end

