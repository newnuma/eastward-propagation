LO=numel(slon); LA=numel(slat); YE=numel(year);%
addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

data = {salltemp};
data_axis = {[5 20]};

%%%
savename = "vertime.png";
blon=92:101; %%150W~140W
data_title = {'(a) Density(western region)', '(c) Temperature(western region)', '(e) Salinity(western region)'};
color_bar = true;

%%%%
% savename = "f12_HW_vertime_2.png";
% blon=102:111; %%140W~130W
% data_title = {'(b) Density(eastern region)', '(d) Temperature(eastern region)', '(f) Salinity(eastern region)'};
% color_bar = false;

%%%
% savename = "f12_HW_vertime_bar.png";
% color_bar = true;

bts=time(141);bte=time(147); 
blat=61:70; bp=1:13; pres_lin=(10:10:500)';xmin=190; xmax=233;

figure;
figure_size = [ 0, 0, 500,600 ];
set(gcf, 'Position', figure_size);
row = 1; col = 1; % subplot列数
left_m = 0.2; bot_m = 0.1; % 下側余白の割合
ver_r = 1.2; col_r = 1;


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


for h=1:1
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
    caxis(data_axis{h}); 
    
    yticks([-100:20:-20]);
    yticklabels({'100m','80m','60m','40m','20m'});
%     xticks('yyyy');
    xticklabels({'','','t-1','t','t+1',''});
%     xtickformat('yyyy');

    ax=gca; c=ax.TickDir; ax.TickDir='both';
    ax.XAxis.FontSize = 17;
    ax.YAxis.FontSize = 17;

    ylabel('depth[m]');
    D.EdgeColor='flat';
    xlim([bts bte]);
    ylim([-120 -10]);
    colormap(m_colmap('jet',256));

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
    plot(time,-1*F1,'k-','LineWidth',3)
    hold off 


end

saveas(gcf,fullfile("results",savename));

clear B1pod_lin B1pod_lin1 B1poda B1poda1 B1tempa B1tempa B1tempa_lin B1tempa_lin1



