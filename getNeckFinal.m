function [yl, neckFinal] ...
  = getNeckFinal(neck, baseline, pltMode, chnl)
    if chnl == 1
       base = baseline.c1; 
    elseif chnl == 2
       base = baseline.c2; 
    end
    if strcmp(pltMode, 'Percent Change')
        neckFinal = 100*(neck-base)/base;
        yl = 'Percent (%)'; 
    elseif strcmp(pltMode, 'Absolute Change')
        neckFinal = neck;
        yl = 'uV'; 
    end
end