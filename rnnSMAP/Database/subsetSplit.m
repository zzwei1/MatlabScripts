function subsetSplit(subsetName,varargin)
% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.
% subset will be wrote as an individual database instead of a index file.
% And the inds in subset file is replace by -1

global kPath

pnames={'rootDB','varLst','varConstLst'};
dflts={kPath.DBSMAP_L3,'varLst','varConstLst'};
[rootDB,varLstName,varConstLstName]=internal.stats.parseArgs(pnames, dflts, varargin{:});


%% read variable list
if iscell(varLstName)
    varLst=varLstName;
elseif ischar(varLstName)
    varFile=[rootDB,'Variable',filesep,varLstName,'.csv'];
    varLst=textread(varFile,'%s');
end

if iscell(varConstLstName)
    varConstLst=varConstLstName;
elseif ischar(varConstLstName)
    varConstFile=[rootDB,'Variable',filesep,varConstLstName,'.csv'];
    varConstLst=textread(varConstFile,'%s');
end

%% read subset index
subsetFile=[rootDB,'Subset',filesep,subsetName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
C = textscan(fid,'%f');
indSub=C{1};
fclose(fid);

if indSub==-1    
    rootFolder=[rootDB,'CONUS',filesep];
    saveFolder=[rootDB,subsetName,filesep];
    inCrd=csvread([rootDB,'CONUS',filesep,'crd.csv']);
    outCrd=csvread([rootDB,subsetName,filesep,'crd.csv']);
    [outInd,inInd] = intersectCrd(nDigit(outCrd,3),nDigit(inCrd,3));
    if length(inInd)~=size(outCrd,1)
        error('check here')
    end
    indSub=inInd;    
else
    %% write crd and time
    rootFolder=[rootDB,rootName,filesep];
    saveFolder=[rootDB,subsetName,filesep];
    if ~isdir(saveFolder)
        mkdir(saveFolder)
    end
    
    crdFileRoot=[rootFolder,'crd.csv'];
    crd=csvread(crdFileRoot);
    crdSub=crd(indSub,:);
    crdFile=[saveFolder,'crd.csv'];
    dlmwrite(crdFile,crdSub,'precision',12);
    
    timeFile=[saveFolder,'time.csv'];
    copyfile([rootFolder,'time.csv'],timeFile);
end

%% time series variable
parfor k=1:length(varLst)
    disp([subsetName,' ',varLst{k}])
    tic
    subsetSplit_var(varLst{k},rootFolder,saveFolder,indSub)
    toc
end

%% constant variable
for k=1:length(varConstLst)
    disp([subsetName,' ',varConstLst{k}])
    tic
    subsetSplit_var(['const_',varConstLst{k}],rootFolder,saveFolder,indSub)
    toc
end

%% SMAP
%{
disp([subsetName,' SMAP'])
tic
subsetSplit('SMAP',subsetName)
toc
%}


%% replace the subset file
dlmwrite(subsetFile,subsetName,'');
dlmwrite(subsetFile, -1,'-append');

end

function subsetSplit_var(varName,rootFolder,saveFolder,indSub)

% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.

% write a subset database for given subset index and variable name

%% pick data by indSub
dataFileRoot=[rootFolder,varName,'.csv'];
data=csvread(dataFileRoot);
dataSub=data(indSub,:);

%% save data
saveFile=[saveFolder,varName,'.csv'];
statFile=[saveFolder,varName,'_stat.csv'];
dlmwrite(saveFile, dataSub,'precision',8);
copyfile([rootFolder,varName,'_stat.csv'],statFile);

end



