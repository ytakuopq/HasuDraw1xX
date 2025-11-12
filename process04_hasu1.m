function process04_hasu1(fignum, imabiki, displayrange)
%PROCESS04_HASU1 蓮の花（波形群）を描画する関数（ウィンドウサイズ復元版）
%
%   fignum       : 図番号（省略時は40）
%   imabiki      : 間引き数（省略時は1）
%   displayrange : 縦方向の表示レンジ（省略時は60）
%
%   変更点:
%   - dc.fname を使用してタイトルを生成（global fname0 を廃止）
%   - 画面サイズ取得＆ウィンドウ位置調整を復元

global dc mc;

if nargin < 1, fignum = 40; end
if nargin < 2, imabiki = 1; end
if nargin < 3, displayrange = 60; end

fname        = dc.fname;
ya1          = dc.ya1;
numya1       = dc.numya1;
numdispya1   = dc.numdispya1;
iscannum     = mc.iscannum;
scanv        = mc.scanv;

figure(fignum); clf; hold on;

% --- 画面サイズに応じたウィンドウ配置（復元） ---
screen_size   = get(groot,'ScreenSize');
screenwidth   = screen_size(3);
screenheight  = screen_size(4);
screenmargine = 100;
set(gcf, "Position", [screenmargine, screenmargine, screenheight - screenmargine*2 + 100, screenheight - screenmargine*2]);

% --- 描画 ---
for iq = 1:imabiki:numya1
    yoffset = -(iq - 1) * displayrange / iscannum; % 見やすいように縦にずらす
    plot(dc.xa0(1:numdispya1) * scanv, ya1(iq, :) + yoffset); hold on;
    title(sprintf('%s, scan speed %7.2f mm/s.', fname, scanv), 'interpreter', 'none');
    xlabel('scan length (mm)');
    ylabel(' ');
end

end
