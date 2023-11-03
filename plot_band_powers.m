function fig = PlotPowersSub(ttlCereSubjects, ...
                             deltaCereSubjects, ...
                             thetaCereSubjects, ...
                             alphaCereSubjects, ...
                             betaCereSubjects, ...
                             gammaCereSubjects, yl)
x = 1:28; lw = 4;
fig = figure('Position',[50,50,2400,600]);
for i = 1:6
   subplot(2,3,i);
   switch i
       case 1
           y = nanmean(ttlCereSubjects);
           sigma = nanstd(ttlCereSubjects); 
           lgd = 'Total (1-50 Hz)'; c = 'k';
       case 2
           y = nanmean(deltaCereSubjects);
           sigma = nanstd(deltaCereSubjects);
           lgd = 'Delta (1-4 Hz)'; c = 'b';
       case 3 
           y = nanmean(thetaCereSubjects);
           sigma = nanstd(thetaCereSubjects);
           lgd = 'Theta (4-8 Hz)'; c = 'r';
       case 4
           y = nanmean(alphaCereSubjects);
           sigma = nanstd(alphaCereSubjects);
           lgd = 'Alpha (8-13 Hz)'; c = 'g';
       case 5
           y = nanmean(betaCereSubjects);
           sigma = nanstd(betaCereSubjects);
           lgd = 'Beta (13-30 Hz)'; c = 'm';
       case 6
           y = nanmean(gammaCereSubjects);
           sigma = nanstd(gammaCereSubjects);
           lgd = 'Gamma (30-50 Hz)'; c = 'c';
   end
   curve1 = y + sigma; 
   curve2 = y - sigma;
   x2 = [x, fliplr(x)]; inBetween = [curve1, fliplr(curve2)];
   fill(x2, inBetween, 'k','FaceAlpha',0.08, ...
        'LineStyle','none'); hold on;
   plot(x, y, 'LineWidth', lw, 'Color', c); legend('',lgd);
   xticks([1,4,5,24,25,28]); xlim([1,28]);
   xlabel('Time (minute)'); ylabel(yl); 
   set(gca,'FontSize',14); grid on;
end
  