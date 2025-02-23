% addpath ..\..\base_data\data
% load("base_setting.mat","slon","slat","time","year");
LO=numel(slon); LA=numel(slat); TI=numel(time); YE=numel(year); PR=numel(pres(1:13));%

focus_pods = [25 25.5 26 26.3 26.5 26.7]; %まとめて実行
% focus_pods = [26];
for index = 1:length(focus_pods)

    DS=focus_pods(index); %%参照密度
    %等密度面解析
    isd=sallpod;
    isot=salltemp;
    isov_n=gv.n;
    isov_e=gv.e;
    % isosal=sallsal;

    isd1=zeros(LO,LA,PR,TI);
    isot1=zeros(LO,LA,PR,TI);
    isov_n1=zeros(LO,LA,PR,TI);
    isov_e1=zeros(LO,LA,PR,TI);
    % isosal1=zeros(141,91,25,264);

    for n=1:TI
        for i=1:LO
            for j=1:LA
                for k=2:PR
                    if isd(i,j,k+1,n)<=DS
                        isd(i,j,k,n)=NaN;
                        isot(i,j,k,n)=NaN;
                        isov_n(i,j,k,n)=NaN;
                        isov_e(i,j,k,n)=NaN;
                        %                    isosal(i,j,k,n)=NaN;
                    end
                    if isd(i,j,k-1,n)>=DS
                        isd(i,j,k,n)=NaN;
                        isot(i,j,k,n)=NaN;
                        isov_n(i,j,k,n)=NaN;
                        isov_e(i,j,k,n)=NaN;
                        %                     isosal(i,j,k,n)=NaN;
                    end
                    %線形補間
                    isd1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(pres(k,1)-pres(k-1,1))/(isd(i,j,k,n)-isd(i,j,k-1,n))+pres(k-1);
                    isot1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(isot(i,j,k,n)-isot(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+isot(i,j,k-1,n);
                    isov_n1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(isov_n(i,j,k,n)-isov_n(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+isov_n(i,j,k-1,n);
                    isov_e1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(isov_e(i,j,k,n)-isov_e(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+isov_e(i,j,k-1,n);
                    %isosal1(i,j,k,n)=(DS-isd(i,j,k-1,n))*(isosal(i,j,k,n)-isosal(i,j,k-1,n))/(isd(i,j,k,n)-isd(i,j,k-1,n))+isosal(i,j,k-1,n);
                end

            end
        end
    end

    for n=1:TI
        for i=1:LO
            for j=1:LA
                for k=1:PR
                    if isd1(i,j,k,n)==0
                        isd1(i,j,k,n)=NaN;
                        isot1(i,j,k,n)=NaN;
                        isov_n1(i,j,k,n)=NaN;
                        isov_e1(i,j,k,n)=NaN;
                        %                    isosal1(i,j,k,n)=NaN;
                    end
                end
            end
        end
    end

    [isd2,ind]=max(isd1,[],3,'omitnan');
    isoD=squeeze(isd2); %%等密度面深さ

    isoT2=max(isot1,[],3,'omitnan');
    isoT=squeeze(isoT2); %%等密度面上水温

    isoV_n2=max(isov_n1,[],3,'omitnan');
    isoV_n=squeeze(isoV_n2); %%等密度面上水温

    isoV_e2=max(isov_e1,[],3,'omitnan');
    isoV_e=squeeze(isoV_e2); %%等密度面上水温

    fieldName = "iso"+ num2str(DS*10);

    Temp = evalin('base', 'Temp');
    Temp.(fieldName).v = isoT;
    Temp.(fieldName) = anomaly(Temp.(fieldName));

    Depth = evalin('base', 'Depth');
    Depth.(fieldName).v = isoD;
    Depth.(fieldName) = anomaly(Depth.(fieldName));

    Gv_n = evalin('base', 'Gv_n');
    Gv_n.(fieldName).v = isoV_n;
    Gv_n.(fieldName) = anomaly(Gv_n.(fieldName));

    Gv_e = evalin('base', 'Gv_e');
    Gv_e.(fieldName).v = isoV_e;
    Gv_e.(fieldName) = anomaly(Gv_e.(fieldName));


    clear isd isd1 isd2 isot isot1 isoT2 isosal isosal1 isosal2


    %月ごとに、NaN（＝密度面が存在しない）が含まれている年の数をカウント
    d1=permute(isoD,[3 1 2]); %%
    d2=reshape(d1,[TI LO*LA]);
    d3=array2timetable(d2,'RowTimes',time);
    mm1=groupsummary(d3,'Time','monthofyear','nummissing');   %NaN要素をカウント
    mm2=table2array(mm1(:,3:end));
    mm3=reshape(mm2,[12 LO LA]);
    N26mc=permute(mm3,[2 3 1]); %%月毎NaNの数
    N26mc1=repmat(N26mc,[1 1 YE]); %%データと同じサイズ
    Temp.(fieldName).n = N26mc1;

    clear d1 d2 d3 mm1 mm2 mm3
    %
end