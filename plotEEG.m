clear; clc; close all;

addpath('C:\Users\Ahmad\Documents\New folder\eeglab_current\eeglab2023.0');
eeglab; fs = 1000;

cnl1 = 17; cnl2 = 14;

data1 = double(ALLEEG(1).data); % Raw
data2 = double(ALLEEG(2).data); % Cleaned
data3 = double(ALLEEG(3).data);
eegData1 = data1(cnl1, :); %
eegData2 = data2(cnl2, :);
eegData3 = data3(cnl2, :);
t = 1/fs:1/fs:length(eegData1)/fs;
t1 = 400; t2 = t1+40;
figure('Position', [40,40,1600,800]); 
subplot(2,1,1); hold on;
plot(t, eegData1, 'Color', [1 0 0 0.8]); 
plot(t, eegData2, 'Color', [0 0 1 1]); hold off;
xlim([t1, t2]);
legend('Raw', 'Cleaned: entire dataset'); 
set(gca,'FontSize',18); 
subplot(2,1,2); hold on;
plot(t, eegData1, 'Color', [1 0 0 0.8]); 
plot(t, eegData3, 'Color', [0 0 0 1]); hold off;
legend('Raw', 'Cleaned: individual trial');
xlim([t1, t2]);
set(gca,'FontSize',18);

% To do: pre, adapt, post correlation plots

eegData = ALLEEG(end).data;
for chnl = 1:26
    eegData(chnl, :) = eegData(chnl, :) - ...
                       mean(eegData(chnl, :));
end
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);




