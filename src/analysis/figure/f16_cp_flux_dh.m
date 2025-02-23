addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

savename = "f16_cp_flux_dh.png";
display_lon = [120 255];
display_lat = [-20 65];

contor_value=[0 0]; 

% フィギュアの初期設定
figure;
set(gcf, 'Position', [0, 0, 1200, 600]);  % 位置とサイズを指定


% サブプロットのサイズと位置を計算

labels = {'(a)', '(b)', '(c)', '(d)'};
LG=repelem(slon,1,91);
LT=repelem(slat,1,141);
LT=LT';

m_proj('miller','lon',display_lon,'lat',display_lat);
m_pcolor(LG,LT,squeeze(mean(flux.total,3)));
caxis([-150 150]);

m_coast('color','black','linewidth',0.001);
colormap(m_colmap('diverging',256));
bndry_lon=[140 240 240 140 140];
bndry_lat=[40 40 50 50 40];
m_line(bndry_lon,bndry_lat,'color','y','linewi',1');


title("(a)",'FontSize',22);


m_grid('YTick',[-20 0 20 40 60],'XTick',[150 180 210 240],'FontSize',13);
colorbar('fontsize',12);

hold on
% m_contour(LG,LT,squeeze(mean(salldh(:,:,1,h),4)),[18 19 20 21 22 23 24 25 26 27],'color','k','linestyle','-','ShowText','on');
m_contour(LG,LT,squeeze(mean(salldh(:,:,1,:),4)),[16 18 20 22 24 26 28],'color','k','linestyle','-','ShowText','on');


saveas(gcf,fullfile("results",savename));





