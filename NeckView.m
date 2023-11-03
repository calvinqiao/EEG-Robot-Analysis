clear; clc; close all;

CHANNELS = 1:32; FS = 1000;
WINTIME = 1; % 1-sec window duration; 1 hz
subjects = [11 13 15 16 17 18 ...
            19 21 22 23 24 25 1 3 4 5 6 7 9 10]; 

neckM = containers.Map();
for iSubject = 1:length(subjects)

subjectID = subjects(iSubject);
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end
neckM(subjectIDstr) = containers.Map();

subjectDataDir = append(strcat('./subjects/', subjectIDstr, '/eeg/*.vhdr'));
nameList = dir(subjectDataDir); nTrials = length(nameList);
path = strcat('./subjects/', subjectIDstr, '/eeg/'); 
load(strcat(path, 'ALLEEG_filtered_raw.mat'));

CHANNELS = 1:32; 
NECK_ELECS = [5,27];

%% Power
overlapPercent = 0.5; timeGap = WINTIME/(1/overlapPercent);
timeVec = []; prevTrialEndTime = 0; 
triggers = []; prevTrialEndTrig = 0;
for trial = 1:nTrials
    fprintf(strcat(subjectIDstr, " ", 'Trial', num2str(trial), '\n'));
    data = double(ALLEEG(trial).data); 
    windowNPts = WINTIME*FS;
    necks.amps = []; 
    
    latencies = ALLEEG(trial).event; latencies = struct2table(latencies);
    triggerIndexesRaw = latencies.latency; trigger_types = latencies.type;
    selectedIndexes = [];
    for trigger = 1:length(trigger_types)
        thisTrigType = trigger_types{trigger};
        if strcmp(thisTrigType, 'M  1')
            selectedIndexes = [selectedIndexes trigger];
        end
    end
    triggerIndexesRaw = triggerIndexesRaw(selectedIndexes);
    triggerIndexes = zeros(length(triggerIndexesRaw)/2, 2);
    for iTrigger = 1:length(triggerIndexesRaw)
        if mod(iTrigger,2)==1
            i_row = ceil(iTrigger/2);
            triggerIndexes(i_row,1) = triggerIndexesRaw(iTrigger);
        end
        if mod(iTrigger,2)==0
            i_row = iTrigger/2;
            triggerIndexes(i_row,2) = triggerIndexesRaw(iTrigger);
        end
    end
    triggers = [triggers; triggerIndexes+prevTrialEndTrig];
    prevSegEndTime = 0;
    for segment = 1:size(triggerIndexes,1)
        segTriggers = triggerIndexes(segment, :);
        segData = data(:, segTriggers(1):segTriggers(2)); % gpu array
        segStartTime = (segTriggers(1)-1)/1000; 
        segNPts = segTriggers(2)-segTriggers(1)+1;
        
        if segNPts >= 1000 % Process segment > 1 sec
            ampChannels = [];
            for iChannel = 1:length(NECK_ELECS) 
                channel = NECK_ELECS(iChannel);
                ampBufs = []; 
                [dataWins,z] = buffer(segData(channel, :), windowNPts, ...
                               round(windowNPts*overlapPercent), 'nodelay');
                for buf = 1:size(dataWins,2)
                    dataBuf = dataWins(:,buf); 
                    if length(dataBuf) > 1
                        ampBufs = [ampBufs mean(dataBuf)];
                    else
                        disp(['#### Buf insufficient ####', num2str(buf)])
                        ampBufs = [ampBufs NaN];
                    end
                    if iChannel == 1
                        timeVec = [timeVec ...
                            (buf)*timeGap+segStartTime+prevTrialEndTime];
                    end
                end
                ampBufs = fillmissing(ampBufs, 'nearest');
                ampChannels = [ampChannels; ampBufs];
            end
            necks.amps = [necks.amps ampChannels];
            timeAdd = 0;
        else
            fprintf(strcat('Trig idx ', num2str(segTriggers(1)),'\n'));
            fprintf('#of pts < 1000 \n');
            timeAdd = length(segData(1, :))/1000;
        end
        fprintf(strcat(num2str(timeVec(end)), ' Sec', '\n'));
    end
    
    prevTrialEndTrig = triggerIndexes(end, 2)+prevTrialEndTrig;
    prevTrialEndTime = timeVec(end) + timeAdd;
    
    if trial == 1        
        baselines.c1 = mean(mean(necks.amps(1,:)));
        baselines.c2 = mean(mean(necks.amps(2,:)));
        subjectPowers = neckM(subjectIDstr);
        subjectPowers('Baseline') = baselines;
    end
    subjectPowers = neckM(subjectIDstr);
    subjectPowers(strcat('Trial',num2str(trial))) = necks;
end
subjectPowers('TimeVec') = timeVec;
subjectPowers('Triggers') = triggers;
end

neckM('Overlap') = overlapPercent;
save(strcat('./', 'necks_0919'), 'neckM');

