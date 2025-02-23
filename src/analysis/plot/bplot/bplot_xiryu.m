blon=102:111; blat=61:70;%bt=1:240;
bt=12*10+1:12*16+1;
%bt=1:12*10;
moveM=3;%移動平均させる月の長さ

dx10=squeeze(mean(Dtxa(blon,blat,1,bt),[1 2],'omitnan'));
dx50=squeeze(mean(Dtxa(blon,blat,4,bt),[1 2],'omitnan'));
dx75=squeeze(mean(Dtxa(blon,blat,5,bt),[1 2],'omitnan'));
dx100=squeeze(mean(Dtxa(blon,blat,6,bt),[1 2],'omitnan'));
dx150=squeeze(mean(Dtxa(blon,blat,8,bt),[1 2],'omitnan'));


figure
plot(Times(bt),dx10,'k--');

hold on
%plot(Times(bt),enbi,'b--');
plot(Times(bt),dx50,'b-');
plot(Times(bt),dx75,'LineWidth',1);
plot(Times(bt),dx100,'LineWidth',1);
plot(Times(bt),dx150,'LineWidth',1);
yline(0);
% line([Times(12*13+1) Times(12*13+1) Times(12*15) Times(12*15) Times(12*13+1)],[-2 2 2 -2 -2],'LineWidth',1.5,'color','y','linestyle','--');

xticks([Times(12*10+1) Times(12*10+7) Times(12*11+1) Times(12*11+7) Times(12*12+1) Times(12*12+7) Times(12*13+1) Times(12*13+7) Times(12*14+1) Times(12*14+7) Times(12*15+1) Times(12*15+7) Times(12*16+1) Times(12*16+7)])
xticklabels({'2011/1','2011/7','2012/1','2012/7','2013/1','2013/7','2014/1','2014/7','2015/1','2015/7','2016/1','2016/7','2017/1','2017/7'})
xlim([Times(bt(1)) Times(bt(end))])
ylim([-0.2 0.2])
legend('10m','50m','75m','100m','150m')
hold off