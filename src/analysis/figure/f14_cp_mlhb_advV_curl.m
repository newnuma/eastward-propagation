% addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';
% load("../data/mlhb.mat","mlhb"); %if you do not load, load it
% load("../data/curl.mat","curl"); %if you do not load, load it
% load("../../base_data/data/slp.mat");
% base_setting_path = "../../base_data/data/base_setting.mat";
% load(base_setting_path,"slor","slar","slon","slat","time","year");%slat,slon:focused latitide & longitude slar,slor: array #
% 

load('../../base_data/data/wind_moment.mat')
winx.v = wind_moment.x;
winx = anomaly(winx);
winy.v = wind_moment.y;
winy = anomaly(winy);

savename = "f14_cp_mlhb_advV_curl.png";
display_lon = [140 250];
display_lat = [0 60];

% フィギュアの初期設定
figure;
set(gcf, 'Position', [0, 0, 1200, 800]);  % 位置とサイズを指定

row = 5;  % サブプロットの行数
col = 6;  % サブプロットの列数

% サブプロット間の余白を設定
left_margin = 0.05;
right_margin = 0.05;
top_margin = 0.05;
bottom_margin = 0.05;
inter_row_space = 0.005;  % 行間のスペース
inter_col_space = 0.005;  % 列間のスペース

% サブプロットのサイズと位置を計算
plot_width = (1 - left_margin - right_margin - (col - 1) * inter_col_space) / col;
plot_height = (1 - top_margin - bottom_margin - (row - 1) * inter_row_space) / row;

labels = {'(a)', '(b)', '(c)', '(d)'};
LG=repelem(slon,1,91);
LT=repelem(slat,1,141);
LT=LT';

geoV10mc_4m=NaN(141,91,23);
for i=3:4:139 
   for j=3:4:89
        for k=1:23
        
     geoV10mc_4m(i,j,k)=squeeze(mean(winx.ay(i-2:i+2,j-2:j+2,k),[1 2])); %%%
     
        end
    end
end

geoV10_nmc_4m=NaN(141,91,23);
for i=3:4:139 
   for j=3:4:89
        for k=1:23
        
     geoV10_nmc_4m(i,j,k)=squeeze(mean(winy.ay(i-2:i+2,j-2:j+2,k),[1 2])); %%%
     
        end
    end
end


for i = 1:row
    for j = 1:col
        % サブプロットの位置計算
        left = left_margin + (j - 1) * (plot_width + inter_col_space);
        bottom = 1 - top_margin - i * plot_height - (i - 1) * inter_row_space;
        axes('Position', [left, bottom, plot_width, plot_height]);
        m_proj('miller','lon',display_lon,'lat',display_lat);
        if i == 1
%             m_pcolor(LG,LT,squeeze(mlhb.dt.ay(:,:,j+10))*12); 
            m_pcolor(LG,LT,squeeze(mlhb.dt.as(:,:,j+10))); 
            caxis([-4 4]);
        elseif i == 2
%             m_pcolor(LG,LT,squeeze(mlhb.asf.ay(:,:,j+10))*12);
            m_pcolor(LG,LT,squeeze(mlhb.asf.as(:,:,j+10)));
            caxis([-4 4]);
        elseif i == 3
%             m_pcolor(LG,LT,squeeze(mlhb.entrain.ay(:,:,j+10))*12);
            m_pcolor(LG,LT,squeeze(mlhb.entrain.as(:,:,j+10)));
            caxis([-2 2]);
        elseif i == 4
%             m_pcolor(LG,LT,squeeze(mlhb.adx.ay(:,:,j+10))*12);
            m_pcolor(LG,LT,squeeze(mlhb.adx.as(:,:,j+10)+mlhb.ady.as(:,:,j+10)));
%                         m_pcolor(LG,LT,squeeze(mlhb.adx.as(:,:,j+10)));
            caxis([-2 2]);
        elseif i == 5
            m_pcolor(LG,LT,squeeze(slp.ay(:,:,j+10)));
            caxis([-4 4]);
            hold on
            m_quiver(LG,LT,-geoV10mc_4m(:,:,j+10),geoV10_nmc_4m(:,:,j+10),4,'black');
        end
        m_coast('color','black','linewidth',0.001);
        colormap(m_colmap('diverging',256));
%         bndry_lon=[140 240 240 140 140];
        bndry_lon=[210 230 230 210 210];
        bndry_lat=[40 40 50 50 40];
        m_line(bndry_lon,bndry_lat,'color','y','linewi',1');
        

        %title
        if i == 1
            title([num2str(j+2010)],'FontSize',15);
        end

        %bar
        if j == 6
            colorbar
        end

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
       
%        if j == 1
%               normalized_y_position = 1 - (i - 0.5) / row;
%               text(-0.2,normalized_y_position,labels(i),'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'FontSize', 12, 'Units', 'normalized');
%        end

       if j == col
            colorbar('Position', [left + plot_width + 0.01, bottom+0.01, 0.013, plot_height-0.02]);
       end

       

    end
end

saveas(gcf,fullfile("results",savename));


 


