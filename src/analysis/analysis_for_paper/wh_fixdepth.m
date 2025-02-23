
h=8;
rho=1025; %密度(kg/m^3)　
R=6371000; % 地球半径（ｍ）
deg2rad = pi/180;
omega = 7.292115e-5; %2π/T (1/s)
f=2*omega*sin(slat*deg2rad);
B=2*omega*cos(slat*deg2rad)/R;

LO=numel(slon); LA=numel(slat); PR=numel(1:h); TIM=numel(time);

%0~10mを追加、0m=10mとする
data = gv.n(:,:,1:h,:);
data_x=permute(data,[3 1 2 4]);
s_data=permute(data(:,:,1,:),[3 1 2 4]);
data_x=[s_data;data_x];
data_x=permute(data_x,[2 3 1 4]);
pres1 = pres(1:h);
pres1=[0;pres1];

%深度方向積分
data_x=permute(data_x,[1 2 4 3]); 
data_x=reshape(data_x,[LO*LA*TIM h+1]);
hm_data=cell(LO*LA*TIM,1);
for i=1:LO*LA*TIM
    hm_data{i,1}=trapz(pres1,data_x(i,:));
end
hm_data=cat(1,hm_data{:});
vgh=reshape(hm_data,[LO LA TIM 1]);

f1=2*omega*sin(slat*deg2rad);
B=2*omega*cos(slat*deg2rad)/R;
B1=(repelem(B,1,141*TIM));
B3=reshape(B1,[91 141 TIM]);
B4=permute(B3,[2 1 3]);

f1=(repelem(f1,1,141*TIM));
f3=reshape(f1,[91 141 TIM]);
f4=permute(f3,[2 1 3]);

uf1=permute(wind_moment.x,[2 1 3]);
vf1=permute(wind_moment.y,[2 1 3]);
curl_tf=NaN(141,91,TIM);

for i=1:TIM
    curl_tf(:,:,i)=wsc(slat,slon,uf1(:,:,i)./f3(:,:,i),vf1(:,:,i)./f3(:,:,i));
end
Wh=curl_tf/rho-B4.*(vgh)./f4;

wh.d150.v = Wh*60*60*24*31; %!!!

for t=1:TIM
    for i=1:141
        for j=1:91
            if wh.d150.v(i,j,t)==Inf
                wh.d150.v(i,j,t)=NaN;
            end
            if wh.d150.v(i,j,t)==-Inf
                wh.d150.v(i,j,t)=NaN;
            end
        end
    end
end

wh.d150 = anomaly(wh.d150);


