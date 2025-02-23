TIM = numel(time);
cp=3.99*1000; rho=1025; dt=60*60*24*31;

m1=NaN(141,91,TIM);
for t=2:TIM
    m1(:,:,t)=(Salt.mlm.v(:,:,t-1)+Salt.mlm.v(:,:,t))/2;
end

Tmd=NaN(141,91,TIM);
for t=1:TIM-1
    Tmd(:,:,t)=m1(:,:,t+1)-m1(:,:,t);
end

mlsb.dt.v = Tmd;
mlsb.dt = anomaly(mlsb.dt);
