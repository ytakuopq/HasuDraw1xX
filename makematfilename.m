function matfile = makematfilename(filename)
% matfile名をつくる
    [filepath, name, ~] = fileparts(filename);
    matfile = fullfile(filepath, [name, '.mat']);
end