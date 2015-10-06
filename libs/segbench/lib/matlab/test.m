im = rgb2gray(double(img)/255);
% figure(1); clf;
% imshow(im);

% create a pb image 
%pb = pbNitzberg(im);
pb = pbGM(im);
% figure(2); clf;
imagesc(pb,[0 1]); 
% axis image; axis off; truesize;
% imshow(pb);