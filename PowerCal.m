clear; clc; close all;

FS = 1000; 
%%%%%%%%%%% OR FS = 500 if using eemd

WINTIME = 1; % 1-sec window duration; 1 hz
DELTA=[1,4]; THETA=[4,8]; ALPHA=[8,14]; BETA=[14,30]; 
GAMMA=[30,50]; TTL=[1,50]; SIGNAL_LIMIT = 100; %vgamma = [80,160]; 

subjects = [17 1 3 4 5 6 ... %  
            7 9 10 11 13 ...
            15 16 18 19 ... % 17
            21 22 23 24 25]; % 4,17
% subjects = [21];

powerM = containers.Map();
for iSubject = 1:length(subjects)

subjectID = subjects(iSubject);
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end
powerM(subjectIDstr) = containers.Map();

subjectDataDir = append(strcat('./subjects/', subjectIDstr, '/eeg/*.vhdr'));
nameList = dir(subjectDataDir); nTrials = length(nameList);
path = strcat('./subjects/', subjectIDstr, '/eeg/'); 
load(strcat(path, 'ALLEEG_fnl_rm.mat'));

% if subjectID == 4
%     CHANNELS = 1:27; 
%     CERE = [8,14,18]; FRONT = [2,3,4,25,26]; MOTOR = [6,21,22]; 
%     PARIETAL = [11,12,16,17]; O = [10,13,15];
% elseif subjectID == 17
%     CHANNELS = 1:29; 
%     CERE = [8,15,19]; FRONT = [2,3,4,27,28]; MOTOR = [6,22,23]; 
%     PARIETAL = [11,12,13,17,18]; O = [10,14,16];
% else
%     CHANNELS = 1:28; 
%     CERE = [9,16,20]; FRONT = [2,3,4,28,29];
%     MOTOR = [7,23,24]; PARIETAL = [12,13,14,18,19]; O = [11,15,17];
% end

% CHANNELS = 1:28;
% CERE = [8,15,19]; FRONT = [2,3,4,26,27]; MOTOR = [6,22,23]; 
% PARIETAL = [11,12,13,17,18]; O = [10,14,16];
% if subjectID == 4
%     CHANNELS = 1:27; 
%     CERE = [8,14,18]; FRONT = [2,3,4,25,26]; MOTOR = [6,21,22]; 
%     PARIETAL = [11,12,16,17]; O = [10,13,15];
% end
% 
% CHANNELS = 1:28;
% CERE = [8,15,19]; FRONT = [2,3,4,26,27]; MOTOR = [6,22,23]; 
% PARIETAL = [11,12,13,17,18]; O = [10,14,16];
% if subjectID == 4
%     CHANNELS = 1:27; 
%     CERE = [8,14,18]; FRONT = [2,3,4,25,26]; MOTOR = [6,21,22]; 
%     PARIETAL = [11,12,16,17]; O = [10,13,15];
% end

% CHANNELS = 1:30; % Need to check and update
% CERE = [9,16,20]; FRONT = [2,3,4,28,29]; MOTOR = [7,23,24]; 
% PARIETAL = [12,13,14,18,19]; O = [11,15,17];
% if subjectID == 4
%     CHANNELS = 1:27; 
%     CERE = [8,14,18]; FRONT = [2,3,4,25,26]; MOTOR = [6,21,22]; 
%     PARIETAL = [11,12,16,17]; O = [10,13,15];
% end
% if subjectID == 17
%     CHANNELS = 1:29; 
%     CERE = [8,15,19]; FRONT = [2,3,4,27,28]; MOTOR = [6,22,23]; 
%     PARIETAL = [11,12,13,17,18]; O = [10,14,16];
% end

CHANNELS = 1:26; % Need to check and update
CERE = [7,14,18]; FRONT = [1,2,3,25,26]; MOTOR = [5,21,22];
PARIETAL = [11,12,25,26]; O = [9,13,15];

