blon=102:111; blat=61:70; %bt=1:240;
bt=12*11+1:12*16+1;
%bt=1:12*20;
moveM=3;%移動平均させる月の長さ

% ena=squeeze(mean(entrain_w(blon,blat,bt),[1 2],'omitnan'));
% dtxaB=squeeze(mean(dT_dt_x(blon,blat,bt),[1 2],'omitnan'));
% dtyaB=squeeze(mean(dT_dt_y(blon,blat,bt),[1 2],'omitnan'));
sf=squeeze(mean(-ssfa(blon,blat,bt)./80,[1 2]));
tmd=squeeze(mean(asfa(blon,blat,bt),[1 2]));

%%8割以上のデータがあるとき
% ent=entraina_w(blon,blat,bt);
% for t=1:numel(bt)
% TF = isnan(ent(:,:,t)); N = nnz(TF);
% if N>numel(blon)*numel(blat)*0.7 
%     ena(t)=NaN;
%     %enbi(t)=NaN;
% end
% end

% 

figure
plot(Times(bt),tmd,'k-');
hold on
% %plot(Times(bt),enbi,'b--');
% plot(Times(bt),ena,'b-');
plot(Times(bt),sf,'r-');
% plot(Times(bt),dtxaB);
% plot(Times(bt),dtyaB);
yline(0);
%line([Times(12*13+1) Times(12*13+1) Times(12*15) Times(12*15) Times(12*13+1)],[-4 6 6 -4 -4],'LineWidth',1.5,'color','y','linestyle','--');

xticks([Times(12*10+1) Times(12*10+7) Times(12*11+1) Times(12*11+7) Times(12*12+1) Times(12*12+7) Times(12*13+1) Times(12*13+7) Times(12*14+1) Times(12*14+7) Times(12*15+1) Times(12*15+7) Times(12*16+1) Times(12*16+7)])
xticklabels({'2011/1','2011/7','2012/1','2012/7','2013/1','2013/7','2014/1','2014/7','2015/1','2015/7','2016/1','2016/7','2017/1','2017/7'})
xlim([Times(bt(1)) Times(bt(end))])
ylim([-2 2])
%legend('水温変化','エントレインメント','海面熱フラックス','移流ｘ','移流ｙ')
legend('海面熱フラックス(温度変化)','海面熱フラックス/80')
hold off
hold off