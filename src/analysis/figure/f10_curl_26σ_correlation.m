savename = "f10_curl_26σ_correlation.png";
display_lon = [185 240];
display_lat = [30 60];
title_core = '(a)correlation';
title_lag = '(b)lab';

curla13=movmean(-curl.a,13,3);
LO=numel(slon); LA=numel(slat); TIM=numel(time); YE=numel(year);%

X = curla13;
Y = Depth.iso260.a;

% for t = 2:TIM
%     for lon =1:141
%         for lat =1:91
%             if isnan(X(lon,lat,t))
%                 X(lon,lat,t) = X(lon,lat,t-1);
%             end
%             if isnan(Y(lon,lat,t))
%                 Y(lon,lat,t) = X(lon,lat,t-1);
%             end
%         end
%     end
% end


core=zeros(141,91);
lag=zeros(141,91);
for i=1:141
    for j=1:91
        x=squeeze(X(i,j,1:240));
        y=squeeze(Y(i,j,1:240));
         [c,lags] = xcorr(x,y,24,'normalized');
         [M,I]=max(abs(c));
         core(i,j)=c(I);
         lag(i,j)=lags(I);
    end
end



% フィギュアの初期設定
figure;
set(gcf, 'Position', [0, 0, 800, 200]);  % 位置とサイズを指定

row = 1;  % サブプロットの行数
col = 2;  % サブプロットの列数

% サブプロット間の余白を設定
left_margin = 0.1;
right_margin = 0.1;
top_margin = 0.12;
bottom_margin = 0.1;
inter_row_space = 0.01;  % 行間のスペース
inter_col_space = 0.07;  % 列間のスペース

% サブプロットのサイズと位置を計算
plot_width = (1 - left_margin - right_margin - (col - 1) * inter_col_space) / col;
plot_height = (1 - top_margin - bottom_margin - (row - 1) * inter_row_space) / row;

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
        if j == 1
            m_pcolor(LG,LT,squeeze(core)); 
            colormap(m_colmap('jet',256));
            caxis([0 1]);
            title(title_core,'FontSize',15);
            colorbar
        elseif j == 2
            m_pcolor(LG,LT,squeeze(lag)); 
            colormap(m_colmap('jet',256));
            caxis([-18 5]);
            title(title_lag,'FontSize',15);
            colorbar
        end
        m_coast('color','black','linewidth',0.001);
        m_grid('YTick',[-20 0 20 30 40 50 60],'XTick',[190 210 230 250],'FontSize',8);
        bndry_lon=[210 230 230 210 210];
        bndry_lat=[40 40 50 50 40];
        m_line(bndry_lon,bndry_lat,'color','k','linewi',1.3,'linestyle','--');
               

    end
end

saveas(gcf,fullfile("results",savename));






% %pcolor用に変換（対象データと同じサイズにする）
% LG=repelem(slon,1,91);
% LT=repelem(slat,1,141);
% LT=LT';
% addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';
% 
% %（地図）m_mapに値をプロット
% figure
% m_proj('miller','lon',display_lon,'lat',display_lat);
% m_pcolor(LG,LT,core);
% title('(a)相関係数','FontSize',15)
% m_coast;
% m_grid('YTick',[-20 0 20 30 40 50 60],'FontSize',9);
% colormap(m_colmap('diverging',256));
% caxis([-1 1]);
% bndry_lon=[210.1 230 230 210.1 210.1];
% bndry_lat=[40 40 50 50 40];
% m_line(bndry_lon,bndry_lat,'color','k','linewi',0.5')
% 
% figure
% m_proj('miller','lon',[140 240],'lat',[0 70]);
% m_pcolor(LG,LT,lag);
% title('(b)ラグ','FontSize',15)
% m_coast;
% m_grid('YTick',[-20 0 20 30 40 50 60],'FontSize',9);
% colormap(m_colmap('diverging',256));
% bndry_lon=[210.1 230 230 210.1 210.1];
% bndry_lat=[40 40 50 50 40];
% m_line(bndry_lon,bndry_lat,'color','k','linewi',0.5')
% 
% caxis([-18 18]);