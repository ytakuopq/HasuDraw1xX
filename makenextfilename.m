function newFilename = makenextfilename(oldFilename)
% 次の連番のファイル名を作る    % 拡張子を除いたファイル名と拡張子を分ける
    [filepath, name, ext] = fileparts(oldFilename);

    % 末尾3桁を取得（数字であると仮定）
    if length(name) < 3
        error('ファイル名が短すぎて、末尾3桁を取得できません。');
    end

    suffix = name(end-2:end);
    num = str2double(suffix);

    if isnan(num)
        if(suffix ~= "ger")
            error('ファイル名の末尾3桁が数字ではありません。');
        end
    end

    % ベースの名前を切り出す（数字を除いた部分）
    baseName = name(1:end-3);

    num = num + 1;
    newNumStr = sprintf('%03d', num);
    newName = [baseName, newNumStr, ext];
    newFilename = fullfile(filepath, newName);
  
end