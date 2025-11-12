function  [flag, fname] = FileDialog02()
%FILEDIALOG02 ファイルダイアログを開き、ファイル名を取得する
%   履歴
%   ver 1.00 20250625 GUI用に作成
%   flagは正しくファイルが選択された場合は0, Cancelが押された場合は1を返す 
    global fname0;

    [file,location] = uigetfile( ...
        {'*.csv', 'CSV (*.csv)'}, ...
        'ファイルを選択');

    if isequal(file,0)
        disp('User selected Cancel');
        fname = 'Canceled ';
        flag = 1;
    else
        disp(['User selected ', fullfile(location,file)]);
        fname = fullfile(location,file);
        flag = 0;
    end
    fname0 = fname;
end

