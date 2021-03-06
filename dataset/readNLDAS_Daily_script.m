% read NLDAS hourly data, and save as matfile for each year.
% default to convert all fields. see the -1 line 27

global kPath
yLst=2000:2017;
%dataLst={'FORA','FORB','NOAH'};
dataLst={'VIC'};
parpool(50)
for yr=yLst
    sdn=datenumMulti(yr*10000+101,1);
    edn=datenumMulti(yr*10000+1231,1);
    %edn=sdn+99; 
    tLst=sdn:edn;
    for iData=1:length(dataLst)
        dataName=dataLst{iData};
        dataFolder=kPath.NLDAS;
        saveFolder=[kPath.NLDAS,'NLDAS_Daily',filesep,dataName,filesep,num2str(yr),filesep];
        mkdir(saveFolder)
        
        % init dataNLDAS
        [dataTemp,lat,lon,tnumTemp,field] = readNLDAS_Hourly(dataName,tLst(1),-1);
        ny=length(lat);
        nx=length(lon);
        dataNLDAS=zeros(ny,nx,length(sdn:edn),length(field))*nan;
        
        parfor iT=1:length(tLst)
            tic
            t=tLst(iT);
            % read NLDAS
            disp([dataName,' ',datestr(t)])
            dataTemp = readNLDAS_Hourly(dataName,t,-1,dataFolder);
            % average to daily
            dataDaily=nanmean(dataTemp,3);
            dataNLDAS(:,:,iT,:)=dataDaily;
            toc
        end
        
        % write output
        for k=1:length(field)
            data=dataNLDAS(:,:,:,k);
            tnum=tLst;
            fieldName=field{k};
            save([saveFolder,fieldName,'.mat'],'data','tnum','lat','lon','-v7.3')
        end
    end
end

poolobj=gcp('nocreate');
delete(poolobj);
