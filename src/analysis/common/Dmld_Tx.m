%混合層深度での水温偏差の等密度面上偏差成分Tx

blon=90:113; blat=71:75; rp=1:13;
LO=numel(blon); LA=numel(blat); PR=numel(rp); TIM=240;
%numel(time);

spod10=squeeze(sallpod(:,:,1,:)); %%
isd=sallpod(:,:,rp,:);
isot=salltemp(:,:,rp,:);  %%
isosal=sallsal(:,:,rp,:); %%

Dmld_isoTa=zeros(141,91,TIM);
Dmld_isoSa=zeros(141,91,TIM);

for n=1:TIM
   for j=blat
        for i=blon
         
        DS=spod10(i,j,n)+0.125;   %参照密度 

        isd1=NaN(1,1,PR,240);
        isot1=NaN(1,1,PR,240);
        isosal1=NaN(1,1,PR,240);

        if mod(n,12)==0
        m=12;
        else
        m=mod(n,12);
        end
        
     for t=m:12:240
                
               k=1;
                while  DS - isd(i,j,k,t)> 0 && k < PR
                      k = k+1;end

%                  if k == P; isd(i,j,k,t)=NaN; isot(i,j,k,t)=NaN;
                 if k == 1; isot1(1,1,k,t)=NaN;
                 else
                isot1(1,1,k,t)=(DS-isd(i,j,k-1,t))*(isot(i,j,k,t)...
                   -isot(i,j,k-1,t))/(isd(i,j,k,t)-isd(i,j,k-1,t))+isot(i,j,k-1,t); 
                 end

              
     end
     
                isoT2=max(isot1,[],3,'omitnan');
                isoT=squeeze(isoT2);
                isosal2=max(isosal1,[],3,'omitnan');
                isoS=squeeze(isosal2);
                
                isoT1=array2timetable(isoT,'RowTimes',time);   %timetableに変換
                mm1=groupsummary(isoT1,'Time','monthofyear','mean');   %月別の気候値、tableカテゴリカル
                mm2=table2array(mm1(:,3:end));        %行列に変換、カテゴリカル部分除く
                mc1=repmat(mm2,[20 1]);   %気候値をデータの年数分。データと同じサイ
                isoTa=isoT-mc1; 
%                 
                isoS1=array2timetable(isoS,'RowTimes',time);   %timetableに変換
                mm1=groupsummary(isoS1,'Time','monthofyear','mean');   %月別の気候値、tableカテゴリカル
                mm2=table2array(mm1(:,3:end));        %行列に変換、カテゴリカル部分除く
                mc1=repmat(mm2,[20 1]);   %気候値をデータの年数分。データと同じサイ
                isoSa=isoS-mc1; 
%            
           Dmld_isoTa(i,j,n)=isoTa(n);           
           Dmld_isoSa(i,j,n)=isoSa(n);
          

        end
     
    end
end

 Dmld_NaN=zeros(141,91,TIM);
for n=1:TIM
   for j=blat
        for i=blon
         
        DS=spod10(i,j,n)+0.125;   %参照密度
        isot1=ones(20,1);
       
        if mod(n,12)==0
        m=12;
        else
        m=mod(n,12);
        end
        
     for t=m:12:240
               y=(t-m+12)/12;
                if DS - isd(i,j,1,t)< 0
                   isot1(y)=NaN; 
                end           
     end
                TF = isnan(isot1);
                N = nnz(TF);
                Dmld_NaN(i,j,n)=N; 

        end
     
    end
end


