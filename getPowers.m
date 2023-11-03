function [powPlt, times, trigS, trigE] = getPowers(...
                        subjectPowers, maxSubjectDataPts, ...
                        ttlPowHist, alphaPowHist, betaPowHist, ...
                        deltaPowHist, thetaPowHist, gammaPowHist, ...
                        e_channels, subjectID)
%     if subjectID == 4
%         if isequal(e_channels, [9,16,20])
%             e_channels = [8,14,18];
%         elseif isequal(e_channels, [2,3,4,28,29])
%             e_channels = [2,3,4,25,26];
%         elseif isequal(e_channels, [7,23,24])
%             e_channels = [6,21,22]; %22 23      
%         elseif isequal(e_channels, [12,13,14,18,19])
%             e_channels = [11,12,16,17];
%         elseif isequal(e_channels, [11,15,17])
%             e_channels = [10,13,15];
%         else
%             e_channels
%             disp(['Error: No channels matched S04'])       
%         end
%     end
%     if subjectID == 17
%         if isequal(e_channels, [9,16,20])
%             e_channels = [8,15,19];
%         elseif isequal(e_channels, [2,3,4,28,29])
%             e_channels = [2,3,4,27,28];
%         elseif isequal(e_channels, [7,23,24])
%             e_channels = [6,22,23]; % 23 24      
%         elseif isequal(e_channels, [12,13,14,18,19])
%             e_channels = [11,12,13,17,18];
%         elseif isequal(e_channels, [11,15,17])
%             e_channels = [10,14,16];
%         else
%             disp(['Error: No channels matched S17'])       
%         end
%     end
    % Get the electrode-averaged cerebellar power
%     if strcmp(mode, 'Abs')
    powPlt.ttlPow = mean(ttlPowHist(e_channels,:));
    powPlt.alphaPow = mean(alphaPowHist(e_channels,:));
    powPlt.betaPow = mean(betaPowHist(e_channels,:));
    powPlt.deltaPow = mean(deltaPowHist(e_channels,:));
    powPlt.thetaPow = mean(thetaPowHist(e_channels,:));
    powPlt.gammaPow = mean(gammaPowHist(e_channels,:));
