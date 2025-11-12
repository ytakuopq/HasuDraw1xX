function process04_common()
%PROCESS03_common 測定条件/描画条件 に関する共通パラメータの定義
%   GUIとのインターフェース用にGlobal変数の初期値をを設定する
%   この値がGUI上に転記されます
%   
%   履歴
%   ver 1.00 20250725 GUI用に作成
%   ver 1.01 20250806 沖縄用にパラメータを修正

global dc; % 読み込んだデータなど
global mc; % 測定条件 スキャン速度やチャネル数、スキャン数、描画条件などを格納
  

%%%%%%%%%% 測定データ（スキャンして取得したデータ）用パラメータ
%%%%%%%%%%
% 測定データ（スキャンしたときのデータ）を読み取り、処理する際に、指定する必要のあるパラメータです。
% 測定ファイルごとに異なりますので、ファイル名と一緒に記載しておいた方が楽です。
% fname ファイル名
%
% スキャン速度
%    scanv = 1; % mm/s scan speed
%
% センサーの間隔
%    sensorpitch = 1; % 1mm ピッチ
%
% 描画範囲
%    xstart 描画開始位置 (mm)
%    xrange 描画範囲 (mm)
%  一度、グラフ化してから決めてください。読み取り範囲のグラフはfig20に描画されます。
%
% センサの傾き
%   sensorangle (度)
%   センサがスキャン方向に対して斜めに置かれる場合は、その角度を指定してください。
%   スキャン方向とセンサの並びが直角の時を０としています。
%
% センサータイプ 現状ch数で自動判定なので設定しなくてよい
%    sensortype = 1; % 14chで1-7と8-14の間に隙間がある
%    sensortype = 0; % 隙間なし 16ch
mc.versionstr = '1.0';

mc.sensorangle = 0.0;
mc.sfcutoff = 2; % 背景除去のLPFのカットオフ（単位はmm）
mc.ycutmax = 2.0; %　(V) 背景除去後、これよりも大きい値のデータはゴミとして扱う

mc.scanv = 200;
mc.scanpitch = 0.05;

% 触らなくていよいパラメータ
% Si基板の透過率
mc.substrate_trans = 0.5; % Si基板の透過率 0.5だと50%透過。（Siのコーティングなしだと、こんなもん）
mc.xstart = 0; % 0を入れる（互換性保持のため残しています）
mc.xrange = 320; 

% 1ch特有の変数
mc.numhead = 1;
mc.numbeam = 1;
mc.iscannum = 6000;

% ファイル読み込み時に追加で別の場所で定義される変数
% mc.numy キーエンスデータの読み取りデータ数 = numhead * numbeam
% 1センサの時は１、11x14センサの時は154

% Si基板の透過率
mc.substrate_trans = 0.5; % Si基板の透過率 0.5だと50%透過。（Siのコーティングなしだと、こんなもん）

% WavDivide2で使用するエッジ検出用の段差
mc.threshold = 0.2;

% WavDivided3で使用するエッジ検出開始地点の横軸座標
mc.WavDivided3StartPoint = 1;
mc.WavDivided3Period = 13200;
mc.WavDivided3AllReadDataDraw = 1; % 読み込んだデータを全部描画（重ね書きしない）
mc.iyokohosei = 3; % 右・左スキャンでの微妙な位置ずれの手動補正。正負の整数。
mc.WavDivided3UseWavDivFile = 1; % WavDivファイルを使うかどうか。0は使わない。

% 前処理で使うパラメータ類
mc.dBscalingEnabled = 1;% 0.2V/10dB → 0.5V/10dBのスケーリング
mc.PDAddDarkCurEnabled = 1; % PD暗電流加算するかどうか
mc.PDDardCurAdded = 0.2; % PD暗電流加算値
mc.NewScalingEnabled = 0; % 新アルゴリズムをトライするか

% カラーマップ描画時に使用するパラメータ類
mc.coloscalingtype = 0; % 0 zerone, 1 minmax, 2 defined
mc.colorscalingmax = 1;
mc.colorscalingmin = 0;
mc.colormaptype= 0; % 0 gray, 1 jet, 2 
mc.pXres = 0.06; % ピクセルの横X方向の分解能（箱の横幅）

%% スキャンパラメータ等
dc.stored = false;
dc.divided = false;

%% 金野さんデータ特栽 CSVから読んだデータを使うときはコメントアウト白
%dc.dxa0_init = 0.2e-3;

end

