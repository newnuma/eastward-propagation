%気候値、偏差、年間平均、年間平均偏差、トレンド除去偏差を求める関数
%[偏差,気候値,年平均,年偏差,偏差(ト除),年偏差(ト除)]＝anomaly_fx(x)
%x：偏差を算出したい3次元データ（経度(LO)×緯度(LA)×時間(TI)）入力

function [a,mc,y,ay] = anomaly_fx(x)

addpath C:\Users\ninum\Documents\MATLAB\argo2022\alldata\temp&salt\2023\data
load("start.mat","slon","slat","time","year");
LO=numel(slon); LA=numel(slat); TI=numel(time); YE=numel(year);%

%気候値、偏差算出
x1=permute(x,[3 1 2]);    
x2=reshape(x1,[TI LO*LA]);     
x3=array2timetable(x2,'RowTimes',time);   
mm1=groupsummary(x3,'Time','monthofyear','mean');   
mm2=table2array(mm1(:,3:end));       
mm3=reshape(mm2,[12 LO LA]);   
mc=permute(mm3,[2 3 1]);    %月ごと気候値
mc1=repmat(mc,[1 1 YE]);   %気候値をデータの年数分。データと同じサイズ

a=x-mc1; %偏差
a2=permute(a,[3 1 2]);
a3=reshape(a2,[TI LO*LA]);     

%年間平均
y1=retime(x3,'yearly','mean');  
y21=timetable2table(y1);
y2=table2array(y21(:,2:end));
y3=reshape(y2,[YE LO LA]);
y=permute(y3,[2 3 1]);  %%

%年平均偏差
ay1=array2timetable(a3,'RowTimes',time); %datatrendどうするか
ay2=retime(ay1,'yearly','mean');
ay31=timetable2table(ay2);
ay3=table2array(ay31(:,2:end));
ay4=reshape(ay3,[YE LO LA]);%25年分
ay=permute(ay4,[2 3 1]);   %%

% y_mc=mean(y,3);
% y_mc1=repmat(y_mc,[1 1 YE]);
% ay_2=y-y_mc1;

clear x1 x2 x3 mm1 mm2 mm3 
clear y1 y21 y2 y3 ay1 ay2 ay31 ay3 ay4
end