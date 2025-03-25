blon=92:111; blat=61:70; %選択領域
f_year=15;%表示年
f_month=2; %表示月
c_year=15;%比較年
d=8;


for f=1:3
    if f==1
        x=salltemp;xa=salltempa;xtitle='水温';
    elseif f==2
        x=sallsal;xa=sallsala;xtitle='塩分';
    elseif f==3
        x=sallpod;xa=sallpoda;xtitle='密度';
    end

    x1=squeeze(mean(x(blon,blat,1:d,(f_year-1)*12+f_month),[1 2 4],'omitnan'));
    x1_title='混合層内平均水温変化';

    X1_mc=x(blon,blat,1:d,(f_year-1)*12+f_month)-xa(blon,blat,1:d,(f_year-1)*12+f_month);
    x1_mc=squeeze(mean(X1_mc,[1 2 4],'omitnan'));

    x1_mld=squeeze(mean(mldD(blon,blat,(f_year-1)*12+f_month),[1 2 3],'omitnan'));
    x1_mld_mc=squeeze(mean(mldDmc(blon,blat,f_month),[1 2 3],'omitnan'));

    x2=squeeze(mean(x(blon,blat,1:d,(c_year-1)*12+f_month+2),[1 2 4],'omitnan'));
    x3=squeeze(mean(x(blon,blat,1:d,(c_year-2)*12+f_month+4),[1 2 4],'omitnan'));



    figure
    figure_size = [ 0, 0, 400,600]; %%図のサイズ調整　[ 0, 0, 横方向,縦方向]
    set(gcf, 'Position', figure_size);
    plot(x1,-pres(1:d),'b-','LineWidth',1.5);
    hold on
    plot(x1_mc,-pres(1:d),'k--','LineWidth',1.5);
%     plot(x2,-pres(1:d),'g-','LineWidth',1);
%     plot(x3,-pres(1:d),'r-','LineWidth',1);

    xmin=min([min(x1_mc),min(x1)]);
    xmax=max([max(x1_mc),max(x1)]);

%     xmin=min([min(x1_mc),min(x1),min(x2),min(x3)]);
%     xmax=max([max(x1_mc),max(x1),min(x3),min(x4)]);
    margin=(xmax-xmin)/5;


    % pres(d)とx1間でx1_mldに対応するx1の値を補間
    interp_x1 = interp1(-pres(1:d), x1, -x1_mld, 'linear', 'extrap');

    % pres(d)とx1_mc間でx1_mld_mcに対応するx1_mcの値を補間
    interp_x1_mc = interp1(-pres(1:d), x1_mc, -x1_mld_mc, 'linear', 'extrap');

    % 交点にマーカーをプロット
%     plot([xmin-margin,interp_x1],[-x1_mld,-x1_mld], 'b-.', 'MarkerSize', 8,'LineWidth',0.5);
%     plot([interp_x1,interp_x1],[-x1_mld,-pres(d)], 'b-.', 'MarkerSize', 8,'LineWidth',0.5);
%     plot(interp_x1, -x1_mld, 'bo', 'MarkerSize', 8);
% 
%     plot([xmin-margin,interp_x1_mc],[-x1_mld_mc,-x1_mld_mc], 'k-.', 'MarkerSize', 8,'LineWidth',0.5);
%     plot([interp_x1_mc,interp_x1_mc],[-x1_mld_mc,-pres(d)], 'k-.', 'MarkerSize', 8,'LineWidth',0.5);
%     plot(interp_x1_mc, -x1_mld_mc, 'bo', 'MarkerSize', 8);
     
    xlim([xmin-margin,xmax+margin]);

    ylim([-pres(d),-pres(1)]);
    title([xtitle,string(time((f_year-1)*12+f_month))],'FontSize',12);
    hold off
end