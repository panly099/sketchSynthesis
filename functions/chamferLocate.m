function [strokeMatched, cost] = chamferLocate(img, stroke, baseScale, baseAspect, threshold)
% This function employs chamfer matching to locate the given stroke in the
% edge map image.
% Input :
%   img : the edge map search region
%   stroke : the given stroke image
%   baseScale : the base scale for searching
%   baseAspect : the base aspect ratio for searching
%   threshold : the matching threshold
% Output :
%   strokeMatched : the new stroke image in which the stroke is placed in
%   the best matched location in the edge map search region
%   score : the chamfer distance
% Author :
%   panly099@gmail.com
% Version :
%   1.0 03/10/2014

if nargin < 5
    threshold = 0.3;
end

% get bounding box of the searching region
[r, c] = size(img);

cost = [];
strokeMatched = {};

if size(stroke,1)<3 || size(stroke,2) < 3
    cost = 1;
    tmpImg = zeros(r, c);
    center = [ceil(r/2), ceil(c/2)];
    
    [rdet, cdet] = size(stroke);
    if rdet > r
        rdet = r;
    end
    if cdet > c
        cdet = c;
    end
    
    stroke = imresize(stroke, [rdet cdet]);
    stroke = stroke > 0.2;
    
    rf = floor((rdet-1)/2);
    rc = ceil((rdet-1)/2);
    cf = floor((cdet-1)/2);
    cc = ceil((cdet-1)/2);
    
    
    tmpImg(center(1)-rf:center(1)+rc, center(2)-cf:center(2)+cc) = stroke;
    strokeMatched{1} = tmpImg;
    
    return;
end
%% Convert edge map into line representation
% 
lineMatchingPara = struct(...
    'NUMBER_DIRECTION',60,...
    'DIRECTIONAL_COST',0.5,...
    'MAXIMUM_EDGE_COST',30,...
    'MATCHING_SCALE',1.0,...
    'TEMPLATE_SCALE',1.0,...
    'BASE_SEARCH_SCALE',baseScale,...
    'MIN_SEARCH_SCALE',-1,...         % base_search_scale.^min_search_scale : base_search_scale.^max_search_scale
    'MAX_SEARCH_SCALE',1,...
    'BASE_SEARCH_ASPECT',baseAspect,...
    'MIN_SEARCH_ASPECT',-1,...
    'MAX_SEARCH_ASPECT',1,...    
    'SEARCH_STEP_SIZE',2,...
    'SEARCH_BOUNDARY_SIZE',2,...
    'MIN_COST_RATIO',1.0...    
    );

% lineMatchingPara = struct(...
%     'NUMBER_DIRECTION',60,...
%     'DIRECTIONAL_COST',0.5,...
%     'MAXIMUM_EDGE_COST',30,...
%     'MATCHING_SCALE',1.0,...
%     'TEMPLATE_SCALE',1.0,...
%     'BASE_SEARCH_SCALE',1,...
%     'MIN_SEARCH_SCALE',1,...         % base_search_scale.^min_search_scale : base_search_scale.^max_search_scale
%     'MAX_SEARCH_SCALE',1,...
%     'BASE_SEARCH_ASPECT',1.2,...
%     'MIN_SEARCH_ASPECT',-1,...
%     'MAX_SEARCH_ASPECT',1,...    
%     'SEARCH_STEP_SIZE',2,...
%     'SEARCH_BOUNDARY_SIZE',2,...
%     'MIN_COST_RATIO',1.0...    
%     );


lineFittingPara = struct(...
    'SIGMA_FIT_A_LINE',0.5,...
    'SIGMA_FIND_SUPPORT',0.5,...
    'MAX_GAP',2.0,...
    'N_LINES_TO_FIT_IN_STAGE_1',300,...
    'N_TRIALS_PER_LINE_IN_STAGE_1',100,...
    'N_LINES_TO_FIT_IN_STAGE_2',100000,...
    'N_TRIALS_PER_LINE_IN_STAGE_2',1);

% convert the template edge map into a line representation
[lineRep, ~] = mex_fitline(double(stroke),lineFittingPara);

%% FDCM detection
lineFittingPara2 = struct(...
    'SIGMA_FIT_A_LINE',0.5,...
    'SIGMA_FIND_SUPPORT',0.5,...
    'MAX_GAP',2.0,...
    'N_LINES_TO_FIT_IN_STAGE_1',0,...
    'N_TRIALS_PER_LINE_IN_STAGE_1',0,...
    'N_LINES_TO_FIT_IN_STAGE_2',100000,...
    'N_TRIALS_PER_LINE_IN_STAGE_2',1);

template{1} = lineRep;
[detWinds] = mex_fdcm_detect(double(img),template,threshold,...
    lineFittingPara2,lineMatchingPara);

% detection visulization
% numWinds = size(detWinds,1);
% for i = 1 : numWinds
%     if ~isempty(detWinds(i,:))
%         imshow(img);
%         hold on;
%         rectangle('Position',detWinds(i,1:4),'EdgeColor','White');
%         hold off;
%     end
% end

%% Generate the returning stroke image
if ~isempty(detWinds)
    for d = 1 : size(detWinds,1)
        tmpImg = zeros(r, c);
        bbox = detWinds(d,1:4);
        rdet = bbox(4);
        cdet = bbox(3);
        if rdet > 0 && cdet > 0
            cost(d) = detWinds(d, 5);
            stroke = imresize(stroke, [rdet,cdet]);
            stroke = stroke > 0.2;
            
            tmpImg(bbox(2) : bbox(2) + bbox(4) - 1, bbox(1) : bbox(1) + bbox(3) - 1) = stroke;
        else
            cost(d) = 1;
            center = [ceil(r/2), ceil(c/2)];
            [rdet, cdet] = size(stroke);
            if rdet > r
                rdet = r;
            end
            if cdet > c
                cdet = c;
            end
            stroke = imresize(stroke, [rdet cdet]);
            stroke = stroke > 0.2;
            
            rf = floor((rdet-1)/2);
            rc = ceil((rdet-1)/2);
            cf = floor((cdet-1)/2);
            cc = ceil((cdet-1)/2);
            
            tmpImg(center(1)-rf:center(1)+rc, center(2)-cf:center(2)+cc) = stroke;
        end
        strokeMatched{d} = tmpImg;
    end
else    
        % put the stroke in the middle of image
        cost = 1;
        tmpImg = zeros(r, c);
        center = [ceil(r/2), ceil(c/2)];
%         
        [rdet, cdet] = size(stroke);
        if rdet > r
            rdet = r;
        end
        if cdet > c
            cdet = c;
        end
        stroke = imresize(stroke, [rdet cdet]);
        stroke = stroke > 0.2;
        
        rf = floor((rdet-1)/2);
        rc = ceil((rdet-1)/2);
        cf = floor((cdet-1)/2);
        cc = ceil((cdet-1)/2);
        
        
        tmpImg(center(1)-rf:center(1)+rc, center(2)-cf:center(2)+cc) = stroke;

        strokeMatched{1} = tmpImg;
end

% visulization for debugging
% figure;imshow(strokeMatched, [0 255]);
% figure;imshow(img);
end