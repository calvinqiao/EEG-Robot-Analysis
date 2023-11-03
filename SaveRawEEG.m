clear; clc; close all;
addpath('C:\Users\calvi\Documents\EEG_adaptation\eeglab_current\eeglab2023.0');
eeglab;

% subjects = [7];
subjects = [1 3 4 5 6 7 9 10 11 13 15 16 17 18 ...
            19 21 22 23 24 25];

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

% Open files
for trial = 1:nTrials
    filename = nameList(trial).name
    EEG = pop_loadbv(path, filename, [], []);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',filename,'gui','off'); 
    CURRENTSET
    % Change channel locations
    EEG=pop_chanedit(EEG, 'rplurchanloc',CURRENTSET,'load',...
        {'ChannelLoc1208.ced','filetype','autodetect'});
    
    latencies = ALLEEG(CURRENTSET).event;
    latencies = struct2table(latencies);
    trigger_indexes_raw = latencies.latency;
    trigger_indexes_raw = trigger_indexes_raw(2:end);
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
    EEG = pop_select(EEG, 'point', trigger_indexes);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off'); 
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end

% Merge all files
EEG = pop_mergeset(ALLEEG,[1:nTrials]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','Merged Set','gui','off');

% Save set
for trial = 1:nTrials
    CURRENTSET = trial;
    filename = nameList(trial).name;
    SetName = erase(filename,'.vhdr');
    SetName = strcat(SetName,'_raw.set');
    SavePlace = strcat(path,'/');
    EEG = pop_saveset( ALLEEG(trial), 'filename',SetName,'filepath',SavePlace);
end
save(strcat('./subjects/', subjectIDstr, '/eeg/ALLEEG_raw.mat'), 'ALLEEG');

end

