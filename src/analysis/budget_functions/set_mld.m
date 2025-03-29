function mld = set_mld()
%混合層深度を求める
mld_range = 0.125; %混合層のとする密度差

addpath ..\..\..\base_data\data\
addpath ..\..\..\..\src\
load("base_setting.mat","slon","slat","time", "pres");
sallpod = loadData("base_data\data\sallpod.mat","sallpod");

LO=numel(slon); LA=numel(slat);rp=1:13; PR=numel(rp); TIM=numel(time);
spod10=squeeze(sallpod(:,:,1,:));
isd=sallpod(:,:,rp,:);  %%
isd1=zeros(LO,LA,PR,TIM);

for n=1:TIM
   for j=1:LA
        for i=1:LO
         
        DS=spod10(i,j,n)+mld_range;   
        
         k = 1;
                while  DS - isd(i,j,k,n)> 0 && k < PR
                      k = k+1;end

                if k == 1; isd1(i,j,k,n)=NaN; 
               
                else
                    %線形補間
                    isd1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(pres(k,1)-pres(k-1,1))...
                    /(isd(i,j,k,n)-isd(i,j,k-1,n))+pres(k-1);

                end      
         
    
         end
   end
end

[iso2,ind]=max(isd1,[],3,'omitnan');
mld.depth = squeeze(iso2);
mld.index = squeeze(ind);

saveData("analysis_data\mld.mat", "mld", mld)

end
