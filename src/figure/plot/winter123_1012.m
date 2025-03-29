function w = winter123_1012(x)

addpath C:\Users\ninum\Documents\MATLAB\argo2022\data
load("start.mat","time");


tim=(1:264);
m=mod(tim,12);
entraina_w=x;


for i=1:264
    if (m(i)==4)||(m(i)==5)||(m(i)==6)||(m(i)==7)||(m(i)==8)||(m(i)==9)
        entraina_w(:,:,i)=nan;
    end
end


da2=permute(entraina_w,[3 1 2]);
da3=reshape(da2,[264 12831]);
da4=array2timetable(da3,'RowTimes',time);
allssty1=retime(da4,'yearly','sum');
allssty21=timetable2table(allssty1);
allssty2=table2array(allssty21(:,2:end));
allssty3=reshape(allssty2,[22 141 91]);%25年分
w=permute(allssty3,[2 3 1]);


