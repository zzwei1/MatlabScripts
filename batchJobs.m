function batchJobs(res,prob,varargin)

%{
nGPU =3; nMultiple=4; jobHead='hlr'; epoch=300; hs=256; temporalTest=2;
% above are things to adjust. also consider 'varFile' below
% by default all test are done on CONUS.
% jobHead: the code finds directories in the rt directory that
starts with this string. All jobs that match will be put into a queue to be
run, multiplied by the number of files in varFile and varCFile (could be a
char string, or)
% jobN: constructed from jobHead, it distinguishes between job scripts
written from different times, because jobs might be too many to
run at once, and may needed to be done in different batches
% namePadd: if desired, this variable can padd the name to distinguish
between multiple runs of the same job.
% if rt is left empty, it will be decided by the hard-coded directories
below
% However, this rt does not concern the code inside the lua codes, which
now need to be changed manually.
/home/facadmin/torch/install/bin/th
%rt  = '/mnt/sdd/rnnSMAP/Database_SMAPgrid/Daily/';
rt = ''; % empty if using default settings on each machine
action = [1 2];
res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);

batchJobs(res,prob,[1 2]) % action contains 1: train; contains 2: test
%}
diary('batchJobsLog.log')

% Grabbing configurations from input
nGPU = res.nGPU; nConc = res.nConc; 
if ~isfield(res,'torchDir') || isempty(res.torchDir)
    if ~ispc
        % torchDir field does not exist and it's on linux. use what is
        % returned by "which th"
        [status,res.torchDir]=system('which th');
    else
        res.torchDir= '/home/kxf227/torch/install/lib';
    end
end
%res.torchDir
jobHead = prob.jobHead; hs = prob.hs; temporalTest = prob.temporalTest; varFile = prob.varFile;
epoch = prob.epoch; if isfield(prob,'varCFile'),varCFile = prob.varCFile; else, varCFile='varConstLst_Noah';  end
if isfield(prob,'namePadd'), namePadd = prob.namePadd; else, namePadd=''; end
if isfield(prob,'dirIndices'), dirIndices = prob.dirIndices; else, dirIndices=''; end
if isfield(prob,'jobN'), jobN = prob.jobN; else, jobN = prob.jobHead; end
testRun  = 1; % inside sub-function--> may get over-written by varargin{2} (4-th input)
% testRun == 1: just print out statement. ==0, and change for i=1:length(D)
% to parfor: will run jobs through parfor

% the following fields will be added to the command line if they are
% present in res or prob.
AddFieldsTrain = {'rootDB','rootOut','saveEpoch'};
AddFieldsTest  = {'rootDB','rootOut'};
R{1}=res; R{2}=prob;

[s,hostname] = system('hostname');
if isfield(res,'rt') && ~isempty(res.rt)
    rt = res.rt;
else
    if ispc
        rt ='H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily';
    elseif strcmp(strip(hostname),'ce-406chsh11')
        rt = '/mnt/sdc/rnnSMAP/Database_SMAPgrid/Daily/';
    elseif strcmp(strip(hostname),'ce406c-kuai')
        rt = '/mnt/sdb/rnnSMAP/Database_SMAPgrid/Daily/';
    end
end
action =[1 2]; % train and test
if length(varargin)>0
    action = varargin{1};
end
if length(varargin)>1
    testRun = varargin{2};
end

D = dir([rt,filesep,jobHead,'*']);
if ~isempty(dirIndices), D=D(dirIndices); end
disp(['Number of directories=',num2str(length(D))]);
hS = zeros(size(D))+hs;


if ~testRun
    myCluster = parcluster('local');
    dirJ = [cd,filesep,'MPT',filesep,jobHead]; if ~exist(dirJ),mkdir(dirJ); end
    myCluster.JobStorageLocation = dirJ;
    myCluster.NumWorkers = max(nConc,myCluster.NumWorkers);
    
    
    try
        parpool(myCluster,nConc);
    catch
        p = gcp('nocreate');
        delete(gcp('nocreate'))
        parpool(myCluster,nConc);
    end
else
    clc
end

if temporalTest==1
    trainTimeOpt = 1;
    testTimeOpt = 2;
else
    trainTimeOpt = 1;
    testTimeOpt = 1;
end
if iscell(varFile) % a list of parameter files)
    VFILE=varFile;
else
    VFILE{1}=varFile;
end

if iscell(varCFile) % a list of parameter files)
    VCFILE=varCFile;
else
    VCFILE{1}=varCFile;
end
nMultiple = nConc/nGPU;