%% Power
overlapPercent = 0.5; timeGap = WINTIME/(1/overlapPercent);
% data = downsample(data, 2); % 500 Hz
timeVec = []; prevTrialEndTime = 0; 
triggers = []; prevTrialEndTrig = 0;
for trial = 1:nTrials
    fprintf(strcat(subjectIDstr, " ", 'Trial', num2str(trial), '\n'));
    data = double(ALLEEG(trial).data); 
    
    windowNPts = WINTIME*FS;
    powers.alpha = []; powers.beta = []; powers.gamma = []; 
    powers.theta = []; powers.delta = []; powers.total = []; % powers.vgamma = [];
    
    for iChannel = 1:26
        pwelchChannels{iChannel} = [];
    end
    
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
            alphaChannels = []; betaChannels = []; gammaChannels = []; 
            thetaChannels = []; deltaChannels = []; ttlChannels = [];
            for channel = 1:length(CHANNELS) 
                alphaBufs = []; betaBufs = []; gammaBufs = [];
                thetaBufs = []; deltaBufs = []; ttlBufs = [];
                pwelchBufs = [];
                [dataWins,z] = buffer(segData(channel, :), windowNPts, ...
                               round(windowNPts*overlapPercent), 'nodelay');
                
               threshold = 100; %3 * std(segData(channel, :));            
               for buf = 1:size(dataWins,2)
                    dataBuf = dataWins(:,buf);  
                    if sum(abs(dataBuf) > threshold) == 0
                        if length(dataBuf) > 1
                            disp(['Computing ...']);
                            [pxx, f] = pwelch(dataBuf,[],[],[],FS); 
                            p = bandpower(pxx',f,ALPHA,"psd");
                            pwelchBufs = [pwelchBufs; pxx'];              
%                             alphaBufs = [alphaBufs bandpower(dataBuf,FS,ALPHA)];
%                             betaBufs = [betaBufs bandpower(dataBuf,FS,BETA)];
%                             gammaBufs = [gammaBufs bandpower(dataBuf,FS,GAMMA)];
%                             thetaBufs = [thetaBufs bandpower(dataBuf,FS,THETA)];
%                             deltaBufs = [deltaBufs bandpower(dataBuf,FS,DELTA)];
%                             ttlBufs = [ttlBufs bandpower(dataBuf,FS,TTL)];
                        else
                            disp(['#### Buf insufficient ####', num2str(buf)])
                            pwelchBufs = [pwelchBufs; NaN(1,129)];
%                             alphaBufs = [alphaBufs NaN];
%                             betaBufs = [betaBufs NaN];
%                             gammaBufs = [gammaBufs NaN];
%                             thetaBufs = [thetaBufs NaN];
%                             deltaBufs = [deltaBufs NaN];
%                             ttlBufs = [ttlBufs NaN];
                        end % bandpower(dataBuf,FS,ALPHA);
                    else
                        disp(['# >Thresh ', ...
                              subjectIDstr, ...
                              ' Trl ', num2str(trial), ...
                              ' Seg ', num2str(segment), ...
                              ' Cnl ', num2str(channel)])
                        pwelchBufs = [pwelchBufs; NaN(1,129)];
%                         alphaBufs = [alphaBufs NaN];
%                         betaBufs = [betaBufs NaN];
%                         gammaBufs = [gammaBufs NaN];
%                         thetaBufs = [thetaBufs NaN];
%                         deltaBufs = [deltaBufs NaN];
%                         ttlBufs = [ttlBufs NaN];
                    end
                    if channel == 1
                        timeVec = [timeVec ...
                            (buf)*timeGap+segStartTime+prevTrialEndTime];
                    end
                end

                alphaBufs = fillmissing(alphaBufs, 'nearest');
                betaBufs = fillmissing(betaBufs, 'nearest');
                thetaBufs = fillmissing(thetaBufs, 'nearest');
                gammaBufs = fillmissing(gammaBufs, 'nearest');
                deltaBufs = fillmissing(deltaBufs, 'nearest');
                ttlBufs = fillmissing(ttlBufs, 'nearest');
                alphaChannels = [alphaChannels; alphaBufs];
                betaChannels = [betaChannels; betaBufs];
                gammaChannels = [gammaChannels; gammaBufs];
                thetaChannels = [thetaChannels; thetaBufs];
                deltaChannels = [deltaChannels; deltaBufs];
                ttlChannels = [ttlChannels; ttlBufs];
                
                pwelchBufs = fillmissing(pwelchBufs, 'nearest');
                pwelchChannels{channel} = [pwelchChannels{channel};
                         pwelchBufs];
            end
            
%             powers.alpha = [powers.alpha alphaChannels];
%             powers.beta = [powers.beta betaChannels];
%             powers.gamma = [powers.gamma gammaChannels];
%             powers.theta = [powers.theta thetaChannels];
%             powers.delta = [powers.delta deltaChannels];
%             powers.total = [powers.total ttlChannels];
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
%         baselines.alpha = mean(mean(powers.alpha(CERE,:)));
%         baselines.beta = mean(mean(powers.beta(CERE,:)));
%         baselines.theta = mean(mean(powers.theta(CERE,:)));
%         baselines.gamma = mean(mean(powers.gamma(CERE,:)));
%         baselines.delta = mean(mean(powers.delta(CERE,:)));
%         baselines.total = mean(mean(powers.total(CERE,:)));
        subjectPowers = powerM(subjectIDstr);
        subjectPowers('BaselineCere') = baselines;

        baselines.alpha = mean(mean(powers.alpha(FRONT,:)));
        baselines.beta = mean(mean(powers.beta(FRONT,:)));
        baselines.theta = mean(mean(powers.theta(FRONT,:)));
        baselines.delta = mean(mean(powers.delta(FRONT,:)));
        baselines.total = mean(mean(powers.total(FRONT,:)));
        subjectPowers = powerM(subjectIDstr);
        subjectPowers('BaselineFront') = baselines;

        baselines.alpha = mean(mean(powers.alpha(MOTOR,:)));
        baselines.beta = mean(mean(powers.beta(MOTOR,:)));
        baselines.theta = mean(mean(powers.theta(MOTOR,:)));
        baselines.gamma = mean(mean(powers.gamma(MOTOR,:)));
        baselines.delta = mean(mean(powers.delta(MOTOR,:)));
        baselines.total = mean(mean(powers.total(MOTOR,:)));
        subjectPowers = powerM(subjectIDstr);
        subjectPowers('BaselineMotor') = baselines;

        baselines.alpha = mean(mean(powers.alpha(PARIETAL,:)));
        baselines.beta = mean(mean(powers.beta(PARIETAL,:)));
        baselines.theta = mean(mean(powers.theta(PARIETAL,:)));
        baselines.gamma = mean(mean(powers.gamma(PARIETAL,:)));
        baselines.delta = mean(mean(powers.delta(PARIETAL,:)));
        baselines.total = mean(mean(powers.total(PARIETAL,:)));
        subjectPowers = powerM(subjectIDstr);
        subjectPowers('BaselineP') = baselines;
        
        baselines.alpha = mean(mean(powers.alpha(O,:)));
        baselines.beta = mean(mean(powers.beta(O,:)));
        baselines.theta = mean(mean(powers.theta(O,:)));
        baselines.gamma = mean(mean(powers.gamma(O,:)));
        baselines.delta = mean(mean(powers.delta(O,:)));
        baselines.total = mean(mean(powers.total(O,:)));
        subjectPowers = powerM(subjectIDstr);
        subjectPowers('BaselineO') = baselines;
        
    end
    subjectPowers = powerM(subjectIDstr);
    subjectPowers(strcat('Trial',num2str(trial))) = powers;
end
subjectPowers('TimeVec') = timeVec;
subjectPowers('Triggers') = triggers;
end

powerM('Overlap') = overlapPercent;
save(strcat('./', 'powers_eemd2'), 'powerM');

