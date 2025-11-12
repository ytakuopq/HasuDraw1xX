function ipeak = findfirstleftpeak(ya0, th)

num = length(ya0);
is = 100;
yref = mean(ya0(1:is));

for iloop = 1:4
    for iq = is:num
        if(ya0(iq)<-0.4)
            continue;
        end

        if(abs(ya0(iq)-yref) > th)
            ipeak = iq;
            return;
        end
    end
    th = th * 0.8;
end
ipeak = 1;
return;

end
