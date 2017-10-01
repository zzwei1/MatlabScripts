
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

%% HLR
dat = readGrid('F:\olddrive\DataBase\National\HLR_CONUS.tif');
saveFolderRt='CONUS';
%interval=1; offset=1;
% varLst=textread('H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\Variable\varLst.csv','%s');
% varLst2=textread('H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\Variable\varConstLst.csv','%s');
% varLst = [varLst; varLst2];
% rootName = 'H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\byGrid';
for i=1:20
    i
    tic
    dat.zoneSel = i; subsetName = ['hlr_',num2str(i)];
    %saveFolder = ['CONUS',num2str(i)];
    indSub=subsetSMAP_shape(saveFolderRt,dat,subsetName );
    toc
    subsetSplit_All(subsetName);

    
    subsetPlot(subsetName);hold on
    if ~isfield(dat,'col')
        % col means it is a raster grid
        plot(dat.X,dat.Y,'-k'); end
    hold off
    axis equal
    saveas(gcf,[kPath.DBSMAP_L3,'Subset',kPath.s,'fig',kPath.s,subsetName,'.fig']);
    close(gcf)
end

%% HUC2
% select nc from 18-1=17 HUC2 (nr realizations; contiguous or not)
dat = readGrid('F:\olddrive\DataBase\National\HUC2_CONUS.tif');
saveFolderRt='CONUS';
%interval=1; offset=1;
% rootName = 'H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\byGrid';
nt=18; nr = 50;ns=4; exclude=8; elem=1:nt;elem(elem==exclude)=[];
k=0;A=zeros([1,ns]);
% A may need to be loaded to extend experiments
while 1
    d = randsample(elem,ns); d= sort(d,'ascend');
    if ~any(ismember(d,A,'rows'))
        k = k + 1;
        A(k,:) = d;
        if k==nr, break; end
    end
end
save exp A
for i=1: nt-length(exclude) - (ns-1)
    d = elem(i:i+3);
    if ~any(ismember(d,A,'rows'))
        k = k + 1;
        A(k,:) = d;
        if k==nr, break; end
    end
end

parpool(6);
dat0=dat;
parfor i=1:size(A,1)
    i
    tic
    dat = dat0;
    dat.zoneSel = A(i,:); 
    ff=''; for j=dat.zoneSel,ff=[ff,sprintf('%02d',j)]; end
    subsetName = ['huc2_',ff];
    %saveFolder = ['CONUS',num2str(i)];
    indSub=subsetSMAP_shape(saveFolderRt,dat,subsetName );
    toc
    subsetSplit_All(subsetName);
    subsetPlot(subsetName);hold on
    if ~isfield(dat,'col')
        % col means it is a raster grid
        plot(dat.X,dat.Y,'-k'); end
    hold off
    axis equal
    saveas(gcf,[kPath.DBSMAP_L3,'Subset',kPath.s,'fig',kPath.s,subsetName,'.fig']);
    close(gcf)
end