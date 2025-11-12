function [ xa0, ya0, num, numy ] = readKYSdataCSV1( fname )
%READNSSDATACSV キーエンスデータロガーのセーブデータCSV形式を読み取る
%   fname 読み込むファイル名
%
%   xa0() 時間　
% 　ya0(ix, iy) 各ch(ix)の電圧値
%   num データ長
%   numy 読み込んだch数
%
%   但し、読み込んだデータ長が奇数の場合は、偶数になるよう最後のデータを切り捨てる
%   Y. Takushima/Optoquest
% 
%   20230828 154chデータ用にnumyを固定
%   20250806 1chデータ用に修正。textscanの利用で高速化。 

numy = 1; % 1ch用

fid = fopen(fname, 'r');
if(fid == -1)
    fprintf('ファイルがオープン出来ません。ファイル名を確認してください\n');
    num=-1;
    return;
end

% first pass
flag = 0;
while ~feof(fid)
    tline = fgets( fid );
    if(length(tline)>9)
        if(strcmp(tline(1:10), '#EndHeader')) 
            flag = 1;
            break;
        end
    end
end
if(flag ==0 ) 
    fprintf('cannot find #EndHeader. Please check your file.');
    return;
end


num=0;
while ~feof(fid)
    tline = fgets( fid );
    if(tline(1) == '#')
        break;
    end
    num = num + 1;
    if(mod(num, 1000000)==0)
        fprintf('Reading %d -th line \r', num);
    end
end
fclose(fid);
fprintf('%s, Num of data = %d\n', fname, num);

% re-open
fid = fopen(fname, 'r');

while ~feof(fid)
    tline = fgets( fid );
    if(length(tline)>9)
        if(strcmp(tline(1:10), '#EndHeader')) 
            break;
        end
    end
end

% 本体の読み込み
data = textscan(fid, '%*s %f %f %*s', ...
    'Delimiter', ',', ...
    'CollectOutput', true);

fclose(fid);

values = data{1};
xa0 = values(1:num, 1).';
ya0 = values(1:num, 2).';
xa0 = xa0 * 1e-6;

end



