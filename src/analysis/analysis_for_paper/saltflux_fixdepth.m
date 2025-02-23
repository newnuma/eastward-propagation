h=8;
rho=1000; dt=60*60*24*31;
salt = squeeze(sallsal(:,:,1,:));

sb150.flux.v = ((evp_pre.evp.v - evp_pre.pre.v).*salt)./(rho.*pres(h))*dt;
sb150.flux  = anomaly(mlsb.flux);

LO=numel(slon); LA=numel(slat);TIM=numel(time);
m1=NaN(LO,LA,TIM);
for t=2:TIM
    m1(:,:,t)=(Salt.d10_150.v(:,:,t-1)+Salt.d10_150.v(:,:,t))/2;
end

Tmd=NaN(LO,LA,TIM);
for t=1:TIM-1
    Tmd(:,:,t)=m1(:,:,t+1)-m1(:,:,t);
end

sb150.dt.v = Tmd;
sb150.dt = anomaly(mlsb.dt);

