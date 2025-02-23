addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

savename = "f6_hofud_150m_sal.png";
xmin=150; xmax=235;

data = {Salt.d150.a, Salt.d150.x, Salt.d150.a - Salt.d150.x};
data_nan = {Temp.d150.xn, Temp.d150.xn, Temp.d150.xn};
data_axis = {[-0.3 0.3], [-0.3 0.3], [-0.3 0.3]};
data_title = {'(d)', '(e)', '(f)'};

LO=numel(slon); LA=numel(slat); TIM=numel(time); YE=numel(year);%


LG=repelem(slon,1,numel(time));
TI1=repelem(time,1,141);TI=TI1';
figure;
figure_size = [ 0, 0, 900,630 ];
set(gcf, 'Position', figure_size);
row = 1; col = 3; % subplot列数
left_m = 0.1; bot_m = 0.1; % 下側余白の割合
ver_r = 1.1; % 縦方向余裕 (値が大きいほど各axes間の余白が大きくなる)
col_r = 1.2;
l=61:70;

for h=1:row*col
    ax(h) = axes('Position',...
        [(1-left_m)*(mod(h-1,col))/col + left_m ,...
        (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
        (1-left_m)/(col*col_r ),(1-bot_m)/(row*ver_r)] );

    
    HD1=mean(data{h}(:,l,:),2,'omitnan');
    HD=squeeze(HD1);
    HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,TIM)=NaN; HD(:,TIM-1)=NaN;
    D=pcolor(LG,TI,HD);
    hold on
    HD1=mean(data{h}(:,l,:),2,'omitnan');
    HD=squeeze(HD1);
    HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,TIM)=NaN; HD(:,TIM-1)=NaN;
    D=pcolor(LG,TI,HD);
    D.LineWidth = 0.0001;
    D.EdgeColor=[0.3 0.3 0.3];
    colormap(m_colmap('diverging',256));

    title(data_title{h},'FontSize',15);


    %密度面が存在しない年がある月に網掛け
    HN=data_nan{h}(:,l,:);
    HN1=mean(HN,[2],'omitnan'); HN2=squeeze(HN1);
    for i=1:140
        for j=1:240
            if HN2(i,j)>=1
                HD(i,j)=NaN;
            end
        end
    end

    if h ~=1
        D=pcolor(LG,TI,HD);
    end

    D.EdgeColor='flat';
    D.EdgeColor='flat';
    caxis(data_axis{h}); %%

    xticks([150 170 190 210 230])
    xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})
    xtickangle(0);

    ax=gca; c=ax.TickDir; ax.TickDir='both';
    ax.XAxis.FontSize = 10;
    ax.YAxis.FontSize = 10;

    xlabel('longitude');
    ax.XLabel.FontSize = 10;

    yticks([year(2:4:23)])
    ytickformat('yyyy');
    ytickangle(90);
    if h ==1
        ylabel('year');
        ax.YLabel.FontSize = 12;
    end

    colormap(m_colmap('diverging',256));
        
    bar_axis = [data_axis{h}(1) 0 data_axis{h}(end)];
    colorbar('southoutside','Ticks',bar_axis,FontSize=10)
    xlim([xmin xmax]);

    hold on
    bndry_lon=[210 230 230 210 210];
    bndry_time=[time(157) time(157) time(181) time(181) time(157)];
    line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--');
    bndry_lon=[220 220];
    % bndry_time=[time(157) time(181)];
    % line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
    % box on
    hold off
end


saveas(gcf,fullfile("results",savename));

