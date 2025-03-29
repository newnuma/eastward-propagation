%ホフメラー図(時間-経度図)　4年分
addpath 'C:\Program Files\MATLAB\R2020a\toolbox\m_map';

%%変更部分%% 
X=-iso26a; %対象データ(141×91×240)
lat_width=61:70; %平均する緯度の範囲（1:10→20S~10S、61:70→40N~50N)

start_month=12*11+6;  %表示開始月
dispyear=4;           %表示する期間の長さ(年)
grid_interval=4; %グリッド表示する月の間隔

value_range=[-20 20];%データ値範囲

ftitle='26σ深度偏差（浅化正）';%図タイトル
west_edge=180; %表示経度の西端(°E)
east_edge=235; %表示経度の東端(°E)
%%%% 


figure;
figure_size = [ 0, 0, 500,630 ];
set(gcf, 'Position', figure_size);

Times2=Times(start_month:start_month+12*dispyear);
LG=repelem(slon,1,numel(Times2));
TI1=repelem(Times2,1,141);TI=TI1';
%TI1=repelem(time,1,141);TI=TI1';

HD1=mean(X(:,lat_width,start_month:start_month+12*dispyear),2,'omitnan');
HD=squeeze(HD1);
% HD(west_edge-119,:)=NaN; HD(east_edge-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
D=pcolor(LG,TI,HD);
xlim([west_edge east_edge]);
D.EdgeColor='flat';
caxis(value_range);
colormap(m_colmap('diverging',256));
title(ftitle,'FontSize',15);

%ytickangle(90);
ylabel('yy/mm');
xticks([150 170 190 210 230])
xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})

Y=start_month:grid_interval:start_month+12*dispyear;
yticks(Times(Y))
yticklabels(datestr(time(Y),'yy/mm'))

xlim([west_edge east_edge]);
 D.EdgeColor='flat';
 caxis(value_range);

hold on
contour(LG,TI,HD,[0 0],'color','k','linestyle','--');
bndry_lon=[210 230 230 210 210];
bndry_time=[Times(157) Times(157) Times(181) Times(181) Times(157)];
%bndry_time=[Times(157) Times(157) time(181) time(181) time(157)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--');

%論文用補助線
bndry_lon=[180 235];
bndry_time=[Times(165) Times(215)];
line(bndry_lon,bndry_time,'color','y','linewi',2,'LineStyle','-');

bndry_lon=[180 235];
bndry_time=[Times(130) Times(180)];
line(bndry_lon,bndry_time,'color','g','linewi',2,'LineStyle','-');

bndry_lon=[180 235];
bndry_time=[Times(100) Times(150)];
line(bndry_lon,bndry_time,'color','y','linewi',2,'LineStyle','-');

bndry_lon=[180 235];
bndry_time=[Times(70) Times(120)];
line(bndry_lon,bndry_time,'color','g','linewi',2,'LineStyle','-');
hold off






