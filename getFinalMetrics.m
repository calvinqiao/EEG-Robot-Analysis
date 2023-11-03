function [yl, alphaFinal, betaFinal, deltaFinal, ...
          gammaFinal, thetaFinal, ttlFinal] = getFinalMetrics(...
                                    pow, baseline, pltMode, ...
                                    pwrMode)
%     fig = figure('Position',[200,50,1440,840]);
%     hold on; 
%     xline(trigs(:,2), '--k'); xlim([0,28])
    if strcmp(pltMode, 'Percent Change')
        if strcmp(pwrMode, 'Abs')
            alphaFinal = 100*(pow.alphaPow-baseline.alpha)/baseline.alpha;
            betaFinal = 100*(pow.betaPow-baseline.beta)/baseline.beta;
            deltaFinal = 100*(pow.deltaPow-baseline.delta)/baseline.delta;
            gammaFinal = 100*(pow.gammaPow-baseline.gamma)/baseline.gamma;
            thetaFinal = 100*(pow.thetaPow-baseline.theta)/baseline.theta;
            ttlFinal = 100*(pow.ttlPow-baseline.total)/baseline.total;
        elseif strcmp(pwrMode, 'Rel')
            alphaFinal = 100*(pow.alphaPow-baseline.alpha/baseline.total)/...
                         (baseline.alpha/baseline.total);
            betaFinal = 100*(pow.betaPow-baseline.beta/baseline.total)/...
                        100*(baseline.beta/baseline.total);
            deltaFinal = 100*(pow.deltaPow-baseline.delta/baseline.total)/...
                         (baseline.delta/baseline.total);
            gammaFinal = 100*(pow.gammaPow-baseline.gamma/baseline.total)/...
                         (baseline.gamma/baseline.total);
            thetaFinal = 100*(pow.thetaPow-baseline.theta/baseline.total)/...
                         (baseline.theta/baseline.total);
            ttlFinal = 100*(pow.ttlPow-baseline.total/baseline.total)/...
                         (baseline.total/baseline.total); % No use
        end
        yl = 'Increase (%)';
    elseif strcmp(pltMode, 'Absolute Change')
        if strcmp(pwrMode, 'Abs')
            alphaFinal = pow.alphaPow;
            betaFinal = pow.betaPow;
            deltaFinal = pow.deltaPow;
            gammaFinal = pow.gammaPow;
            thetaFinal = pow.thetaPow;
            ttlFinal = pow.ttlPow;
            yl = 'Power (mV^2/Hz)';
        elseif strcmp(pwrMode, 'Rel')
            alphaFinal = 100*pow.alphaPow./pow.ttlPow;
            betaFinal = 100*pow.betaPow./pow.ttlPow;
            deltaFinal = 100*pow.deltaPow./pow.ttlPow;
            gammaFinal = 100*pow.gammaPow./pow.ttlPow;
            thetaFinal = 100*pow.thetaPow./pow.ttlPow;
            ttlFinal = 100*pow.ttlPow./pow.ttlPow; % No use
            yl = 'Band / total power (%)'; 
        end
    end
    
%     subplot(4,5,iSubject);
%     switch band
%     case 'delta'
%         plot(times, deltaFinal,'-', 'LineWidth',LN);1 
%     case 'theta'
%         plot(times, thetaFinal,'-', 'LineWidth',LN);2
%     case 'alpha'
%         plot(times, alphaFinal,'-', 'LineWidth',LN);3
%     case 'beta'
%         plot(times, betaFinal,'-', 'LineWidth',LN);4
%     case 'gamma'
%         plot(times, gammaFinal,'-', 'LineWidth',LN); 5
%     otherwise
%         disp('other value')
%     end
    
%     xticks([0,4,24,28]); xlim([0,28]);
%     xlabel('Time (minute)'); ylabel(yl); 
%     set(gca,'FontSize',28); grid on; 
end
