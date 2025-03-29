blon=92:111; blat=61:70; %bt=1:240;
bt=12*10+1:12*16+1;
moveM=3;%移動平均させる月の長さ

ena=squeeze(mean(entrain_w(blon,blat,bt),[1 2],'omitnan'));
%dtaB=squeeze(mean(Dtx_mlda(blon,blat,bt)+Dty_mlda(blon,blat,bt),[1 2],'omitnan'));
dtxaB=squeeze(mean(Dtx_mld(blon,blat,bt),[1 2],'omitnan'));
dtyaB=squeeze(mean(Dty_mld(blon,blat,bt),[1 2],'omitnan'));
sf=squeeze(mean(asf(blon,blat,bt),[1 2]));
tmd=squeeze(mean(Tmd(blon,blat,bt),[1 2]));


%%8割以上のデータがあるとき
ent=entrain_w(blon,blat,bt);
for t=1:numel(bt)
TF = isnan(ent(:,:,t)); N = nnz(TF);
if N>numel(blon)*numel(blat)*0.8 
    ena(t)=NaN;
    %enbi(t)=NaN;
end
end


ena=movmean(ena,moveM,1,'omitnan');

sf=movmean(sf,moveM,1);
tmd=movmean(tmd,moveM,1);

figure
plot(Times(bt),tmd,'k--');
hold on
%plot(Times(bt),enbi,'b--');
plot(Times(bt),ena,'b-');
plot(Times(bt),sf,'r-');
plot(Times(bt),dtxaB);
plot(Times(bt),dtyaB);
yline(0);

 xticks([Times(12+1) Times(12*3+1) Times(12*5+1) Times(12*7+1) Times(12*9+1) Times(12*10+1) Times(12*11+1) Times(12*12+1) Times(12*13+1) Times(12*14+1) Times(12*15+1) Times(12*16+1) Times(12*17+1)])
%xticks([Times(12+1) Times(12*3+1) Times(12*5+1) Times(12*7+1) Times(12*9+1) Times(12*11+1) Times(12*13+1) Times(12*15+1) Times(12*17+1) Times(12*19+1)])
 xticklabels({'2002', '2004', '2006', '2008 ','2010','2011','2012','2013','2014','2015','2016','2017','2018'})
%xticklabels({'2002', '2004', '2006', '2008 ','2010','2012','2014','2016','2018','2020'})

legend('水温変化','エントレインメント','海面熱フラックス','移流ｘ','移流ｙ')
hold off