% the following files are prepared in case we cannot run matlab on the
% target machine
fid = fopen(['allJobs_',jobN,'.sh'],'wt');
%queueHeadGPU(fid,res,jobN,'xstream');
k = 0;
for i=1:nGPU
    for j=1:nMultiple
        ff=['JOB',jobN,'_g',num2str(i-1),'_c',num2str(j)];
        CFILE{i,j} = [ff,'.sh'];
        %if exist(CFILE{i,j}), mode='at'; else, mode='wt'; end
        %CID(i,j)= fopen(CFILE{i,j},mode);
        fprintf(fid,'%s\n',['. ',CFILE{i,j},' > ',ff,'.log &']);
        k = k + 1;
        line = ['var[',num2str(k-1),']=$!']; fprintf(fid,'%s\n',line);
    end
end

for k=1:nGPU*nMultiple
    line = ['wait ${var[',num2str(k-1),']}'];
    fprintf(fid,'%s\n',line);
end
fprintf(fid,'unset var');
fclose(fid); CA=zeros([nGPU,1]); nk=0;nD=length(D);
%for m=1:length(VCFILE)
%for k=1:length(VFILE)
%for i=1:nD
siz = ([nD,length(VFILE),length(VCFILE)]);
nM=prod(siz);
nm = ceil(nM/nConc);
% a 1-nConc loop. each element contains nm. may skip some
% turning M into a 2D matrix of [nConc,nm]. each spmd run goes through nm
% nConc will be further decomposed to [nGPU,nMultiple]
cid = -1;
spmd
id = labindex;
%for id=1:nConc % for debugging or writting scripts for clusters, comment out two lines above and
    %uncomment this line
    for is = 1:nm % "is" is the index inside a concurrent process
        ii = (is-1)*nConc+id; % job id in the entire sequence
        if ii<=nM
            [i,k,m] = ind2sub(siz,ii);
            
            varFile = VFILE{k};
            varCFile = VCFILE{m};
            
            %    tic
            if D(i).isdir
                nk = ii;
                
                %nk=sub2ind([nD,length(VFILE),length(VCFILE)],i,k,m);
                %nk = i-1+(length(VFILE)-1)*length(D);
                %nk = nk+1; % job id in the sequence
                %ID = mod(nk,nGPU); wd = ['=',num2str(ID)]; CA(ID+1)=CA(ID+1)+1; % ID is GPU iD
                %j = mod(CA(ID+1)-1,nMultiple)+1; % j is concurrent job id
                [ID,j,kk]=ind2sub([nGPU,nMultiple,10000],nk); % 1000 is just to make it large enough
                
                if is==1
                    ff=['JOB',jobN,'_g',num2str(ID-1),'_c',num2str(j)];
                    jobScriptFile = [ff,'.sh'];
                    if exist(jobScriptFile,'file'), mode='at'; else, mode='wt'; end
                    cid= fopen(jobScriptFile,mode);
                    if isfield(res,'torchMod')
                        % on XSEDE, it is load a torch module
                        fprintf(cid,'%s\n',['module load ',res.torchMod]);
                    else
                        fprintf(cid,'%s\n',['export LD_LIBRARY_PATH=',res.torchDir]);
                    end
                    %fprintf(fid,'%s\n',['. ',CFILE{i,j},' > ',ff,'.log &']);
                end
                %ID=kk0(1); j=kk0(2); kk=kk0(3);
                % kk is the number of training instance on the job script
                wd = ['=',num2str(ID-1)];
                trainCMD = 'CUDA_VISIBLE_DEVICES=0 th trainLSTM_SMAP.lua -out XX_out -train CONUS -dr 0.5 -timeOpt 1 -hiddenSize 384 -var varLst_Noah -varC varConstLst_Noah -nEpoch 500';
                trainCMD = strrep(trainCMD, 'CONUS', D(i).name);
                trainCMD = strrep(trainCMD, '384', num2str(hS(i)));
                trainCMD = strrep(trainCMD, '=0', wd);
                trainCMD = strrep(trainCMD, '-timeOpt 1', ['-timeOpt ',num2str(trainTimeOpt)]);
                trainCMD = strrep(trainCMD, 'varLst_Noah', varFile);
                trainCMD = strrep(trainCMD, 'varConstLst_Noah', varCFile);
                trainCMD = strrep(trainCMD, '500', num2str(epoch));
                AddFields = AddFieldsTrain;
                for k=1:length(R)
                    obj = R{k}; % it will work either the field is on prob or res
                    % prob will overwrite the one in res if they conflict
                    for ii=1:length(AddFields)
                        f = AddFields{ii};
                        if isfield(obj,f)
                            trainCMD = [trainCMD, ' -',f,' ',obj.(f)];
                        end
                    end
                end
                
                %od = [D(i).name,namePadd,'_',varFile,'_',varCFile]; % output folder name. must be unique
                % for huc n4
                od = [D(i).name,namePadd,'_',varFile,'_',varCFile]; % output folder name. must be unique
				if strcmp(jobHead,'huc2_')
                	od=[D(i).name,'_hS256_VF',varFile];
				end
                                
                trainCMD = strrep(trainCMD, 'XX_out', od);
                if any(action==1)
                    runCmdInScript(trainCMD,jobN,i,1,testRun,cid,res.torchDir);
                end
                
                %ID = mod(i-1,nGPU);
                %trainCMD = 'CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_hS384dr04 -epoch 500  -rootOut aaa -rootDB bbb -test CONUSv2f1 -timeOpt 2';
                trainCMD = 'CUDA_VISIBLE_DEVICES=0 th testLSTM_SMAP.lua -gpu 1 -out fullCONUS_hS384dr04 -epoch 500 -test CONUSv2f1 -timeOpt 2';
                trainCMD = strrep(trainCMD, '=0', ['=',num2str(ID-1)]);
                trainCMD = strrep(trainCMD, 'fullCONUS_hS384dr04', [od]);
                %trainCMD = strrep(trainCMD, 'CONUSv2f1', D(i).name);
                trainCMD = strrep(trainCMD, '500', num2str(epoch));
                strTime  = ['-timeOpt ',num2str(testTimeOpt)];
                trainCMD = strrep(trainCMD, '-timeOpt 2', strTime);
                AddFields = AddFieldsTest;
                for k=1:length(R)
                    obj = R{k}; % it will work either the field is on prob or res
                    % prob will overwrite the one in res if they conflict
                    for ii=1:length(AddFields)
                        f = AddFields{ii};
                        if isfield(obj,f)
                            if isnumeric(obj.(f)), obj.(f)=num2str(obj.(f)); end
                            trainCMD = [trainCMD, ' -',f,' ',obj.(f)];
                        end
                    end
                end
                
                trainCMD2 = strrep(trainCMD, strTime, ['-timeOpt ',num2str(3)]);
                
                if any(action==2)
                    runCmdInScript(trainCMD,jobN,nk,2,testRun,cid,res.torchDir);
                    %runCmdInScript(trainCMD2,jobHead,nk,2,testRun,cid);
                end
            end
            if is==nm && cid>0, fclose(cid); cid=-1; end
        else
            % exceeds bound
            if cid>0, fclose(cid); end
        end
    end
