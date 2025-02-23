addpath C:\Users\ninum\Documents\MATLAB\GSW\gsw_matlab_v3_06_13
LO=numel(slon); LA=numel(slat); PR=numel(rp); TI=numel(time);
e_r = 6371000;
pi180 = pi/180;
rho=1025; %密度(kg/m^3)　
R=6371000; % 地球半径（ｍ）
deg2rad = pi/180;
omega = 7.292115e-5; %2π/T (1/s)

dista=NaN(90,1);
dista(:,1)=deg2rad*e_r;

dist=(repelem(dista,1,numel(slon)))';
mid_lat = 0.5*(slat(2:91,1) + slat(1:90,1));
mid_long = 0.5*(slon(2:141,1) + slon(1:140,1));

f=2*omega*sin(mid_lat*deg2rad);
f1=(repelem(f,1,141))';

gv_w=nan(LO,90,13,TIM);

for n=1:TI
    for i=1:13
        gv_w(:,:,i,n) = (squeeze(salldh(:,1:90,i,n)) - squeeze(salldh(:,2:91,i,n)))./(dist.*f1);
    end
end

gv_w=permute(gv_w,[2 1 3 4]);
gv_wl2 = zeros(91,LO,13,TI);
for n=1:TI
    for lon = 1:141
        for d = 1:13
            gv_wl2(:,lon,d,n) = interp1(mid_lat,gv_w(:,lon,d,n),slat);

        end
    end
end

%東向正に変更
gv.e=-permute(gv_wl2,[2 1 3 4]);

if gv.e(:,:,:,:)==inf
    gv.e(:,:,:,:) = NaN;
end

if gv.e(:,:,:,:)==-inf
    gv.e(:,:,:,:) = NaN;
end

