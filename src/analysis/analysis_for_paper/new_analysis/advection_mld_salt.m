% addpath ../anomaly

% %taux,tauy,geoVをロード
% h=9;
% rho=1025; %密度(kg/m^3)　
% R=6371000; % 地球半径（ｍ）
% deg2rad = pi/180;
% omega = 7.292115e-5; %2π/T (1/s)
% 
% TIM=numel(time);
% f=2*omega*sin(slat*deg2rad);
% f1=(repelem(f,1,141*TIM));
% f3=reshape(f1,[91 141 TIM]);
% f4=permute(f3,[2 1 3]);
% rho_f=rho*f4;
% B=2*omega*cos(slat*deg2rad)/R;
% 
% %dT/dx
% dT_dx=NaN(141,91,h,TIM);
% for t=1:TIM
%     for k=1:h
%         for j=1:91
%             for i=2:140
%                 dT_dx(i,j,k,t)=(sallsal(i+1,j,k,t)-sallsal(i-1,j,k,t))/(cos(slat(j)/180*pi)*(2/180)*pi*R);
%             end
%         end
%     end
% end
% 
% %dT/dy
% dT_dy=NaN(141,91,h,TIM);
% for t=1:TIM
%     for k=1:h
%         for j=2:90
%             for i=2:140
%                 dT_dy(i,j,k,t)=(sallsal(i,j+1,k,t)-sallsal(i,j-1,k,t))/((2/360)*2*pi*R);
%             end
%         end
%     end
% end
% 
% % エクマン輸送
% Ue=wind_moment.y./Depth.mld.v;
% Ue=Ue./rho_f;
% 
% Ve=-wind_moment.x./Depth.mld.v;
% Ve=Ve./rho_f;
% 
% % 地衡流速を足す
% U=NaN(141,91,h,TIM);
% V=NaN(141,91,h,TIM);
% for t=1:TIM
%     for k=1:h
%         for j=2:90
%             for i=2:140
% 
%                 if pres(k)<Depth.mld.v(i,j,t)
%                     %混合層内→地衡流＋エクマン輸送
%                     U(i,j,k,t)=Ue(i,j,t)+gv.e(i,j,k,t);
%                     V(i,j,k,t)=Ve(i,j,t)+gv.n(i,j,k,t);
%                 else
%                     %混合層下→地衡流のみ
%                     U(i,j,k,t)=gv.e(i,j,k,t);
%                     V(i,j,k,t)=gv.n(i,j,k,t); 
%                 end
% 
%             end
%         end
%     end
% end
% 
% 
% 
% % 一月分
% Dtx=dT_dx.*U*(60*60*24*31)*-1;
% Dty=dT_dy.*V*(60*60*24*31)*-1;
% 
% spod10=squeeze(sallpod(:,:,1,:));
% isd=sallpod(:,:,1:h,:);
% isd1=zeros(141,91,h,TIM);
% isox1=zeros(141,91,h,TIM);
% isoy1=zeros(141,91,h,TIM);
% %混合層深度、混合層深度上水温
% for n=1:TIM
%     for j=1:91
%         for i=1:141
% 
%             DS=spod10(i,j,n)+0.125;   %参照密度 10m深から0.125kg/m~^3
% 
%             k = 1;
%             while  DS - isd(i,j,k,n)> 0 && k < h
%                 k = k+1;end
% 
%             if k == 1
%                isd1(i,j,k,n)=NaN;
%                 isox1(i,j,k,n)=NaN;
%                 isoy1(i,j,k,n)=NaN;
% 
%             else
%                 isd1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(pres(k,1)-pres(k-1,1))...
%                                     /(isd(i,j,k,n)-isd(i,j,k-1,n))+pres(k-1);
%                 isox1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(Dtx(i,j,k,n)...
%                     -Dtx(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+Dtx(i,j,k-1,n);
%                 isoy1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(Dty(i,j,k,n)...
%                     -Dty(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+Dty(i,j,k-1,n);
%             end
% 
% 
%         end
%     end
% end
% 
% [iso2,ind]=max(isd1,[],3,'omitnan');
% mldD=squeeze(iso2);  %混合層深度
% mldindex=squeeze(ind);  %
% isox2=max(isox1,[],3,'omitnan');
% dtxb=squeeze(isox2);
% 
% isoy2=max(isox1,[],3,'omitnan');
% dtyb=squeeze(isoy2);
% 
% 
% 
% % %経度方向の移流項を深度方向に積分
% Dtx3=permute(Dtx,[3 1 2 4]);
% Dtx1=permute(Dtx(:,:,1,:),[3 1 2 4]);
% %0mを追加
% Dtx0=[Dtx1;Dtx3];
% pres1=[0;pres(1:9)]; 
% clear Dtx3 Dtx1
% Dtx01=permute(Dtx0,[2 3 4 1]);
% 
% Dtx_mld=NaN(141,91,TIM);
% for t=1:TIM
%     for j=1:91
%         for i=1:141
%             te=Dtx01(i,j,t,1:mldindex(i,j,t));
%             te1=squeeze(te); id=mldindex(i,j,t); id1=mldindex(i,j,t)+1;
%             %mldtb,mldDを追加
%             te2=[te1;squeeze(dtxb(i,j,t))]; pres2=[pres1(1:id);mldD(i,j,t)];
%             Dtx_mld(i,j,t)=trapz(pres2,te2)/mldD(i,j,t);
%         end
%     end
% end
% 
% clear Dtx01
% 
% 
% %緯度方向の移流項を深度方向に積分
% Dty3=permute(Dty,[3 1 2 4]);
% Dty1=permute(Dty(:,:,1,:),[3 1 2 4]);
% %0mを追加
% Dty0=[Dty1;Dty3];
% pres1=[0;pres(1:9)]; 
% clear Dty3 Dty1
% Dty01=permute(Dty0,[2 3 4 1]);
% 
% Dty_mld=NaN(141,91,TIM);
% for t=1:TIM
%     for j=1:91
%         for i=1:141
%             te=Dty01(i,j,t,1:mldindex(i,j,t));
%             te1=squeeze(te); id=mldindex(i,j,t); id1=mldindex(i,j,t)+1;
%             %mldtb,mldDを追加
%             te2=[te1;squeeze(dtyb(i,j,t))]; pres2=[pres1(1:id);mldD(i,j,t)];
%             Dty_mld(i,j,t)=trapz(pres2,te2)/mldD(i,j,t);
%         end
%     end
% end
% 
% clear Dty01


mlsb.adx.v = Dtx_mld;
mlsb.adx = anomaly(mlsb.adx);
