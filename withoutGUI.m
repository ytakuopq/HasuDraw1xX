function withoutGUI()
%WITHOUTGUI この関数の概要をここに記述
%   詳細説明をここに記述

global dc; % 読み込んだデータなど
global mc; % 測定条件 スキャン速度やチャネル数、スキャン数などを格納
global fname0;

%% スキャンパラメータ等

dc.stored = false;

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

%　沖縄機用デバッグ

% (debug) removed duplicate global declaration - globals are declared at top

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

% Si基板の透過率
mc.substrate_trans = 0.5; % Si基板の透過率 0.5だと50%透過。（Siのコーティングなしだと、こんなもん）



%%
process04_common();

%fname = '20250806\20250804195625____DataLogger_001.csv';
%fname = '20250820S\20250819195405____DataLogger_000.csv';
%fname = '20250820Soi\20250815104041____DataLogger_000.csv'; %soitec 1
%fname = '..\20250820Soi\20250815153716____DataLogger_000.csv'; %soitec 2
%fname = '..\20250820Soi\20250818105244____DataLogger_000.csv'; %soitec 3
%fname = '20250820Soi\20250819094629____DataLogger_000.csv'; %soitec 4

%fname = '..\20251030sil\20250608133830____DataLogger.csv'; %siltronic
fname = '..\20251030sil\20250608162443____DataLogger.csv'; %siltronic
%fname = '..\20251030sil\20250608165525____DataLogger.csv'; %siltronic
mc.iscannum = 620;
mc.scanv = 100;
mc.scanpitch = 0.5;
dc.dxa0_init = 1e-3;
mc.WavDivided3Period = 5600;
mc.threshold = 0.07;
mc.pXres = 0.11; % ピクセルの横X方向の分解能（箱の横幅）

process04_readdatafile1(fname);
mc.iscannum = 620;
mc.WavDivided3UseWavDivFile = 0; %以前に処理したことがあるなら使え
process04_main2(0);
%%

global fname0; fname0 = fname;
process04_hasu1(41, 1 , 15 );

%%
dc.divided = true;
process04_colormap1(1, 1);


%fname = '20250619\20250425122940___1-14_DataLogger.csv';
%process03_readdatafile154(fname);
%process3_main1();
%process3_main2();

%%
end

