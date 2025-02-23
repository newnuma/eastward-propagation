addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

savename = "f3_hofud.png";

xmin=150; xmax=237;

data = {Temp.d10.a, Temp.d10_300.a, Salt.d10_300.a ,Density.d10_300.a};
data_axis = {[-3 3], [-1.5 1.5], [-0.2 0.200001], [-0.2 0.200001] };
data_title = {'(a)', '(b)', '(c)', '(d)'};


LG=repelem(slon,1,numel(time));
TI1=repelem(time,1,141);TI=TI1';
figure;
figure_size = [ 0, 0, 1000,600 ];
set(gcf, 'Position', figure_size);
row = 1; col = 4; % subplot列数
left_m = 0.1; bot_m = 0.1; % 下側余白の割合
ver_r = 1.1; % 縦方向余裕
col_r = 1.2;
l=61:70;%40N~50N

LO=numel(slon); LA=numel(slat); TIM=numel(time); YE=numel(year);%

for h=1:4
    ax(h) = axes('Position',...
        [(1-left_m)*(mod(h-1,col))/col + left_m ,...
        (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
        (1-left_m)/(col*col_r ),(1-bot_m)/(row*ver_r)] );

    HD1=mean(data{h}(:,l,:),2,'omitnan');
    HD=squeeze(HD1);
    HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,TIM)=NaN; HD(:,TIM-1)=NaN;

    D=pcolor(LG,TI,HD);
    D.EdgeColor='flat';

    colormap(m_colmap('diverging',256));
    caxis(data_axis{h});

    title(data_title{h},'FontSize',15);

    yticks([year(2:4:23)])
    ytickformat('yyyy');
    ytickangle(90);

    xticks([150 170 190 210 230])
    xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})
    xtickangle(0);

    ax=gca; c=ax.TickDir; ax.TickDir='both';
    ax.XAxis.FontSize = 10;
    ax.YAxis.FontSize = 10;

    xlabel('longitude');
    ax.XLabel.FontSize = 10;

    if h ==1
        ylabel('year');
        ax.YLabel.FontSize = 12;
    end



    colorbar('southoutside',FontSize=10)
    xlim([xmin xmax]);

    hold on
    bndry_lon=[210 230 230 210 210];
    bndry_time=[time(157) time(157) time(181) time(181) time(157)];
    line(bndry_lon,bndry_time,'color','y','linewi',1.5,'LineStyle','--');
    bndry_lon=[220 220];
    % bndry_time=[time(157) time(181)];
    % line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
    % box on
    hold off
end

saveas(gcf,fullfile("results",savename));

%



