addpath 'C:\Program Files\MATLAB\R2020a\toolbox\m_map';
blat=61:70; bp=1:13; pres_lin=(10:10:500)';xmin=145; xmax=237;
figure;
figure_size = [ 0, 0, 800,530 ];
set(gcf, 'Position', figure_size);
row = 2; col = 2; % subplot列数
left_m = 0.1; bot_m = 0.1; % 下側余白の割合
ver_r = 1.25; col_r = 1.13; 

l=61:70;
for h=1:4
    
       ax(h) = axes('Position',...
      [(1-left_m)*(mod(h-1,col))/col + left_m ,...
      (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
      (1-left_m)/(col*col_r ),(1-bot_m)/(row*ver_r)] );

m=3*h;%参照月
B1tempa=mean(sallpod(:,blat,bp,m:12:240),[2 4],'omitnan');  %%
B1tempa1=(squeeze(B1tempa))';
B1tempa1=double(B1tempa1);
 
%z2 = [10;20;30;50;75;100;125;150;200;250;300]';
B1tempa_lin1 = zeros(numel(pres_lin),numel(slon));   

for t = 1:numel(slon)
        
 B1tempa_lin1(:,t) = interp1(pres(bp),B1tempa1(:,t),pres_lin);
              
 end
            
B1tempa_lin=permute(B1tempa_lin1,[2 1]);
HD=B1tempa_lin;
LG=repelem(slon,1,numel(pres_lin));
PR1=repelem(pres_lin,1,141);
PR=PR1';
HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN;  HD(:,44)=NaN;
%figure
D=pcolor(LG,-1*PR,HD);
%title('9月','FontSize',15);
  caxis([24.5 27]);
D.EdgeColor='flat';
 xlim([xmin xmax]);
 ylim([-400 -0]);
colormap(m_colmap('jet'));
xticks([150 170 190 210 230])
xticklabels({'150\circE', '170\circE', '170\circW', '150\circW ','130\circW '})
yticks([-400:50:-50]);
yticklabels({'400','350','300','250','200','150','100','50'});
ax=gca; c=ax.TickDir; ax.TickDir='both';
if h==3||h==4
xlabel('longitude');
end
if h==1||h==3
ylabel('depth[m]');
end
%title([num2str(m),'月'],'FontSize',12);
% c = colorbar;
% c.Label.String = 'σ(kg/m^3)';
hold on
 
 [C,h]=contour(LG,-1*PR,HD,'black','ShowText','on','LineWidth',0.7);
w=h.LevelList;
h.LevelList=[25 25.5 26 26.3 26.5 26.7];
clabel(C,h,'FontSize',8);

F=squeeze(mean(Depth.mld.mc(:,blat,m),[2],'omitnan'));
F1=F';
plot(slon,-1*F1,'w--','LineWidth',1)
end
