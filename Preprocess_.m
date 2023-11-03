clear; clc; close all;
addpath('C:\Users\Ahmad\Documents\New folder\eeglab_current\eeglab2023.0');
eeglab;

%% Some constants
CHANNELS = 32; REF = 13; FS = 1000;
MUSCLE_DENOISING_MODE = 'EEMD-CCA'; % CCA or EEMD-CCA

%% Select subjects
subjects = [1 3 5 6 ... %  
            7 9 10 11 13 ...
            15 16 17 18 19 ... 
            21 22 23 24 25]; % 4 is not usable 
% subjects = [1 5 6 7 9 10 ...
%             11 15 16 18 19 22 25];
subjects = [3];

%% Each subject
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

% Each trial
for trial = 1:nTrials 
    fileName = nameList(trial).name;
    EEG = pop_loadbv(path, fileName, [], []);
    [ALLEEG EEG CURRENTSET] = ...
        pop_newset(ALLEEG, EEG, 0,'setname',fileName,'gui','off'); 
    
    % Set channel locations
    EEG=pop_chanedit(EEG, 'rplurchanloc',CURRENTSET,'load',...
        {'ChannelLoc1208.ced','filetype','autodetect'});
    [ALLEEG EEG CURRENTSET] = ...
    pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');
    
    % Re-referencing
    ref = EEG.data(REF, :);
    for channel = 1:CHANNELS
        EEG.data(channel, :) = EEG.data(channel, :) - ref;
    end
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    clear ref
    
    % Remove motion-artifact contaminated channels
    EEG = pop_select( EEG, 'rmchannel',{'TP9'});
    EEG = pop_select( EEG, 'rmchannel',{'TP10'});
    EEG = pop_select( EEG, 'rmchannel',{'SPL'});
    EEG = pop_select( EEG, 'rmchannel',{'SPR'});
    EEG = pop_select( EEG, 'rmchannel',{'FP1'});
    EEG = pop_select( EEG, 'rmchannel',{'FP2'});
    [ALLEEG EEG CURRENTSET] = ...
    pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');
    
    % Extract triggers
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
    
    % Each segment
    for iSegment = 1:size(trigger_indexes, 1)
        EEGThis = pop_select(EEG, 'point', trigger_indexes(iSegment, :));
        
        % Band pass filtering
        EEGThis = pop_eegfiltnew(EEGThis,'locutoff',1,'hicutoff',50);
        if iSegment == 1
            OUTEEG = EEGThis;
        end
        if iSegment > 1
            OUTEEG = pop_mergeset(OUTEEG, EEGThis);
        end
        length(OUTEEG.times)
    end
    CURRENTSET
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, OUTEEG, CURRENTSET,'overwrite','on','gui','off'); 
end

%% Merge all files
EEG = pop_mergeset(ALLEEG,[1:nTrials]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','Merged Set','gui','off');
EEG = eeg_checkset(EEG);

%% ICA & ICLabel
% Use the entire merged set. 
EEG = pop_runica(ALLEEG(end), 'icatype', 'sobi'); % sobi or runica
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

% IC Label
EEG = eeg_checkset(EEG); EEG = pop_iclabel(EEG, 'default');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

% ICA Flag
cut = 0.5;
EEG = pop_icflag(EEG,[NaN NaN;NaN NaN;cut 1; ...
                      cut 1;cut 1;cut 1;NaN NaN]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset(EEG);

% Remove flagged components
EEG = pop_subcomp(EEG,'',0,0); % [] or ' means removing components flaged for rejection
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off'); 
[ALLEEG EEG CURRENTSET] = ...
pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');

%% Additional muscle denoising
if strcmp(MUSCLE_DENOISING_MODE, 'EEMD-CCA')
    % EEMD-CCA
    numIMFs = 10; 
    [clean_eeg] = EEMD_CCA(EEG.data, numIMFs, FS);
    EEG.data = clean_eeg;
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
elseif strcmp(MUSCLE_DENOISING_MODE, 'CCA')
    % CCA
    eegData = double(EEG.data); 
    gems = mean(eegData,2); % zero mean
    eegData = eegData-gems*ones(1,size(eegData,2)); 
    [y,w,r] = ccaqr(eegData,1);
    A = pinv(w'); nCCA = 14; % <=26
    A(:,end-nCCA+1:end)=0; B = A*y;
    ccaEEG = [B B(:,end-1+1:end)]+gems*ones(1,size(eegData,2));    
    EEG.data = ccaEEG;
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end

%% Saving final results
% Save EEG set
EEG = pop_saveset(ALLEEG(end),'filename', ...
    'ica_muscle_off_eemd.set','filepath', strcat(path));

% Save EEG structure
save(strcat('./subjects/', subjectIDstr,...
    '/eeg/eemdall_halfcomp.mat'), 'ALLEEG');

eeglab redraw

end
