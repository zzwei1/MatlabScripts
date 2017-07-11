
%% arguments
global kPath
outName='CONUSs4f1';
trainName='CONUSs4f1';
testName='CONUSs4f1';
epoch=500;

figFolder='H:\Kuai\rnnSMAP\paper\';
opt=2;
stat='rmse';
unitStr='[-]';

%% read Data
dirData=[kPath.DBSMAP_L3,trainName,kPath.s];
fileCrd=[dirData,'crd.csv'];
crd=csvread(fileCrd);
shapefile='H:\Kuai\map\USA.shp';
[outTrain,outTest,covMethod]=testRnnSMAP_readData(outName,trainName,testName,epoch);

statLSTM{1}=statCal(outTrain.yLSTM,outTrain.ySMAP);
statLSTM{2}=statCal(outTest.yLSTM,outTest.ySMAP);

statNLDAS{1}=statCal(outTrain.yGLDAS,outTrain.ySMAP);
statNLDAS{2}=statCal(outTest.yGLDAS,outTest.ySMAP);

%% LSTM map - rmse
[gridStatLSTM,xx,yy] = data2grid( statLSTM{opt}.rmse,crd(:,2),crd(:,1));
[lon,lat]=meshgrid(xx,yy);
data=gridStatLSTM;
titleStr='RMSE Between SMAP and LSTM Predictions';
colorRange=[0,0.1];
[h,cmap]=showMap(data,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
suffix = '.jpg';
fname=[figFolder,'fig_rmseMap_LSTM'];
fixFigure(gcf,[fname,suffix]);
saveas(gcf, fname);

%% NLDAS map - bias
[gridStatNLDAS,xx,yy] = data2grid( statNLDAS{opt}.bias,crd(:,2),crd(:,1));
[lon,lat]=meshgrid(xx,yy);
data=gridStatNLDAS;
colorRange=[-0.2,0.2];
titleStr='Bias Between SMAP and NLDAS Predictions';
[h,cmap]=showMap(data,yy,xx,'colorRange',colorRange,'shapefile',shapefile,'title',titleStr);
colormap(cmap)
suffix = '.jpg';
fname=[figFolder,'fig_biasMap_NLDAS'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
