clear; clc; close all;
addpath('C:\Users\calvi\Documents\EEG_adaptation\eeglab_current\eeglab2023.0');
eeglab;

subjects = [10 11 13 15 16 17 18 ...
            19 21 22 23 24 25 1 3 4 5 6 7 9]; %1 3 4 5 6 7 

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

CHANNELS = 32; REF1 = 7; REF2 = 29; 

% Open files
for trial = 1:nTrials 
    filename = nameList(trial).name
    EEG = pop_loadbv(path, filename, [], []);
    [ALLEEG EEG CURRENTSET] = ...
        pop_newset(ALLEEG, EEG, 0,'setname',filename,'gui','off'); 
    
    % Change channel locations
    EEG=pop_chanedit(EEG, 'rplurchanloc',CURRENTSET,'load',...
        {'ChannelLoc1208.ced','filetype','autodetect'});
    
    ref = mean(EEG.data([REF1,REF2], :));
    for channel = 1:CHANNELS
        EEG.data(channel, :) = EEG.data(channel, :) - ref;
    end
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
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

    LOW_FREQUENCY_CUT = 1;
    for iSegment = 1:size(trigger_indexes, 1)
        
        EEG_this = pop_select(EEG, 'point', trigger_indexes(iSegment, :));
        EEG_this = pop_eegfiltnew(EEG_this, 'locutoff',LOW_FREQUENCY_CUT);
        
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
    
end

%% Merge all files
EEG = pop_mergeset(ALLEEG,[1:nTrials]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','Merged Set','gui','off');
EEG = eeg_checkset(EEG);

save(strcat('./subjects/', subjectIDstr, '/eeg/ALLEEG_filtered_raw.mat'), 'ALLEEG');

end
