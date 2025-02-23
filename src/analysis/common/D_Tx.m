%ある深度でのTχ

blon=30:113; blat=61:70; rp=1:13;  %計算範囲を限定する
LO=numel(blon); LA=numel(blat); PR=numel(rp); TIM=240;

%1  2  3  4  5  6   7   8   9   10  11  12  13  14
%10,20,30,50,75,100,125,150,200,250,300,
spod50=squeeze(sallpod(:,:,8,:)); %%参照深度

D150_isoTa=zeros(141,91,TIM);  %%
D150_isoSa=zeros(141,91,TIM);  %%

isd=sallpod(:,:,rp,:);
isot=salltemp(:,:,rp,:);  
isosal=sallsal(:,:,rp,:);

for n=1:TIM
   for j=blat
        for i=blon
        
        DS=spod50(i,j,n);   %参照密度 
        
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
               isosal1(1,1,k,t)=(DS-isd(i,j,k-1,t))*(isosal(i,j,k,t)-isosal(i,j,k-1,t))...
               /(isd(i,j,k,t)-isd(i,j,k-1,t))+isosal(i,j,k-1,t);
                 end

              
     end
     

                isoT2=max(isot1,[],3,'omitnan');
                isoT=squeeze(isoT2);
                isosal2=max(isosal1,[],3,'omitnan');
                isoS=squeeze(isosal2);
                
                isoT1=isoT(m:12:240,1);
                tmc=mean(isoT1,1,'includenan');
                isotn=isoT(n,1);
                isoTa=isotn-tmc; 
                
                isoS1=isoS(m:12:240,1);
                smc=mean(isoT1,1,'includenan');
                isosn=isoT(n,1);
                isoSa=isosn-smc; 

%            
           D150_isoTa(i,j,n)=isoTa;  %%         
           D150_isoSa(i,j,n)=isoSa;  %%
        end
    end
     
end


%NaN(密度面が存在しない年)がある要素数をカウント
 D150_NaN=zeros(141,91,TIM);    %%   
for n=1:TIM
   for j=blat
        for i=blon
         
        DS=spod50(i,j,n);   %参照密度

        isot1=ones(20,1);
       
        if mod(n,12)==0
        m=12;
        else
        m=mod(n,12);
        end
     
     for t=m:12:240
               y=(t-m+12)/12;
                if DS - isd(i,j,1,t)< 0  %参照密度より10mでの密度が高いとき
                   isot1(y)=NaN; 

                end       
     end

     
                TF = isnan(isot1);
                N = nnz(TF);
                D150_NaN(i,j,n)=N;  %%


        end
     
    end
end

