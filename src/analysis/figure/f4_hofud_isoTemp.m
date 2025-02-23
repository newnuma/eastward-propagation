addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

xmin=150; xmax=235;

savename = "f4_hofud_isoTemp_1.png";
data = {Temp.iso250.a, Temp.iso255.a, Temp.iso260.a,Temp.iso263.a, Temp.iso265.a, Temp.iso267.a };
data_nan = {Temp.iso250.n, Temp.iso255.n, Temp.iso260.n, Temp.iso263.n, Temp.iso265.n, Temp.iso267.n};
data_gv = {Gv_e.iso250.v, Gv_e.iso255.v, Gv_e.iso260.v, Gv_e.iso263.v, Gv_e.iso265.v, Gv_e.iso267.v};
data_axis = {[-1.5 1.5], [-1.5 1.5], [-1.5 1.5], [-1 1], [-0.5 0.5], [-0.3 0.3000001]};
data_title = {'(a)25.0σ', '(b)25.5σ', '(c)26.0σ','(d)', '(e)', '(f)'};
gv_plot = {false, false, true};

savename = "f4_hofud_isoTemp_2.png";
data = {Temp.iso263.a, Temp.iso265.a, Temp.iso267.a };
data_nan = {Temp.iso263.n, Temp.iso265.n, Temp.iso267.n};
data_gv = {Gv_e.iso263.v, Gv_e.iso265.v, Gv_e.iso267.v};
data_axis = {[-1 1], [-0.5 0.5], [-0.3 0.3]};
data_title = {'(d)26.3σ', '(e)26.5σ', '(f)26.7σ'};
gv_plot = {false, false, true};


LO=numel(slon); LA=numel(slat); TIM=numel(time); YE=numel(year);%
e_r = 6371000;
LD=(60*60*24*100*360)/(e_r*2*pi*cos(45/180*pi));

a  = hours(time(end)-time(1));
LG=repelem(slon,1,numel(time));

time_h = NaN(TIM,1);
for t = 1:TIM
    time_h(t,1) = hours(time(t)-time(1));
end
TI1=repelem(time_h,1,141);TI=TI1';
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


    D=pcolor(LG,TI,HD);
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

    yticks([time_h(12+1) time_h(12*5+1) time_h(12*9+1) time_h(12*13+1) time_h(12*17+1) time_h(12*21+1)])
    yticklabels({'2002', '2006', '2010', '2014','2018', '2022'})

%     yticks([year(2:4:23)])
%     ytickformat('yyyy');
%     ytickangle(90);
    if h ==1
        ylabel('year');
        ax.YLabel.FontSize = 12;
    end

    
    if gv_plot{h}
        geov267_4m=NaN(LO,LA,TIM);
        for i=5:8:136
            for j=1:91
                for k=5:8:235+36

                    geov267_4m(i,j,k)=squeeze(mean(data_gv{h}(i-4:i+4,j,k-4:k+4),[1 3])); %%%

                end
            end
        end
        FD=geov267_4m(:,61:70,:);%S20N+
        FD1=squeeze(mean(FD,2,'omitnan'));
        F=squeeze(FD1).*LD;
        f=zeros(LO,TIM);
        f(:,:)=hours(time(end)-time(1))/141;
        for i=1:LO
            for j=1:TIM
                if isnan(F(i,j))
                    f(i,j)=NaN;
                end
            end
        end
        q=quiver(LG,TI,-F.*100,f.*100,2.5,'k.');
        q.ShowArrowHead = 'off';

    end
    

    colormap(m_colmap('diverging',256));
        
    bar_axis = [data_axis{h}(1) 0 data_axis{h}(end)];
    colorbar('southoutside','Ticks',bar_axis,FontSize=10)
    xlim([xmin xmax]);

%     hold on
    bndry_lon=[210 230 230 210 210];
    bndry_time=[time_h(157) time_h(157) time_h(181) time_h(181) time_h(157)];
    line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--');
    bndry_lon=[220 220];
%     % bndry_time=[time(157) time(181)];
%     % line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
%     % box on
%     hold off
end


saveas(gcf,fullfile("results",savename));

