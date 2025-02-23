blon=92:111; blat=61:70; %bt=1:240;
bt=12*10+1:12*16+1;
%bt=1:12*10;
moveM=3;%移動平均させる月の長さ

dtxa=squeeze(mean(Dtxa(blon,blat,1,bt),[1 2],'omitnan'));
dtya=squeeze(mean(Dtya(blon,blat,bt),[1 2],'omitnan'));
dtxaB=squeeze(mean(Dtx_mlda(blon,blat,bt),[1 2],'omitnan'));
dtyaB=squeeze(mean(Dty_mlda(blon,blat,bt),[1 2],'omitnan'));


dtxaB=movmean(dtxaB,moveM,1);
dtyaB=movmean(dtyaB,moveM,1);
dtxa=movmean(dtxa,moveM,1);
dtya=movmean(dtya,moveM,1);

figure
plot(Times(bt),dtxa,'b--');
hold on
%plot(Times(bt),enbi,'b--');
plot(Times(bt),dtxaB,'b-','LineWidth',1);
plot(Times(bt),dtyaB,'r-','LineWidth',1);
plot(Times(bt),dtya,'r--');
yline(0);

xticks([Times(1) Times(12+1) Times(12*2+1) Times(12*3+1) Times(12*4+1) Times(12*5+1) Times(12*6+1) Times(12*7+1) Times(12*8+1) Times(12*9+1) Times(12*10+1) ...
    Times(12*11+1) Times(12*12+1) Times(12*13+1) Times(12*14+1) Times(12*15+1) Times(12*16+1) Times(12*17+1) Times(12*18+1) Times(12*19+1)])
%xticks([Times(12+1) Times(12*3+1) Times(12*5+1) Times(12*7+1) Times(12*9+1) Times(12*11+1) Times(12*13+1) Times(12*15+1) Times(12*17+1) Times(12*19+1)])
 xticklabels({'2001','2002', '2003','2004', '2005','2006','2007', '2008 ','2009','2010',...
     '2011','2012','2013','2014','2015','2016','2017','2018','2019','2020'})
%xticklabels({'2002', '2004', '2006', '2008 ','2010','2012','2014','2016','2018','2020'})
xlim([Times(bt(1)) Times(bt(end))])
ylim([-1 1])
legend('移流ｘ(海面)','移流ｙ(海面)','移流ｘ(mld)','移流ｙ(mld)')
hold off