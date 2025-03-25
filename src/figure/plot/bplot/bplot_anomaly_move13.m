blon=92:111; blat=61:70; %bt=1:240;
%bt=12*10+1:12*20;
bt=1:12*20;
moveM=13;%移動平均させる月の長さ

% ena=squeeze(mean(entraina_w(blon,blat,bt),[1 2],'omitnan'));
ena=squeeze(mean(entraina_w(blon,blat,bt),[1 2],'omitnan'));
dtaB=squeeze(mean(Dtx_mlda(blon,blat,bt)+Dty_mlda(blon,blat,bt),[1 2],'omitnan'));
dtxaB=squeeze(mean(Dtx_mlda(blon,blat,bt),[1 2],'omitnan'));
dtyaB=squeeze(mean(Dty_mlda(blon,blat,bt),[1 2],'omitnan'));
sf=squeeze(mean(asfa(blon,blat,bt),[1 2]));
tmd=squeeze(mean(Tmda(blon,blat,bt),[1 2]));

%mldtm=squeeze(mean(mldTma(blon,blat,bt),[1 2]));
%8割以上のデータがあるとき
ent=entraina_w(blon,blat,bt);
for t=1:numel(bt)
TF = isnan(ent(:,:,t)); N = nnz(TF);
if N>numel(blon)*numel(blat)*0.7 
    ena(t)=NaN;
    %enbi(t)=NaN;
end
end


for t=7:numel(bt)-6
    if isnan(ena(t))==false
        ena(t)=mean([ena(t-6) ena(t-5) ena(t-4) ena(t-3) ena(t-2) ena(t-1) ...
            ena(t) ena(t+1) ena(t+2) ena(t+3) ena(t+4) ena(t+5) ena(t+6)],'omitnan');
    end
end
sf=movmean(sf,moveM,1);
tmd=movmean(tmd,moveM,1);
%mldtm=movmean(mldtm,moveM,1);
dtaB=movmean(dtaB,moveM,1);
dtxaB=movmean(dtxaB,moveM,1);
dtyaB=movmean(dtyaB,moveM,1);

figure;
plot(Times(bt),tmd,'k--');
%plot(Times(bt),dtxaB,'r');
hold on
%plot(Times(bt),enbi,'b--');
plot(Times(bt),sf,'r-');
%plot(Times(bt),ena,'b-');
plot(Times(bt),dtaB,'g-');
% plot(Times(bt),dtxaB,'Color','#7E2F8E');
% plot(Times(bt),dtyaB,'b');
yline(0);

xticks([Times(1) Times(12+1) Times(12*2+1) Times(12*3+1) Times(12*4+1) Times(12*5+1) Times(12*6+1) Times(12*7+1) Times(12*8+1) Times(12*9+1) Times(12*10+1) ...
    Times(12*11+1) Times(12*12+1) Times(12*13+1) Times(12*14+1) Times(12*15+1) Times(12*16+1) Times(12*17+1) Times(12*18+1) Times(12*19+1)])
%xticks([Times(12+1) Times(12*3+1) Times(12*5+1) Times(12*7+1) Times(12*9+1) Times(12*11+1) Times(12*13+1) Times(12*15+1) Times(12*17+1) Times(12*19+1)])
xticklabels({'2001','2002', '2003','2004', '2005','2006','2007', '2008 ','2009','2010',...
     '2011','2012','2013','2014','2015','2016','2017','2018','2019','2020'});
%xticklabels({'2002', '2004', '2006', '2008 ','2010','2012','2014','2016','2018','2020'})
xlim([Times(bt(1)) Times(bt(end))])
ylim([-0.5 0.5])
legend('水温変化','海面熱フラックス','移流x')

% legend('移流ｘ','移流ｙ')
hold off