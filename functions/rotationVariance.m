function variations = rotationVariance(img, stepAngle, numStep)
% This function generates rotation variations of the stroke image. The 
% stroke image is still the size of the original sketch, so the stroke just
% possesses a small portion of it. The rotation center is the center of the
% stroke bounding box and the image will be expanded if the rotated stroke
% is out of the boundary of the original image.
%
% Input : 
%   img : the stroke image
%   stepAngle : the rotation step, and default is 10 degrees
%   numStep : the number of steps to each direction(left and right), and
%   default is 2
% Output :
%   variations : the rotation variations of the stroke.  
% Author :
%    panly099@gmail.com
% Version :
%    1.0 04/10/2014
   if nargin < 2
       stepAngle = 10;
   end
   if nargin < 3
       numStep = 2;
   end
   
   
       
   variations = cell(1, 2 * numStep + 1);
   variations{1} = img;
   [r,c] = size(img);
   
   if numStep == 0
       return;
   end
   %% obtain stroke bounding box
   bbox = getBoundingBox(img, 0);
   width = bbox(3) - bbox(1) + 1;
   height = bbox(4) - bbox(2) + 1;
   % old center
   cx = floor((bbox(1) + bbox(3))/2);
   cy = floor((bbox(2) + bbox(4))/2);
   
   strokeImg = img(bbox(2):bbox(4), bbox(1):bbox(3));
   
   %% get rotation variations
   count = 2;
   for i = -numStep : numStep
        if i ~= 0
            % rotate the stroke
            angle = i * stepAngle;
            bg = zeros(height,width);
            var = imrotate(strokeImg, angle, 'nearest', 'loose');
%             bg = imrotate(bg, angle, 'nearest', 'loose');
%             var(bg <= 0) = 0;
%             var = imresize(var, [height, width]);
   
            % check if the rotated stroke out of original boundary 
            [rv,cv] = size(var);
            rvf = floor((rv-1)/2);
            rvt = ceil((rv-1)/2);
            
            cvf = floor((cv-1)/2);
            cvt = ceil((cv-1)/2);
            
            newLeft = cx -cvf;
            newRight = cx + cvt;
            newTop = cy -rvf;
            newBottom = cy + rvt;
            
            expLeft = 0;
            expRight = 0;
            expTop = 0;
            expBottom = 0;
            
            if newLeft < 1
                expLeft = 1 - newLeft;
            end
            if newRight > c
                expRight = newRight - c;
            end
            if newTop < 1
                expTop = 1 - newTop;
            end
            if newBottom > r
                expBottom = newBottom - r;
            end
            
            r = r + expTop + expBottom;
            c = c + expLeft + expRight;
            
            cx = cx + expLeft;
            cy = cy + expTop;
            
            % generate the rotated stroke image
            varImg = zeros(r,c);
            varImg(cy - rvf : cy + rvt, cx - cvf : cx + cvt) = var;
            
            variations{count} = varImg;
            count = count + 1;
        end
   end
   
   %visualization for debugging
%    for i = 1 : length(variations)
%         figure; imshow(variations{i});
%    end
end