blon=92:101; blat=61:70;
title_name = '(a)150°W ~ 140°W';
savename='f9_bplotcurl_26depth_1.png';

% blon=102:111; blat=61:70;
% title_name = '(b)140°W ~ 130°W';
% savename="f9_bplotcurl_26depth_2.png";

curla13=movmean(curl.a,13,3);
B11=mean(curla13(blon,blat,:),[1 2]);
B1=squeeze(movmean(B11,13,3));
B21=mean(Depth.iso260.a(blon,blat,:),[1 2],'omitnan');
B2=squeeze(movmean(B21,3,3));

figure
set(gcf, 'Position', [0, 0, 1200, 330]); 

yyaxis left
plot(time,-1*B2);
ylim([-20 20])

hold on
yyaxis right
plot(time,B1);
legend('26σ depth anomaly','wind-stress curl anomaly')
ylim([-0.00000005 0.00000005])
% y = yticklabels;
% y.FontSize = 10;
xticks(year(1:3:end))
xtickformat('yyyy');
% xticklabels(time(1:3,end),'fontsize', 10);

ax = gca;
c = ax.Color;
ax.FontSize = 12;

t = title(title_name);
t.FontSize = 20;

saveas(gcf,fullfile("results",savename));



% bndry_lon=[20 -20 -20 20 20];
% bndry_time=[time(157) time(157) time(181) time(181) time(157)];
% line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--');

