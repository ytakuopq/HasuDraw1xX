function newFilename = makefirstfilename(oldFilename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 最初の連番のファイル名を作る
    % 拡張子を除いたファイル名と拡張子を分ける
    [filepath, name, ext] = fileparts(oldFilename);

    % 末尾3桁を取得（数字であると仮定）
    if length(name) < 3
        error('ファイル名が短すぎて、末尾3桁を取得できません。');
    end

    suffix = name(end-2:end);
    num = str2double(suffix);
    if isnan(num)
        if(suffix ~= "ger")
            newFilename = sprintf('File name invalid suffix = %s', suffix);
            return;
        else
            newFilename = oldFilename;
            return;
        end
    end

    % ベースの名前を切り出す（数字を除いた部分）
    baseName = name(1:end-3);

    newNumStr = sprintf('%03d', 0);
    newName = [baseName, newNumStr, ext];
    newFilename = fullfile(filepath, newName);
end
