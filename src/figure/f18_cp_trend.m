addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

savename = "f18_cp_trend.png";
display_lon = [120 255];
display_lat = [-20 65];

data = {Temp.d10_150, Salt.d10_150, Density.d10_150};
data_axis = {[-1 1], [-0.15 0.15], [-0.15 0.15]};
title_name = ["(a) Tempreture", "(b) Salinity", "(c) Density"];

% フィギュアの初期設定
figure;
set(gcf, 'Position', [0, 0, 1200, 600]);  % 位置とサイズを指定

row = 1;  % サブプロットの行数
col = 3;  % サブプロットの列数

% サブプロット間の余白を設定
left_margin = 0.05;
right_margin = 0.05;
top_margin = 0.05;
bottom_margin = 0.05;
inter_row_space = 0.005;  % 行間のスペース
inter_col_space = 0.05;  % 列間のスペース

% サブプロットのサイズと位置を計算
plot_width = (1 - left_margin - right_margin - (col - 1) * inter_col_space) / col;
plot_height = (1 - top_margin - bottom_margin - (row - 1) * inter_row_space) / row;

labels = {'(a)', '(b)', '(c)', '(d)'};
LG=repelem(slon,1,91);
LT=repelem(slat,1,141);
LT=LT';

for i = 1:row
    for j = 1:col

        % サブプロットの位置計算
        left = left_margin + (j - 1) * (plot_width + inter_col_space);
        bottom = 1 - top_margin - i * plot_height - (i - 1) * inter_row_space;
        axes('Position', [left, bottom, plot_width, plot_height]);
        m_proj('miller','lon',display_lon,'lat',display_lat);

        %トレンド差
        trend_dif = data{j}.ay(:,:,end) - data{j}.ady(:,:,end);
        m_pcolor(LG,LT,trend_dif);
        caxis(data_axis{j});

        m_coast('color','black','linewidth',0.001);
        colormap(m_colmap('diverging',256));
        bndry_lon=[140 240 240 140 140];
        bndry_lat=[40 40 50 50 40];
        m_line(bndry_lon,bndry_lat,'color','y','linewi',1');

        title(title_name{j},'FontSize',22);


        m_grid('YTick',[-20 0 20 40 60],'XTick',[150 180 210 240],'FontSize',9);
        colorbar('fontsize',9);




    end
end

saveas(gcf,fullfile("results",savename));





