function flux = salt_flux(pres_index)
%  海面の塩分収支収支　蒸発-降水
%   Inputs:
%       pres_index  : 収支を計算する深さ(number 例:8→0~150m)。混合層深度の場合は"mld"
%  
%   mlab.flux = salt_flux("mld")

pres = evalin("base","pres");
sallsal = loadData("base_data\sallsal.mat","sallsal");
evp_pre = loadData("analysis\evp_pre.mat","evp_pre");
mld = loadData("analysis\mld.mat","mld");


rho=1000; dt=60*60*24*31;
salt = squeeze(sallsal(:,:,1,:));

if pres_index == "mld"
    flux.v = ((evp_pre.evp.v - evp_pre.pre.v).*salt)./(rho.*mld.depth)*dt;
else
    flux.v = ((evp_pre.evp.v - evp_pre.pre.v).*salt)./(rho.*pres(str2double(pres_index)))*dt;
end
flux = anomaly(flux);




