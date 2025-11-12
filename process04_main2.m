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
    dxa0 = dc.dxa0;
else
    dc.dxa0 = dc.xa0(2) - dc.xa0(1);
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

%% 
% 2024/11/6 新新PDBOX用　スロープ変更分を換算
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

%% 
% 2024/11/6 暗電流をソフト処理
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
