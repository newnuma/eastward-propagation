blon=92:111; blat=61:70; %選択領域

savename = "f13_HW_depth.png";

f_month=3; %選択月

f_year_1=13;%表示年
f_year_2=14;%表示年
f_year_3=15;%表示年
f_year_4=16;%表示年

d=8;%深度
mode='c'; %年内比較:'y' or 気候値比較:'c'

figure;
figure_size = [ 0, 0, 700,600 ];
set(gcf, 'Position', figure_size);
row = 1; col = 3; % subplot列数
left_m = 0.1; bot_m = 0.1; % 下側余白の割合
ver_r = 1.4; col_r = 1.2;


for h=1:3
     ax(h) = axes('Position',...
        [(1-left_m)*(mod(h-1,col))/col + left_m ,...
        (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
        (1-left_m)/(col*col_r ),(1-bot_m)/(row*ver_r)] );

    if h==1
        x=sallpod;xa=sallpoda;xtitle='(a) Density';x_lim=[25,26.5];    
    elseif h==2
        x=salltemp;xa=salltempa;xtitle='(b) Temperature';x_lim=[7,11.5];
    elseif h==3
        x=sallsal;xa=sallsala;xtitle='(c) Salinity';x_lim=[32.5,33.7];
    end

    x1=squeeze(mean(x(blon,blat,1:d,(f_year_1-1)*12+f_month),[1 2 4],'omitnan'));
    X1_mc=x(blon,blat,1:d,(f_year_1-1)*12+f_month)-xa(blon,blat,1:d,(f_year_1-1)*12+f_month);
    x1_mc=squeeze(mean(X1_mc,[1 2 4],'omitnan'));
    %混合層深度
    x1_mld=squeeze(mean(Depth.mld.v(blon,blat,(f_year_1-1)*12+f_month),[1 2 3],'omitnan'));
    x1_mld_mc=squeeze(mean(Depth.mld.mc(blon,blat,f_month),[1 2 3],'omitnan'));
    %depth=mldの値
    interp_x1 = interp1(-pres(1:d), x1, -x1_mld, 'linear', 'extrap');
    interp_x1_mc = interp1(-pres(1:d), x1_mc, -x1_mld_mc, 'linear', 'extrap');
    
    x2=squeeze(mean(x(blon,blat,1:d,(f_year_2-1)*12+f_month),[1 2 4],'omitnan'));
    x3=squeeze(mean(x(blon,blat,1:d,(f_year_3-1)*12+f_month),[1 2 4],'omitnan'));
    x4=squeeze(mean(x(blon,blat,1:d,(f_year_4-1)*12+f_month),[1 2 4],'omitnan'));

    x2_mld=squeeze(mean(Depth.mld.v(blon,blat,(f_year_2-1)*12+f_month),[1 2 3],'omitnan'));
    x3_mld=squeeze(mean(Depth.mld.v(blon,blat,(f_year_3-1)*12+f_month),[1 2 3],'omitnan'));
    x4_mld=squeeze(mean(Depth.mld.v(blon,blat,(f_year_4-1)*12+f_month),[1 2 3],'omitnan'));
    
    interp_x2 = interp1(-pres(1:d), x2, -x2_mld, 'linear', 'extrap');
    interp_x3 = interp1(-pres(1:d), x3, -x3_mld, 'linear', 'extrap');
    interp_x4 = interp1(-pres(1:d), x4, -x4_mld, 'linear', 'extrap');


    plot(x1_mc,-pres(1:d),'k--','LineWidth',1.5);
    hold on
    plot(x1,-pres(1:d),'b-','LineWidth',1.5);
    plot(x2,-pres(1:d),'g-','LineWidth',1);
    plot(x3,-pres(1:d),'r-','LineWidth',1);
    %plot(x4,-pres(1:d),'m-','LineWidth',1);

    plot(interp_x1_mc, -x1_mld_mc, 'k*', 'MarkerSize', 8);
    plot(interp_x1, -x1_mld, 'b*', 'MarkerSize', 8);      
    plot(interp_x2, -x2_mld, 'g*', 'MarkerSize', 8);
    plot(interp_x3, -x3_mld, 'r*', 'MarkerSize', 8);
    %plot(interp_x4, -x4_mld, 'm*', 'MarkerSize', 8);

%     legend(['C',string(f_year_1),string(f_year_2),string(f_year_3) ,string(f_year_4)])
    if h==2
        legend(['C',string(2000+f_year_1),string(2000+f_year_2),string(2000+f_year_3)],'Location', 'southeast')
    else
%         legend(['C',string(2000+f_year_1),string(2000+f_year_2),string(2000+f_year_3)],'Location', 'southwest')
    end
    title(xtitle,'FontSize',12);

    yticks([-140:20:-20]);
    yticklabels({'140m','120m','100m','80m','60m','40m','20m'});


    xmin=min([min(x1_mc),min(x1),min(x2),min(x3)]);
    xmax=max([max(x1_mc),max(x1),max(x2),max(x3)]);
    margin=(xmax-xmin)/5;
   
    xlim(x_lim)
%     xlim([xmin-margin,xmax+margin]);
    ylim([-pres(d),-pres(1)]);
    hold off
end

saveas(gcf,fullfile("results",savename));