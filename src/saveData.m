function saveData(relMatPath, varName, varValue)
%CUSTOMSAVEDATA Save a variable to a MAT file relative to this function's location.
%
%   customSaveData(relMatPath, varName, varValue)
%
%   Inputs:
%       relMatPath : この関数 (customSaveData.m) があるディレクトリからの相対パス
%                    (例: 'data/myData.mat')
%       varName    : 保存したい変数名 (MAT ファイル内に格納する名前)
%       varValue   : 実際に保存するデータ (行列・構造体など任意)
%
%   使用例:
%       X = rand(5);
%       customSaveData('data/myData.mat', 'X', X);
%
%       % その後、同じフォルダ内にある customLoadData と組み合わせて、
%       % X = customLoadData('data/myData.mat','X');
%       % のようにロードが可能になります。

    %--------------------------------------------------------------------------
    % 1) この関数があるディレクトリを取得し、そこから relMatPath を絶対パスに変換
    %--------------------------------------------------------------------------
    thisFuncFullPath = mfilename('fullpath');        % customSaveData.m のフルパス
    [thisFuncDir, ~, ~] = fileparts(thisFuncFullPath);
    absMatPath = fullfile(thisFuncDir, relMatPath);  % 絶対パス化

    %--------------------------------------------------------------------------
    % 2) 保存先ディレクトリが存在しない場合は作成 (任意)
    %--------------------------------------------------------------------------
    [saveDir, ~, ~] = fileparts(absMatPath);
    if ~isempty(saveDir) && ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    %--------------------------------------------------------------------------
    % 3) MAT ファイルに保存
    %--------------------------------------------------------------------------
    S.(varName) = varValue;
    % 例: save('C:\path\to\myData.mat','-struct','S') → S のフィールドそれぞれを変数として保存
    save(absMatPath, '-struct', 'S');

    fprintf('[customSaveData] 変数 ''%s'' をファイル %s に保存しました。\n', varName, absMatPath);
end
