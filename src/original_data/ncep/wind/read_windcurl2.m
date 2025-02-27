timelange=(637:912);
lonlange=(64:140);
latlange=(10:59);

longitude=ncread('uflx.sfc.mon.mean.nc','lon');   
latitude=ncread('uflx.sfc.mon.mean.nc','lat');
Times=ncread('uflx.sfc.mon.mean.nc','time');
uf=ncread('uflx.sfc.mon.mean.nc','uflx');
vf=ncread('vflx.sfc.mon.mean.nc','vflx');

times=caldays(Times/24)+calyears(1800)+caldays(1)+calmonths(1); %アルゴデータ：1900年から月
times=datetime(datevec(times));

uf=-uf(lonlange,latlange,timelange);
vf=vf(lonlange,latlange,timelange);
times=times(timelange);
longitude=longitude(lonlange);
latitude=latitude(latlange);
latitude = flip(latitude,1);

uf1=permute(uf,[2 1 3]);
vf1=permute(vf,[2 1 3]);
curl2 = NaN(numel(longitude),numel(latitude),numel(time));  
for i=1:numel(time)
    curl2(:,:,i) = wsc(latitude,longitude,uf1(:,:,i),vf1(:,:,i));
end


uf_lin = NaN(numel(slon),numel(latitude),numel(time));  
vf_lin = NaN(numel(slon),numel(latitude),numel(time)); 
curl_lin = NaN(numel(slon),numel(latitude),numel(time)); 

for t = 1:numel(time)
    for lat=1:numel(latlange)
        
        uf_lin(:,lat,t)  = interp1(longitude,uf(:,lat,t),slon);
        vf_lin(:,lat,t)  = interp1(longitude,vf(:,lat,t),slon);
        curl_lin(:,lat,t)  = interp1(longitude,curl2(:,lat,t),slon);

    end         
end

uf_lin = permute(uf_lin,[2 1 3]);
vf_lin = permute(vf_lin,[2 1 3]);
curl_lin = permute(curl_lin,[2 1 3]);

uf_lin2 =  NaN(numel(slat),numel(slon),numel(time)); 
vf_lin2 =  NaN(numel(slat),numel(slon),numel(time)); 
curl_lin2 =  NaN(numel(slat),numel(slon),numel(time)); 

 for t = 1:numel(time)
    for lo=1:numel(slon)     

        uf_lin2(:,lo,t)  = interp1(latitude,uf_lin(:,lo,t),slat);
        vf_lin2(:,lo,t)  = interp1(latitude,vf_lin(:,lo,t),slat);
        curl_lin2(:,lo,t)  = interp1(latitude,curl_lin(:,lo,t),slat);
        
    end         
 end
curl_test.v = permute(curl_lin2,[2 1 3]);

% wind_moment.x = -permute(uf_lin2,[2 1 3]);%東向正に変更
% wind_moment.y=permute(vf_lin2,[2 1 3]);
% 
% clear slp_lin slp_lin2 uf_lin uf_lin2 vf_lin vf_lin2
% 
% uf1=permute(wind_moment.x,[2 1 3]);
% vf1=permute(wind_moment.y,[2 1 3]);
% wind_moment.curl = NaN(numel(slon),numel(slat),numel(time)); 
% 
% for i=1:numel(time)
%     wind_moment.curl(:,:,i) = wsc(slat,slon,uf1(:,:,i),vf1(:,:,i));
% end

% clear uf1 vf1