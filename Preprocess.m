clear; clc; close all;
addpath('C:\Users\calvi\Documents\EEG_adaptation\eeglab_current\eeglab2023.0');
eeglab;

% Check raw data plots

subjects = [1 3 4 5 6 ... %  
            7 9 10 11 13 ...
            15 16 17 18 19 ... 
            21 22 23 24 25]; % At 4 
subjects = [99];

for iSubject = 1:length(subjects)
ALLEEG=[];
subjectID = subjects(iSubject)
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end
subjectDataDir = append(strcat('./subjects/', subjectIDstr, '/eeg/*.vhdr'));
nameList = dir(subjectDataDir); nTrials = length(nameList);
path = strcat('./subjects/', subjectIDstr, '/eeg/'); 

CHANNELS = 32; REF1 = 7; REF2 = 29; REF3 = 13;  
if subjectID == 4
%     CHANNELS = 27; REF1 = 7; REF2 = 28;
    CHANNELS = 29; REF1 = 6; REF2 = 26; REF3 = 12;  
end
if subjectID == 17
    CHANNELS = 31; REF1 = 6; REF2 = 28; REF3 = 12;  
end

% Open files
for trial = 1:nTrials 
    filename = nameList(trial).name
    EEG = pop_loadbv(path, filename, [], []);
    [ALLEEG EEG CURRENTSET] = ...
        pop_newset(ALLEEG, EEG, 0,'setname',filename,'gui','off'); 
    
    % Change channel locations
    EEG=pop_chanedit(EEG, 'rplurchanloc',CURRENTSET,'load',...
        {'ChannelLoc1208.ced','filetype','autodetect'});
    [ALLEEG EEG CURRENTSET] = ...
    pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');

%     EEG = pop_reref( EEG, [7 29]);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

    if subjectID == 4 
        EEG = pop_select( EEG, 'rmchannel',{'SPL'});
        EEG = pop_select( EEG, 'rmchannel',{'SPR'});
        EEG = pop_select( EEG, 'rmchannel',{'Pz'}); 
        [ALLEEG EEG CURRENTSET] = ...
    pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');
    end
    if subjectID == 17
        EEG = pop_select( EEG, 'rmchannel',{'SPL'});
        [ALLEEG EEG CURRENTSET] = ...
    pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');
    end
    
%     ref = mean(EEG.data([1:4,6:9,11:20,22:26,28:32], :));
    ref = EEG.data(REF3, :);
%     ref = mean(EEG.data([REF1, REF2], :));
    for channel = 1:CHANNELS
        EEG.data(channel, :) = EEG.data(channel, :) - ref;
    end
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
%     EEG = pop_select( EEG, 'rmchannel',{'TP9'});
%         [ALLEEG EEG CURRENTSET] = ...
%     [ALLEEG EEG CURRENTSET] = ...
%     pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');
    
    EEG = pop_select( EEG, 'rmchannel',{'TP9'});
    EEG = pop_select( EEG, 'rmchannel',{'TP10'});
%     EEG = pop_select( EEG, 'rmchannel',{'SPL'});
%     EEG = pop_select( EEG, 'rmchannel',{'SPR'});
    [ALLEEG EEG CURRENTSET] = ...
    pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');
        
    info = ALLEEG(CURRENTSET).event;
    info = struct2table(info);
    trigger_indexes_raw = info.latency;
    type = info.type; trig = [];
    for i = 1:length(type)
        if strcmp(type{i}, 'M  1')
           trig = [trig trigger_indexes_raw(i)]; 
        end
    end
    trigger_indexes_raw = trig';
    trigger_indexes = zeros(length(trigger_indexes_raw)/2, 2);
    for i_trigger = 1:length(trigger_indexes_raw)
        if mod(i_trigger,2)==1
            i_row = ceil(i_trigger/2);
            trigger_indexes(i_row,1) = trigger_indexes_raw(i_trigger);
        end
        if mod(i_trigger,2)==0
            i_row = i_trigger/2;
            trigger_indexes(i_row,2) = trigger_indexes_raw(i_trigger);
        end
    end
%     end_times = floor(trigger_indexes(:,2)/1000)*1000;
%     trigger_indexes(:,2) = end_times;
%     EEG = pop_select( EEG, 'point', trigger_indexes);
%     LOW_FREQUENCY_CUT = 1;
    for iSegment = 1:size(trigger_indexes, 1)
        
        EEG_this = pop_select(EEG, 'point', trigger_indexes(iSegment, :));
        EEG_this = pop_eegfiltnew(EEG_this,'locutoff',1,...
                                  'hicutoff',80);
        
%         L = double(EEG_this.data);
%         for iChannel = 1:size(L,1)
%             temp = L(iChannel, :);
%             temp = highpass(temp, 1, 1000);
%             temp = notchfilter(temp, 1000);
%             L(iChannel, :) = temp;
%         end
%         L = filtfilt(b, a, L);
%         L = notchfilter(L, 1000); 
%         EEG_this.data = L;
       
%         L = double(EEG_this.data);
%         gems=mean(L,2); % zero mean
%         L=L-gems*ones(1,size(L,2));
%         [y,w,r] = ccaqr(L,1);
%         A=pinv(w'); iCCA=20; %<=27
%         if subjectID == 4
%             iCCA=19;
%         end
%         A(:,end-iCCA+1:end)=0;
%         B=A*y;
%         CCAData = [B B(:,end-1+1:end)]+gems*ones(1,size(L,2));    
%         EEG_this.data = CCAData;
        
        if iSegment == 1
            OUTEEG = EEG_this;
        end
        if iSegment > 1
            OUTEEG = pop_mergeset(OUTEEG, EEG_this);
        end
        length(OUTEEG.times)
    end
    CURRENTSET
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, OUTEEG, CURRENTSET,'overwrite','on','gui','off'); 
    
