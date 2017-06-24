function [ grid,xx,yy,t ] = csv2grid_SMAP(dirData,varName)
% convert csv which torch can learn from to grid
% read directory are hard coded as kPath.DBSMAP_L3 
% mask are hard coded to kPath.maskSMAP_CONUS 

% dirData='H:\Kuai\rnnSMAP\Database\Daily\CONUS\';
% varName='SMAP';
% maskMat - contains maskMat.mask, maskMat.maskInd. Example: '\SMAP\maskSMAP_CONUS.mat'

fileData=[dirData,varName,'.csv'];
fileCrd=[dirData,'crd.csv'];
fileDate=[dirData,'time.csv'];

data=csvread(fileData);
crd=csvread(fileCrd);
t=csvread(fileDate);
lat=crd(:,1);
lon=crd(:,2);

if ~startsWith(varName,'const_')
    [grid,xx,yy] = data2grid3d(data,lon,lat);
else
    [grid,xx,yy] = data2grid(data,lon,lat);
    t=1;
end



