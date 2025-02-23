blon=92:111; blat=61:70; %選択領域
start_time=12*12+1;%表示開始月
end_time=12*16+1; %表示終了月
start_time=1;%表示開始月
end_time=264; %表示終了月
moveM=13;%移動平均の長さ
tick_lange=12; %

x1=squeeze(mean(-taux(blon,blat,:),[1 2],'omitnan'));
x1=movmean(x1,moveM,1);
x1=(x1-mean(x1,'omitnan'))/std(x1,'omitnan'); % 標準化
x1_title='混合層内平均水温変化';

x2=squeeze(mean(Dty_mlda(blon,blat,:),[1 2],'omitnan'));
x2=movmean(x2,moveM,1);
x2=(x2-mean(x2,'omitnan'))/std(x2,'omitnan'); % 標準化
x2_title='海面フラックス偏差';

% x3=squeeze(mean(Dtx_mlda(blon,blat,:),[1 2],'omitnan'));
% x3=movmean(x3,moveM,1);
% x3=(x3-mean(x3,'omitnan'))/std(x3,'omitnan'); % 標準化
% x3_title='移流x';
% 
% x4=squeeze(mean(Dty_mlda(blon,blat,:),[1 2],'omitnan'));
% x4=movmean(x4,moveM,1);
% x4=(x4-mean(x4,'omitnan'))/std(x4,'omitnan'); % 標準化
% x4_title='移流y';

% 以降のコード...

% x=movmean(x,moveM,1);

figure
figure_size = [ 0, 0, 1100,300]; %%図のサイズ調整　[ 0, 0, 横方向,縦方向]
set(gcf, 'Position', figure_size);
plot(time,x1,'k-','LineWidth',1);
hold on
% plot(time,x2,'LineWidth',1);
% plot(time,x3,'LineWidth',1);
plot(time,x2,'LineWidth',1);
yline(0);
xticks(time(start_time:tick_lange:end_time)) 
xticklabels(datestr(time(start_time:tick_lange:end_time),'yyyy/mm'))
% legend(x1_title,x2_title,x3_title,x4_title, 'Location', 'northeast')
legend('東西風応力','南北移流項', 'Location', 'northeast')
ylim([-3 3]);
xlim([time(start_time) time(end_time)]);
hold off