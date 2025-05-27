function flux = air_sea_flux(pres_index)

cp=3.99*1000; rho=1025; dt=60*60*24*31;

pres = evalin("base","pres");
ssf= loadData("base_data\ssf.mat","ssf");
mld = loadData("analysis\mld.mat","mld");


if pres_index == "mld"
    flux.v = -ssf./(mld.depth*rho*cp)*dt;
else
    flux.v = -ssf./(pres(str2double(pres_index))*rho*cp)*dt;
end
flux = anomaly(flux);