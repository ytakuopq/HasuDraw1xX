function process04_colormap1_redraw()
%PROCESS04_COLORMAP1_REDRAW この関数の概要をここに記述
%   詳細説明をここに記述
global figcolormap;

if(isempty(figcolormap)) % 一度も描画したことがない
    return;
end

fignum = figcolormap.fignum;
type = figcolormap.type;
withbar = figcolormap.withbar;

% 1) Figure と image のある axes を探す
    fig = findobj('Type','figure','Number',fignum);
    ax  = [];
    if ~isempty(fig) && isvalid(fig)
        % 既存 figure 内の image → 親 axes を優先的に取得
        imgObjs = findobj(fig, 'Type', 'image');
        if ~isempty(imgObjs)
            ax = ancestor(imgObjs(1), 'axes');  % 最初の image の axes
        else
           return;
        end
    end
    figure(fignum);

% 2) 現在の表示状態を退避（ユーザがズーム・パンしていた範囲）
    oldXLim = get(ax,'XLim');
    oldYLim = get(ax,'YLim');
    oldXDir = get(ax,'XDir');
    oldYDir = get(ax,'YDir');

    process04_colormap1(type, withbar);
    xlim(oldXLim);
    ylim(oldYLim);

end

