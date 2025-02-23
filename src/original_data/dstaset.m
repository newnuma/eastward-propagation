sst=squeeze(salltemp(:,:,1,:));
% [ssta,sstmc,ssty,sstay,sstay2] = anomaly_fx(sst);
[ssta,sstmc,ssty,sstay,sstad,sstady] = anomaly_fx_td(sst);

sss=squeeze(sallsal(:,:,1,:));
% [sssa,sssmc,sssy,sssay,sssay2] = anomaly_fx(sss);
[sssa,sssmc,sssy,sssay,sssad,sssady] = anomaly_fx_td(sss);

spod=squeeze(sallpod(:,:,1,:));
% [sssa,sssmc,sssy,sssay,sssay2] = anomaly_fx(sss);
[spoda,spodmc,spody,spoday,spodad,spodady] = anomaly_fx_td(spod);

% sallpod=allpod(slor,slar,:,:);
% [sala,salmc,saly,salay,salay2] = anomaly_fx(ssal);
%temp150m=squeeze(salltemp(:,:,8,:));
% [sspa,sspmc,sspy,sspay,sspay2] = anomaly_fx(ssp);
 %[temp150ma,temp150mmc,temp150my,temp150may,temp150mad,temp150mady] = anomaly_fx(temp150m);
% [sal150a,sal150mc,sal150y,sal150ay,sal150ad,sal150ady] = anomaly_fx(sal150);
% [isoT26a,isoT26mc,isoT26y,isoT26ay,isoT26ay2] = anomaly_fx(isoT26);
% [iso263a,iso263mc,iso263y,iso263ay,iso263ad,iso263ady] = anomaly_fx(iso263);

% [asfa,asfmc,asfy,asfay] = anomaly_fx(asf);
% [Dtx_mlda,Dtx_mldmc,Dtx_mldy,Dtx_mlday,Dtx_mlday2] = anomaly_fx(Dtx_mld);
% [Dty_mlda,Dty_mldmc,Dty_mldy,Dty_mlday,Dty_mlday2] = anomaly_fx(Dty_mld);
% [ssfa,ssfmc,ssfy,ssfay,ssfay2] = anomaly_fx(ssf);
% [entrain_wa,entrain_wmc,entrain_wy,entrain_way,entrain_way2] = anomaly_fx(entrain_w);
% [Tmda,Tmdmc,Tmdy,Tmday,Tmday2] = anomaly_fx(Tmd);
% [sstTmda,sstTmdmc,sstTmdy,sstTmday,sstTmday2] = anomaly_fx(sstTmd);
% [mldTma,mldTmmc,mldTmdy,mldTmay,mldTmay2] = anomaly_fx(mldTm);
% [mldTba,mldTbmc,mldTby,mldTbay,mldTbay2] = anomaly_fx(mldTb);
% [slpa,slpmc,slpy,slpay,slpad,slpady] = anomaly_fx(slp);
% [curla,curlmc,curly,curlay,curlad,curlady] = anomaly_fx(curltau);
% [tauxa,tauxmc,tauxy,tauxay,tauxay2] = anomaly_fx(taux);
%  [mldDa,mldDmc,mldDy,mldDay,mldDay2] = anomaly_fx(mldD);
% gv_n_10=squeeze(gv_n(:,:,5,:));
% [gv_n_10a,gv_n_10mc,gv_n_10y,gv_n_10ay] = anomaly_fx(gv_n_10);
% % 
% gv_w_10=squeeze(gv_e(:,:,1,:));
% [gv_w_10a,gv_w_10mc,gv_w_10y,gv_w_10ay] = anomaly_fx(gv_w_10);
% [Dmld_Tbxa,Dmld_Tbxmc,Dmld_Tbxy,Dmld_Tbxay,Dmld_Tbxay2] = anomaly_fx(Dmld_Tbx);
% [Dmld_Tbqa,Dmld_Tbqmc,Dmld_Tbqy,Dmld_Tbqay,Dmld_Tbqy2] = anomaly_fx(Dmld_Tbq);
% [mldtbba,mldtbbmc,mldtbby,mldtbbay,mldtbbay2] = anomaly_fx(mldtbb);
% [mldtbb_wha,mldtbb_whmc,mldtbb_why,mldtbb_whay,mldtbb_whay2] = anomaly_fx(mldtbb_wh);
% [wha,whmc,why,whay,whay2] = anomaly_fx(wh);

% 
% [sstTmda,sstTmdmc,sstTmdy,sstTmday,sstTmday2] = anomaly_fx(sstTmd);
% [t50Tmda,t50Tmdmc,t50Tmddy,t50Tmday,t50Tmday2] = anomaly_fx(t50Tmd);
% [t100Tmda,t100Tmdmc,t100Tmdy,t100Tmday,t100Tmday2] = anomaly_fx(t100Tmd);