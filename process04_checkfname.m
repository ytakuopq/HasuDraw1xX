function [flag_fname, flag_mat, flag_wavdiv] = process04_checkfname(fname)
%PROCESS04_CHECKFNAME 
% 連番のfnameの一番始めのファイルがあるかどうか
% それを一度読み込んでmatに落としたデータファイルがあるかどうか？
% それを切り出して、切りだし位置を保管したデータファイルがあるかどうか
% を調べる
%   
flag_fname = false;
flag_mat = false;
flag_wavdiv = false;

fnamex = makefirstfilename(fname);

if(isfile(fnamex)) % 指定されたデータファイルがない場合
    flag_fname = true;
end

%
matfile = makematfilename(fnamex);
if(isfile(matfile)) %以前に読んでセーブしたことがある
    flag_mat = true;
end

%
wavdivfile = makewavdivfilename(fnamex);
if(isfile(wavdivfile))
    flag_wavdiv = true;
end

end

