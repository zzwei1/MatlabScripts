function postRnnSMAP_map(outName,dataName,varargin)
% First test for trained rnn model.
% plot nash/rmse map for given testset and click map to plot timeseries
% comparison between GLDAS, SMAP and RNN prediction.

% example:
%{
outName='CONUSv2f1_Noah';
dataName='CONUSv2f1';
postRnnSMAP_map(outName,dataName)
%}

global kPath

pnames={'rootOut','rootDB','mapTime','tsTime','epoch','stat','colorRange','drBatch','stdLst','itemLst'};
dflts={kPath.OutSMAP_L3,kPath.DBSMAP_L3,2,2,0,'rmse',[0,0.05],0,1,{'Model','LSTM','SMAP'}};
[rootOut,rootDB,mapTime,tsTime,epoch,stat,colorRange,drBatch,stdLst,itemLst]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

%% predefine
fileCrd=[rootDB,dataName,filesep,'crd.csv'];
crd=csvread(fileCrd);
fileDate=[rootDB,dataName,filesep,'time.csv'];
tnum=csvread(fileDate);

opt=readRnnOpt(outName,rootOut);
if epoch==0
    epoch=opt.nEpoch;
end


%% read Map data and calculate stat
outMap=postRnnSMAP_load(outName,dataName,mapTime,'epoch',epoch,...
    'rootOut',rootOut,'rootDB',rootDB,'drBatch',drBatch);
if drBatch~=0
    statLSTM=statCal(outMap.yLSTM,outMap.ySMAP);
    if strcmp(stat,'std')
        statB=statBatch(outMap.yLSTM_batch);
        statLSTM.std=mean(statB.std,1)';
    end
else
    statLSTM=statCal(outMap.yLSTM,outMap.ySMAP);
end

[gridStatLSTM,xx,yy] = data2grid(statLSTM.(stat),crd(:,2),crd(:,1));
[gridIndex,xx,yy] = data2grid(1:length(statLSTM.(stat)),crd(:,2),crd(:,1));
% index cell grid as title
tsTitleGrid=cell(size(gridIndex));
for j=1:length(yy)
    for i=1:length(xx)
        tsTitleGrid{j,i}=['Index ',num2str(gridIndex(j,i))];
    end
end

%% read timeseries data and transfer to grid
outTS=cell([length(tsTime),1]);
for iT=1:length(tsTime)
    if tsTime(iT)==mapTime
        outTS{iT}=outMap;
    else
        outTS{iT}=postRnnSMAP_load(outName,dataName,tsTime(iT),'epoch',epoch,...
            'rootOut',rootOut,'rootDB',rootDB,'drBatch',drBatch);
    end
end
switch tsTime
    case 1
        tnumTS=tnum(1:366);
    case 2
        tnumTS=tnum(367:732);
    case 0
        tnumTS=tnum;
end

%% add plot items
% A reference table. hard coded. Add more if needed. will be plotted in order.
itemRefLst={'SMAP','Model','LSTM'};
fieldLst={'ySMAP','yGLDAS','yLSTM'};
symLst={'or','-k','-b'};

tsStr=[];
for k=1:length(itemLst)
    ind=find(strcmp(itemRefLst,itemLst{k}));
    tsData=[];
    for iT=1:length(tsTime)
        tsData=[tsData;outTS{iT}.(fieldLst{ind})];
    end
    [gridTemp,xx,yy] = data2grid3d(tsData',crd(:,2),crd(:,1));
    tsStr(k).grid=gridTemp;
    tsStr(k).t=tnumTS;
    tsStr(k).symb=symLst{ind};
    tsStr(k).legendStr=itemLst{k};
end

%% add std from batch
tsStrFill=[];
if ~isempty(stdLst) && drBatch~=0
    tsDataBatch=[];
    for iT=1:length(tsTime)
        tsDataBatch=[tsDataBatch;outTS{iT}.yLSTM_batch];
    end
    tsStatBatch=statBatch(tsDataBatch);
    
    nc=length(stdLst);
    colorLst=[linspace(0.1,0.3,nc)',linspace(0.9,0.7,nc)',ones(nc,1)];
    
    for k=stdLst
        temp1=tsStatBatch.mean+tsStatBatch.std*k;
        temp2=tsStatBatch.mean-tsStatBatch.std*k;
        [gridTemp1,xx,yy] = data2grid3d(temp1',crd(:,2),crd(:,1));
        [gridTemp2,xx,yy] = data2grid3d(temp2',crd(:,2),crd(:,1));
        tsStrFill(k).grid1=gridTemp1;
        tsStrFill(k).grid2=gridTemp2;
        tsStrFill(k).t=tnumTS;
        tsStrFill(k).color=colorLst(k,:);
        tsStrFill(k).legendStr=['std*',num2str(k)];
    end
end

showMap( gridStatLSTM,yy,xx,'colorRange',colorRange,...
    'tsStr',tsStr,'tsStrFill',tsStrFill,'tsTitleGrid',tsTitleGrid)
end

