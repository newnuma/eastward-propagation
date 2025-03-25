% 例: 北太平洋領域のルートパスを設定
data_folder = 'C:\Users\ninum\Desktop\east_data\north_pacific';
base_setting_path = fullfile(data_folder, "\base_data\base_setting.mat");

load(base_setting_path,"slon","slat","time","pres");