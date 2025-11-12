function ipeak = findleftpeak(ya0, is, iperiod, th)

% fprintf('is %d iperiod %d, th %f\n', is, iperiod, th);

yref = mean(ya0(is:is+floor(iperiod/20)));

for iq = is:is+iperiod
    if(iq>length(ya0))
        fprintf('iq = %d\n', iq);
        ipeak = is;
        return;
    end
    
    if(abs(ya0(iq)-yref) > th)
        ipeak = iq;
        return;
    end
end

ipeak = 0;
return;

end
