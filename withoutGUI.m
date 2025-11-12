function withoutGUI()
%WITHOUTGUI GUIを使わずに処理を実行するメインスクリプト
%   共通初期化を呼び出し、対象データを読み込み、解析・描画を行います。
%
%   【主な変更点】
%   - global fname0 の再代入を削除。
%   - dc.fname を process04_readdatafile1 内で自動設定。
%   - コメント・処理順を整理。

global dc mc;

%% --- 共通初期化 ---
process04_common();

%% --- データセット設定例 ---
fname = '..\\20251030sil\\20250608162443____DataLogger.csv';  % サンプルデータ
mc.iscannum = 620;
mc.scanv = 100;
mc.scanpitch = 0.5;
dc.dxa0_init = 1e-3;        % CSVのサンプリング時間補正
mc.WavDivided3Period = 5600;
mc.threshold = 0.07;
mc.pXres = 0.11;

%% --- データ読み込み・解析実行 ---
process04_readdatafile1(fname);     % dc.fname が内部で設定される
mc.WavDivided3UseWavDivFile = 0;    % 既存wavdivがあっても再生成
process04_main2(0);                 % メイン処理

%% --- 描画処理 ---
process04_hasu1(41, 1, 15);         % hasu（波形群）描画
dc.divided = true;
process04_colormap1(1, 1);          % カラーマップ描画

fprintf('Processing complete for: %s\n', dc.fname);
end
