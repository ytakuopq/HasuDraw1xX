function process04_hasu1(fignum, imabiki, displayrange)
%PROCESS3_HASU1 蓮の華を描画
%   fignum Matlab上の図番号　省略された場合は40
%   

global fname0;
global dc;
global mc;

if(~exist('fignum','var'))
    fignum = 40;
end

if(~exist("imabiki", "var"))
    imabiki = 1;
end

if(~exist("displayrange", "var"))
    displayrange = 60;
end


fname = fname0;
ya1 = dc.ya1;
numya1 = dc.numya1;
numdispya1 = dc.numdispya1;
iscannum = mc.iscannum;
scanv = mc.scanv;

figure(fignum);clf;hold on;

screen_size = get(groot,'ScreenSize');
screenwidth = screen_size(3);
screenheight = screen_size(4);
screenmargine = 100;
set(gcf, "Position", [screenmargine screenmargine screenheight-screenmargine*2+100 screenheight-screenmargine*2 ]);

% displayrange=60;
for iq=1:imabiki:numya1
    yoffset = -(iq-1)*displayrange/iscannum; % 見やすいように縦にずらす
    plot(dc.xa0(1:numdispya1) * scanv, ya1(iq, :)+yoffset);hold on;
    %text(1, ya1(iq, 1)+yoffset, sprintf('ch%d,s%d', ...
    %    floor(iq/iscannum)+1, ...
    %    mod(iq-1, iscannum)+1));
    title( sprintf('%s, scan speed %7.2f mm/s.',  fname, scanv), 'interpreter', 'none');
    xlabel('scan length (mm)')
    ylabel(' ');
end

end

