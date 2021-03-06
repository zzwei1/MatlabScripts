%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gribhelp                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gribhelp(option)
global rgversion ParamTable

switch lower(option)
   case 'mainhelp'
      disp('READ_GRIB Main help section')
      str={'READ_GRIB is a set of MATLAB functions to process weather',...
           'model output files, distributed in the WMO GRiB format.  This',...
           'format is a very compact, machine independent binary that',...
           'allows exchange of meteorological model products around',...
           'the modeling community.',...
           '',...
           'The general procedure is to inventory a GRiB file with',...
           'read_grib(gribname,''invent'') to identify which records are to',...
           'be extracted.  Then, use READ_GRIB to extract specific',...
           'records.  Alternatively, READ_GRIB can accept a list of',...
           'parameter names to extract, by using read_grib(gribname,list)',...
           'where list is a cell array containing parameter names.',...
           'For example, read_grib("grib_file",{''UFLX'',''VFLX'',''PRES''},...) ',...
           'will extract from the GRiB file "grib_file" the records ',...
           'that have parameter names UFLX, VFLX, and PRES. Be ',...
           'advised that more than one GRiB record can have the same ',...
           'parameter NAME, as the pressure denoted by the parameter ',...
           'name PRES can be provided at several atmospheric levels.',...
           '',...
           'Extraction by other GRiB information is not yet possible.',...
           '',...
           'Call READ_GRIB with the following "help" arguments for more',...
           'information:',...
           '''mainhelp'',''paramtableshort'',''paramtablelong'',''output_struct'''};
	   str=str';
     
      title1=['READ_GRIB V' rgversion ' General Help'];

   case 'paramtableshort'
      Set_Parameter_Table(ParamTable);
      disp('READ_GRIB Parameter Table section')
      str=[];
      k=-1;
      for i=1:85
         for j=1:3
	    k=k+1;         
            str=[str sprintf('Param %3d --> %6s  :  ',k,Get_Parameter(k,1))];
         end
       str=[str sprintf(' \n')];
      end
      str=[str sprintf('Param %3d = %6s   ',255,Get_Parameter(255,1))]; 
      title1=['READ_GRIB V' rgversion ' GRiB Parameter Table, Short  Version'];
   case 'paramtablelong'
      Set_Parameter_Table(ParamTable);
      disp('READ_GRIB Parameter Table section, Long Version')
      str=sprintf('           Parameter\n');
      str=[str sprintf('Number   Name  Units             Description\n')];
      str=[str sprintf('---------------------------------------------------------\n')];
      for k=0:255
         str=[str sprintf(' %3d   %6s | %-14s | %-s\n',...
	 k,Get_Parameter(k,1),Get_Parameter(k,3),Get_Parameter(k,2))];
      end
      title1=['READ_GRIB V' rgversion ' GRiB Parameter Table, Long Version'];
   case 'output_struct'
      
      str={'READ_GRIB returns the requested GRiB records in the',...
           'form of an array of structure.  This array contains one',...
	   'structure per GRiB record.',...
	   '',...
	   'Each structure has the following fields, with examples given',...
	   'to the right of the colons:',...
           '         sec1_1: ''GRIB''',...
           '        lengrib: 109524',...
           '        edition: 1',...
           '           file: ''gdas1.T00Z.SFLUXGrbF06''',...
           '         record: 1',...
           '    description: ''Zonal momentum flux''',...
           '      parameter: ''UFLX''',...
           '          units: ''N/m^2''',...
           '       gridtype: ''Gaussian Lat/Lon''',...
           '            pds: [1x1 struct]',...
           '            gds: [1x1 struct]',...
           '            bms: [1x1 struct]',...
           '            bds: [1x1 struct]',...
           '       fltarray: [72960x1 double]',...
	   '',...
	   'This particular grib_struct example contains the Zonal momentum',...
	   'flux from record # 1 of the GRiB file gdas1.T00Z.SFLUXGrbF06.',...
	   'The UFLX units are N/m^2, and the grid is Gaussian.  The actual',...
	   'data is contained in the field fltarray, in which there is ',...
	   'one value per gaussian grid piont.  See the OPNML/MATLAB routine',...
	   'GAUSS2LL to convert this gaussian data to lon/lat points.',...
	   '',...
	   'There is much more info in the pds,gds,bms,and bds structures, but',...
           'see the GRiB manual for more information on the contents of these',...
	   'sections.'};
	   str=str';
      title1=['READ_GRIB V' rgversion ' Output Structure Help'];
   otherwise
      disp('READ_GRIB must be called with a valid help string.')
      disp('Try: ''mainhelp'',''paramtableshort'',''paramtablelong'',''output_struct''') 
      return
end

if ~isempty(str)
%   BOB 6 Sep, 2002: 
   helpwin(str,title1);
%   msgbox(str,title1,'replace');
end
