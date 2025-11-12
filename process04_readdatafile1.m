function process04_readdatafile1(fname)
%PROCESS04_READDATAFILE154 この関数の概要をここに記述
%   沖縄機用に作成(1chデータ用）
global fname0;
global dc; % 読み込んだデータなど

%fname = '20250806\20250804195625____DataLogger_001.csv'; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 測定対象データの処理
timestart = now;

ix = 0;
while true
    if(ix == 0)
        fnamex = makefirstfilename(fname);
        %
        matfile = makematfilename(fnamex);
        if(isfile(matfile)) %以前に読んでセーブしたことがある
            dcold = dc;
            load(matfile, 'dcread');
            dcold.xa0 = dcread.xa0;
            dcold.ya0backup = dcread.ya0backup;
            dcold.num = dcread.num;
            dcold.numy = dcread.numy;
            dcold.stored = true;
            dcold.divided = false;
            dc = dcold;
            fname0 = fnamex;
            return;
        end
        
        if(~isfile(fnamex)) % 指定されたデータファイルがない場合
            dc.stored = false;
            dc.divided = false;
            return;
        end
        
    else
        fnamex = makenextfilename(fnamex);        
        if(~isfile(fnamex))
            break;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % データの読み込み
    fprintf('Reading data file1  %s \n', fnamex);
    [xa0, ya0, num, numy ] = readKYSdataCSV1( fnamex );

    % 時間軸の開始を0にする。
    if(ix == 0)
        xa0base=xa0(1);
        dc.xa0 = xa0 - xa0base;
        % dc.ya0 = ya0;
        dc.ya0backup = ya0;
        dc.num = num;
        dc.numy = numy;
        % 一応読んだファイルを格納
    else
        dc.xa0 = [dc.xa0, xa0 - xa0base];
        % dc.ya0 = ya0;
        dc.ya0backup = [dc.ya0backup, ya0];
        dc.num = dc.num + num;
    end
    
    dc.stored = true;
    dc.divided = false;

    fprintf('... done %d points X %d ch\n', num, numy);
    ix = ix +1;
end

fprintf('reading time %g\n', (now-timestart)*24*24*60);
fname0 = fname;    


if(any(isnan(dc.xa0)) || any(isnan(dc.ya0backup)))
    fprintf('NaNが混じってしまったようです。すいません。\n');
    fprintf('NaNを0に置き換えて処理ぞ続行します。\n');
    dc.xa0(isnan(dc.xa0))=0;
    dc.ya0backup(isnan(dc.xa0))=0;    
    return;
else
    dcread = dc;
    save(matfile, 'dcread', '-v7.3');
end

end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