end
4;
% for i=1:numel(CID)
%     fclose(CID(i));
% end

function runCmdInScript(cmd,jobHead,i,act,testRun,cid,torchDir)
%testRun = 0;
% two files: a script file is for each individual job, to be used by Matlab
% parfor
% a global file is to generate job a per-GPU script to be run manually
% this is only generated on pc.
verb = 1;
sD = [cd,filesep,'scripts',filesep];
if ~exist(sD)
    mkdir(sD)
end
sF = [jobHead,'_',num2str(i),'_a',num2str(act),'.sh'];
file = [sD,sF];

% Why do this?
% This file is only needed when running in Linux and launching jobs
% directly from Matlab using a 'system' call.
% to set some environmental variables and avoid conflict in java
% between Matlab and Scripts
fid = fopen(file,'wt');
fprintf(fid,'%s\n','. ~/.bashrc');
[status,cmdout] =system('which th');
if isempty(cmdout)
    error('no torch is found?')
else
    strrep(cmdout,'/bin/th','/install/lib')
end
%fprintf(fid,'%s\n','export LD_LIBRARY_PATH=/home/kxf227/torch/install/lib');
fprintf(fid,'%s\n',['export LD_LIBRARY_PATH=',torchDir]);
% Above is what is causing problems with a simple Matlab launch
fprintf(fid,'%s\r\n',cmd);
fclose(fid);


if verb>2
    suffix = '';
else
    suffix = ' >/dev/null'; % standard device for discarding screen output
    % lua already has output logs in each directory
end
trainCMD = ['. ',file,suffix];
if ispc || testRun
%     if verb>1
%         disp('*******************************************')
%         disp('runCmdInScript:: cmd to be submitted to OS:')
%     end
    fprintf(cid,'%s\n',cmd);
    disp(['runCmdInScript Written::', cmd]);
    %if verb>1 type(file); end
