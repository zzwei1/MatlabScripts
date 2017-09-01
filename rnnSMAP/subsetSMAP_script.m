
%  a script summarized all steps to create existing subsets

%% interval - write Database
vecV=[2,2,4,4,4,4];
vecF=[1,2,1,2,3,4];
for k=1:length(vecV)
    interval=vecV(k);
    offset=vecF(k);
    subsetSMAP_interval(interval,offset);
    subsetSplit_All(['CONUSv',num2str(interval),'f',num2str(offset)]);
end

%% HUC - write indFile
interval=2;
offset=1;
shapeAll=shaperead('H:\Kuai\map\HUC\HUC2_CONUS.shp');
for k=1:length(shapeAll)
    shape=shapeAll(k);
    subsetName=['huc',shape.charName,'v',num2str(interval),'f',num2str(offset)];
    rootName=['CONUSv',num2str(interval),'f',num2str(offset)];
    indSub=subsetSMAP_shape(rootName,shape,subsetName);
    
    % save a figure
    subsetPlot(subsetName);hold on
    plot(shape.X,shape.Y,'-k');hold off
    axis equal
    saveas(gcf,[kPath.DBSMAP_L3,'Subset',kPath.s,'fig',kPath.s,subsetName,'.fig']);
    close(gcf)
end