function [neck1, neck2, times, trigS, trigE] = getNecks(subjectNecks, ...
                            maxSubjectDataPts, ...
                            c1NeckHist, c2NeckHist)
                        
   neck1 = c1NeckHist; neck2 = c2NeckHist;
   
   ts = subjectNecks('TimeVec');
   trigTs = subjectNecks('Triggers');
   trigS = (trigTs(:,1)/trigTs(end,2)*28);
   trigE = (trigTs(:,2)/trigTs(end,2)*28); 
    
   ts_new = linspace(0, 1680, maxSubjectDataPts)'; 
   ts_new_pre = ts_new(ts_new<=240);
   ts_new_adapt = ts_new(logical((ts_new>=240).*(ts_new<=1440)));
   ts_new_post = ts_new(ts_new>=1440);
    
   ts_old_pre = ts(ts<=240);
   ts_old_adapt = ts(logical((ts>=240).*(ts<=1440)));
   ts_old_post = ts(ts>=1440);
    
   overlapPercent = 0.8; windowWidth = 60; % 120 before  
   
   neck1_pre = neck1(ts<=240);
   neck1_adapt = neck1(logical((ts>=240).*(ts<=1440)));
   neck1_post = neck1(ts>=1440); 
   temp_pre = interp1(ts_old_pre, neck1_pre, ts_new_pre);
   temp_adapt = interp1(ts_old_adapt, neck1_adapt, ts_new_adapt);
   temp_post = interp1(ts_old_post, neck1_post, ts_new_post);
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
   neck1 = fillmissing(temp, 'nearest');
   
   neck2_pre = neck2(ts<=240);
   neck2_adapt = neck2(logical((ts>=240).*(ts<=1440)));
   neck2_post = neck2(ts>=1440); 
   temp_pre = interp1(ts_old_pre, neck2_pre, ts_new_pre);
   temp_adapt = interp1(ts_old_adapt, neck2_adapt, ts_new_adapt);
   temp_post = interp1(ts_old_post, neck2_post, ts_new_post);
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
   neck2 = fillmissing(temp, 'nearest');
   
   tn_pre = linspace(0, 4, length(temp_pre))';
   tn_adapt = linspace(4, 24, length(temp_adapt))';
   tn_post = linspace(24, 28, length(temp_post))';
   times = [tn_pre; tn_adapt; tn_post];
                                            
end