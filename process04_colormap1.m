function retval = process04_colormap1(type, withbar)
%PROCESS04_colormap1 エッジ検出されたデータをカラーマップで表示する
%  type: カラーマップの種類を指定　0 gray, 1 jet, 
%  withbar: 図の右側にスケール用のカラーバーをだすかどうか
%  
%  スケーリングの指定はmcで
%

global fname0;
global dc; % 読み込んだデータなど
global mc; % 測定条件 スキャン速度やチャネル数、スキャン数などを格納
global figcolormap;

figcolormap.fignum = 31; %　描画する図の番号、他から
figcolormap.type = type;
figcolormap.withbar = withbar;

retval = 0;

if(~dc.divided) 
    retval = -1;
    return;
end

% mc.colormaptypeは今のところ使っていない

ya1 = dc.ya1;
numya1 = dc.numya1;
numdispya1 = dc.numdispya1;
sensorpitch = mc.scanpitch;
scanv = mc.scanv;
iscannum = mc.iscannum;
xrange = mc.xrange;
xa0 = dc.xa0;
fname = fname0;

%%% 3次元（2次元マップ）%%%%%%%%%%%%%%%%%%%%%%
pYnum = numya1;
pYres = sensorpitch; % y方向（スキャン方向）の空間分解能　単芯とアレイでは異なる

widthpY = pYnum*pYres;

widthpX = xrange;
pXres = mc.pXres; % X方向（スキャン方向）の空間分解能　
pXnum = floor(widthpX/pXres);

% 下記で指定する空間分解能の升目をつくって、データを入れていきます。
if (pYnum == 0) 
    return; % Y方向に一つも入らないようだと終了。例えば、スキャン方向とセンサの並びが一致しているときなど。
end
pZ=zeros(pYnum, pXnum);

dxa0 = dc.dxa0;
for ipy = 1:pYnum
    iyy = ipy;

    for ix =1:numdispya1
        targetx = dxa0*(ix-1)*scanv;
        ipx = floor(targetx/pXres)+1;
        if(ipx>pXnum) 
            ipx = pXnum;
        end
        pZ(ipy, ipx) = ya1(iyy, ix);
        %pZ(ipy, ipx) = 10^(ya1(iyy, ix)); % linear sqrt() 
    end
  
end

% 2次元マップ表示
figure(31);clf;
image(pZ,'CDataMapping','scaled');        

% スケーリング
switch mc.coloscalingtype
    case 0
        %caxis([0.4 0.8]);      % default
        clim([0 1.0]);      
    case 1
        pZmax = max(pZ(:));
        pZmin = min(pZ(:));
        mc.colorscalingmin = pZmin;
        mc.colorscalingmax = pZmax;
        clim([pZmin pZmax]);
    case 2
        if(mc.colorscalingmax > mc.colorscalingmin)
            clim([mc.colorscalingmin mc.colorscalingmax]);      
        else
            clim([mc.colorscalingmax mc.colorscalingmin]);
            fprintf('逆です\n');
        end
    otherwise
        clim([0 1.0]);      
end

% 描画タイプ
switch type
    case 0
        colormap(gray);
    case 1
        colormap(jet);
    case 2
        colormap(jet);
    otherwise
        colormap(gray);   % 2次元マップを書く時のカラーの指定
end

if(withbar == 1)
    colorbar();
end

ax = gca;
ax.DataAspectRatio= [1 pYnum/pXnum/(widthpY/widthpX) 1];
title( sprintf('%s, scan speed %7.2f mm/s. res %7.2f, %7.2f',  fname, scanv, pXres, pYres), 'interpreter', 'none');
af = gcf;
af.Position = [ 50 50 1000 800 ]; % 貼り合わせのために表示ウィンドウを固定

end

