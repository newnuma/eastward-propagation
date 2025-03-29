function varOut = loadData(relMatPath, varName)
%CUSTOMLOADDATA Loads a variable from a MAT-file if it does not exist in the base workspace.
%
%   varOut = customLoadData(relMatPath, varName)
%
%   Inputs:
%       relMatPath  : 関数 customLoadData のあるディレクトリからの相対パス
%                     (例: 'data/myData.mat')
%       varName     : ロードしたい変数名 (文字列)
%
%   Output:
%       varOut      : base ワークスペース上に既に変数があればそれを返す。
%                     存在しなければ MAT ファイルからロードした変数を返す。
%
%   使い方:
%       X = customLoadData('data/myData.mat', 'X');
%       % 上記の場合、この関数が置かれているフォルダ内の data サブフォルダにある
%       % myData.mat から X をロードする(既に base ワークスペースに X が存在すればスキップ)。

    %--------------------------------------------------------------------------
    % 1) この関数 (customLoadData.m) が置かれているディレクトリを取得し、
    %    relMatPath と組み合わせて絶対パスを作成する
    %--------------------------------------------------------------------------
    % mfilename('fullpath') でこのファイル自身 (customLoadData.m) のフルパスを取得
    if ismac
        relMatPath = strrep(relMatPath, '\', '/');
    end
    
    data_folder = evalin('base','data_folder');
    absMatPath = fullfile(data_folder, relMatPath);

    varExists = evalin('base', sprintf('exist(''%s'', ''var'')', varName));
    if varExists
        % すでに存在するのでロードをスキップ
        varOut = evalin('base', varName);
        return;
    end

    if ~isfile(absMatPath)
        error('[customLoadData] 指定されたファイルが存在しません: %s', absMatPath);
    end

    S = load(absMatPath, varName);

    % ロードした .mat ファイルに varName が含まれていない場合のチェック
    if ~isfield(S, varName)
        error('[customLoadData] ファイル %s に変数 ''%s'' は含まれていません。', absMatPath, varName);
    end

    varOut = S.(varName);
    assignin('base', varName, varOut);

    fprintf('[customLoadData] 変数 ''%s'' をファイル %s からロードしました。\n', varName, absMatPath);

end
