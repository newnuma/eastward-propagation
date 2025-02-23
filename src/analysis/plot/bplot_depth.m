blon=92:111; blat=61:70; %選択領域
start_time=12*12+1;%表示開始月
end_time=12*16+1; %表示終了月
% start_time=1;%表示開始月
% end_time=264; %表示終了月

x=Dtxa;
moveM=3;%移動平均の長さ
tick_lange=4; %
value_lange=[-0.1 0.1] ;

x1=squeeze(mean(x(blon,blat,1,:),[1 2],'omitnan'));
x1=movmean(x1,moveM,1);
x1_title='10m';

x2=squeeze(mean(x(blon,blat,3,:),[1 2],'omitnan'));
x2=movmean(x2,moveM,1);
x2_title='50m';

x3=squeeze(mean(x(blon,blat,6,:),[1 2],'omitnan'));
x3=movmean(x3,moveM,1);
x3_title='100m';

x4=squeeze(mean(x(blon,blat,8,:),[1 2],'omitnan'));
x4=movmean(x4,moveM,1);
x4_title='150m';


figure
figure_size = [ 0, 0, 1100,300]; %%図のサイズ調整　[ 0, 0, 横方向,縦方向]
set(gcf, 'Position', figure_size);
plot(time,x1,'k-','LineWidth',1);
hold on
plot(time,x2,'LineWidth',1);
plot(time,x3,'LineWidth',1);
plot(time,x4,'LineWidth',1);
yline(0);
xticks(time(start_time:tick_lange:end_time)) 
xticklabels(datestr(time(start_time:tick_lange:end_time),'yyyy/mm'))
legend(x1_title,x2_title,x3_title,x4_title, 'Location', 'northeast')
ylim(value_lange);
xlim([time(start_time) time(end_time)]);
hold off

clear x