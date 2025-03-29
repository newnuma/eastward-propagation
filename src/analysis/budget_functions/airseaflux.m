cp=3.99*1000; rho=1025; dt=60*60*24*31;
% ssf=ssf_lin; ssfa=ssfa_lin;

asf=-ssf./(mldD*rho*cp)*dt;

% allsst1=permute(ssf,[3 1 2]);      
% allsst2=reshape(allsst1,[240 141*91]);    
% allsst3=array2timetable(allsst2,'RowTimes',time);   
% mm1=groupsummary(allsst3,'Time','monthofyear','mean');   
% mm2=table2array(mm1(:,3:end));        
% mm3=reshape(mm2,[12 141 91]);        
% ssfmc=permute(mm3,[2 3 1]);              
% ssfmc1=repmat(ssfmc,[1 1 20]); %20年

allsst1=permute(asf,[3 1 2]);      
allsst2=reshape(allsst1,[240 141*91]);    
allsst3=array2timetable(allsst2,'RowTimes',time);   
mm1=groupsummary(allsst3,'Time','monthofyear','mean');   
mm2=table2array(mm1(:,3:end));        
mm3=reshape(mm2,[12 141 91]);        
asfmc=permute(mm3,[2 3 1]);              
asfmc1=repmat(asfmc,[1 1 20]); %20年
asfa=asf-asfmc1;

allsst1=permute(asfa,[3 1 2]);      
allsst2=reshape(allsst1,[240 141*91]);    
allsst3=array2timetable(allsst2,'RowTimes',time);  
allssty1=retime(allsst3,'yearly','sum');  
allssty21=timetable2table(allssty1); %月毎を合計
allssty31=table2array(allssty21(:,2:end));
allssty3=reshape(allssty31,[20 141 91]);
asfay=permute(allssty3,[2 3 1]); 

% asf_h=-ssfmc1./(mldDmc1*rho*cp)*dt.*(mldDa./mldDmc1);
% asf_f=-ssfa./(mldDmc1*rho*cp)*dt;