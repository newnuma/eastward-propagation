addpath 'C:\Program Files\MATLAB\R2020a\toolbox\m_map';
figure;
figure_size = [ 0, 0, 900,320 ];
set(gcf, 'Position', figure_size);
row = 2; % subplot行数
col = 4; % subplot列数
left_m = 0.03; % 左側余白の割合
bot_m = 0.03; % 下側余白の割合
ver_r = 1.15; % 縦方向余裕 (値が大きいほど各axes間の余白が大きくなる)
col_r = 1.15; 

LG=repelem(slon,1,91);
LT=repelem(slat,1,141);
LT=LT';


for h =1:1:row*col
   % Position は、各Axes に対し、 [左下(x), 左下(y) 幅, 高さ] を指定
   ax(h) = axes('Position',...
      [(1-left_m)*(mod(h-1,col))/col + left_m ,...
      (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
      (1-left_m)/(col*col_r ),...
      (1-bot_m)/(row*ver_r)] );
%for h=1:20
m_proj('miller','lon',[200 235],'lat',[35 53]);
m_pcolor(LG,LT,entraina_tbxy(:,:,h+11));
m_coast('color','black','linewidth',0.001);
c=h+2000+11;
title([num2str(c)],'FontSize',10);
%title([datestr(time(m))],'FontSize',10);

m_grid('YTick',[-20 0 20 30 40 50 60],'FontSize',4);
colormap(m_colmap('diverging',256));
%colormap(m_colmap('jet'));
caxis([-2.00001 2.0000001]);

m_grid('YTick',[-20 0 20 30 40 50 60],'FontSize',4);
colormap(m_colmap('diverging',256));
bndry_lon=[210 230 230 210 210];
bndry_lat=[40 40 50 50 40];
m_line(bndry_lon,bndry_lat,'color','y','linewi',0.5')


end
