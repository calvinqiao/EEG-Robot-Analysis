function [alphaCohs, betaCohs, ...
        deltaCohs, gammaCohs, thetaCohs, ttlCohs, times] = ...
        processCohs(alphaCohs, betaCohs, ...
        deltaCohs, gammaCohs, thetaCohs, ttlCohs, ...
        ts, maxSubjectDataPts)
    
    ts_new = linspace(0, 1680, maxSubjectDataPts)'; 
    
    ts_new_pre = ts_new(ts_new<=240);
    ts_new_adapt = ts_new(logical((ts_new>=240).*(ts_new<=1440)));
    ts_new_post = ts_new(ts_new>=1440);
    
    ts_old_pre = ts(ts<=240);
    ts_old_adapt = ts(logical((ts>=240).*(ts<=1440)));
    ts_old_post = ts(ts>=1440);
    
    overlapPercent = 0.8; windowWidth = 200; % 120 before
    
    alpha_coh_pre = alphaCohs(ts<=240);
    alpha_coh_adapt = alphaCohs(logical((ts>=240).*(ts<=1440)));
    alpha_coh_post = alphaCohs(ts>=1440); 
    temp_pre = interp1(ts_old_pre, alpha_coh_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, alpha_coh_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, alpha_coh_post, ts_new_post);
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
    alphaCohs = fillmissing(temp, 'nearest');
    
    tn_pre = linspace(0, 4, length(temp_pre))';
    tn_adapt = linspace(4, 24, length(temp_adapt))';
    tn_post = linspace(24, 28, length(temp_post))';
    times = [tn_pre; tn_adapt; tn_post];
    
    beta_coh_pre = betaCohs(ts<=240);
    beta_coh_adapt = betaCohs(logical((ts>=240).*(ts<=1440)));
    beta_coh_post = betaCohs(ts>=1440); 
    temp_pre = interp1(ts_old_pre, beta_coh_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, beta_coh_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, beta_coh_post, ts_new_post);
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
    betaCohs = fillmissing(temp, 'nearest'); 
    
    delta_coh_pre = deltaCohs(ts<=240);
    delta_coh_adapt = deltaCohs(logical((ts>=240).*(ts<=1440)));
    delta_coh_post = deltaCohs(ts>=1440); 
    temp_pre = interp1(ts_old_pre, delta_coh_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, delta_coh_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, delta_coh_post, ts_new_post);
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
    deltaCohs = fillmissing(temp, 'nearest'); 
    
    gamma_coh_pre = gammaCohs(ts<=240);
    gamma_coh_adapt = gammaCohs(logical((ts>=240).*(ts<=1440)));
    gamma_coh_post = gammaCohs(ts>=1440); 
    temp_pre = interp1(ts_old_pre, gamma_coh_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, gamma_coh_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, gamma_coh_post, ts_new_post);
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
    gammaCohs = fillmissing(temp, 'nearest'); 
    
    theta_coh_pre = thetaCohs(ts<=240);
    theta_coh_adapt = thetaCohs(logical((ts>=240).*(ts<=1440)));
    theta_coh_post = thetaCohs(ts>=1440); 
    temp_pre = interp1(ts_old_pre, theta_coh_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, theta_coh_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, theta_coh_post, ts_new_post);
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
    thetaCohs = fillmissing(temp, 'nearest');
    
    ttl_coh_pre = ttlCohs(ts<=240);
    ttl_coh_adapt = ttlCohs(logical((ts>=240).*(ts<=1440)));
    ttl_coh_post = ttlCohs(ts>=1440); 
    temp_pre = interp1(ts_old_pre, ttl_coh_pre, ts_new_pre);
    temp_adapt = interp1(ts_old_adapt, ttl_coh_adapt, ts_new_adapt);
    temp_post = interp1(ts_old_post, ttl_coh_post, ts_new_post);
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
    ttlCohs = fillmissing(temp, 'nearest');
    
end