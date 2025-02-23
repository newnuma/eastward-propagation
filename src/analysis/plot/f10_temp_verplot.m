addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';
blat=61:70; bp=1:13; pres_lin=(10:10:500)';xmin=190; xmax=233;
figure;
figure_size = [ 0, 0, 500,500 ];
set(gcf, 'Position', figure_size);
row = 2; col = 1; % subplot列数
left_m = 0.1; bot_m = 0.1; % 下側余白の割合
ver_r = 1.35; col_r = 1.13; 

l=61:70; y=13;m=3;%% y年＋ｍか月
for h=1:2
    
       ax(h) = axes('Position',...
      [(1-left_m)*(mod(h-1,col))/col + left_m ,...
      (1-bot_m)*(1-ceil(h/col)/(row)) + bot_m ,...
      (1-left_m)/(col*col_r ),(1-bot_m)/(row*ver_r)] );


B1tempa=mean(salltempa(:,blat,bp,m+12*y),[2 4],'omitnan');  %%
B1tempa1=(squeeze(B1tempa))';
%B1tempa1=double(B1tempa1);

B1sala=mean(sallsala(:,blat,bp,m+12*y),[2 4],'omitnan');  %%
B1sala1=(squeeze(B1sala))';
%B1sala1=double(B1tempa1);

B1pod=mean(sallpod(:,blat,bp,m+12*y),[2 4],'omitnan');  %%
B1pod1=(squeeze(B1pod))';

B1podmc=mean(sallpoda(:,blat,bp,m+12*y),[2 4],'omitnan');  %%
B1podmc1=(squeeze(B1podmc))';
%B1pod1=double(B1pod1);
 
%z2 = [10;20;30;50;75;100;125;150;200;250;300]';
B1tempa_lin1 = zeros(numel(pres_lin),numel(slon));   
B1pod_lin1 = zeros(numel(pres_lin),numel(slon));  
B1sal_lin1 = zeros(numel(pres_lin),numel(slon)); 
B1podmc_lin1 = zeros(numel(pres_lin),numel(slon));  
for t = 1:numel(slon)
        
 B1tempa_lin1(:,t) = interp1(pres(bp),B1tempa1(:,t),pres_lin);
 B1pod_lin1(:,t) = interp1(pres(bp),B1pod1(:,t),pres_lin);   
 B1sal_lin1(:,t) = interp1(pres(bp),B1sala1(:,t),pres_lin); 
 B1podmc_lin1(:,t) = interp1(pres(bp),B1podmc1(:,t),pres_lin);  
end
B1pod_lin=permute(B1pod_lin1,[2 1]);
PD=B1pod_lin;
PD(xmin-119:xmin-118,:)=NaN; PD(xmax-118,:)=NaN; 
B1podmc_lin=permute(B1podmc_lin1,[2 1]);
PDmc=B1podmc_lin;
%PDmc(xmin-119:xmin-118,:)=NaN; PDmc(xmax-118,:)=NaN; 
LG=repelem(slon,1,numel(pres_lin));
PR1=repelem(pres_lin,1,141);
PR=PR1';
 
 if h==2
B1tempa_lin=permute(B1tempa_lin1,[2 1]);
HD=B1tempa_lin;
%HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN;  HD(:,44)=NaN;
D=pcolor(LG,-1*PR,HD);
caxis([-2.5 2.5]);
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',8.5)
% title(['(d)水温偏差(',num2str(y+2001),'/',num2str(m),')'],'fontsize',12);

 elseif h==3 
B1sala_lin=permute(B1sal_lin1,[2 1]);
HD=B1sala_lin;   
%HD(xmin-119,:)=NaN; HD(xmax-119,:)=NaN;  HD(:,44)=NaN;
D=pcolor(LG,-1*PR,HD);
xlabel('longitude');
caxis([-0.5 0.5000001]);
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',8.5)
title(['(f)塩分偏差(',num2str(y+2001),'/',num2str(m),')'],'FontSize',12);
 else

D=pcolor(LG,-1*PR,PDmc);
caxis([-0.5 0.5000001]);
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',8.5)
% title(['(b)密度偏差(',num2str(y+2001),'/',num2str(m),')'],'FontSize',12);
 end


D.EdgeColor='flat';
 xlim([xmin xmax]);
 ylim([-200 -0]);
colormap(m_colmap('diverging'));
xticks([180 190 200 210 220 230])
xticklabels({'180\circ', '170\circW', '160\circW', '150\circW ','140\circW ','130\circW '})
yticks([-400:50:-50]);
yticklabels({'400','350','300','250','200','150','100','50'});
ax=gca; c=ax.TickDir; ax.TickDir='both';


ylabel('depth[m]');



%title([num2str(m),'月'],'FontSize',12);
% c = colorbar;
% c.Label.String = 'σ(kg/m^3)';
hold on
 
[C,h]=contour(LG,-1*PR,PD,'black','ShowText','on','LineWidth',0.4);
w=h.LevelList;
h.LevelList=[25.5 26];
clabel(C,h,'FontSize',7);

% [C,h]=contour(LG,-1*PR,PDmc,'k--','ShowText','off','LineWidth',0.4);
% w=h.LevelList;
% h.LevelList=[26.3];
% clabel(C,h,'FontSize',7);


F=squeeze(mean(mldD(xmin-118:xmax-119,blat,m+12*y),[2],'omitnan'));
F1=F';
plot(slon(xmin-118:xmax-119),-1*F1,'g-','LineWidth',1);

F=squeeze(mean(mldDmc(xmin-118:xmax-119,blat,m),[2],'omitnan'));
F1=F';
plot(slon(xmin-118:xmax-119),-1*F1,'g--','LineWidth',1)
% 
F=squeeze(mean(iso255mc(:,blat,m),[2]));
F1=F';
plot(slon,-1*F1,'k--','LineWidth',0.5)

F=squeeze(mean(iso26mc(:,blat,m),[2]));
F1=F';
plot(slon,-1*F1,'k--','LineWidth',0.5)
% 
% F=squeeze(mean(iso263mc(:,blat,m),[2]));
% F1=F';
% plot(slon,-1*F1,'k--','LineWidth',0.5)
% 
% F=squeeze(mean(iso263mc(:,blat,m),[2]));
% F1=F';
% plot(slon,-1*F1,'k--','LineWidth',0.5)
% 
% F=squeeze(mean(iso265mc(:,blat,m),[2]));
% F1=F';
% plot(slon,-1*F1,'k--','LineWidth',0.5)

% F=squeeze(mean(iso263(:,blat,m+12*y),[2]));
% F1=F';
% plot(slon,-1*F1,'k--','LineWidth',0.5)

bndry_lon=[210 230 230 210 210];
bndry_d=[-5 -5 -300 -300 -5];
line(bndry_lon,bndry_d,'color','y','linewi',1,'LineStyle','--');

% bndry_lon=[220 220];
% bndry_d=[-5 -300 ];
% line(bndry_lon,bndry_d,'color','y','linewi',1,'LineStyle','--');

% D=zeros(141);
% D(:)=-300;
% plot(slon,D,'k--','LineWidth',0.1);
% 

end
saveas(gcf,'verplot.png');
clear B1pod B1pod1 B1podmc1 B1podmc B1podmc_lin1 B1pod_lin1 PD PDmc