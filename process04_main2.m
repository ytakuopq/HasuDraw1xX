function retval = process04_main2(processflag, updateFcn, isCanceled)
%PROCESS04_MAIN2 メイン解析・エッジ検出関数
%   processflag : 未使用（将来的な拡張用）
%   updateFcn   : GUI等からの更新コールバック（省略可）
%   isCanceled  : 中断チェック関数（省略可）
%
%   【変更点】
%   - global fname0 を削除。
%   - dc.fname を正式採用。
%   - wavdivファイル名生成やログ表示をdc.fname基準に統一。

global dc mc;

if nargin < 2 || isempty(updateFcn), updateFcn = @(varargin) []; end
if nargin < 3 || isempty(isCanceled), isCanceled = @() false; end
retval = 0;

if ~dc.stored
    retval = -1;
    fprintf('No data loaded.\n');
    return;
end

%% --- サンプリング間隔を確定 ---
if isfield(dc, 'dxa0_init')
    dc.dxa0 = dc.dxa0_init;
else
    dc.dxa0 = dc.xa0(2) - dc.xa0(1);
end

ya0 = dc.ya0backup;
numy = dc.numy;
iscannum = mc.iscannum;

%% --- エッジ検出・分割処理 ---
[~, ~, flag_wavdiv] = process04_checkfname(dc.fname);
if ~flag_wavdiv
    mc.WavDivided3UseWavDivFile = 0;
end

if mc.WavDivided3UseWavDivFile == 0
    [ya1, numya1, numdispya1, icenterpos, icenterposhosei] = ...
        WavDivide3(ya0, numy, iscannum, mc.numhead, mc.numbeam, dc.dxa0, mc.xrange, mc.scanv, updateFcn, isCanceled);

    dc.divided = true;
    dc.ya1 = ya1;
    dc.numya1 = numya1;
    dc.numdispya1 = numdispya1;
    dc.icenterpos = icenterpos;
    dc.icenterposhosei = icenterposhosei;

    dccopy = dc;
    wavdivfile = makewavdivfilename(dc.fname);
    save(wavdivfile, 'dccopy', '-v7.3');
else
    wavdivfile = makewavdivfilename(dc.fname);
    load(wavdivfile, 'dccopy');
    dc = dccopy;
end

%% --- 可視化 ---
process04_hasu1(41, 16);
fprintf('Processing completed for %s\n', dc.fname);
end
