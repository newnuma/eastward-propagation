%20年分の平面図
addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';
row = 5; % plot行数
col = 4; % plot列数


% [Dtx_mlda,Dtx_mldmc,Dtx_mldy,Dtx_mlday,Dtx_mlday2] = anomaly_fx(Dtx_mld);
% [Dty_mlda,Dty_mldmc,Dty_mldy,Dty_mlday,Dty_mlday2] = anomaly_fx(Dty_mld);
% [asfa,asfmc,asfy,asfay] = anomaly_fx(asf);
% [entrain_wa,entrain_wmc,entrain_wy,entrain_way,entrain_way2] = anomaly_fx(entrain_w);
% [Tmda,Tmdmc,Tmdy,Tmday,Tmday2] = anomaly_fx(Tmd);


%%変更部分%%
X1=winter123_1012(Tmda); %%対象データ(141×91×20)
value_range1=[-4 4]; %%データ値範囲

X2=winter123_1012(asfa); %%対象データ(141×91×20)
value_range2=[-4 4]; %%データ値範囲

X3=winter123_1012a(entrain_w); %%対象データ(141×91×20)
value_range3=[-4 4]; %%データ値範囲

X4=winter123_1012(Dtx_mlda); %%対象データ(141×91×20)
value_range4=[-4 4]; %%データ値範囲

X5=winter123_1012(Dty_mlda); %%対象データ(141×91×20)
value_range5=[-4 4]; %%データ値範囲

start_year=13;

savename='海面熱フラックス年間偏差.png'; %%図の保存名
contor_value=[0 0];   %%コンターを引く値
lon_range=[180 240];  %%表示経度範囲
lat_range=[35 55];    %%表示緯度範囲
mapcolor='diverging'; %%図の色　'diverging'or'jet'
%%%

%%図の表示範囲に応じて調整する部分%%
figure;
figure_size = [ 0, 0, 1100,600]; %%図のサイズ調整　[ 0, 0, 横方向,縦方向]
set(gcf, 'Position', figure_size);
left_m = 0.03; % 左側余白の割合
bot_m = 0.03; % 下側余白の割合
ver_r = 1.15; % 縦方向余裕 (値が大きいほど各axes間の余白が大きくなる)
col_r = 1.0;  % 横方向余裕
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

if h<=col
    m_pcolor(LG,LT,X1(:,:,h+start_year-1));
    caxis(value_range1);
    title([num2str(2000+h+start_year-1)],'FontSize',10);
    hold on
    m_contour(LG,LT,squeeze(X1(:,:,h+start_year-1)),[0 0],'color','k','linestyle','--');
elseif h<=col*2
    m_pcolor(LG,LT,X2(:,:,h+start_year-col*1-1));
    caxis(value_range2);
    hold on
    m_contour(LG,LT,squeeze(X2(:,:,h+start_year-col*1-1)),[0 0],'color','k','linestyle','--');
elseif h<=col*3
    m_pcolor(LG,LT,X3(:,:,h+start_year-col*2-1));
    caxis(value_range3);
    hold on
    m_contour(LG,LT,squeeze(X3(:,:,h+start_year-col*2-1)),[0 0],'color','k','linestyle','--');
elseif h<=col*4
    m_pcolor(LG,LT,X4(:,:,h+start_year-col*3-1));
    caxis(value_range4);
    hold on
    m_contour(LG,LT,squeeze(X4(:,:,h+start_year-col*3-1)),[0 0],'color','k','linestyle','--');
elseif h<=col*5
    m_pcolor(LG,LT,X5(:,:,h+start_year-col*4-1));
    caxis(value_range5);
    hold on
    m_contour(LG,LT,squeeze(X5(:,:,h+start_year-col*4-1)),[0 0],'color','k','linestyle','--');
end

m_coast('color','black','linewidth',0.001);
m_grid('YTick',[-20 0 20 30 40 50 60], ...
    'XTick',[140 160 180 200 220 240 260],'FontSize',5); %グリッド間隔
colormap(m_colmap(mapcolor,256));
% 
% if mod(h, col) == 0 % if the current plot is at the end of a row
%     colorbar; % add a colorbar to the plot
%     % adjust the Position property of the axes to accommodate the colorbar
%     axpos = get(ax(h), 'Position');
%     set(ax(h), 'Position', [axpos(1) axpos(2) axpos(3)*0.8 axpos(4)]);
% end

%40~50N,150~130Wを囲む
bndry_lon=[210.1 230 230 210.1 210.1];
bndry_lat=[40 40 50 50 40];
m_line(bndry_lon,bndry_lat,'color','y','linewi',1','linestyle','--')
% 
hold off
end

saveas(gcf,savename);