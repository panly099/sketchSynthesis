%--------------------------------------------------------------------------
% This script summarizes the user study results
%--------------------------------------------------------------------------
resultPath = '../../results';
evalPath = [resultPath, '/EvaluationCR'];

numPart = 10;
%% recognition
correctAnswer = {'horse','bicycle','face','shark','duck','teapot'};
answers = zeros(numPart,6);
for i = 1 : numPart
    curPartPath = [evalPath,'/',num2str(i),'/recogResults.mat'];
    load(curPartPath);
    for j = 1  : length(correctAnswer)
        if strcmp(recogResults{j}, correctAnswer{j})
            answers(i,j) = 1;
        else 
            answers(i,j) = 0;
        end
    end
end

%% linking
cateResults = zeros(1,4);
for i = 1 : numPart
    curPartPath = [evalPath,'/',num2str(i),'/linkResults.mat'];
    load(curPartPath);
    result = abs(link(:,1) - link(:,2));
    result = 1 - result;
    for j = 1 : 4
        cateResults(j) = cateResults(j) + sum(result((j-1)*3+1:(j-1)*3+3));
    end
end
cateAccuracy = cateResults/30;

%% rating
realResults = zeros(1,4);
synResults = zeros(1,4);

for i = 1 : numPart
    curPartPath = [evalPath,'/',num2str(i),'/rateResults.mat'];
    load(curPartPath);
    idx = rate(1,:);
    [~,order] = sort(idx);
    rate = rate(:,order);
    
    for j = 1 : 4
        realResults(j) = realResults(j) + 1 - abs(rate(2, j+4) - rate(3,j+4));
        synResults(j) = synResults(j) + 1 - abs(rate(2, j) - rate(3,j));
    end
end

realAcc = realResults/10;
synAcc = synResults/10;

