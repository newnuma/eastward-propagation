addpath 'C:\Program Files\MATLAB\R2022a\toolbox\m_map';

blon=92:111;%%
blat=61:70; bp=1:11; pres_lin=(10:5:200)';%%
bts=time(144);bte=time(193);axislow=-2; axishigh=2;
x=salltempa;
% ylim=[-150 -10];


B1tempa=mean(x(blon,blat,bp,:),[1 2],'includenan');  %%
B1tempa1=squeeze(B1tempa);

B1poda=mean(sallpod(blon,blat,bp,:),[1 2],'includenan');
B1poda1=squeeze(B1poda);

allsst1=permute(B1poda1,[2 1]);
allsst3=array2timetable(allsst1,'RowTimes',time);
mm1=groupsummary(allsst3,'Time','monthofyear','mean');
mm2=table2array(mm1(:,3:end));
mm3=reshape(mm2,[12 numel(bp)]);
B1podmc=permute(mm3,[2 1]);
B1podmc1=repmat(B1podmc,[1 1 22]);


z2 = [10;20;30;50;75;100;125;150;200;250;300]';
B1tenpa_lin1 = zeros(numel(pres_lin),numel(time));
B1pod_lin1 = zeros(numel(pres_lin),numel(time));
B1podmc_lin1 = zeros(numel(pres_lin),numel(time));

for t = 1:numel(time)

    B1tenpa_lin1(:,t) = interp1(pres(bp),B1tempa1(:,t),pres_lin);
    B1pod_lin1(:,t) = interp1(pres(bp),B1poda1(:,t),pres_lin);
    B1podmc_lin1(:,t) = interp1(pres(bp),B1podmc1(:,t),pres_lin);

end

B1tenpa_lin=permute(B1tenpa_lin1,[2 1]);
B1pod_lin=permute(B1pod_lin1,[2 1]);
B1podmc_lin=permute(B1podmc_lin1,[2 1]);

TIM=repelem(time,1,numel(pres_lin));
PR1=repelem(pres_lin,1,numel(time));
PR2=PR1';

%B1tenpa_lin(132,:)=NaN; B1tenpa_lin(204,:)=NaN;  %B1tenpa_lin(:,44)=NaN;
figure;
figure_size = [ 0, 0, 500,230 ];
set(gcf, 'Position', figure_size);
box on
D=pcolor(TIM,-1*PR2,B1tenpa_lin);
%title('3月','FontSize',20);  %%
caxis([axislow axishigh]);           %%
clear axislow axishigh
yticks([-150:50:-50]);
yticklabels({'150','100','50','0'});
ax=gca; c=ax.TickDir; ax.TickDir='both';
ylabel('depth[m]');
D.EdgeColor='flat';
xlim([bts bte]);
ylim([-200 -10]);
colormap(m_colmap('diverging',256));
%xtickformat('yyyy-MM');
%colorbar
%colormap(m_colmap('jet'));

clear days
H=squeeze(B1pod_lin);
D1=time-datetime(2001,1,15);
DT=days(D1);
TIMs=repelem(DT,1,numel(pres_lin));
H2=squeeze(B1podmc_lin);

hold on
F=squeeze(mean(mldD(blon,blat,:),[1 2],'includenan'));
F1=F';
plot(time,-1*F1,'g','LineWidth',1)
[C,h]=contour(TIMs,-1*PR2,H,'black','ShowText','off','LineWidth',0.7);
w=h.LevelList;
h.LevelList=[25 25.5 26];
clabel(C,h,'FontSize',8);

[C,h]=contour(TIMs,-1*PR2,H2,'k--','ShowText','off','LineWidth',0.7);
w=h.LevelList;
h.LevelList=[25 25.5 26];


bndry_lon=[-10 -10 -150 -150 -10];
bndry_time=[DT(157) DT(181) DT(181) DT(157) DT(157)];
line(bndry_time,bndry_lon,'color','y','linewi',1,'LineStyle','--');


% mc1=repmat(mldDmc,[1 1 20]);
% F=squeeze(mean(mc1(blon,blat,:),[1 2]));
% F1=F';
% plot(time,-1*F1,'k--','LineWidth',1)
%
% mc1=repmat(iso26mc,[1 1 20]);
% F=squeeze(mean(mc1(blon,blat,:),[1 2]));
% F1=F';
% plot(time,-1*F1,'k--','LineWidth',0.5)
%
% mc1=repmat(iso255mc,[1 1 20]);
% F=squeeze(mean(mc1(blon,blat,:),[1 2]));
% F1=F';
% plot(time,-1*F1,'k--','LineWidth',0.5)
%
%
% mc1=repmat(iso263mc,[1 1 20]);
% F=squeeze(mean(mc1(blon,blat,:),[1 2],'includenan'));
% F1=F';
% plot(time,-1*F1,'k--','LineWidth',0.5)
hold off

clear B1pod_lin B1pod_lin1 B1poda B1poda1 B1tempa B1tempa B1tempa_lin B1tempa_lin1