else
    if verb>0,
        fprintf(cid,'%s\n',['runCmdInScript Submitted::', cmd]);
        disp(['runCmdInScript Submitted::', cmd]);
    end;tic;
    system(trainCMD);
    t1=toc;
    if verb>0, disp(['Elapsed time = ',num2str(t1),' for job: ',cmd]); end
    %delete(file);
end

function caseScripts
% these codes are not used inside batchJobs.m.
% they are scripts to be used outside
% I save them here so we don't lose these notes
c=1;
switch c
    case 1
        % some scripts for used cases:
        nGPU =3; nMultiple=4; jobHead='huc2'; epoch=300; hs=256; temporalTest=2;
        % above are things to adjust. also consider 'varFile' below
        % by default all test are done on CONUS.
        %rt  = '/mnt/sdd/rnnSMAP/Database_SMAPgrid/Daily/';
        rt = ''; % empty if using default settings on each machine
        action = [1 2];
        res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
        prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);
        
        batchJobs(res,prob,action) % action contains 1: train; contains 2: test
    case 2
        % run through parfor
        nGPU =3; nMultiple=4; jobHead='hucv2n3'; epoch=300; hs=256; temporalTest=2;
        rt = ''; action = [1 2]; % empty if using default settings on each machine
        res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
        prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);
        
        batchJobs(res,prob,action,0) % action contains 1: train; contains 2: test
    case 3
        % an example of modifying parameter file
        p = [kPath.DBSMAP_L3,filesep,'Variable']; action = [1 2];
        v0 = importdata([p,'\varLst_Noah.csv']);
        vc0 = importdata([p,'\varConstLst_Noah.csv']);
        vn0 = importdata([p,'\varLst_NoModel.csv']);
        loc = ismember(v0,vn0); % if loc==1, it means this variable is not in vn
        nGPU =1; nMultiple=3; jobHead='CONUSv4f1'; epoch=300; hs=256; temporalTest=2;
        % jobHead: for both output and training set naming.
        toDropC = {'IrriSq','flag_Capa','flag_vegetation'};
        % Backward
        res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
        prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);
        for i=1:length(toDropC) % removing one variable at a time.
            k = ismember(vc0,toDropC{i}); vc=vc0; vc(k)=[];
            filename = ['varConstLst',num2str(i),'.csv'];
            file = [p,filesep,filename]; writetable(cell2table(vc),file);
            prob.varCFile{i} = filename;
        end
        batchJobs(res,prob,action,1)
    case 4
        % Kuai: forward all hucv2nx model to their local / CONUSv2f1
        nGPU =2; nMultiple=2; jobHead='hucv2n3'; epoch=300; hs=256; temporalTest=1;
        rt = ''; action = [2]; % empty if using default settings on each machine
        res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt);
        prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,'hs',hs,'temporalTest',temporalTest);
        prob.rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/',jobHead];
        prob.rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/',jobHead];
        % on either prob or res these AddFields will work
        batchJobs(res,prob,action,0) % action contains 1: train; contains 2: test
    case 5
        % XSEDE jobs
        nGPU =8; nMultiple=4; jobHead='hucv2n4'; epoch=300; hs=256; temporalTest=1;
        rt = ''; action = [1 2]; % empty if using default settings on each machine
        jobID = 1;
        res = struct('nGPU',nGPU,'nConc',nMultiple*nGPU,'rt',rt,...
            'saveEpoch','50','torchMod','torch','rootDB',['$WORK/rnnSMAP/Database_SMAPgrid/',jobHead],...
            'rootOut',['$WORK/rnnSMAP/Output_SMAPgrid/',jobHead],'t','47:00:00','memMB','2000');
        % 2000 means each job requires 2 GB. This number will be multiplied
        % by the nConc/nGPU, which is what is needed on each CPU
        prob = struct('jobHead',jobHead,'varFile','varLst_Noah','epoch',epoch,...
            'hs',hs,'temporalTest',temporalTest,'jobN',[jobHead,'_j',num2str(jobID)],...
            'namePadd',''); % namePadd is to distinguish between multiple runs of the same job
        rt = '/cstor/xsede/users/xs-cxs1024/rnnSMAP/';
        res.rootOut=[rt,jobHead];
        res.rootDB=[rt,'/Output_SMAPgrid/',jobHead];
        res.rt = 'E:\Kuai\rnnSMAP_inputs\hucv2n4'; % this is for local generation of scripts only
        % on either prob or res these AddFields will work
        
        batchJobs(res,prob,action,0) % action contains 1: train; contains 2: test
        % generate the scripts. Upload it to XSEDE to run
end
