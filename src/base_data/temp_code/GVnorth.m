addpath C:\Users\ninum\Documents\MATLAB\GSW\gsw_matlab_v3_06_13
e_r = 6371000;
pi180 = pi/180;
rho=1025; %密度(kg/m^3)　
R=6371000; % 地球半径（ｍ）
deg2rad = pi/180;
omega = 7.292115e-5; %2π/T (1/s)
f=2*omega*sin(slat*deg2rad);
f1=(repelem(f,1,140))';

dista=NaN(91,1);
dista(:,1)=cos(slat(:)*deg2rad)*deg2rad*e_r;

dist=(repelem(dista,1,numel(slon)-1))';
mid_long = 0.5*(slon(2:141,1) + slon(1:140,1));
TIM=numel(time);


gv_n=nan(140,91,13,TIM);

for n=1:TIM
    for i=1:13
        gv_n(:,:,i,n) = (squeeze(salldh(2:141,:,i,n)) - squeeze(salldh(1:140,:,i,n)))./(dist.*f1);
    end
end

gv_nl2 = zeros(141,91,13,TIM);
for n=1:TIM
    for lat = 1:91
        for d = 1:13
            gv_nl2(:,lat,d,n) = interp1(mid_long,gv_n(:,lat,d,n),slon);

        end
    end
end

gv.n=gv_nl2;

if gv.n(:,:,:,:)==inf
    gv.n(:,:,:,:) = NaN;
end

