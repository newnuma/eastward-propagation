timelange=(637:912);
lonlange=(64:140);
latlange=(10:59);

longitude=ncread('prate.sfc.mon.mean.nc','lon');   
latitude=ncread('prate.sfc.mon.mean.nc','lat');
Times=ncread('prate.sfc.mon.mean.nc','time');

skt=ncread('skt.sfc.mon.mean.nc','skt');
prcp=ncread('prate.sfc.mon.mean.nc','prate');
% evpr=ncread('pevpr.sfc.mon.mean.nc','pevpr');

times=caldays(Times/24)+calyears(1800)+caldays(1)+calmonths(1); %アルゴデータ：1900年から月
times=datetime(datevec(times));

lh=skt(lonlange,latlange,timelange);
sh=prcp(lonlange,latlange,timelange);
% lw=evpr(lonlange,latlange,timelange);

times=times(timelange);
longitude=longitude(lonlange);
latitude=latitude(latlange);


lh_lin = NaN(numel(slon),numel(latitude),numel(time));
sh_lin = NaN(numel(slon),numel(latitude),numel(time));
% lw_lin = NaN(numel(slon),numel(latitude),numel(time));


for t = 1:numel(time)
    for lat=1:numel(latlange)        
        lh_lin(:,lat,t)  = interp1(longitude,lh(:,lat,t),slon);
        sh_lin(:,lat,t)  = interp1(longitude,sh(:,lat,t),slon);
%         lw_lin(:,lat,t)  = interp1(longitude,lw(:,lat,t),slon);
    end         
end

lh_lin = permute(lh_lin,[2 1 3]);
sh_lin = permute(sh_lin,[2 1 3]);
% lw_lin = permute(lw_lin,[2 1 3]);

lh_lin2 = NaN(numel(slat),numel(slon),numel(time)); 
sh_lin2 = NaN(numel(slat),numel(slon),numel(time)); 
% lw_lin2 = NaN(numel(slat),numel(slon),numel(time)); 


 for t = 1:numel(time)
    for lo=1:numel(slon)        
        lh_lin2(:,lo,t)  = interp1(latitude,lh_lin(:,lo,t),slat);
        sh_lin2(:,lo,t)  = interp1(latitude,sh_lin(:,lo,t),slat);
%         lw_lin2(:,lo,t)  = interp1(latitude,lw_lin(:,lo,t),slat);
    end         
 end


evp.skt = permute(lh_lin2,[2 1 3]);
evp.prcp = permute(sh_lin2,[2 1 3]);
% evp.evpr = permute(lw_lin2,[2 1 3]);

clear ssf_lin ssf_lin2
