addpath 'C:\Program Files\MATLAB\R2020a\toolbox\m_map';

d=8; l=61:65;
HD1=mean(salltempa(:,l,d,:),[2],'omitnan'); ;
HD2=mean(sallsala(:,l,d,:),[2],'omitnan'); 
HD3=mean(sallpoda(:,l,d,:),[2],'omitnan'); 

LG=repelem(slon,1,numel(time));
TI1=repelem(time,1,141);TI=TI1';

HD=squeeze(HD1);
figure('position', [0, 0, 1300, 500])
subplot(1,3,1);
D=pcolor(LG,TI,HD);
%title('Tbi','FontSize',17);
ylabel('year');xlabel('longitude(°E)');
caxis([-1 1]);
xlim([150 238]);
colormap(m_colmap('diverging',256));
ytickformat('yyyy');
D.EdgeColor='flat';
ax=gca; c=ax.TickDir; ax.TickDir='both';
hold on
bndry_lon=[210 230 230 210 210];
bndry_time=[time(157) time(157) time(181) time(181) time(157)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','-');
bndry_lon=[220 220];
bndry_time=[time(157) time(181)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
hold off

HD=squeeze(HD2);
subplot(1,3,2); D=pcolor(LG,TI,HD);
%title('Tbi','FontSize',17);
ylabel('year');xlabel('longitude(°E)');
caxis([-0.2 0.2]);
xlim([150 238]);
colormap(m_colmap('diverging',256));
ytickformat('yyyy');
D.EdgeColor='flat';
ax=gca; c=ax.TickDir; ax.TickDir='both';
hold on
bndry_lon=[210 230 230 210 210];
bndry_time=[time(157) time(157) time(181) time(181) time(157)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','-');
bndry_lon=[220 220];
bndry_time=[time(157) time(181)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
hold off

HD=squeeze(HD3);
subplot(1,3,3); D=pcolor(LG,TI,HD);
%title('Tbi','FontSize',17);
ylabel('year');xlabel('longitude(°E)');
caxis([-0.2 0.2]);
xlim([150 238]);
colormap(m_colmap('diverging',256));
ytickformat('yyyy');
D.EdgeColor='flat';
ax=gca; c=ax.TickDir; ax.TickDir='both';
hold on
bndry_lon=[210 230 230 210 210];
bndry_time=[time(157) time(157) time(181) time(181) time(157)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','-');
bndry_lon=[220 220];
bndry_time=[time(157) time(181)];
line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
hold off


