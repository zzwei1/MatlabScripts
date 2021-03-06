function HUCstr = grid2HUC_daily( dataName,dataGrid,dataT,mask,HUCstr, strT)
%   fit data into a huc 
%   see Sample_grid2HUCall.m


if(length(mask)~=length(HUCstr))
    error('mask and HUCstr do not fit')
end

n=length(HUCstr);

%intersect by month
strT=str2num(datestr(strT,'yyyymmdd'));
[C,idata,istr]=intersect(dataT,strT);

%dataGrid(isnan(dataGrid))=0;

for i=1:n
    masktemp=mask{i};
    temp=zeros(length(strT),1)*nan;
    data=zeros(length(dataT),1)*nan;
    for j=1:length(dataT)
        ind=find(masktemp>0);
        g=dataGrid(:,:,j);g=g(ind);
        m=masktemp(ind);
        ind2=find(~isnan(g));
        g=g(ind2);m=m(ind2);
        data(j)=sum(g.*m)/sum(m);
    end
    temp(istr)=data(idata);
    eval(['HUCstr(i).',dataName, '=temp;']);
end

end

