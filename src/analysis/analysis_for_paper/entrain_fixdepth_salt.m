h=8;
data = sallsal(:,:,1:h,:);
LO=numel(slon); LA=numel(slat); TIM=numel(time);

%0~10mを追加、0m=10mとする
data_x=permute(data,[3 1 2 4]);
s_data=permute(data(:,:,1,:),[3 1 2 4]);
data_x=[s_data;data_x];
data_x=permute(data_x,[2 3 1 4]);
pres1 = pres(1:h);
pres1=[0;pres1];

%平均水温
data_x=permute(data_x,[1 2 4 3]); 
data_x=reshape(data_x,[LO*LA*TIM h+1]);
hm_data=cell(LO*LA*TIM,1);
for i=1:LO*LA*TIM
    hm_data{i,1}=trapz(pres1,data_x(i,:))/pres(h);
end
hm_data=cat(1,hm_data{:});
hm_data=reshape(hm_data,[LO LA TIM 1]);

b_data = squeeze(data(:,:,h,:));

entrain_w=NaN(141,91,TIM);
for t = 1:TIM-1
    for lon = slon
        for lat = slat
            entrain_w(lon,lat,t)= -(hm_data(lon,lat,t)-b_data(lon,lat,t))*(wh.d150.v(lon,lat,t))/pres(h);
        end
    end
end

entrain_w(:,:,276)=NaN;
sb150.entrain.v = entrain_w; 
sb150.entrain = anomaly(sb150.entrain);


clear allsst1 allsst2 allsst3 mm1 mm2 mm3 isd1 isd isot isoT2 isot1 te
clear allssty1 allssty21 allssty2 allssty3 allsstay1 allsstay2 allsstay31 allsstay3 allsstay4