%     EEG = pop_cleanline(EEG, ...
%     'bandwidth',2,'chanlist',[1:32] ,'computepower',1,...
%     'linefreqs',60,'newversion',0,'normSpectrum',0,'p',...
%     0.01,'pad',2,'plotfigures',0,'scanforlines',0,'sigtype',...
%     'Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
end

%% Merge all files
EEG = pop_mergeset(ALLEEG,[1:nTrials]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','Merged Set','gui','off');
EEG = eeg_checkset(EEG);

% EEG = pop_saveset(ALLEEG(end), 'filename', 'all_filtered.set',...
%      'filepath',SavePlace);

% Save filtered EEG sets
% for trial = 1:nTrials
%     filename = nameList(trial).name;
%     SetName = erase(filename,'.vhdr');
%     SetName = strcat(SetName,'_filtered.set');
%     SavePlace = strcat(path);
%     EEG = pop_saveset(ALLEEG(trial), 'filename',SetName,'filepath',SavePlace);
% end

SavePlace = strcat(path);
% EEG = pop_saveset(ALLEEG(end),'filename', ...
%     'ALL_filtered_2.set','filepath',SavePlace);

% save(strcat('./subjects/', subjectIDstr, ...
%      '/eeg/ALLEEG_filtered.mat'), 'ALLEEG');

%% ASR
% EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,...
%                             'ChannelCriterion',0.8,...
%                             'LineNoiseCriterion',4, ...
%                             'Highpass','off', ...
%                             'BurstCriterion',20, ...
%                             'WindowCriterion',0.25, ...
%                             'BurstRejection','on', ...
%                             'Distance','Euclidian', ...
%                             'WindowCriterionTolerances',[-Inf 7] );
% 
% [ALLEEG EEG CURRENTSET] = ...
%     pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');

%% ICA Artifact Rejection 
% Eye, muscle, heart, line noise, channle noise

EEG = pop_runica(ALLEEG(end), 'icatype', 'sobi'); %sobi  runica
% Use the entire merged set. 
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

% ICLabel
EEG = eeg_checkset(EEG); EEG = pop_iclabel(EEG, 'default');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

eeglab redraw
subjectIDstr 
% % ICAflag
cut = 0.05;
EEG = pop_icflag(EEG,[NaN NaN;cut 1;cut 1; ...
                      cut 1;cut 1;cut 1;NaN NaN]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset(EEG);
% 
% Remove flagged components
EEG = pop_subcomp(EEG,'',0,0); % [] or ' means removing components flaged for rejection
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
[ALLEEG EEG CURRENTSET] = ...
pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');

% % Retrieve ICAed results and save them in ALLEEG
% sum_end = 0;
% for trial = 1:nTrials
%     trial_start = 1+sum_end;
%     trial_len = length(ALLEEG(trial).data);
%     sum_end = sum_end + trial_len;
%     ALLEEG(trial).data = ALLEEG(nTrials+2).data(:,trial_start:sum_end);
% end

% % Save ICAed EEG sets
% for trial = 1:nTrials
% %     CURRENTSET = trial;
%     filename = nameList(trial).name;
%     SetName = erase(filename,'.vhdr');
%     SetName = strcat(SetName,'_ICAed.set');
%     SavePlace = strcat(path);
%     EEG = pop_saveset(ALLEEG(trial), 'filename',SetName,'filepath',SavePlace);
% end

% EEG = pop_saveset(ALLEEG(end),'filename', ...
%       'ALL_ICAed.set','filepath',SavePlace);

%% EEMD-CCA
num_IMFs = 10;
[clean_eeg] = EEMD_CCA(EEG.data, num_IMFs, 1000);
EEG.data = clean_eeg;
fs = 500
eeglab redraw;

%% Additional muscle denoising
% L=double(EEG.data); gems=mean(L,2); % zero mean
% L=L-gems*ones(1,size(L,2)); [y,w,r] = ccaqr(L,1);
% A=pinv(w'); nCCA=15; %<=27
% if subjectID == 4
%     nCCA=14;
% end
% A(:,end-nCCA+1:end)=0; B=A*y;
% CCAData = [B B(:,end-1+1:end)]+gems*ones(1,size(L,2));    
% EEG.data = CCAData;

%% Additional line noise removal
EEG = pop_cleanline(EEG,'bandwidth',2, ...
                     'chanlist',[1:(CHANNELS-2)],...
                     'computepower',1,...
                     'linefreqs',60,'newversion',0,...
                     'normSpectrum',0,'p',0.01,'pad',2,...
                     'plotfigures',0,'scanforlines',0,...
                     'sigtype','Channels','taperbandwidth',2,...
                     'tau',100,'verb',1,'winsize',4,'winstep',1);

%% Saving final results
EEG = pop_saveset(ALLEEG(end),'filename', ...
    'ALL_fnl.set','filepath',SavePlace);

% Save ICAed EEG structure
save(strcat('./subjects/', subjectIDstr,...
    '/eeg/ALLEEG_eemd.mat'), 'ALLEEG');

end
