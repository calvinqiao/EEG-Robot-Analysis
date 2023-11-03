clear; clc; close all;

addpath('C:\Users\calvi\Documents\EEG adaptation\eeglab_current\eeglab2023.0');
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

EEG = pop_loadset('filename','Trial2_raw.set','filepath', ...
      'C:\\Users\\calvi\\Documents\\EEG adaptation\\analysis\\subjects\\S07\\eeg\\');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

cleanedEEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );

d_old = double(EEG.data);
d_new = double(cleanedEEG.data);
cbl_old = d_old(10,:); cbl_new = d_new(9,:);
figure; plot(cbl_old); hold on; plot(cbl_new);

EEG = pop_chanedit(EEG, 'rplurchanloc',CURRENTSET,'load',...
        {'ChannelLoc1208.ced','filetype','autodetect'});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

options = {};
opt.FlatlineCriterion  = 5;
opt.ChannelCriterion   = 0.8;
opt.LineNoiseCriterion = 4;
opt.Highpass           = 'off';
opt.BurstCriterion     = 20;
opt.WindowCriterion    = 0.25;
opt.BurstRejection     = 'on';
opt.Distance           = 'Euclidian';
opt.channels_ignore    = [];
opt.WindowCriterionTolerances = [-Inf 7];
    
cleanEEG = clean_artifacts(EEG, options{:});
vis_artifacts(cleanEEG,EEG);

dataClean = double(cleanEEG.data);
dataOld = double(EEG.data);
d1 = dataClean(17,:); d2 = dataOld(17,:);
figure; plot(d1-mean(d1)); hold on; plot(d2-mean(d2));
a = [1 23 3]; b = [1 5 3];
std(d2)
% for iChannel = 1:32
%     thisChClean = 
%     diffs = find(cleanEEG ~= EEG);
% end

    
% EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,...
%                         'ChannelCriterion',0.8, ...
%                         'LineNoiseCriterion',4, ...
%                         'Highpass','off','BurstCriterion',20, ...
%                         'WindowCriterion',0.25,'BurstRejection','on', ...
%                         'Distance','Euclidian','channels_ignore',[], ...
%                         'WindowCriterionTolerances',[-Inf 7] );
eeglab redraw