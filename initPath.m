function initPath(varargin)
% to deal with directory setting in different computer
% generate a structure contains directory for given pcStr.
% pcStr == 'server' -> linux server
% pcStr == 'workstation' -> work station 

global kPath

addpath(genpath('.')) 

if isempty(varargin)
	pcStr='server';
else
	pcStr=varargin{1};
end

if strcmp(pcStr,'server')
	kPath.s='/';
    kPath.workDir='/mnt/sdb1/Kuai/';

	kPath.SMAP='/mnt/sdb1/Database/SMAP/';
	kPath.SMAP_L2='/mnt/sdb1/Database/SMAP/SPL2SMP.004/';
	kPath.SMAP_L3='/mnt/sdb1/Database/SMAP/SPL3SMP.004/';
    kPath.SMAP_VAL='/mnt/sdb1/Database/SMAP/SMAP_VAL/';

    kPath.DBSMAP_L3='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3_CONUS/';
    kPath.DBSMAP_L3_Global='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L3/';       
    kPath.DBSMAP_L4='/mnt/sdb1/rnnSMAP/Database_SMAPgrid/Daily_L4_CONUS/';
    
    kPath.OutSMAP_L3='/mnt/sdb1/rnnSMAP/output_SMAPgrid/';
    kPath.OutSMAP_L3_L3_Global='/mnt/sdb1/rnnSMAP/output_SMAPgrid_global/';       
    kPath.OutSMAP_L4='/mnt/sdb1/rnnSMAP/output_SMAPL4grid/';

    kPath.CRN='/mnt/sdb1/Database/CRN/';
    kPath.SCAN='/mnt/sdb1/Database/SCAN/';
    kPath.OutSCAN='/mnt/sdb1/rnnGAGE/outputSCAN/';
    kPath.DBSCAN='/mnt/sdb1/rnnGAGE/databaseSCAN/';
    
	kPath.GLDAS='/mnt/sdb1/Database/GLDAS/';
	kPath.GLDAS_NOAH='/mnt/sdb1/Database/GLDAS/GLDAS_NOAH025_3H.2.1/';
    kPath.GLDAS_NOAH_Mat='//mnt/sdb1/Database/GLDAS/GLDAS_Noah_Daily_Mat/';

	kPath.NLDAS='/mnt/sdb1/Database/NLDAS/';
	kPath.NLDAS_Daily='/mnt/sdb1/Database/NLDAS/NLDAS_Daily/';
	kPath.DBNLDAS='/mnt/sdb1/rnnSMAP/Database_NLDASgrid/';
	kPath.NLDAS_SMAP_Mat='/mnt/sdb1/Database/NLDAS/NLDAS_gridSMAP_CONUS_Daily/';
    
    kPath.maskSMAP_CONUS='/mnt/sdb1/Database/SMAP/maskSMAP_CONUS.mat';
    kPath.maskSMAPL4_CONUS='/mnt/sdb1/Database/SMAP/maskSMAP_CONUS_L4.mat';

	% add path of nctoolbox
	% addpath('/home/kxf227/install/nctoolbox-1.1.1/')
	% setup_nctoolbox

end

if strcmp(pcStr,'workstation')
	kPath.s='\';
    kPath.workDir='E:\Kuai\';
    
    kPath.SMAP='E:\Kuai\Data\SMAP\';
    kPath.SMAP_VAL='E:\Kuai\SMAP_VAL\';

    kPath.DBSMAP_L3='E:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\';
    kPath.DBSMAP_L3_CONUS='E:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\CONUS\';
    kPath.OutSMAP_L3='E:\Kuai\rnnSMAP\output_SMAPgrid\';
    
    kPath.SCAN='E:\Kuai\Data\SoilMoisture\SCAN\';
    kPath.OutSCAN='E:\Kuai\rnnGAGE\outputSCAN\';
    kPath.DBSCAN='E:\Kuai\rnnGAGE\databaseSCAN\';
    
	%kPath.SMAP_L2='Y:\SMAP\SPL3SMP.004\';
	%kPath.SMAP_L3='Y:\SMAP\SPL3SMP.004\';
	%kPath.GLDAS='Y:\GLDAS\data\GLDAS_V1\GLDAS_NOAH025SUBP_3H\';  
    kPath.NLDAS='Y:\NLDAS\';
    kPath.DBNLDAS='E:\Kuai\rnnSMAP\Database_NLDASgrid\';
    kPath.NLDAS_SCAN_Mat='E:\Kuai\Data\NLDAS\NLDAS_SCAN_Daily\';
    
    kPath.maskSMAP_CONUS='E:\Kuai\rnnSMAP\maskSMAP_CONUS.mat';
end

if strcmp(pcStr,'pc-kuai')
	kPath.s='/';
    
    kPath.SMAP_VAL='/mnt/sdb/Database/SMAP/SMAP_VAL/';    
    
    kPath.DBSMAP_L3='/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/';
    kPath.DBSMAP_L3_CONUS='/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/CONUS/';    
    kPath.OutSMAP_L3='/mnt/sdb/rnnSMAP/output_SMAPgrid/';
    
    kPath.SCAN='/mnt/sdb/Database/SCAN/';
    kPath.OutSCAN='/mnt/sdb/rnnGAGE/outputSCAN/';
    kPath.DBSCAN='/mnt/sdb/rnnGAGE/databaseSCAN/';
    
	kPath.DBNLDAS='/mnt/sdb/rnnSMAP/Database_NLDASgrid/';    
    kPath.maskSMAP_CONUS='/mnt/sdb/rnnSMAP/maskSMAP_CONUS.mat';

end


disp(['Initialized kPath on ',pcStr])

end
