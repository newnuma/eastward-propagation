timelange=(637:900);
lonlange=(49:105);
latlange=(8:45);

longitude=ncread('slp.mon.mean.nc','lon');   
latitude=ncread('slp.mon.mean.nc','lat');
Times=ncread('slp.mon.mean.nc','time');
slp=ncread('slp.mon.mean.nc','slp');

times=caldays(Times/24)+calyears(1800)+caldays(1)+calmonths(1); %アルゴデータ：1900年から月
times=datetime(datevec(times));

slp=slp(lonlange,latlange,timelange);
times=times(timelange);
longitude=longitude(lonlange);
latitude=latitude(latlange);

slp_lin = NaN(numel(slon),numel(latitude),numel(time));   

for t = 1:numel(time)
    for lat=1:numel(latlange)     
        slp_lin(:,lat,t) = interp1(longitude,slp(:,lat,t),slon);
    end         
end

slp_lin = permute(slp_lin,[2 1 3]);


slp_lin2 = NaN(numel(slat),numel(slon),numel(time));   


 for t = 1:numel(time)
    for lo=1:numel(slon)
        
        slp_lin2(:,lo,t) = interp1(latitude,slp_lin(:,lo,t),slat);

    end         
 end

slp=permute(slp_lin2,[2 1 3]);

clear slp_lin slp_lin2 

