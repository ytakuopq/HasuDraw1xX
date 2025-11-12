function dispWavHead( ya0, numhead, numbeam, fignum, strtitle, step )
%DISPWAVHEAD この関数の概要をここに記述
%   fignum+1~で指定されるFigに波形をヘッド（センサー）ごとに表示する
%   横軸はいじらない


% 生データ描画
% 縦にずらして全範囲を描画
for ih=1:numhead
    figure(fignum+ih);clf;
    for ib = 1:numbeam
        ix = (ih-1)*numbeam + ib;
        
        yoffset = -(ib-1)*step; % 見やすいように縦にずらす
        % xoffset = (ib-1)*sensorpitch* sin(sensorangle/180*pi);
        
        plot(ya0(ix, :)+yoffset);hold on;
        text(1, ya0(ix, 1)+yoffset, sprintf('ch%d', ib));
    end
    title( strtitle, 'interpreter', 'none');
    xlabel('scan ')
    ylabel(sprintf('head %d', ih));
end



end

