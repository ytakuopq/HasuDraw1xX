function process04_readdatafile1(fname)
%PROCESS04_READDATAFILE1 読み込み関数（1chデータ用）
%   指定されたCSVデータファイルを読み込み、dc構造体に格納します。
%   また、既存の.matキャッシュがあればそれを優先して読み込みます。
%
%   【主な変更点】
%   - グローバル変数 fname0 の使用を廃止し、dc.fname を正式に採用。
%   - fname0 は互換目的で同期のみ行います（今後削除予定）。
%
%   引数:
%     fname : 読み込むデータファイルのパス

global dc;

fprintf('Reading data: %s\n', fname);
timestart = now;
ix = 0;

while true
    if ix == 0
        % 最初のファイル名を決定
        fnamex = makefirstfilename(fname);
        matfile = makematfilename(fnamex);

        % 既にキャッシュがある場合はそれをロード
        if isfile(matfile)
            fprintf('Cached MAT file found: %s\n', matfile);
            load(matfile, 'dcread');
            dc = dcread;
            dc.stored = true;
            dc.divided = false;
            dc.fname = fnamex;    % 単一の真実
            fname0 = dc.fname;    % 旧互換
            return;
        end

        % ファイルが存在しない場合
        if ~isfile(fnamex)
            fprintf('Data file not found: %s\n', fnamex);
            dc.stored = false; dc.divided = false;
            return;
        end
    else
        % 次のファイル名を生成
        fnamex = makenextfilename(fnamex);
        if ~isfile(fnamex)
            break;
        end
    end

    %--------------------------------------------
    % 実際の読み込み処理
    fprintf('Reading data file %s\n', fnamex);
    [xa0, ya0, num, numy] = readKYSdataCSV1(fnamex);

    if ix == 0
        xa0base = xa0(1);
        dc.xa0 = xa0 - xa0base;
        dc.ya0backup = ya0;
        dc.num = num; dc.numy = numy;
    else
        dc.xa0 = [dc.xa0, xa0 - xa0base];
        dc.ya0backup = [dc.ya0backup, ya0];
        dc.num = dc.num + num;
    end

    dc.stored = true; 
    dc.divided = false;
    fprintf('... done %d points X %d ch\n', num, numy);

    ix = ix + 1;
end

fprintf('Reading time %.2f min\n', (now - timestart) * 24 * 60);
dc.fname = fname;      % 正式な格納先
fname0   = dc.fname;   % 旧互換用（削除予定）
end
