%20年分の平面図
addpath 'C:\Program Files\MATLAB\R2020a\toolbox\m_map';

%%変更部分%%
%X=ssfmc;     %%対象データ(141×91×12) isoT26mc,
h=10;
X=sstay(:,:,22)-sstady(:,:,22);
titlename='海面熱フラックス';
value_range=[-1.5 1.5]; %%データ値範囲
contor_value=[0 0];   %%コンターを引く値
lon_range=[140 240];  %%表示経度範囲
lat_range=[10 65];    %%表示緯度範囲
mapcolor='diverging'; %%図の色　'diverging'or'jet'
%%%

LG=repelem(slon,1,91); LT=repelem(slat,1,141); LT=LT';
figure

m_proj('miller','lon',lon_range,'lat',lat_range);
m_pcolor(LG,LT,X);
m_coast('color','black','linewidth',0.001);

% title(['3月気候値'],'FontSize',15);

m_grid('YTick',[-20 0 20 30 40 50 60], ...
    'XTick',[140 160 180 200 220 240 260],'FontSize',8); %グリッド間隔

colormap(m_colmap(mapcolor,256));  
caxis(value_range);

 hold on
%m_contour(LG,LT,squeeze(X),[0 0],'color','k','linestyle','--');
% 
% %40~50N,150~130Wを囲む
bndry_lon=[210.1 230 230 210.1 210.1];
bndry_lat=[40 40 50 50 40];
m_line(bndry_lon,bndry_lat,'color','y','linewi',1','linestyle','--')
%  m_quiver(LG,LT,-geoV150yc,geoV150yc_n,10,'k');
%m_quiver(LG,LT,taux(:,:,h),tauy(:,:,h),4,'black');
%m_quiver(LG,LT,U(:,:,h),V(:,:,h),4,'black');
% 
hold off

