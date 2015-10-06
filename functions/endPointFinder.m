function [ endPoints, finalRoutes ] = endPointFinder( strokeImg )
% This function finds the endpoints for the given stroke image.
% Input :
%   strokeImg : the stroke image.
% Output :
%   endpoints : the end points of the given stroke.
%   finalRoutes : the finalRoute from one end point to the other.
% Author :
%   panly099@gmail.com
% Version :
%   1.0 23/04/15
endPoints = [];
finalRoutes = {};
sklImg = bwmorph(strokeImg,'skel', Inf);
cc = bwconncomp(sklImg);

for k = 1 : length(cc.PixelIdxList)
    tmplImg = zeros(size(strokeImg));
    tmplImg(cc.PixelIdxList{k}) = 1;
    
    endPointsImg = bwmorph(tmplImg,'endpoints');
    [r, c] = find(endPointsImg == 1);
    if size(r,1) < 2 || var(r) <= 1 || var(c) <= 1% circle condition
        [y,x] = find(sklImg);
        r = [y(1);y(end)];
        c = [x(1);x(end)];
    end
    
    vec = 1:length(r);
    if length(vec) == 1% strokes contains too few pixels
        continue;
    end
    C = combnk(vec,2);
    
    routeLengthMax = 0;
    tmpEndPoints = [];
    for p = 1 : size(C, 1)
        r1 = r(C(p,1));
        c1 = c(C(p,1));
        
        r2 = r(C(p,2));
        c2 = c(C(p,2));
        
        D1 = bwdistgeodesic(sklImg, c1, r1, 'quasi-euclidean');
        D2 = bwdistgeodesic(sklImg, c2, r2, 'quasi-euclidean');
        
        D = D1 + D2;
        D = round(D * 8) / 8;
        
        D(isnan(D)) = inf;
        if min(D(:)) ~= inf
            skeleton_path = imregionalmin(D);
            
            sizePath = sum(skeleton_path(:));
            if sizePath > routeLengthMax
                routeLengthMax = sizePath;
                tmpFinalRoute = skeleton_path;
                tmpEndPoints = [r1 c1; r2 c2];
            end
        end
    end
    if ~isempty(tmpEndPoints)
        endPoints =[endPoints;tmpEndPoints];
        finalRoutes{end+1} = tmpFinalRoute;
    end
end

    % display the endpoints
%     figure;imshow(sklImg);
%     hold on;
%     for j = 1 : size(endPoints,1)
%         plot(endPoints(j,2),endPoints(j,1),'rx','LineWidth',2);
%     end
%     hold off;
%     close all;
end

