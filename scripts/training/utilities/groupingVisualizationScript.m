%--------------------------------------------------------------------------
% This script visualize the grouping results
%--------------------------------------------------------------------------

for i = 1 : iteration
    strokeInfoPath = [cateInfoPath, '/strokeInfo_it', num2str(i)];
    load(strokeInfoPath);
    
    sketchesAff = cell2mat(strokeInfo(:,4));
    
    allSketches = unique(sketchesAff);

    groupingPath = [cateResultPath, '/grouping/it_', num2str(i)];
    if exist(groupingPath, 'dir')
        rmdir(groupingPath, 's');
    end
    mkdir(groupingPath);
    
    for j = 1 : length(allSketches)
        idx = sketchesAff == allSketches(j);
        segs = strokeInfo(idx,:);
        labels = (1:length(segs));
        segsList = cell(1,length(segs));
        
        for k= 1 : length(segs)
            segsList{k} = [segs(k,1) labels(k)];
        end
        
        h = showGrouping(segsList,labels, avgWidth, avgHeight);
        saveas(h, [groupingPath, '/', num2str(allSketches(j)), '.png']);
        close(h);
    end
end