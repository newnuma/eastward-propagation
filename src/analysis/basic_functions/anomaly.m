%気候値、偏差、年間平均、年間平均偏差を求める関数
%data：data.v を持つデータ偏差を算出したい3次元データ（経度(LO)×緯度(LA)×時間(TI)）入力

function data = anomaly(data)

[slon,slat,time] = evalin("base",'deal(slon, slat, time)');
LO=numel(slon); LA=numel(slat); TI=numel(time);

% 引数xをmydata.vに変更
x = data.v; % 構造体からデータを取得
% 気候値、偏差算出（欠測月があっても可）
x1=permute(x,[3 1 2]);
x2=reshape(x1,[TI LO*LA]);
x3=array2timetable(x2,'RowTimes',time);

mon = month(time);
mc_flat = NaN(12, LO*LA);
for im = 1:12
	idx = (mon == im);
	if any(idx)
		mc_flat(im,:) = mean(x2(idx,:), 1, 'omitnan');
	end
end
mc = permute(reshape(mc_flat,[12 LO LA]),[2 3 1]);    %月ごと気候値

mc_time_flat = mc_flat(mon,:);
a_flat = x2 - mc_time_flat; %偏差
a = permute(reshape(a_flat,[TI LO LA]),[2 3 1]);

% 年間平均（不完全年でも可）
y1=retime(x3,'yearly','mean');
y2=y1.Variables;
y3=reshape(y2,[size(y2,1) LO LA]);
y=permute(y3,[2 3 1]);  %%

% 年平均偏差（不完全年でも可）
ay1=array2timetable(a_flat,'RowTimes',time);
ay2=retime(ay1,'yearly','mean');
ay3=ay2.Variables;
ay4=reshape(ay3,[size(ay3,1) LO LA]);
ay=permute(ay4,[2 3 1]);   %%

% 結果を構造体に格納
data.a = a;
data.mc = mc;
data.y = y;
data.ay = ay;

clear x1 x2 x3 y1 y2 y3 ay1 ay2 ay3 ay4
end