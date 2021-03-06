

figFolder='H:\Kuai\rnnSMAP\paper\';
fname=[figFolder,'\','boxplot_All_MOS'];
suffix = '.eps';
global fsize
fsize=16

%% load data
% temporal
global kPath
outName='CONUSv4f1_MOS';
trainName='CONUSv4f1';
testNameT='CONUSv4f1';
modelName='MOS';
epoch=500;

[outTrainT,outT,covT]=testRnnSMAP_readData(outName,trainName,testNameT,epoch,...
    'readData',0,'model',modelName);

statTtrain_LSTM=statCal(outTrainT.yLSTM,outTrainT.ySMAP);
statT_LSTM=statCal(outT.yLSTM,outT.ySMAP);
statTtrain_NLDAS=statCal(outTrainT.yGLDAS,outTrainT.ySMAP);
statT_NLDAS=statCal(outT.yGLDAS,outT.ySMAP);
statTtrain_LR=statCal(outTrainT.yLR,outTrainT.ySMAP);
statT_LR=statCal(outT.yLR,outT.ySMAP);
statTtrain_NN=statCal(outTrainT.yNN,outTrainT.ySMAP);
statT_NN=statCal(outT.yNN,outT.ySMAP);
statTtrain_LRpbp=statCal(outTrainT.yLRpbp,outTrainT.ySMAP);
statT_LRpbp=statCal(outT.yLRpbp,outT.ySMAP);
statTtrain_NNpbp=statCal(outTrainT.yNNpbp,outTrainT.ySMAP);
statT_NNpbp=statCal(outT.yNNpbp,outT.ySMAP);

% ARMA 
matARMA=load('H:\Kuai\rnnSMAP\ARMA\q0N\yARMApbp_CONUSv4f1.mat')
statTtrain_ARMA=statCal(matARMA.yARMA(1:366,:),outTrainT.ySMAP);
statT_ARMA=statCal(matARMA.yARMA(367:732,:),outT.ySMAP);

%% spatial
outName='CONUSv4f1_MOS';
trainName='CONUSv4f1';
testNameS='CONUSv4f2';
modelName='MOS';
epoch=500;

[outTrainS,outS,covS]=testRnnSMAP_readData(outName,trainName,testNameS,epoch,...
    'timeOpt',3,'readData',0,'model',modelName);
statSel=statCal(outS.yLSTM,outS.ySMAP);
%ind=find(statSel.rmse<0.1);
ind=1:length(statSel.rmse);

statStrain_LSTM=statCal(outTrainS.yLSTM,outTrainS.ySMAP);
statS_LSTM=statCal(outS.yLSTM,outS.ySMAP);
statStrain_NLDAS=statCal(outTrainS.yGLDAS,outTrainS.ySMAP);
statS_NLDAS=statCal(outS.yGLDAS,outS.ySMAP);
statStrain_LR=statCal(outTrainS.yLR,outTrainS.ySMAP);
statS_LR=statCal(outS.yLR,outS.ySMAP);
statStrain_NN=statCal(outTrainS.yNN,outTrainS.ySMAP);
statS_NN=statCal(outS.yNN,outS.ySMAP);


%% plot
figure('Position',[1,1,1000,1200])
statLst={'rmse','bias','rsq'};
subLst={'(a)','(b)','(c)','(d)','(e)','(f)'};
for k=1:length(statLst)
    stat=statLst{k};
    switch stat
        case 'rmse'
            yRangeT=[0,0.1];
            yRangeS=[0,0.1];
            yLabelStr='RMSE';
            yTickLst=0:0.02:0.1;
        case 'bias'
            yRangeT=[-0.05,0.05];
            yRangeS=[-0.05,0.05];
            yLabelStr='Bias';
            yTickLst=-0.05:0.02:0.05;
        case 'rsq'
            yRangeT=[0.3,1];
            yRangeS=[0.3,1];
            yLabelStr='R';
            yTickLst=0.4:0.2:1;

    end
    
    %% plot temporal
    nTrain=length(statTtrain_LSTM.(stat));
    nT=length(statT_LSTM.(stat));
    dataLst=[statTtrain_LSTM.(stat);statT_LSTM.(stat);...
        statTtrain_NN.(stat);statT_NN.(stat);...
        statTtrain_ARMA.(stat);statT_ARMA.(stat);...
        statTtrain_LR.(stat);statT_LR.(stat);...
        statTtrain_NNpbp.(stat);statT_NNpbp.(stat);...
        statTtrain_LRpbp.(stat);statT_LRpbp.(stat);...
        statTtrain_NLDAS.(stat);statT_NLDAS.(stat);];
    
    labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nT,1);];
    labelLst2=[repmat({'LSTM'},nTrain+nT,1);...
        repmat({'NN'},nTrain+nT,1);...
        repmat({'AR'},nTrain+nT,1);...
        repmat({'LR'},nTrain+nT,1);...
        repmat({'NNp'},nTrain+nT,1);...
        repmat({'LRp'},nTrain+nT,1);...
        repmat({'Noah'},nTrain+nT,1);];
    
    subplot(3,2,(k-1)*2+1)
    bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
        'factorgap',9,'factorseparator',1,'color','rk','Symbol','','Widths',0.75);
    ylabel(yLabelStr);
    xlabel(subLst{(k-1)*2+1})
    ylim(yRangeT)
    xLimit=get(gca,'xlim');
    nBin=length(unique(labelLst2));
    xTick=linspace(xLimit(1),xLimit(2),2*nBin+1);
    set(gca,'xtick',xTick(2:2:end),'ytick',yTickLst)
    set(gca,'xticklabel',{'LSTM','NN','ARp','LR','NNp','LRp','Noah'})
    set(bh,'LineWidth',2)
    box_vars = findall(gca,'Tag','Box');
    %     if strcmp(stat,'rsq')
    %         hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northeast');
    %     else
    %         hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northwest');
    %     end
    if k==1
        hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northwest');
    end
    if strcmp(stat,'bias')
        hline=refline([0,0]);
        set(hline,'color',[0.2 0.2 0.2],'LineWidth',1.5,'LineStyle','-.')
    end
    if strcmp(stat,'rmse')
        title(['Temporal Generalization Test'])
    end
    set(gca,'Position',[0.1,0.1+(3-k)*0.3,0.45,0.225])
    
    %% plot spatial
    nTrain=length(statStrain_LSTM.(stat));
    nS=length(statS_LSTM.(stat));
    dataLst=[statStrain_LSTM.(stat);statS_LSTM.(stat);...
        statStrain_NN.(stat);statS_NN.(stat);...
        statStrain_LR.(stat);statS_LR.(stat);...
        statStrain_NLDAS.(stat);statS_NLDAS.(stat);];
    
    labelLst1=[repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);...
        repmat({'Train'},nTrain,1);repmat({'Test'},nS,1);];
    labelLst2=[repmat({'LSTM'},nTrain+nS,1);...
        repmat({'NN'},nTrain+nS,1);...
        repmat({'LR'},nTrain+nS,1);...
        repmat({'Noah'},nTrain+nS,1);];
    
    subplot(3,2,(k-1)*2+2)
    bh=boxplot(dataLst, {labelLst2,labelLst1},'colorgroup',labelLst1,...
        'factorgap',9,'factorseparator',1,'color','rk','Symbol','','Widths',0.75);
    %ylabel(yLabelStr);
    xlabel(subLst{(k-1)*2+2})
    ylim(yRangeS)
    set(bh,'LineWidth',2)
    xLimit=get(gca,'xlim');
    nBin=length(unique(labelLst2));
    xTick=linspace(xLimit(1),xLimit(2),2*nBin+1);
    set(gca,'xtick',xTick(2:2:end),'ytick',yTickLst)
    set(gca,'xticklabel',{'LSTM','NN','LR','Noah'});
    box_vars = findall(gca,'Tag','Box');
%     if strcmp(stat,'rsq')
%         hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northeast');
%     else
%         hLegend = legend(box_vars([2,1]), {'Train','Test'},'location','northwest');
%     end
    if strcmp(stat,'bias')
        hline=refline([0,0]);
        set(hline,'color',[0.2 0.2 0.2],'LineWidth',1.5,'LineStyle','-.')
    end
    if strcmp(stat,'rmse')
        title(['Regular Spatial Generalization Test'])
    end
    set(gca,'Position',[0.65,0.1+(3-k)*0.3,0.275,0.225])
end

fixFigure([],[fname,suffix]);
saveas(gcf, [fname]);



