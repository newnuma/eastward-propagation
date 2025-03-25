addpath 'C:\Program Files\MATLAB\R2020a\toolbox\m_map';

d=8; xmin=190; xmax=237; axmin=[-0.3 0.3];
LG=repelem(slon,1,numel(time));
TI1=repelem(time,1,141);TI=TI1';
figure;
figure_size = [ 0, 0, 700,630 ];
set(gcf, 'Position', figure_size);
row = 1; col = 2; % subplot列数
left_m = 0.1; bot_m = 0.1; % 下側余白の割合
ver_r = 1.1; % 縦方向余裕 (値が大きいほど各axes間の余白が大きくなる)
col_r = 1.2; 
l=61:70;
for h=1:3
       ax(h) = axes('Position',...
      [(1-left_m)*(mod(h-1,col))/col + left_m ,...
      (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
      (1-left_m)/(col*col_r ),(1-bot_m)/(row*ver_r)] );
if h==1
% HD1=mean(iso26a(:,l,:),2,'omitnan');
% HD=squeeze(HD1);
% HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
% D=pcolor(LG,TI,HD);
% hold on
HD1=mean(iso26a(:,l,:),2,'omitnan');
HD=squeeze(HD1);
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
D=pcolor(LG,TI,HD);
colormap(m_colmap('diverging',256));
title('(a)26σ深度偏差','FontSize',15);
ytickformat('yyyy');
ytickangle(90);
ylabel('year');
xticks([150 170 190 210 230])
xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})
caxis([-30 30.0000001]);

elseif h==2 
% HD1=mean(curla_lin13(:,l,:),2,'omitnan');
% HD=squeeze(HD1);
% HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
% D=pcolor(LG,TI,HD);
% hold on
HD1=mean(-curla_lin13(:,l,:),2,'omitnan');
HD=squeeze(HD1);
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
D=pcolor(LG,TI,HD);
title('(b)風応力カール偏差×(-1)','FontSize',15);
ytickformat('yyyy');
ytickangle(90);
%yticklabels({})
caxis([-0.0000001 0.0000001]);

end

 colormap(m_colmap('diverging',256));
xticks([150 170 190 210 230])
xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})   
 D.EdgeColor='flat';
ax=gca; c=ax.TickDir; ax.TickDir='both';
colorbar('southoutside')
xlabel('longitude');
 xlim([xmin xmax]);

hold on
bndry_lon=[210 230 230 210 210];
bndry_time=[time(157) time(157) time(181) time(181) time(157)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--');


% bndry_lon=[210 230 230 210 210];
% bndry_time=[time(1) time(1) time(240) time(240) time(1)];
% line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--');
% bndry_lon=[220 220];

% bndry_time=[time(157) time(181)];
% line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
% box on
hold off
end


% HD=squeeze(HD3);
% subplot(1,3,3); D=pcolor(LG,TI,HD);
% %title('Tbi','FontSize',17);
% ylabel('year');xlabel('longitude(°E)');
% caxis([-0.2 0.2]);
% xlim([150 238]);
% colormap(m_colmap('diverging',256));
% ytickformat('yyyy');
% D.EdgeColor='flat';
% ax=gca; c=ax.TickDir; ax.TickDir='both';
% hold on
% bndry_lon=[210 230 230 210 210];
% bndry_time=[time(157) time(157) time(181) time(181) time(157)];
% line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','-');
% bndry_lon=[220 220];
% bndry_time=[time(157) time(181)];
% line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
% hold off


