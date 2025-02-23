addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

d=8; xmin=150; xmax=235; axmin=[-0.3 0.3];
LG=repelem(slon,1,numel(time));
TI1=repelem(Times,1,141);TI=TI1';
figure;
figure_size = [ 0, 0, 900,630 ];
set(gcf, 'Position', figure_size);
row = 1; col = 3; % subplot列数
left_m = 0.1; bot_m = 0.1; % 下側余白の割合
ver_r = 1.1; % 縦方向余裕 (値が大きいほど各axes間の余白が大きくなる)
col_r = 1.2; 
e_r = 6371000;
l=61:70; LD=(60*60*24*100*360)/(e_r*2*pi*cos(45/180*pi));

for h=1:3
       ax(h) = axes('Position',...
      [(1-left_m)*(mod(h-1,col))/col + left_m ,...
      (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
      (1-left_m)/(col*col_r ),(1-bot_m)/(row*ver_r)] );
if h==1
HD1=mean(Temp.iso260.a(:,l,:),2,'omitnan');
HD=squeeze(HD1);
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
D=pcolor(LG,TI,HD);
hold on
HD1=mean(Temp.iso260.a(:,l,:),2,'omitnan');
HD=squeeze(HD1);
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
D=pcolor(LG,TI,HD);
colormap(m_colmap('diverging',256));
title('(c) 水温偏差(26.0σ)','FontSize',15);
ytickangle(90);
ylabel('year');
xticks([150 170 190 210 230])
xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})
yticks([Times(12+1) Times(12*5+1) Times(12*9+1) Times(12*13+1) Times(12*17+1)])
yticklabels({'2002', '2006', '2010', '2014 ','2018'})
D.LineWidth = 0.0001;
D.EdgeColor=[0.3 0.3 0.3];

HN=Temp.iso260.n(:,61:70,:);
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
 caxis([-1.5 1.5]);

% geov267_4m=NaN(141,91,240);
% for i=5:8:137 
%     for j=1:91
%         for k=5:8:235
%         
%      geov267_4m(i,j,k)=squeeze(mean(geoV26(i-4:i+4,j,k-4:k+4),[1 3])); %%%
%      
%         end
%     end
% end
% FD=geov267_4m(:,61:70,:);%S20N+
% FD1=squeeze(mean(FD,2,'omitnan'));
% F=squeeze(FD1).*LD;
% f=zeros(141,240);
% f(:,:)=(Times(240)-Times(1))/141;
% for i=1:141
%     for j=1:240
% if isnan(F(i,j))==1
%     f(i,j)=NaN;
% end
%     end
% end
% q=quiver(LG,TI,-F.*100,f.*100,2.5,'k.');
% q.ShowArrowHead = 'off';



elseif h==2 
HD1=mean(Temp.iso263.a(:,l,:),2,'omitnan');
HD=squeeze(HD1);
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
D=pcolor(LG,TI,HD);
hold on
HD1=mean(Temp.iso263.a(:,l,:),2,'omitnan');
HD=squeeze(HD1);
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
D=pcolor(LG,TI,HD);
title('(d) 深度偏差(26.0σ)','FontSize',15);

ytickangle(90);
yticks([Times(12+1) Times(12*5+1) Times(12*9+1) Times(12*13+1) Times(12*17+1)])
yticklabels({'2002', '2006', '2010', '2014 ','2018'})
caxis([-30 30]);
D.LineWidth = 0.0001;
D.EdgeColor=[0.3 0.3 0.3];


HN=Temp.iso263.n(:,61:70,:);
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
 caxis([-30 30]);

% geov267_4m=NaN(141,91,240);
% for i=5:8:136 
%     for j=1:91
%         for k=5:8:235
%         
%      geov267_4m(i,j,k)=squeeze(mean(geoV26(i-4:i+4,j,k-4:k+4),[1 3])); %%%
%      
%         end
%     end
% end
% FD=geov267_4m(:,61:70,:);%S20N+
% FD1=squeeze(mean(FD,2,'omitnan'));
% F=squeeze(FD1).*LD;
% f=zeros(141,240);
% f(:,:)=(Times(240)-Times(1))/141;
% for i=1:141
%     for j=1:240
% if isnan(F(i,j))==1
%     f(i,j)=NaN;
% end
%     end
% end
% q=quiver(LG,TI,-F.*100,f.*100,2.5,'k.');
% q.ShowArrowHead = 'off';



elseif h==3  
HD1=mean(Temp.iso267.a(:,l,:),2,'omitnan');
HD=squeeze(HD1);
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;
D=pcolor(LG,TI,HD);
hold on
HD1=mean(Temp.iso267.a(:,l,:),2,'omitnan');
HD=squeeze(HD1);
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN; HD(:,1)=NaN; HD(:,240)=NaN; HD(:,239)=NaN;

D=pcolor(LG,TI,HD);
colormap(m_colmap('diverging',256));
title('(c)26.7σ','FontSize',15);
yticks([Times(12+1) Times(12*5+1) Times(12*9+1) Times(12*13+1) Times(12*17+1)])
yticklabels({'2002', '2006', '2010', '2014 ','2018'}) 
ytickangle(90);
D.LineWidth = 0.0001;
D.EdgeColor=[0.3 0.3 0.3];

HN=Temp.iso267.n(:,61:70,:);
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
 caxis([-0.3 0.3000001]);


geov267_4m=NaN(141,91,240);
for i=5:8:136 
    for j=1:91
        for k=5:8:235
        
     geov267_4m(i,j,k)=squeeze(mean(Gv.iso263.v(i-4:i+4,j,k-4:k+4),[1 3])); %%%
     
        end
    end
end
FD=geov267_4m(:,61:70,:);%S20N+
FD1=squeeze(mean(FD,2,'omitnan'));
F=squeeze(FD1).*LD;
f=zeros(141,240);
f(:,:)=(Times(240)-Times(1))/141;
for i=1:141
    for j=1:240
if isnan(F(i,j))==1
    f(i,j)=NaN;
end
    end
end
q=quiver(LG,TI,-F.*100,f.*100,2.5,'k.');
q.ShowArrowHead = 'off';
end

 colormap(m_colmap('diverging',256));
xticks([150 170 190 210 230])
xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})   
 D.EdgeColor='flat';
ax=gca; c=ax.TickDir; ax.TickDir='both';
colorbar('southoutside')
xlabel('longitude');
 xlim([xmin xmax]);

% hold on
% bndry_lon=[210 230 230 210 210];
% bndry_time=[Times(157) Times(157) time(181) time(181) time(157)];
% line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--');
% bndry_lon=[220 220];
% bndry_time=[time(157) time(181)];
% line(bndry_lon,bndry_time,'color','y','linewi',1,'LineStyle','--')
% box on
hold off
end

saveas(gcf,'図.png');




