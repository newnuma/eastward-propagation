timelange=(637:912);
lonlange=(49:105);
latlange=(8:45);

longitude=ncread('slp.mon.mean.nc','lon');   
latitude=ncread('slp.mon.mean.nc','lat');
Times=ncread('slp.mon.mean.nc','time');
lh=ncread('slp.mon.mean.nc','slp');


times=caldays(Times/24)+calyears(1800)+caldays(1)+calmonths(1); %アルゴデータ：1900年から月
times=datetime(datevec(times));

lh=lh(lonlange,latlange,timelange);


times=times(timelange);
longitude=longitude(lonlange);
latitude=latitude(latlange);


lh_lin = NaN(numel(slon),numel(latitude),numel(time));


for t = 1:numel(time)
    for lat=1:numel(latlange)        
        lh_lin(:,lat,t)  = interp1(longitude,lh(:,lat,t),slon);
    end         
end


lh_lin = permute(lh_lin,[2 1 3]);

lh_lin2 = NaN(numel(slat),numel(slon),numel(time)); 


 for t = 1:numel(time)
    for lo=1:numel(slon)        
        lh_lin2(:,lo,t)  = interp1(latitude,lh_lin(:,lo,t),slat);
    end         
 end


slp.v = permute(lh_lin2,[2 1 3]);

clear ssf_lin ssf_lin2

