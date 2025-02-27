base_setting_path = "..\..\..\base_data\data\base_setting.mat";
load(base_setting_path,"slor","slar");

%データの呼び出し、連結
ncfiles = dir('*.nc');      %this identifies all files within my folder ending in '.nc4'
Nfiles = length(ncfiles);    %this indicates the number of files in my folder (i.e. 31)
all_temp = cell(Nfiles,1);
all_salt = cell(Nfiles,1);
Times1 = cell(Nfiles,1);

for i = 1:Nfiles
   % ncfiles(i).name         %.name:ファイル名の情報
    all_temp{i} = ncread(ncfiles(i).name, 'TOI'); 
    all_salt{i} = ncread(ncfiles(i).name, 'SOI');
    Times1{i} = ncfiles(i).name(4:9);
end
temp=cat(4,all_temp{:});      %時間(4)方向に連結
salt=cat(4,all_salt{:});  
Times1=cat(1,Times1{:});
time = datetime(Times1, 'InputFormat', 'yyyyMM');
year = time(1:12:end);
salltemp  = temp(slor,slar,:,:);
sallsal = salt(slor,slar,:,:);

% save(base_setting_path,time)




% 時間呼び出し、並べる
% Times = cell(Nfiles,1);
% for i = 1:Nfiles
%    % ncfiles(i).name         
%     Times{i} = ncread(ncfiles(i).name, 'TIME');     %
% end
% Times=cat(1,Times{:});%int32で出力      
% time=calmonths(Times)+calmonths(1)+calyears(1900)+caldays(1); %アルゴデータ：1900年から月
% time=datetime(datevec(time));  %datetimeに変換