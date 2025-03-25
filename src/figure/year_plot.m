addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

data = wh.d150.ay;  %表示データ
data_axis = [-5 5]; %表示データの値の範囲
% data = mlsb.dt.ay ;  %表示データ
% data_axis = [-0.05 0.05]; %表示データの値の範囲
savename = "year.png";
plot_color = 'diverging'; % plotの色 'jet'

display_lon = [140 250];
display_lat = [0 60];

% フィギュアの初期設定
figure;
set(gcf, 'Position', [0, 0, 1300, 600]);  % 位置とサイズを指定

row = 4;  % サブプロットの行数
col = 6;  % サブプロットの列数

% サブプロット間の余白を設定
left_margin = 0.05;
right_margin = 0.1;
top_margin = 0.05;
bottom_margin = 0.05;
inter_row_space = 0.01;  % 行間のスペース
inter_col_space = 0.01;  % 列間のスペース

% サブプロットのサイズと位置を計算
plot_width = (1 - left_margin - right_margin - (col - 1) * inter_col_space) / col;
plot_height = (1 - top_margin - bottom_margin - (row - 1) * inter_row_space) / row;

labels = {'(a)', '(b)', '(c)', '(d)'};
LG=repelem(slon,1,91);
LT=repelem(slat,1,141);
LT=LT';

for i = 1:row
    for j = 1:col
            
        if (j+(i-1)*col) <= numel(year)
            % サブプロットの位置計算   
            left = left_margin + (j - 1) * (plot_width + inter_col_space);
            bottom = 1 - top_margin - i * plot_height - (i - 1) * inter_row_space;
            axes('Position', [left, bottom, plot_width, plot_height]);

            m_proj('miller','lon',display_lon,'lat',display_lat);
            m_pcolor(LG,LT,squeeze(data(:,:,j+(i-1)*col)));
            caxis(data_axis);
            m_coast('color','black','linewidth',0.001);
            colormap(m_colmap(plot_color,256));

            %title
            title([num2str(j+col*(i-1)+2000)],'FontSize',13);

            
            %HW領域を囲む線
%             bndry_lon=[210 230 230 210 210];
%             bndry_lat=[40 40 50 50 40];
%             m_line(bndry_lon,bndry_lat,'color','y','linewi',1');


            %TickLabel
            if i == row
                if j == 1
                    m_grid('YTick',[-20 0 20 40 60],'XTick',[150 180 210 240],'FontSize',8);
                else
                    m_grid('YTick',[-20 0 20 40 60],'XTick',[150 180 210 240],'YTickLabel',[],'FontSize',8);
                end
            else
                if j == 1
                    m_grid('YTick',[-20 0 20 40 60],'XTick',[150 180 210 240],'XTickLabel',[],'FontSize',8);
                else
                    m_grid('YTick',[-20 0 20 40 60],'XTick',[150 180 210 240],'YTickLabel',[],'XTickLabel',[],'FontSize',8);
                end
            end

           
            %colorbar
            if (j+(i-1)*col)==12
             colorbar('Position', [left + plot_width + 0.015, bottom-plot_height*1.5, 0.014, plot_height*3]);
            end

        end



    end
end

saveas(gcf,fullfile("results",savename));


 


