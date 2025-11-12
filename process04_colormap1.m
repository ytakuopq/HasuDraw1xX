function retval = process04_colormap1(type, withbar)
%PROCESS04_COLORMAP1 エッジ検出後のデータをカラーマップで可視化（clim等復元版）
%
%   type    : カラーマップタイプ (0=gray, 1=jet, 2=jet拡張)
%   withbar : カラーバーを表示する場合は1
%
%   変更点:
%   - dc.fname を使用（global fname0 を廃止）
%   - スケーリング（mc.coloscalingtype）と DataAspectRatio、ウィンドウ位置を復元

global dc mc figcolormap;

figcolormap.fignum = 31; % 描画する図の番号
figcolormap.type   = type;
figcolormap.withbar= withbar;

retval = 0;

if ~dc.divided
    retval = -1;
    return;
end

% --- 変数取得 ---
ya1         = dc.ya1;
numya1      = dc.numya1;
numdispya1  = dc.numdispya1;
sensorpitch = mc.scanpitch;
scanv       = mc.scanv;
iscannum    = mc.iscannum; %#ok<NASGU> % 将来使用のため温存
xrange      = mc.xrange;
xa0         = dc.xa0; %#ok<NASGU>
fname       = dc.fname;

% --- 空間マッピング ---
pYnum = numya1;
pYres = sensorpitch;                    % y方向（スキャン方向）の空間分解能
widthpY = pYnum * pYres;

widthpX = xrange;
pXres   = mc.pXres;                     % X方向（横方向）の空間分解能
pXnum   = floor(widthpX / pXres);

if (pYnum == 0)
    return;
end

pZ = zeros(pYnum, pXnum);

dxa0 = dc.dxa0;
for ipy = 1:pYnum
    iyy = ipy;
    for ix = 1:numdispya1
        targetx = dxa0 * (ix - 1) * scanv;
        ipx     = floor(targetx / pXres) + 1;
        if ipx > pXnum
            ipx = pXnum;
        end
        pZ(ipy, ipx) = ya1(iyy, ix);
        % pZ(ipy, ipx) = 10^(ya1(iyy, ix)); % linear sqrt() （必要なら復活）
    end
end

% --- 2次元マップ表示 ---
figure(figcolormap.fignum); clf;
image(pZ, 'CDataMapping', 'scaled');

% --- スケーリング（復元） ---
switch mc.coloscalingtype
    case 0  % zerone
        clim([0 1.0]);
    case 1  % minmax
        pZmax = max(pZ(:));
        pZmin = min(pZ(:));
        mc.colorscalingmin = pZmin;
        mc.colorscalingmax = pZmax;
        clim([pZmin pZmax]);
    case 2  % defined
        if mc.colorscalingmax > mc.colorscalingmin
            clim([mc.colorscalingmin mc.colorscalingmax]);
        else
            clim([mc.colorscalingmax mc.colorscalingmin]);
            fprintf('逆です\n');
        end
    otherwise
        clim([0 1.0]);
end

% --- 描画タイプ（復元） ---
switch type
    case 0
        colormap(gray);
    case 1
        colormap(jet);
    case 2
        colormap(jet);
    otherwise
        colormap(gray);
end

if withbar == 1
    colorbar();
end

% --- アスペクトとウィンドウ位置（復元） ---
ax = gca;
ax.DataAspectRatio = [1, pYnum / pXnum / (widthpY / widthpX), 1];

title(sprintf('%s, scan speed %7.2f mm/s. res %7.2f, %7.2f', fname, scanv, pXres, pYres), 'interpreter', 'none');
af = gcf;
af.Position = [50 50 1000 800]; % 貼り合わせのために表示ウィンドウを固定

end
