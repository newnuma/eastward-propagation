blon=92:111; blat=61:70; %選択領域
f_year=13;%表示年
f_month=3; %開始月
interval=3;%月間隔
d=8;
mode='y'; %年内比較:'y' or 気候値比較:'c'



for f=1:3
    if f==1
        x=salltemp;xa=salltempa;xtitle='水温';x_lim=[7,20];
    elseif f==2
        x=sallsal;xa=sallsala;xtitle='塩分';x_lim=[32.5,33.7];
    elseif f==3
        x=sallpod;xa=sallpoda;xtitle='密度';x_lim=[24,26.5];
    end

    x1=squeeze(mean(x(blon,blat,1:d,(f_year-1)*12+f_month),[1 2 4],'omitnan'));
    X1_mc=x(blon,blat,1:d,(f_year-1)*12+f_month)-xa(blon,blat,1:d,(f_year-1)*12+f_month);
    x1_mc=squeeze(mean(X1_mc,[1 2 4],'omitnan'));
    %混合層深度
    x1_mld=squeeze(mean(mldD(blon,blat,(f_year-1)*12+f_month),[1 2 3],'omitnan'));
    x1_mld_mc=squeeze(mean(mldDmc(blon,blat,f_month),[1 2 3],'omitnan'));   
    %depth=mldの値
    interp_x1 = interp1(-pres(1:d), x1, -x1_mld, 'linear', 'extrap');
    interp_x1_mc = interp1(-pres(1:d), x1_mc, -x1_mld_mc, 'linear', 'extrap');

    if mode=='y'
        x2=squeeze(mean(x(blon,blat,1:d,(f_year-1)*12+f_month+interval),[1 2 4],'omitnan'));
        x3=squeeze(mean(x(blon,blat,1:d,(f_year-1)*12+f_month+interval*2),[1 2 4],'omitnan'));
        x4=squeeze(mean(x(blon,blat,1:d,(f_year-1)*12+f_month+interval*3),[1 2 4],'omitnan'));

        x2_mld=squeeze(mean(mldD(blon,blat,(f_year-1)*12+f_month+interval),[1 2 3],'omitnan'));
        x3_mld=squeeze(mean(mldD(blon,blat,(f_year-1)*12+f_month+interval*2),[1 2 3],'omitnan'));
        x4_mld=squeeze(mean(mldD(blon,blat,(f_year-1)*12+f_month+interval*3),[1 2 3],'omitnan'));
        
        interp_x2 = interp1(-pres(1:d), x2, -x2_mld, 'linear', 'extrap');
        interp_x3 = interp1(-pres(1:d), x3, -x3_mld, 'linear', 'extrap');
        interp_x4 = interp1(-pres(1:d), x4, -x4_mld, 'linear', 'extrap');

    end

    if mode=='c'
        X2_mc=x(blon,blat,1:d,(f_year-1)*12+f_month+interval)-xa(blon,blat,1:d,(f_year-1)*12+f_month+interval);
        x2_mc=squeeze(mean(X2_mc,[1 2 4],'omitnan'));
        X3_mc=x(blon,blat,1:d,(f_year-1)*12+f_month+interval*2)-xa(blon,blat,1:d,(f_year-1)*12+f_month+interval*2);
        x3_mc=squeeze(mean(X3_mc,[1 2 4],'omitnan'));
        X4_mc=x(blon,blat,1:d,(f_year-1)*12+f_month+interval*3)-xa(blon,blat,1:d,(f_year-1)*12+f_month+interval*3);
        x4_mc=squeeze(mean(X4_mc,[1 2 4],'omitnan'));

        x2_mld_mc=squeeze(mean(mldDmc(blon,blat,f_month+interval),[1 2 3],'omitnan'));
        x3_mld_mc=squeeze(mean(mldDmc(blon,blat,f_month+interval*2),[1 2 3],'omitnan'));
        x4_mld_mc=squeeze(mean(mldDmc(blon,blat,f_month+interval*3),[1 2 3],'omitnan'));

        interp_x2_mc = interp1(-pres(1:d), x2_mc, -x2_mld_mc, 'linear', 'extrap');
        interp_x3_mc = interp1(-pres(1:d), x3_mc, -x3_mld_mc, 'linear', 'extrap');
        interp_x4_mc = interp1(-pres(1:d), x4_mc, -x4_mld_mc, 'linear', 'extrap');        
    end


    figure
    figure_size = [ 0, 0, 400,600]; %%図のサイズ調整　[ 0, 0, 横方向,縦方向]
    set(gcf, 'Position', figure_size);

    % 年内比較
    if mode=='y'

        plot(x1,-pres(1:d),'b-','LineWidth',1.5);
        hold on
        plot(x1_mc,-pres(1:d),'k--','LineWidth',1.5);
        plot(x2,-pres(1:d),'g-','LineWidth',1);
        plot(x3,-pres(1:d),'r-','LineWidth',1);
        plot(x4,-pres(1:d),'m-','LineWidth',1);

        plot(interp_x1, -x1_mld, 'b*', 'MarkerSize', 8);
        plot(interp_x1_mc, -x1_mld_mc, 'k*', 'MarkerSize', 8);
        plot(interp_x2, -x2_mld, 'g*', 'MarkerSize', 8);
        plot(interp_x3, -x3_mld, 'r*', 'MarkerSize', 8);
        plot(interp_x4, -x4_mld, 'm*', 'MarkerSize', 8);

        legend([string(f_month),string(f_month)+'C',string(f_month+interval),string(f_month+interval*2) ,string(f_month+interval*3)])
        title([xtitle,string(time((f_year-1)*12+f_month))+'~'],'FontSize',12);
    end

    % 気候値比較
    if mode=='c'
        plot(x1_mc,-pres(1:d),'b-','LineWidth',1.5);
        hold on
        plot(x2_mc,-pres(1:d),'g-','LineWidth',1.5);
        plot(x3_mc,-pres(1:d),'r-','LineWidth',1.5);
        plot(x4_mc,-pres(1:d),'m-','LineWidth',1.5);

        plot(interp_x1_mc, -x1_mld_mc, 'b*', 'MarkerSize', 8);
        plot(interp_x2_mc, -x2_mld_mc, 'g*', 'MarkerSize', 8);
        plot(interp_x3_mc, -x3_mld_mc, 'r*', 'MarkerSize', 8);
        plot(interp_x4_mc, -x4_mld_mc, 'm*', 'MarkerSize', 8);

        legend([string(f_month),string(f_month+interval),string(f_month+interval*2) ,string(f_month+interval*3)])
        title([xtitle,'気候値'],'FontSize',12);
    end

    xlim(x_lim);
    ylim([-pres(d),-pres(1)]);
    hold off
end