function newdata = depth_mean(data,top_index,bottom_index)


% 深さD1～D2の平均(水温、塩分、密度…)
LO=numel(slon); LA=numel(slat); TI=numel(time); YE=numel(year);

%pres
%1  2  3  4  5  6   7   8   9   10  11  12  13  14
%10,20,30,50,75,100,125,150,200,250,300,400,500,600m,...

d1=top_index; d2=bottom_index; %%深さの範囲
D1=pres(d1); D2=pres(d2); 
pres1=pres(d1:d2);

all15=data(:,:,d1:d2,:); %%4次元データ
all15=permute(all15,[1 2 4 3]); 
all15=reshape(all15,[LO*LA*TI (d2-d1+1)]);  %lon*lat*time=10713600

hc=cell(LO*LA*TI,1);
for i=1:LO*LA*TI
    hc{i,1}=trapz(pres1,all15(i,:))/(D2-D1);
end
allhc1=cat(1,hc{:});

allhc2=reshape(allhc1,[LO LA TI 1]);
newdata = squeeze(allhc2);  %%深さ平均

clear all15 allhc1 allhc2 d1 d2 D1 D2
