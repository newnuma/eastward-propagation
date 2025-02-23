
function [temp,depth] = isopycnal()

%等密度面解析
isd=sallpod;
isot=salltemp;
% isosal=sallsal;

isd1=zeros(141,91,25,276);
isot1=zeros(141,91,25,276);
% isosal1=zeros(141,91,25,276);
% 
DS=24.5; %%参照密度

for n=1:276
    for i=1:141
        for j=1:91
            for k=2:24
                if isd(i,j,k+1,n)<=DS
                   isd(i,j,k,n)=NaN;
                   isot(i,j,k,n)=NaN;
%                    isosal(i,j,k,n)=NaN;
                end
                if isd(i,j,k-1,n)>=DS
                    isd(i,j,k,n)=NaN;
                    isot(i,j,k,n)=NaN;
%                     isosal(i,j,k,n)=NaN;
                end
                %線形補間
                isd1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(pres(k,1)-pres(k-1,1))/(isd(i,j,k,n)-isd(i,j,k-1,n))+pres(k-1);
               isot1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(isot(i,j,k,n)-isot(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+isot(i,j,k-1,n);
%                 isosal1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(isosal(i,j,k,n)-isosal(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+isosal(i,j,k-1,n);
            end
            
         end
    end
end

for n=1:276
    for i=1:141
        for j=1:91
            for k=1:25
               if isd1(i,j,k,n)==0
                   isd1(i,j,k,n)=NaN;
                   isot1(i,j,k,n)=NaN;
%                    isosal1(i,j,k,n)=NaN;
               end
            end
        end
    end
end

[isd2,ind]=max(isd1,[],3,'omitnan');
iso26=squeeze(isd2); %%等密度面深さ

isoT2=max(isot1,[],3,'omitnan');
isoT26=squeeze(isoT2); %%等密度面上水温

[isoT26a,isoT26mc,isoT26y,isoT26ay,isoT26ad,isoT26ady] = anomaly_fx_td(isoT26);
[iso26a,iso26mc,iso26y,iso26ay,iso26ad,iso26ady] = anomaly_fx_td(iso26);
% isosal2=max(isosal1,[],3,'omitnan');
% isosal265=squeeze(isosal2); %%等密度面上塩分

clear isd isd1 isd2 isot isot1 isoT2 isosal isosal1 isosal2


%月ごとに、NaN（＝密度面が存在しない）が含まれている年の数をカウント
d1=permute(iso255,[3 1 2]); %%    
d2=reshape(d1,[276 12831]);     
d3=array2timetable(d2,'RowTimes',time);   
mm1=groupsummary(d3,'Time','monthofyear','nummissing');   %NaN要素をカウント
mm2=table2array(mm1(:,3:end));        
mm3=reshape(mm2,[12 141 91]);        
N26mc=permute(mm3,[2 3 1]); %%月毎NaNの数              
N26mc1=repmat(N26mc,[1 1 20]); %%データと同じサイズ

clear d1 d2 d3 mm1 mm2 mm3 
% 
