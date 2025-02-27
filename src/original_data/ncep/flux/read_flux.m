timelange=(637:912);
lonlange=(64:140);
latlange=(10:59);

longitude=ncread('nlwrs.sfc.mon.mean.nc','lon');   
latitude=ncread('nlwrs.sfc.mon.mean.nc','lat');
Times=ncread('nlwrs.sfc.mon.mean.nc','time');
lh=ncread('lhtfl.sfc.mon.mean.nc','lhtfl');
lw=ncread('nlwrs.sfc.mon.mean.nc','nlwrs');
sw=ncread('nswrs.sfc.mon.mean.nc','nswrs');
sh=ncread('shtfl.sfc.mon.mean.nc','shtfl');

a=squeeze(sh(:,35,:));

times=caldays(Times/24)+calyears(1800)+caldays(1)+calmonths(1); %アルゴデータ：1900年から月
times=datetime(datevec(times));

lh=lh(lonlange,latlange,timelange);
sh=sh(lonlange,latlange,timelange);
lw=lw(lonlange,latlange,timelange);
sw=sw(lonlange,latlange,timelange);

ssf=lh+lw+sw+sh;

times=times(timelange);
longitude=longitude(lonlange);
latitude=latitude(latlange);


ssf_lin = NaN(numel(slon),numel(latitude),numel(time));  
lh_lin = NaN(numel(slon),numel(latitude),numel(time));
sh_lin = NaN(numel(slon),numel(latitude),numel(time));
sw_lin = NaN(numel(slon),numel(latitude),numel(time));
lw_lin = NaN(numel(slon),numel(latitude),numel(time));


for t = 1:numel(time)
    for lat=1:numel(latlange)        
        ssf_lin(:,lat,t)  = interp1(longitude,ssf(:,lat,t),slon);
        lh_lin(:,lat,t)  = interp1(longitude,lh(:,lat,t),slon);
        sh_lin(:,lat,t)  = interp1(longitude,sh(:,lat,t),slon);
        sw_lin(:,lat,t)  = interp1(longitude,sw(:,lat,t),slon);
        lw_lin(:,lat,t)  = interp1(longitude,lw(:,lat,t),slon);

    end         
end

ssf_lin = permute(ssf_lin,[2 1 3]);
lh_lin = permute(lh_lin,[2 1 3]);
sh_lin = permute(sh_lin,[2 1 3]);
sw_lin = permute(sw_lin,[2 1 3]);
lw_lin = permute(lw_lin,[2 1 3]);

ssf_lin2 = NaN(numel(slat),numel(slon),numel(time)); 
lh_lin2 = NaN(numel(slat),numel(slon),numel(time)); 
sh_lin2 = NaN(numel(slat),numel(slon),numel(time)); 
sw_lin2 = NaN(numel(slat),numel(slon),numel(time)); 
lw_lin2 = NaN(numel(slat),numel(slon),numel(time)); 


 for t = 1:numel(time)
    for lo=1:numel(slon)        
        ssf_lin2(:,lo,t)  = interp1(latitude,ssf_lin(:,lo,t),slat);
        lh_lin2(:,lo,t)  = interp1(latitude,lh_lin(:,lo,t),slat);
        sh_lin2(:,lo,t)  = interp1(latitude,sh_lin(:,lo,t),slat);
        sw_lin2(:,lo,t)  = interp1(latitude,sw_lin(:,lo,t),slat);
        lw_lin2(:,lo,t)  = interp1(latitude,lw_lin(:,lo,t),slat);
    end         
 end

flux.total = permute(ssf_lin2,[2 1 3]);
flux.lh = permute(lh_lin2,[2 1 3]);
flux.sh = permute(sh_lin2,[2 1 3]);
flux.sw = permute(sw_lin2,[2 1 3]);
flux.lw = permute(lw_lin2,[2 1 3]);

clear ssf_lin ssf_lin2

