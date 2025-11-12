function retval = process04_main2_hosei(processflag)
%PROCESS04_MAIN2_HOSEI データの切りだし補正を行う
% もしprocessflag = 1ならセーブする
%
%   ver 1.00 20250922   切りだしデータを保存するように修正

global fname0;
global dc; % 読み込んだデータなど
global mc; % 測定条件 スキャン速度やチャネル数、スキャン数などを格納

retval = 0;

% CSVから読んだサンプリング時間が信用出来ないときは、process04_common.m
% などでdc.xa0_initに数値をいれる。そうでなければそっちでコメントアウト
% 初期値が入っていないようであれば、警告を出してサンプリング時間から計算
if(isfield(dc, 'dxa0_init'))
    dc.dxa0 = dc.dxa0_init;
    dxa0 = dc.dxa0;
else
    dxa0 = dc.xa0(2)-dc.xa0(1);
end
ya0 = dc.ya0processed;
numhead = mc.numhead;
numbeam = mc.numbeam;
numy = dc.numy;
num = dc.num;
xrange = mc.xrange;
iscannum = mc.iscannum;
scanv = mc.scanv;

[ya1, numya1, numdispya1] = ...
    WavDivide3_hosei( ya0, numy, iscannum, numhead, ...
        numbeam, dxa0, xrange, scanv );

dc.divided = true;
dc.ya1 = ya1;
dc.numya1 = numya1;
dc.numdispya1 = numdispya1;
%dc.icenterpos = icenterpos;
%dc.icenterposhosei = icenterposhosei;

if(processflag == 1)
    dccopy = dc;
    wavdivfile = makewavdivfilename(fname0);
    save(wavdivfile, 'dccopy', "-v7.3");
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ ya1, numya1, numdispya1 ] = ...
    WavDivide3_hosei( ya0, numy, iscannum, numhead, ...
        numbeam, dxa0, xrange, scanv)

global mc;
global dc;
try
    icenterpos = dc.icenterpos;
    icenterposhosei = dc.icenterposhosei;
catch
    return;
end

numdispya1 = floor(xrange/scanv/dxa0); % この範囲分を切り出して格納
numdispya1 = floor(numdispya1/2)*2; % 偶数化
iyokohosei = floor(mc.iyokohosei);

%%
% 切り出し
numya1 = numy *iscannum;
ya1 = zeros(numya1, numdispya1);

[ixya0, iyya0] = size(ya0);
for ih=1:numhead
    for iq =1:iscannum
        for ib = 1:numbeam
            ix = (ih-1)*numbeam + ib;
            iscan = (ix-1)*iscannum+iq;
            itmp = icenterpos(ih, iq)-numdispya1/2;
            
            if(mod(iq,2)==1)
                itmp = itmp + icenterposhosei(ih, iq);
            else
                itmp = itmp - icenterposhosei(ih, iq);
            end 

            if(itmp < 0)
                itmp = icenterpos(ih, iq-2)-numdispya1/2;
            end
            if(mod(iq,2)==1) % 偶奇で処理を変える
                if(itmp <= 0 || itmp + numdispya1 -1 >= iyya0)
                    itmp = 1; % 範囲外になったときにはあきらめて適当なデータを表示
                end
                ya1tmp = ya0(ix, itmp:(itmp+numdispya1-1));
                ya1(iscan, :) = ya1tmp;
            else
                itmp = itmp + iyokohosei;
                if(itmp <= 0 || itmp + numdispya1 -1>= iyya0)
                    itmp = 1; % 範囲外になったときにはあきらめて適当なデータを表示
                end
                ya1tmp = ya0(ix, itmp:(itmp+numdispya1-1));
                ya1(iscan, :) = flip(ya1tmp);
            end
        end
    end
end

end
