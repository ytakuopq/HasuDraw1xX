function [ ya1, numya1, numdispya1, icenterpos, icenterposhosei ] = WavDivide3( ya0, numy, iscannum, numhead, ...
    numbeam, dxa0, xrange, scanv, updateFcn, isCanceled)
% WavDivide3 エッジを検出して切り出す処理 沖縄機用(proces04シリーズ）
%
% numdispya1 表示する領域の幅分の点数（切り出した幅ｘ）
% numya1 切り出されたラインの数　センサ数ｘスキャン回数
% 履歴
% originalは、14ビームx11センサ用として開発
% ver 1.00 20250725 GUI用に作成
% ver 1.01 20250728 右スキャン、左スキャンの補正を手動で入れられるようにしたい
%          mcの中にパラメータ追加 →　まだやってないぞ
% 20250806 沖縄用データに大幅改造
% 単芯センサなのでnumbeamは常に1、ヘッドは将来的に複数になるので残す
%       
% 20250926 icenterpos(切り出し用の中心位置を保存した変数）を戻り値に加える
%
global mc;

% 引数の数をチェック
    if isempty(updateFcn)
        % 何も渡されなければ、ダミー関数にしておく
        updateFcn = @(varargin) [];
    end
    if isempty(isCanceled)
        % キャンセルチェックも同様に
        isCanceled = @() false;
    end



% iperiod_ref スキャン周期（測定点数で）
iperiod_ref = mc.WavDivided3Period;

% 20250728　追加 最後の切りだしで使用する
% 偶数奇数のずれを補正する
iyokohosei = floor(mc.iyokohosei);

%%

% 周期検出
ix = 1;
haba = 8192*8;
num=length(ya0(ix, :));
numcenter = floor(num/2);
if(numcenter>haba)
    haba = haba/2;
end


ytmp = ya0(ix, (numcenter - haba):(numcenter +haba-1));
ytmp = ytmp - mean(ytmp);
ytmp1 = ifft(abs(fft(ytmp)).^2);
figure(2);clf;plot(ytmp1);
figure(3);clf;plot(ytmp);
iskip = floor(iperiod_ref *0.75 );

%[peak, ipeak] = max(ytmp1(iskip:length(ytmp1)/2));
[peak, ipeak] = max(ytmp1(iskip:floor(iperiod_ref*1.25)));
ipeak = ipeak + iskip -1;

fprintf('ipeak = %d, period = %g\n', ipeak, ipeak * dxa0);

iperiod = ipeak;
iperiod = floor(iperiod/2+0.5)*2; %% 偶数化

if(abs(iperiod_ref - iperiod)/iperiod_ref > 0.05)
    fprintf('スキャン周期の判定で間違っているかも\n');
    fprintf('iperiod = %d, スキャンレンジ %f (mm)\n\n', iperiod, iperiod * dxa0 *scanv);
    iperiod = iperiod_ref;
    fprintf('修正　iperiod = %d, スキャンレンジ %f (mm)\n\n', iperiod, iperiod * dxa0 *scanv);
end

%%
%%% データをほどく作業
% ほどいたデータを入れる

ioffset = floor(iperiod/10); %% 
numdispya1 = floor(xrange/scanv/dxa0); % この範囲分を切り出して格納
numdispya1 = floor(numdispya1/2)*2; % 偶数化

icenterpos= zeros(numhead, iscannum);
icenterposhosei = zeros(numhead, iscannum);

% LPF 
%sfcutoff = 0.25;
%ya0lpf = lowpass(ya0, sfcutoff, scanv*dxa0);
%figure(19);clf;
%plot(ya0(10, :));
%plot(ya0lpf(10,:));hold on;
%ya0 = ya0lpf;

%%

% エッジ検出用の段差パラメータ 
%  threshold = 0.2;
threshold = mc.threshold;

% ヘッドごとに切り出し開始位置を検出し、ほどいたデータを格納
ipeakL = zeros(numhead, iscannum);
ipeakR = zeros(numhead, iscannum);
ipeaklevelL = zeros(numhead, iscannum);
ipeaklevelR = zeros(numhead, iscannum);

shippai = zeros(numhead, iscannum);


for ih=1:numhead
    fignum = 3+ih*mc.WavDivided3AllReadDataDraw;

    ipeak = zeros(numhead, 1);
    figure(fignum);clf;
    % まず、左側のエッジのピークを見つける
    %for ib = 1:numbeam
        ix = (ih-1) + 1;
        ipeak(ix) = findfirstleftpeak(ya0(ix,:), threshold);
        figure(fignum);hold on;
        plot(ya0(ix, 1:iperiod*5)-0.1*ih);
        plot(ipeak(ix), ya0(ix,ipeak(ix))-0.1*ih, '*');
        title(sprintf('head# %d', ih));
    %end

    ipmean = mean(ipeak);
    %itmp = 0;
    %icount = 0;
    %for ib = 1:numbeam
    %    if(abs(ipeak(ib)-ipmean)<iperiod/10)
    %        icount = icount + 1;
    %        itmp = itmp + ipeak(ib);
    %    end
    %end
    
    %if(icount==0)
    %    icenterpos(ih, :) = -1;
    %    fprintf('ih %d \n', ih);
    %    for jx = 1:numbeam
    %        fprintf('ipeak(%d) = %d\n', jx, ipeak(jx));
    %    end
    %   continue;
    %end
    
    %ipmean = floor(itmp/icount); % ipmeanが左端のピーク位置
    
    fprintf('ih %d, ipmean %d\n', ih, ipmean);
    

    
    % 
    
    newscanrange = floor(350/(scanv*dxa0)/2)*2;
    for iq =1:iscannum
        if(iq==1) %　エッジ検出するスタート位置を決める
            istart = ipmean-ioffset;
        else 
            %if(iq==2)
                istart = icenterpos(ih, iq-1) + iperiod - floor(newscanrange/2);
            %else
            %    istart = icenterpos(ih, iq-2) + iperiod*2 - floor(newscanrange/2);
            %%end
        end
        
        if(istart + iperiod > num)
            iscannum = iq-1;
            mc.iscannum = iscannum;
            fprintf('iscannum is changed to %d\n', iscannum);
            break;
        end

        %for ib = 1:numbeam
            ix = (ih-1)*numbeam + 1;
            [ipeakL(ih, iq), ipeaklevelL(ih, iq)] = ...
                findleftpeak4(ya0(ix, :), istart, newscanrange/2, threshold);
            [ipeakR(ih, iq), ipeaklevelR(ih, iq)] = ...
                findrightpeak4(ya0(ix, :), istart+newscanrange, newscanrange/2, threshold);
        
            %fprintf('ix %d, ib %d, L %ds R %d\n', ix, ib, ipeakL(ib), ipeakR(ib));
            %figure(fignum);hold on;
            % if(ipeakL(ib)~=0)
            %     plot(ipeakL(ib), ya0(ix,ipeakL(ib))-0.1*ib, 'x');
            % end
            % if(ipeakR(ib)~=0)
            %     plot(ipeakR(ib), ya0(ix,ipeakR(ib))-0.1*ib, 'o');
            % end
        %end

        ipmeanL = ipeakL(ih, iq);
        ipmeanR = ipeakR(ih, iq);
        if(iq>1)
            iwaferwidth0 = iwaferwidthnow;
        end    
        iwaferwidthnow = ipmeanR - ipmeanL;
        newcenter = floor((ipmeanL+ipmeanR)/2);
        
        % 途中経過の更新
        if mod(iq,10)==0
            updateFcn(iq/iscannum, sprintf('処理中... (%d/%d)', iq, iscannum));
        end

        % キャンセル対応
        if isCanceled()
            updateFcn(0, 'キャンセルしています...');
            return;
        end



        if(iq >2)
            wafersizefault = 0;
            fprintf('iq %d, iw0 %d, iwnow %d\n', iq, iwaferwidth0, iwaferwidthnow);

            if(abs(iwaferwidthnow-iwaferwidth0)>(5/dxa0/scanv))
                % 右エッジと左エッジの差からウエハ横幅を計算し
                % 一つまえの横幅と5mm以上違っていたら、何かおかしいと判断
                wafersizefault = 1;

                figure(7);clf;
                plot((istart:istart+iperiod), ya0(ix, istart:istart+iperiod));
                hold on;
                plot(newcenter, ya0(ix, newcenter), 'x');
                plot(ipmeanR, ya0(ix, ipmeanR), 'x');
                plot(ipmeanL, ya0(ix, ipmeanL), 'x');
                
                % 2つ前のデータの右エッジ、左エッジの位置の差を計算
                idiffL = abs(ipeakL(ih, iq) - ipeakL(ih, iq-2) - iperiod *2);
                idiffR = abs(ipeakR(ih, iq) - ipeakR(ih, iq-2) - iperiod *2);
                fprintf('hosei>>idiffL %d idiffR %d \n', idiffL, idiffR);
                
                idiffth = 900;%一つ前のエッジ位置との差が大きすぎないかチェック
                
                if(idiffR<idiffL) 
                    if(idiffR > idiffth) %右端を信じてよいか
                        %　右側の方が信じられそう
                        flagright = 1;
                    else
                        % どちらを信じてよいかわからない
                        % ピークの大きい方を信じる
                        shippai(ih, iq) = 1;
                        if(abs(ipeaklevelR(ih, iq))>abs(ipeaklevelL(ih, iq)))
                            flagright = 1;
                        else
                            flagright = 0;
                        end
                    end
                else
                    if(idiffL < idiffth) %左端を信じてよいか
                        %　左側の方が信じられそう
                        flagright = 0;
                    else
                        % どちらを信じてよいかわからない
                        % ピークの大きい方を信じる
                        shippai(ih, iq) = 1;
                        if(abs(ipeaklevelR(ih, iq))>abs(ipeaklevelL(ih, iq)))
                            flagright = 1;
                        else
                            flagright = 0;
                        end
                    end
                end
                if(flagright==1)
                    newcenter = ipmeanR - floor(iwaferwidth0/2);
                else
                    newcenter = ipmeanL + floor(iwaferwidth0/2);
                end
                
                iwaferwidthnow = iwaferwidth0;
                plot(newcenter, ya0(ix, newcenter), 'o');
                fprintf('  new newcenter %d\n', newcenter);
            end
            
            % if(wafersizefault ==1 & ...
            %   abs(newcenter - icenterpos(ih, iq-2) - iperiod*2) > 2000)
            %     %　もしサイズの補正が入り、且つ、中心位置がずれていた場合
            %     %  
            %     newiperiod = floor( ...
            %         mean(icenterpos(ih, 2:iq-1)- icenterpos(ih, 1:iq-2)));
            % 
            %     fprintf('hoseic> newcenter候補 %d, (差-1） %d,（差2） %d, newiperiod(ref) %d, iperiod  %d, iperiod*2 %d\n', ...
            %         newcenter, newcenter - icenterpos(ih, iq-1), newcenter - icenterpos(ih, iq-2), ...
            %         newiperiod, iperiod, iperiod*2);
            %     fprintf('  iq %d, oldiwafer %d, newwafer %d\n', ...
            %         iq, iwaferwidth0, iwaferwidthnow);
            % 
            %     figure(6);clf;
            %     plot((istart:istart+iperiod), ya0(ix, istart:istart+iperiod));
            %     hold on;
            %     plot(newcenter, ya0(ix, newcenter), 'x');
            %     plot(ipmeanR, ya0(ix, ipmeanR), 'x');
            %     plot(ipmeanL, ya0(ix, ipmeanL), 'x');
            % 
            %     newcenter = icenterpos(ih, iq-2)+ newiperiod*2;
            %     plot(newcenter, ya0(ix, newcenter), 'o');
            %     %if(iq>2800)
            %     %    pause();
            %     %end
            % 
            % end
        end
        icenterpos(ih, iq)=newcenter;
        
        %fprintf('ih  %d, iq  %d, L %d R %d ', ih, iq, ipmeanL, ipmeanR);
        %if(iq>1)
        %    fprintf('中心間隔 %d\n', icenterpos(ih, iq)-icenterpos(ih, iq-1));
        %else
        %    fprintf('中心位置 %d\n', icenterpos(ih, iq));
        %end

    end
    
    % debug 
    %figure(20+ih);clf;
    %for ib = 1:numbeam
    %   ix = (ih-1)*numbeam + ib;
    %   plot(ya0(ix, :));hold on;
    %end
    %pause();
end
%%
% for debug
save('ictemp.mat', 'icenterpos', 'ipeakR', 'ipeaklevelR', 'ipeakL', "ipeaklevelL");

figure(5);clf;
tmpperiod = icenterpos(1, 2:end)-icenterpos(1, 1:end-1);
plot(tmpperiod(1:2:end), 'x');hold on;
plot(tmpperiod(2:2:end), 'o');hold on;

icodd = icenterpos(1, 1:2:end);
iceven = icenterpos(1, 2:2:end);
figure(6);clf;
tmpperiododd = icodd(1, 2:end)-icodd(1, 1:end-1);
tmpperiodeven = iceven(1, 2:end)-iceven(1, 1:end-1);
plot(tmpperiododd, 'x');hold on;
plot(tmpperiodeven, 'o');hold on;





%%
% 切り出し
numya1 = numy *iscannum;
ya1 = zeros(numya1, numdispya1);

[ixya0, iyya0] = size(ya0);
for ih=1:numhead
    for iq =1:iscannum
        for ib = 1:numbeam
            ix = (ih-1)*numbeam + ib;
            iscan = (ix-1)*iscannum+iq;
            itmp = icenterpos(ih, iq)-numdispya1/2;

            if(itmp < 0)
                itmp = icenterpos(ih-2, iq)-numdispya1/2;
            end
            if(mod(iq,2)==1) % 偶奇で処理を変える
                if(itmp <= 0 || itmp + numdispya1 -1 >= iyya0)
                    itmp = 1; % 範囲外になったときにはあきらめて適当なデータを表示
                end
                ya1tmp = ya0(ix, itmp:(itmp+numdispya1-1));
                ya1(iscan, :) = ya1tmp;
            else
                itmp = itmp + iyokohosei;
                if(itmp <= 0 || itmp + numdispya1 -1>= iyya0)
                    itmp = 1; % 範囲外になったときにはあきらめて適当なデータを表示
                end
                ya1tmp = ya0(ix, itmp:(itmp+numdispya1-1));
                ya1(iscan, :) = flip(ya1tmp);
            end
        end
    end
end

%　エッジ検出で失敗したところは一つ前のデータで置き換える
for ih=1:numhead
    for iq =1:iscannum
        if(shippai(ih, iq)==1)
            iscan = (ih-1)*iscannum+iq;
            if(iscan > 1)
                ya1(iscan, :) = ya1(iscan-1, :);
            end
        end
    end
end

end


%%%%%%%%%%%%%
function [ipeak, peakval] = findleftpeak4(ya0, is, iperiod, th)

% fprintf('is %d iperiod %d, th %f\n', is, iperiod, th);

yref = mean(ya0(1:100));
for iloop = 1:20
    for iq = is:is+iperiod
        if(iq>length(ya0))
            fprintf('iq = %d\n', iq);
            peakval = ya0(iq)-yref;
            ipeak = is;
            return;
        end

        if(abs(ya0(iq)-yref) > th)
            ipeak = iq;
            peakval = ya0(iq)-yref;
            return;
        end
    end
    th = th * 0.8;
end

ipeak = 0;
peakval = 1000;
return;

end
%%%%%%%%%%%%%%%%%%%%%
function [ipeak, peakval] = findrightpeak4(ya0, is, iperiod, th)


if(is>length(ya0))
    is = length(ya0);
end

yref = mean(ya0(1:100));

for iloop = 1:20
    for iq = is:-1:is-iperiod+1
        if(abs(ya0(iq)-yref) > th)
            ipeak = iq;
            peakval = ya0(iq)-yref;
            return;
        end
    end
    th = th * 0.8;
end

ipeak = 0;
peakval = 1000;
return;

end
