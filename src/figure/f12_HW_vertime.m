LO=numel(slon); LA=numel(slat); YE=numel(year);%
addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

data = {sallpoda, salltempa, sallsala};
data_axis = {[-0.3 0.3], [-2 2], [-0.3 0.3]};

%%%
savename = "f12_HW_vertime_1.png";
blon=92:101; %%150W~140W
data_title = {'(a) Density(western region)', '(c) Temperature(western region)', '(e) Salinity(western region)'};
color_bar = false;

%%%%
% savename = "f12_HW_vertime_2.png";
% blon=102:111; %%140W~130W
% data_title = {'(b) Density(eastern region)', '(d) Temperature(eastern region)', '(f) Salinity(eastern region)'};
% color_bar = false;

%%%
% savename = "f12_HW_vertime_bar.png";
% color_bar = true;

bts=time(132);bte=time(205); 
blat=61:70; bp=1:13; pres_lin=(10:10:500)';xmin=190; xmax=233;

figure;
figure_size = [ 0, 0, 500,600 ];
set(gcf, 'Position', figure_size);
row = 3; col = 1; % subplot列数
left_m = 0.1; bot_m = 0.1; % 下側余白の割合
ver_r = 1.4; col_r = 1.15;


B1poda=mean(sallpod(blon,blat,bp,:),[1 2],'includenan');
B1poda1=squeeze(B1poda);

allsst1=permute(B1poda1,[2 1]);
allsst3=array2timetable(allsst1,'RowTimes',time);
mm1=groupsummary(allsst3,'Time','monthofyear','mean');
mm2=table2array(mm1(:,3:end));
mm3=reshape(mm2,[12 13]);
B1podmc=permute(mm3,[2 1]);
B1podmc1=repmat(B1podmc,[1 1 YE]);

z2 = [10;20;30;50;75;100;125;150;200;250;300]';
B1pod_lin1 = zeros(numel(pres_lin),numel(time));
B1podmc_lin1 = zeros(numel(pres_lin),numel(time));


for t = 1:numel(time)
    B1pod_lin1(:,t) = interp1(pres(bp),B1poda1(:,t),pres_lin);
    B1podmc_lin1(:,t) = interp1(pres(bp),B1podmc1(:,t),pres_lin);
end

B1pod_lin=permute(B1pod_lin1,[2 1]);
B1podmc_lin=permute(B1podmc_lin1,[2 1]);

TIM=repelem(time,1,numel(pres_lin));
PR1=repelem(pres_lin,1,numel(time));
PR2=PR1';


for h=1:3
    ax(h) = axes('Position',...
        [(1-left_m)*(mod(h-1,col))/col + left_m ,...
        (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
        (1-left_m)/(col*col_r ),(1-bot_m)/(row*ver_r)] );

    X = data{h};
    B1tempa=mean(X(blon,blat,bp,:),[1 2],'includenan');  %%
    B1tempa1=squeeze(B1tempa);
    B1tenpa_lin1 = zeros(numel(pres_lin),numel(time));
    for t = 1:numel(time)
        B1tenpa_lin1(:,t) = interp1(pres(bp),B1tempa1(:,t),pres_lin);
    end
    B1tenpa_lin=permute(B1tenpa_lin1,[2 1]);

    box on
    D=pcolor(TIM,-1*PR2,B1tenpa_lin);
    title(data_title{h},'FontSize',13);  %%
    caxis(data_axis{h}); 
    
    yticks([-300:50:-50]);
    yticklabels({'300','250','200','150','100','50'});
    xtickformat('yyyy');

    ax=gca; c=ax.TickDir; ax.TickDir='both';
    ax.XAxis.FontSize = 10;
    ax.YAxis.FontSize = 10;

    ylabel('depth[m]');
    D.EdgeColor='flat';
    xlim([bts bte]);
    ylim([-300 -10]);
    colormap(m_colmap('diverging',256));

    if (color_bar)
        colorbar
    end

    clear days
    H=squeeze(B1pod_lin);
    D1=time-datetime(2001,1,15);
    DT=days(D1);
    TIMs=repelem(DT,1,numel(pres_lin));
    H2=squeeze(B1podmc_lin);

    hold on
    F=squeeze(mean(Depth.mld.v(blon,blat,:),[1 2],'includenan'));
    F1=F';
    plot(time,-1*F1,'g','LineWidth',1)

    [C,h]=contour(TIMs,-1*PR2,H,'black','ShowText','off','LineWidth',0.7);
    w=h.LevelList;
    h.LevelList=[26.3 26  25.5  26.5];
    clabel(C,h,'FontSize',8);

    [C,h]=contour(TIMs,-1*PR2,H2,'k--','ShowText','off','LineWidth',0.7);
    w=h.LevelList;
    h.LevelList=[26.3 26  25.5  26.5];

    bndry_lon=[-10 -10 -300 -300 -10];
    bndry_time=[DT(157) DT(181) DT(181) DT(157) DT(157)];
    line(bndry_time,bndry_lon,'color','y','linewi',1,'LineStyle','--');

    hold off


end

saveas(gcf,fullfile("results",savename));

clear B1pod_lin B1pod_lin1 B1poda B1poda1 B1tempa B1tempa B1tempa_lin B1tempa_lin1



