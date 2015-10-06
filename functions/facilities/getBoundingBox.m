function bbox = getBoundingBox (imInput, fBigWhite)
    
    if fBigWhite
        m = max(imInput(:));
        [y,x] = find(imInput<m);
        bbox(1) = min(x);
        bbox(3) = max(x);
        bbox(2) = min(y);
        bbox(4) = max(y);
    else
        m = min(imInput(:));
        [y,x] = find(imInput>m);
        bbox(1) = min(x);
        bbox(3) = max(x);
        bbox(2) = min(y);
        bbox(4) = max(y);
    end
%     imshow(imgBdBox);
    
    %%%%code to draw bounding box
%     imshow(imInput);
% %     hold on;
% %     rectangle('Position',[leftmost topmost rightmost-leftmost bottommost-topmost], 'LineWidth',2, 'EdgeColor','b');
% %     hold off;
end