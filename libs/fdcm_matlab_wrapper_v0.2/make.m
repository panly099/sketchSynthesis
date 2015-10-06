mex -g -v -c Fitline/LFLineFitter.cpp -I.
mex -g -v -c Fitline/LFLineSegment.cpp -I.
mex -g -v -c Image/DistanceTransform.cpp -I.
mex -g -v -c Fdcm/EIEdgeImage.cpp -I.
mex -g -v -c Fdcm/LMDirectionalIntegralDistanceImage.cpp -I.
mex -g -v -c Fdcm/LMDisplay.cpp -I.
mex -g -v -c Fdcm/LMDistanceImage.cpp -I.
mex -g -v -c Fdcm/LMLineMatcher.cpp -I.
mex -g -v -c Fdcm/LMNonMaximumSuppression.cpp -I.
mex -g -v -c Fdcm/MatchingCostMap.cpp -I.

% make fdcm
mex -v -g mex_fdcm_detect.cpp...
    LFLineFitter.o LFLineSegment.o DistanceTransform.o ...
    EIEdgeImage.o LMDirectionalIntegralDistanceImage.o LMDisplay.o...
    LMDistanceImage.o LMLineMatcher.o LMNonMaximumSuppression.o...
    MatchingCostMap.o

% make fitline
mex -v -g mex_fitline.cpp LFLineFitter.o LFLineSegment.o

delete *.o