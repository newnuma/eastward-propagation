%12ヶ月の平面図
addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';
row = 3; % plot行数
col = 4; % plot列数

%%変更部分%%
X=mldtbmc-Tb_MLDmc(:,:,1:12);     %%対象データ(141×91×12) isoT26mc,
value_range=[-0.3 0.3]; %%データ値範囲
savename='海面熱フラックス気候値.png'; %%図の保存名
contor_value=[0 0];   %%コンターを引く値
lon_range=[140 240];  %%表示経度範囲
lat_range=[10 65];    %%表示緯度範囲
 mapcolor='diverging'; %%図の色　'diverging'or'jet'
% mapcolor='jet';
%%%

%%図の表示範囲に応じて調整する部分%%
figure;
figure_size = [ 0, 0, 1100,600]; %%図のサイズ調整　[ 0, 0, 横方向,縦方向]
set(gcf, 'Position', figure_size);
left_m = 0.03; % 左側余白の割合
bot_m = 0.03; % 下側余白の割合
ver_r = 1.15; % 縦方向余裕 (値が大きいほど各axes間の余白が大きくなる)
col_r = 1.1;  % 横方向余裕
%%%



LG=repelem(slon,1,91); LT=repelem(slat,1,141); LT=LT';
for h=1:1:row*col
   % Position は、各Axes に対し、 [左下(x), 左下(y) 幅, 高さ] を指定
   ax(h) = axes('Position',...
      [(1-left_m)*(mod(h-1,col))/col + left_m ,...
      (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
      (1-left_m)/(col*col_r ),...
      (1-bot_m)/(row*ver_r)] );

m_proj('miller','lon',lon_range,'lat',lat_range);
m_pcolor(LG,LT,X(:,:,h));
m_coast('color','black','linewidth',0.001);

title([num2str(h),'月'],'FontSize',12);

m_grid('YTick',[-20 0 20 30 40 50 60], ...
    'XTick',[140 160 180 200 220 240 260],'FontSize',5); %グリッド間隔

colormap(m_colmap(mapcolor,256));  
caxis(value_range);

hold on
m_contour(LG,LT,squeeze(X(:,:,h)),[0 0],'color','k','linestyle','--');
%m_quiver(LG,LT,Umc_4m(:,:,h),Vmc_4m(:,:,h),3,'black');
%40~50N,150~130Wを囲む
bndry_lon=[210.1 230 230 210.1 210.1];
bndry_lat=[40 40 50 50 40];
m_line(bndry_lon,bndry_lat,'color','y','linewi',1','linestyle','--')
% 
hold off
end

saveas(gcf,savename);