%     end
%     if strcmp(mode, 'Rel')
%         powPlt.ttlPow = mean(ttlPowHist(e_channels,:));
%         powPlt.alphaPow = mean(alphaPowHist(e_channels,:))./powPlt.ttlPow;
%         powPlt.betaPow = mean(betaPowHist(e_channels,:)./powPlt.ttlPow);
%         powPlt.deltaPow = mean(deltaPowHist(e_channels,:))./powPlt.ttlPow;
%         powPlt.thetaPow = mean(thetaPowHist(e_channels,:))./powPlt.ttlPow;
%         powPlt.gammaPow = mean(gammaPowHist(e_channels,:))./powPlt.ttlPow;
%     end
    
    % Get the time vec
    ts = subjectPowers('TimeVec'); %endTime = ts(end);
    trigTs = subjectPowers('Triggers');
    trigS = (trigTs(:,1)/trigTs(end,2)*28);
    trigE = (trigTs(:,2)/trigTs(end,2)*28);
    % To do: index the corresponding indexes in ts 
    
    ts_new = linspace(0, 1680, maxSubjectDataPts)'; 
    ts_new_pre = ts_new(ts_new<=240);
    ts_new_adapt = ts_new(logical((ts_new>=240).*(ts_new<=1440)));
    ts_new_post = ts_new(ts_new>=1440);
    
    ts_old_pre = ts(ts<=240);
    ts_old_adapt = ts(logical((ts>=240).*(ts<=1440)));
    ts_old_post = ts(ts>=1440);
    
    overlapPercent = 0.8; windowWidth = 60; % 120 before
    
    alpha_pow_pre = powPlt.alphaPow(ts<=240);
    alpha_pow_adapt = powPlt.alphaPow(logical((ts>=240).*(ts<=1440)));
    alpha_pow_post = powPlt.alphaPow(ts>=1440); 
    temp_pre = interp1(ts_old_pre, alpha_pow_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, alpha_pow_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, alpha_pow_post, ts_new_post);
    [result,z] = buffer(temp_pre, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_pre = mean(result)';
    [result,z] = buffer(temp_adapt, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_adapt = mean(result)';
    [result,z] = buffer(temp_post, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_post = mean(result)';
    temp = [temp_pre; temp_adapt; temp_post];
    powPlt.alphaPow = fillmissing(temp, 'nearest'); 
    % pchip
    
    beta_pow_pre = powPlt.betaPow(ts<=240);
    beta_pow_adapt = powPlt.betaPow(logical((ts>=240).*(ts<=1440)));
    beta_pow_post = powPlt.betaPow(ts>=1440); 
    temp_pre = interp1(ts_old_pre, beta_pow_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, beta_pow_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, beta_pow_post, ts_new_post);
    [result,z] = buffer(temp_pre, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_pre = mean(result)';
    [result,z] = buffer(temp_adapt, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_adapt = mean(result)';
    [result,z] = buffer(temp_post, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_post = mean(result)';
    temp = [temp_pre; temp_adapt; temp_post];
    powPlt.betaPow = fillmissing(temp, 'nearest'); 
    
    delta_pow_pre = powPlt.deltaPow(ts<=240);
    delta_pow_adapt = powPlt.deltaPow(logical((ts>=240).*(ts<=1440)));
    delta_pow_post = powPlt.deltaPow(ts>=1440); 
    temp_pre = interp1(ts_old_pre, delta_pow_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, delta_pow_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, delta_pow_post, ts_new_post);
    [result,z] = buffer(temp_pre, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_pre = mean(result)';
    temp_pre = fillmissing(temp_pre, 'nearest');
    [result,z] = buffer(temp_adapt, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_adapt = mean(result)';
    temp_adapt = fillmissing(temp_adapt, 'nearest');
    [result,z] = buffer(temp_post, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_post = mean(result)';
    temp_post = fillmissing(temp_post, 'nearest');
    powPlt.deltaPow = [temp_pre; temp_adapt; temp_post];
    % temp = [temp_pre; temp_adapt; temp_post];
%     powPlt.deltaPow = fillmissing(temp, 'nearest');
%     powPlt.deltaPow = fillmissing(temp, 'constant', 0);
    
    tn_pre = linspace(0, 4, length(temp_pre))';
    tn_adapt = linspace(4, 24, length(temp_adapt))';
    tn_post = linspace(24, 28, length(temp_post))';
    times = [tn_pre; tn_adapt; tn_post];
    
    theta_pow_pre = powPlt.thetaPow(ts<=240);
    theta_pow_adapt = powPlt.thetaPow(logical((ts>=240).*(ts<=1440)));
    theta_pow_post = powPlt.thetaPow(ts>=1440); 
    temp_pre = interp1(ts_old_pre, theta_pow_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, theta_pow_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, theta_pow_post, ts_new_post);
    [result,z] = buffer(temp_pre, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_pre = mean(result)';
    [result,z] = buffer(temp_adapt, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_adapt = mean(result)';
    [result,z] = buffer(temp_post, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_post = mean(result)';
    temp = [temp_pre; temp_adapt; temp_post];
    powPlt.thetaPow = fillmissing(temp, 'nearest');
    
    gamma_pow_pre = powPlt.gammaPow(ts<=240);
    gamma_pow_adapt = powPlt.gammaPow(logical((ts>=240).*(ts<=1440)));
    gamma_pow_post = powPlt.gammaPow(ts>=1440); 
    temp_pre = interp1(ts_old_pre, gamma_pow_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, gamma_pow_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, gamma_pow_post, ts_new_post);
    [result,z] = buffer(temp_pre, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_pre = mean(result)';
    [result,z] = buffer(temp_adapt, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_adapt = mean(result)';
    [result,z] = buffer(temp_post, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_post = mean(result)';
    temp = [temp_pre; temp_adapt; temp_post];
    powPlt.gammaPow = fillmissing(temp, 'nearest');
    
    ttl_pow_pre = powPlt.ttlPow(ts<=240);
    ttl_pow_adapt = powPlt.ttlPow(logical((ts>=240).*(ts<=1440)));
    ttl_pow_post = powPlt.ttlPow(ts>=1440); 
    temp_pre = interp1(ts_old_pre, ttl_pow_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, ttl_pow_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, ttl_pow_post, ts_new_post);
    [result,z] = buffer(temp_pre, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_pre = mean(result)';
    [result,z] = buffer(temp_adapt, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_adapt = mean(result)';
    [result,z] = buffer(temp_post, windowWidth, ...
                     round(windowWidth*overlapPercent),'nodelay');
    temp_post = mean(result)';
    temp = [temp_pre; temp_adapt; temp_post];
    powPlt.ttlPow = fillmissing(temp, 'nearest');
    
%     temp = interp1(ts_adapt, powPlt.betaPow, ts_new);
%     powPlt.betaPow = fillmissing(temp, 'pchip');
%     temp = interp1(ts_adapt, powPlt.deltaPow, ts_new);
%     powPlt.deltaPow = fillmissing(temp, 'pchip');
%     temp = interp1(ts_adapt, powPlt.thetaPow, ts_new);
%     powPlt.thetaPow = fillmissing(temp, 'pchip');
%     temp = interp1(ts_adapt, powPlt.gammaPow, ts_new);
%     powPlt.gammaPow = fillmissing(temp, 'pchip');
%     temp = interp1(ts_adapt, powPlt.ttlPow, ts_new);
%     powPlt.ttlPow = fillmissing(temp, 'pchip');
    
%     overlapPercent = 0.0; windowWidth = 30; % 120 before
%     [result,z] = buffer(powPlt.alphaPow, windowWidth, ...
%                      round(windowWidth*overlapPercent),'nodelay');
%     powPlt.alphaPow = mean(result)';
%     [result,z] = buffer(powPlt.betaPow, windowWidth, ...
%                      round(windowWidth*overlapPercent),'nodelay');
%     powPlt.betaPow = mean(result)';
%     [result,z] = buffer(powPlt.deltaPow, windowWidth, ...
%                      round(windowWidth*overlapPercent),'nodelay');
%     powPlt.deltaPow = mean(result)';
%     [result,z] = buffer(powPlt.thetaPow, windowWidth, ...
%                      round(windowWidth*overlapPercent),'nodelay');
%     powPlt.thetaPow = mean(result)';
%     [result,z] = buffer(powPlt.gammaPow, windowWidth, ...
%                      round(windowWidth*overlapPercent),'nodelay');
%     powPlt.gammaPow = mean(result)';
%     [result,z] = buffer(powPlt.ttlPow, windowWidth, ...
%                      round(windowWidth*overlapPercent),'nodelay');
%     powPlt.ttlPow = mean(result)';

%     times = linspace(0, 20, length(powPlt.thetaPow))';
    
%     plot(t, powPlt.deltaPow);
% t = linspace(0, 28, length(powPlt.deltaPow))';
end