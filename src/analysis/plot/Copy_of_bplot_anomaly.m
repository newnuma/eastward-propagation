blon=92:111; blat=61:70; %選択領域
start_time=12*12+1;%表示開始月
end_time=12*16+1; %表示終了月
% start_time=1;%表示開始月
% end_time=264; %表示終了月
moveM=3;%移動平均の長さ
tick_lange=4; %
value_lange=[-6 6] ;

% mc1=repmat(Dtx_mld1mc,[1 1 22]); 

x1=squeeze(mean(Tmda(blon,blat,:),[1 2],'omitnan'));
x1=movmean(x1,moveM,1);
x1_title='混合層内平均水温変化';

x2=squeeze(mean(asfa(blon,blat,:),[1 2],'omitnan'));
x2=movmean(x2,moveM,1);
x2_title='海面フラックス偏差';

x3=squeeze(mean(entraina_w(blon,blat,:),[1 2],'omitnan'));
x3=movmean(x3,moveM,1);
x3_title='エントレインメント';

x4=squeeze(mean(Dty_mlda(blon,blat,:),[1 2],'omitnan'));
x4=movmean(x4,moveM,1);
x4_title='移流y';

x5=squeeze(mean(Dtx_mlda(blon,blat,:),[1 2],'omitnan'));
x5=movmean(x5,moveM,1);
x5_title='移流y';


ena=squeeze(mean(entrain_w(blon,blat,:),[1 2],'omitnan'));
%%8割以上のデータがあるとき
ent=entraina_w(blon,blat,:);
for t=1:numel(time)
    TF = isnan(ent(:,:,t)); N = nnz(TF);
    if N>numel(blon)*numel(blat)*0.7
        ena(t)=NaN;
        %enbi(t)=NaN;
    end
end

x3=squeeze(mean(entraina_w(blon,blat,:),[1 2],'omitnan'));
x3=movmean(ena,moveM,1);
x3_title='エントレインメント';

figure
figure_size = [ 0, 0, 1100,300]; %%図のサイズ調整　[ 0, 0, 横方向,縦方向]
set(gcf, 'Position', figure_size);
plot(time,x1,'k--','LineWidth',1);
hold on
plot(time,x2,'r','LineWidth',1);
plot(time,x3,'m','LineWidth',1);
plot(time,x4,'g','LineWidth',1);
plot(time,x5,'b','LineWidth',1);
yline(0);
xticks(time(start_time:tick_lange:end_time)) 
xticklabels(datestr(time(start_time:tick_lange:end_time),'yyyy/mm'))
% legend(x1_title,x2_title,x3_title,x4_title,'エントレインメント', 'Location', 'southwest')
ylim(value_lange);
xlim([time(start_time) time(end_time)]);
hold off