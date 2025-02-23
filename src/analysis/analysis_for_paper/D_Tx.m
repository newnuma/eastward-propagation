%ある深度でのTχ

blon=30:130; blat=61:70; rp=1:13;  %計算範囲を限定する
LO=numel(slon); LA=numel(slat); PR=numel(rp); TI=numel(time);

%1  2  3  4  5  6   7   8   9   10  11  12  13  14
%10,20,30,50,75,100,125,150,200,250,300,
focus_depth_list = [4 6 8 11];%まとめて実行 50,100,150,300m

for index = 1:length(focus_depth_list)
    focus_depth = focus_depth_list(index);
    focus_depth_pod=squeeze(sallpod(:,:,focus_depth,:)); %%参照深度

    fieldName = "d"+ num2str(pres(focus_depth));

    Temp = evalin('base', 'Temp');
    if ~isfield(Temp, fieldName)
        Temp.(fieldName).v = squeeze(salltemp(:,:,focus_depth,:));
        if ~isfield(Temp.(fieldName),'a')
            Temp.(fieldName) = anomaly(Temp.(fieldName));
        end
    end
    Temp.(fieldName).x = zeros(LO,LA,TI);

    Salt = evalin('base', 'Salt');
    if ~isfield(Salt, fieldName)
        Salt.(fieldName).v = squeeze(sallsal(:,:,focus_depth,:));
        if ~isfield(Salt.(fieldName), 'a')
            Salt.(fieldName) = anomaly(Salt.(fieldName));
        end
    end
    Salt.(fieldName).x = zeros(LO,LA,TI);

%     D150_isoTa=zeros(LO,LA,TIM);  %%
%     D150_isoSa=zeros(LO,LA,TIM);  %%

    isd=sallpod(:,:,rp,:);
    isot=salltemp(:,:,rp,:);
    isosal=sallsal(:,:,rp,:);

    for n=1:TI
        for j=blat
            for i=blon

                DS=focus_depth_pod(i,j,n);   %参照密度

                isot1=NaN(1,1,PR,TI);
                isosal1=NaN(1,1,PR,TI);

                if mod(n,12)==0
                    m=12;
                else
                    m=mod(n,12);
                end


                for t=m:12:TI

                    k=1;
                    while  DS - isd(i,j,k,t)> 0 && k < PR
                        k = k+1;end

                    %                  if k == P; isd(i,j,k,t)=NaN; isot(i,j,k,t)=NaN;
                    if k == 1; isot1(1,1,k,t)=NaN;
                    else
                        isot1(1,1,k,t)=(DS-isd(i,j,k-1,t))*(isot(i,j,k,t)...
                            -isot(i,j,k-1,t))/(isd(i,j,k,t)-isd(i,j,k-1,t))+isot(i,j,k-1,t);
                        isosal1(1,1,k,t)=(DS-isd(i,j,k-1,t))*(isosal(i,j,k,t)-isosal(i,j,k-1,t))...
                            /(isd(i,j,k,t)-isd(i,j,k-1,t))+isosal(i,j,k-1,t);
                    end


                end


                isoT2=max(isot1,[],3,'omitnan');
                isoT=squeeze(isoT2);
                isosal2=max(isosal1,[],3,'omitnan');
                isoS=squeeze(isosal2);

                isoT1=isoT(m:12:TI,1);
                tmc=mean(isoT1,1,'includenan');
                isotn=isoT(n,1);
                isoTa=isotn-tmc;

                isoS1=isoS(m:12:TI,1);
                smc=mean(isoS1,1,'includenan');
                isosn=isoS(n,1);
                isoSa=isosn-smc;

                %
                Temp.(fieldName).x(i,j,n)=isoTa;  %%
                Salt.(fieldName).x(i,j,n)=isoSa;  %%
            end
        end

    end


    %NaN(密度面が存在しない年)がある要素数をカウント
%     D150_NaN=zeros(141,91,TIM);    %%
    Temp.(fieldName).xn = zeros(LO,LA,TI);
    for n=1:TI
        for j=blat
            for i=blon

                DS=focus_depth_pod(i,j,n);   %参照密度

                isot1=ones(20,1);

                if mod(n,12)==0
                    m=12;
                else
                    m=mod(n,12);
                end

                for t=m:12:TI
                    y=(t-m+12)/12;
                    if DS - isd(i,j,1,t)< 0  %参照密度より10mでの密度が高いとき
                        isot1(y)=NaN;

                    end
                end


                TF = isnan(isot1);
                N = nnz(TF);
                Temp.(fieldName).xn(i,j,n)=N;  %%

            end

        end
    end

end
