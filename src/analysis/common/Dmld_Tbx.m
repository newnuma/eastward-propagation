%翌月混合層深度での水温偏差の等密度面上偏差成分Tx

blon=30:113; blat=56:73; rp=1:13;
LO=numel(blon); LA=numel(blat); PR=numel(rp); TIM=240;
%numel(time);
spod10=squeeze(sallpod(:,:,1,:)); %%

Dmld_isoTBmc=zeros(141,91,TIM);
Dmld_isoTBa=zeros(141,91,TIM);
% Dmld_isoSBa=zeros(141,91,TIM);
isd=sallpod(:,:,rp,:);
isot=salltemp(:,:,rp,:); 

for n=1:TIM-1
   for j=blat
        for i=blon
        
 if    mldD(i,j,n+1)-mldD(i,j,n)>0 
        %isosal=sallsal(:,:,rp,:); %%
        id=mldindex(i,j,n+1);
        DS=isd(i,j,id,n);  %参照密度 

        isd1=NaN(1,1,PR,240);
        isot1=NaN(1,1,PR,240);
        %isosal1=NaN(1,1,PR,240);
        
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
                
                isoT1=isoT(m:12:240,1);
                tmc=mean(isoT1,1,'omitnan');
                isotn=isoT(n,1);
                isoTa=isotn-tmc; 
                
           Dmld_isoTBmc(i,j,n)=mm2(m); 
           Dmld_isoTBa(i,j,n)=isoTa(n);           
%            Dmld_isoSBa(i,j,t)=isoSa(t);
          
 end
        end
     
    end
end
