%--------------------------------------------------------------------------
% This script manages the parameter settings for all the categories both in
% training time and testing time.
%--------------------------------------------------------------------------
cates = {'horse', 'bicycle', 'face','shark','duck','teapot', ...
    'Artistic faceA90', 'Artistic faceE90',...
    'Artistic faceA30', 'Artistic faceE30',...
    };

if strcmp(type,'training')
    %% training params
    sampleStep = 20;
    %               cate 1   2   3   4   5   6   7     8     9     10
    varNums =           [1   1   1   1   1   1   1     1     1     1];
    angleTrain =        [10  5   10  5   5   5   10    10    10    10];
    detScale =          [3   2   2   2   3   3   2     2     2     2];
    refineCircle =      [3   2   2   2   2   0   2     2     2     2];
    refineStep =        [50  100 100 100 50  100 100   100   100   100];
    overSizePortion =   [7/8 7/8 7/8 7/8 7/8 7/8 1     1     7/8   1];
    strokeNumPerGroup = [1   1   1   1   1   1   11    11    1     3];
    varNumFinal =       [3   3   2   2   2   2   1     1     1     1];
    angleFinal =        [5   5   5   5   5   5   5     5     5     5];
    
    % weights for [ proximity, continuity, size ] in perceptual grouping
    weights = [ 0.33, 0.33, 0.33;...  1
                0.33, 0.33, 0.33;...  2
                0.33, 0.33, 0.33;...  3
                0.33, 0.33, 0.33;...  4
                0.33, 0.33, 0.33;...  5
                0.33, 0.33, 0.33;...  6
                0.5,  0,    0.5;...   7 
                0.5,  0,    0.5;...   8
                0.33, 0.33, 0.33;...  9
                0.33, 0.33, 0.33;...  10
               ];
elseif strcmp(type,'testing')
    %% synthesis params
    %               cate 1   2   3   4   5   6   7    8    9    10
    detScale =          [3   2   2   2   3   2   2    2    1.8  1.8];
    refineCircle =      [5   3   3   3   4   3   2    2    2    2];
    refineStep =        [50  50  50  100 50  100 200  200  200  200];
    edgeThreshold =     [0.3 0.3 0.1 0.1 0.3 0.3 0.2  0.2  0.2  0.2];
    
end