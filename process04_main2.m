function retval = process04_main2(processflag, updateFcn, isCanceled)
%process3_main2 データの読み込みと切りだしを行う
%   
%   processflag 処理の種類を決める 現在のところ未使用
%   
%   履歴
%   ver 1.00 20250725 　GUI用に作成
%   ver 1.00 20250922   切りだしデータを保存するように修正

global fname0;
global dc; % 読み込んだデータなど
global mc; % 測定条件 スキャン速度やチャネル数、スキャン数などを格納

% 引数の数をチェック
    if nargin < 2 || isempty(updateFcn)
        % 何も渡されなければ、ダミー関数にしておく
        updateFcn = @(varargin) [];
    end
    if nargin < 3 || isempty(isCanceled)
        % キャンセルチェックも同様に
        isCanceled = @() false;
    end

% 単体で呼ばれたとき
if exist('processflag', 'var')~=1
    %fname = '20250619\20241212172837_test2__1-18_DataLogger.csv';
    %fname = '20250619\20250425122620___1-6_DataLogger.csv';
    process04_common();
    %fname = '20250619\20250425122940___1-14_DataLogger.csv';
    %process03_readdatafile154(fname);
else
    fname = fname0;
end

%% 
retval = 0;

% データが読まれていなかったら何もしないでもどる
if(~dc.stored) 
    retval = -1;
    return;
end

% CSVから読んだサンプリング時間が信用出来ないときは、process04_common.m
% などでdc.xa0_initに数値をいれる。そうでなければそっちでコメントアウト
% 初期値が入っていないようであれば、警告を出してサンプリング時間から計算
if(isfield(dc, 'dxa0_init'))
    dc.dxa0 = dc.dxa0_init;
    dxa0 = dc.dxa0;
else
    dxa0 = dc.xa0(2)-dc.xa0(1);
end
ya0 = dc.ya0backup;
numhead = mc.numhead;
numbeam = mc.numbeam;
numy = dc.numy;
num = dc.num;
xrange = mc.xrange;
iscannum = mc.iscannum;
scanv = mc.scanv;
% scanrange = mc.scanrange; % 金野さんがスキャンしているレンジ 

%%
% 生データ描画
% 縦にずらして全範囲を描画
%if(mc.WavDivided2AllReadDataDraw)
%    strtitle = sprintf('生データ %s, scan speed %7.2f mm/s.',  fname0, mc.scanv);
%    dispWavHead(ya0, mc.numhead, mc.numbeam, 50, strtitle, 0.15 );
%end

%% 2024/11/6 新新PDBOX用　スロープ変更分を換算
if(mc.dBscalingEnabled)
    for ih=1:numhead
        for ib = 1:numbeam
            ix = (ih-1)*numbeam + ib;

            ytmp = ya0(ix, :);
            ya0(ix, :) = ytmp *2.4058-2.1249;
        end
    end
    fprintf('reread and conversion done\n');
end

%% 2024/11/6 暗電流をソフト処理
if(mc.PDAddDarkCurEnabled)
    for ih=1:numhead
        vd = mc.PDDardCurAdded; % 暗電圧
        v0 = 0.5; % 0.5V/10dB
        vd10 = 10^(vd/v0);

        for ib = 1:numbeam
            ix = (ih-1)*numbeam + ib;

            ytmp = ya0(ix, :);
            ya0(ix, :) = 0.5 * log10(10.^(ytmp/v0) + vd10);
        end
    end
    fprintf('dark volt added\n');
end

dc.ya0processed = ya0;

%%
% debug
figure(50);
plot(ya0);

%%
% エッジを検出して切り出し
% scanrange = 600; % 金野さんがスキャンしているレンジ
[flag_fname, flag_mat, flag_wavdiv] = process04_checkfname(fname0);
if(~flag_wavdiv)
    mc.WavDivided3UseWavDivFile =0;%以前に読んで作成したwavdivファイルがなければエッジ検出に進む
end

if(mc.WavDivided3UseWavDivFile ==0) % 以前に読んで作成したエッジ検出結果を使うか？
    % 使わずに新たにエッジ検出、もしくは、以前に作成したデータがない
    [ ya1, numya1, numdispya1, icenterpos, icenterposhosei] = WavDivide3( ya0, numy, iscannum, numhead, ...
        numbeam, dxa0, xrange, scanv, updateFcn, isCanceled );
    dc.divided = true;
    dc.ya1 = ya1;
    dc.numya1 = numya1;
    dc.numdispya1 = numdispya1;
    dc.icenterpos = icenterpos;
    dc.icenterposhosei = icenterposhosei;
    dccopy = dc;

    wavdivfile = makewavdivfilename(fname0);
    save(wavdivfile, 'dccopy', "-v7.3");
else
    wavdivfile = makewavdivfilename(fname0);
    load(wavdivfile, 'dccopy');
    dc = dccopy;
end

%%
% 切り出し描画
% 縦にずらして全範囲を描画
% いわゆる蓮の花

process04_hasu1(41, 16);

end