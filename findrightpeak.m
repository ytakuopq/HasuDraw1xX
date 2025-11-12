function ipeak = findrightpeak(ya0, is, iperiod, th)


if(is>length(ya0))
    is = length(ya0);
end

yref = mean(ya0(is-floor(iperiod/20):is));

    for iq = is:-1:is-iperiod+1
        if(abs(ya0(iq)-yref) > th)
            ipeak = iq;
            return;
        end
    end

ipeak = 0;
return;

end
