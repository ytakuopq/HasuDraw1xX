function matfile = makewavdivfilename(filename)
% wavdivideで得られた切り出し用データを保存するwavdivを付けたfile名をつくる
    [filepath, name, ~] = fileparts(filename);
    matfile = fullfile(filepath, [name, '_wavdiv.mat']);
end

