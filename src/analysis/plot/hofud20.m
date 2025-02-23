%ホフメラー図(時間-経度図)　20年分
addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

% mldtbmc1=repmat(mldtbmc,[1 1 22]);
% entrain_wa13=movmean(mldTma-mldtba,5,3,'omitnan');
X=sala; %対象データ(141×91×240)

lat_width=61:70; %平均する緯度の範囲（1:10→20S~10S、61:70→40N~50N)
value_range=[-0.3 0.3];%データ値範囲
ftitle='';%図タイトル
west_edge=150; %表示経度の西端(°E)
east_edge=235; %表示経度の東端(°E)
 
figure;
figure_size = [ 0, 0, 400,630 ];
set(gcf, 'Position', figure_size);
LG=repelem(slon,1,numel(time));
%TI1=repelem(Times,1,141);TI=TI1';
TI1=repelem(time,1,141);TI=TI1';

HD1=mean(X(:,lat_width,:),2,'omitnan');
HD=squeeze(HD1);
HD(west_edge-119,:)=NaN; HD(east_edge-119,:)=NaN; HD(:,1)=NaN; HD(:,264)=NaN; HD(:,263)=NaN;
D=pcolor(LG,TI,HD);
xlim([west_edge east_edge]);
% D.EdgeColor='flat';
colormap(m_colmap('diverging',256));

%ytickangle(45);
ylabel('yy/mm');
xticks([150 170 190 210 230])
xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})
Y=13:24:264;
yticks(time(Y))
yticklabels(datestr(time(Y),'yy/mm'))
% yticks([Times(12+1) Times(12*3+1) Times(12*5+1) Times(12*7+1) ...
%     Times(12*9+1) Times(12*11+1) Times(12*13+1) Times(12*15+1) Times(12*17+1) Times(12*19+1)])
% yticklabels({'2002/1','2004', '2006','2008', '2010','2012', '2014','2016','2018','2020'})
D.LineWidth = 0.0001;
D.EdgeColor=[0.3 0.3 0.3];
caxis(value_range);


HN=Dmld_Tbx_nan(:,lat_width,:);
HN1=mean(HN,[2],'omitnan'); HN2=squeeze(HN1);
for i=1:140
    for j=1:264
     if HN2(i,j)>=10
     HD(i,j)=NaN;
     end
    end
end

hold on
D=pcolor(LG,TI,HD);
D.EdgeColor='flat';
ax=gca; c=ax.TickDir; ax.TickDir='both';
xlim([west_edge east_edge]);

% contour(LG,TI,HD,[0 0],'color','k','linestyle','--');
bndry_lon=[210 230 230 210 210];
% bndry_time=[Times(157) Times(157) Times(181) Times(181) Times(157)];
bndry_time=[time(157) time(157) time(181) time(181) time(157)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--');


%論文用補助線
% bndry_lon=[180 235];
% bndry_time=[time(165) time(215)];
% line(bndry_lon,bndry_time,'color','y','linewi',2,'LineStyle','-');
% 
% bndry_lon=[180 235];
% bndry_time=[time(130) time(180)];
% line(bndry_lon,bndry_time,'color','g','linewi',2,'LineStyle','-');
% 
% bndry_lon=[180 235];
% bndry_time=[time(100) time(150)];
% line(bndry_lon,bndry_time,'color','y','linewi',2,'LineStyle','-');
% 
% bndry_lon=[180 235];
% bndry_time=[time(70) time(120)];
% line(bndry_lon,bndry_time,'color','g','linewi',2,'LineStyle','-');

hold off






