clear; clc; close all;

channels = 1:26; fs = 1000;
WINTIME = 1; % 1 sec window ; 1 hz
DELTA=[1,4]; THETA=[4,8]; ALPHA=[8,14]; BETA=[14,30]; 
GAMMA=[30,50]; TTL=[1,50]; SIGNAL_LIMIT = 100;

subjects = [1 3 5 6 ... %  
            7 9 10 11 13 ...
            15 16 17 18 19 ... % 17
            21 22 23 24 25]; % 4,17
cohM = containers.Map();

for iSubject = 1:length(subjects)
subjectID = subjects(iSubject);
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end

cohM(subjectIDstr) = containers.Map();

subjectDataDir = append(strcat('./subjects/', subjectIDstr, '/eeg/*.vhdr'));
nameList = dir(subjectDataDir);
nTrials = length(nameList);
path = strcat('./subjects/', subjectIDstr, '/eeg/'); 
load(strcat(path, 'eemdall_halfcomp.mat'));

% CERE_CHANNELS = [9,16,20]; 
% MOTOR_CHANNELS = [7,23,24]; 
% if subjectID == 4 
%     CERE_CHANNELS = [8,14,18]; 
%     MOTOR_CHANNELS = [6,21,22]; 
% end
% if subjectID == 17
%     CERE_CHANNELS = [8,15,19]; 
%     MOTOR_CHANNELS = [6,22,23]; 
% end

CERE_CHANNELS = [7,14,18]; 
MOTOR_CHANNELS = [21]; % 5 21 22
% Check motor and frontal next
%% Calculating the coherence
overlapPercent = 0.5;
timeGap = WINTIME/(1/overlapPercent);
timeVec = []; prevTrialEndTime = 0; 
triggers = []; prevTrialEndTrig = 0;

cohTrial = []; 
for trial = 1:nTrials
    fprintf(strcat(subjectIDstr, " ", 'Trial', num2str(trial), '\n'));
    data = double(ALLEEG(trial).data);
    
    windowNPts = WINTIME*fs;

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
    
    prevSegEndTime = 0; nSegments = size(triggerIndexes,1);
    pairsCoh = {};
    for segment = 1:nSegments
        fprintf(strcat(subjectIDstr, " ", 'Trial', num2str(trial), ...
            " ", 'Segment', num2str(segment), '\n'));
        segTriggers = triggerIndexes(segment, :);
        segData = data(:, segTriggers(1):segTriggers(2)); % gpu array
        segStartTime = (segTriggers(1)-1)/1000; 
        segNPts = segTriggers(2)-segTriggers(1)+1;
        
        if segNPts >= 1000 
            for iChannelMotor = 1:length(MOTOR_CHANNELS)
                for iChannelCere = 1:length(CERE_CHANNELS)
                    channelMotor = MOTOR_CHANNELS(iChannelMotor);
                    channelCere = CERE_CHANNELS(iChannelCere);
                    [motorWins,z] = buffer(segData(channelMotor, :), windowNPts, ...
                                   round(windowNPts*overlapPercent), 'nodelay');
                    [cereWins,z] = buffer(segData(channelCere, :), windowNPts, ...
                                   round(windowNPts*overlapPercent), 'nodelay');
                    thisPairCoh = zeros(size(cereWins, 2), 12);
                    % 12 columns 1-6 imag 7-12 mag2
                    totalSegCoh = zeros(size(cereWins, 2), 12);
                     
                    for buf = 1:size(cereWins, 2)
                        motorDataBuf = motorWins(:, buf); 
                        cereDataBuf = cereWins(:, buf);
                        N = size(motorDataBuf, 1);
                        if (sum(abs(cereDataBuf-mean(cereDataBuf)) > SIGNAL_LIMIT) == 0 && ... 
                                sum(abs(motorDataBuf-mean(motorDataBuf)) > SIGNAL_LIMIT) == 0)
                        if (length(motorDataBuf)>1) && (length(cereDataBuf)>1)
                            % disp(['Computing...']);
                            [cpsd1,f]=cpsd(motorDataBuf,cereDataBuf,hann(N),[],N,fs);
                            [pxx1,fx]=pwelch(motorDataBuf,hann(N),[],N,fs);
                            [pxx2,~]=pwelch(cereDataBuf,hann(N),[],N,fs);
                            cxy1 = imag(cpsd1./sqrt(pxx1 .* pxx2));
                            % Make the mean coherence within each band
%                             [~,al]=min(abs(f-ALPHA(1))); [~,ah]=min(abs(f-ALPHA(2)));
%                             [~,bl]=min(abs(f-BETA(1))); [~,bh]=min(abs(f-BETA(2)));
%                             [~,dl]=min(abs(f-DELTA(1))); [~,dh]=min(abs(f-DELTA(2)));
%                             [~,tl]=min(abs(f-THETA(1))); [~,th]=min(abs(f-THETA(2)));
%                             [~,gl]=min(abs(f-GAMMA(1))); [~,gh]=min(abs(f-GAMMA(2)));
%                             [~,totl]=min(abs(f-TTL(1))); [~,toth]=min(abs(f-TTL(2)));
                            % Separate the coherence according to eeg band
                            alphaImagCoh=mean(cxy1(ALPHA(1):ALPHA(2))); 
                            betaImagCoh=mean(cxy1(BETA(1):BETA(2)));
                            deltaImagCoh=mean(cxy1(DELTA(1):DELTA(2))); 
                            gammaImagCoh=mean(cxy1(GAMMA(1):GAMMA(2)));
                            thetaImagCoh=mean(cxy1(THETA(1):THETA(2))); 
                            totalImagCoh=mean(cxy1(TTL(1):TTL(2)));

                            [cms,f]=mscohere(motorDataBuf,cereDataBuf,[],[],[],fs);
                            alphaMagCoh=mean(cms(ALPHA(1):ALPHA(2))); 
                            betaMagCoh=mean(cms(BETA(1):BETA(2)));  
                            deltaMagCoh=mean(cms(DELTA(1):DELTA(2))); 
                            gammaMagCoh=mean(cms(GAMMA(1):GAMMA(2))); 
                            thetaMagCoh=mean(cms(THETA(1):THETA(2)));
                            totalMagCoh=mean(cms(TTL(1):TTL(2)));

                            thisPairCoh(buf,1)=alphaImagCoh; thisPairCoh(buf,2)=betaImagCoh;
                            thisPairCoh(buf,3)=deltaImagCoh; thisPairCoh(buf,4)=gammaImagCoh;
                            thisPairCoh(buf,5)=thetaImagCoh; thisPairCoh(buf,6)=totalImagCoh;
                            thisPairCoh(buf,7)=alphaMagCoh; thisPairCoh(buf,8)=betaMagCoh;
                            thisPairCoh(buf,9)=deltaMagCoh; thisPairCoh(buf,10)=gammaMagCoh;
                            thisPairCoh(buf,11)=thetaMagCoh; thisPairCoh(buf,12)=totalMagCoh;
                        else
                            disp(['#### Buf insufficient ####', num2str(buf)]);
                            thisPairCoh(buf,1)=NaN; thisPairCoh(buf,2)=NaN;
                            thisPairCoh(buf,3)=NaN; thisPairCoh(buf,4)=NaN;
                            thisPairCoh(buf,5)=NaN; thisPairCoh(buf,6)=NaN;
                            thisPairCoh(buf,7)=NaN; thisPairCoh(buf,8)=NaN;
                            thisPairCoh(buf,9)=NaN; thisPairCoh(buf,10)=NaN;
                            thisPairCoh(buf,11)=NaN; thisPairCoh(buf,12)=NaN;
                        end
                        else
                            disp(['# >Thresh ', ...
                              subjectIDstr, ...
                              ' Trl ', num2str(trial), ...
                              ' Seg ', num2str(segment)])
                            thisPairCoh(buf,1)=NaN; thisPairCoh(buf,2)=NaN;
                            thisPairCoh(buf,3)=NaN; thisPairCoh(buf,4)=NaN;
                            thisPairCoh(buf,5)=NaN; thisPairCoh(buf,6)=NaN;
                            thisPairCoh(buf,7)=NaN; thisPairCoh(buf,8)=NaN;
                            thisPairCoh(buf,9)=NaN; thisPairCoh(buf,10)=NaN;
                            thisPairCoh(buf,11)=NaN; thisPairCoh(buf,12)=NaN;
                        end
                        if iChannelMotor == 1 && iChannelCere == 1
%                             disp([num2str(iChannelMotor), num2str(iChannelCere)]);
%                             disp([num2str(length(timeVec))]);
%                             disp(['Buf: ', num2str(buf)]);
                            timeVec = [timeVec ...
                                (buf)*timeGap+segStartTime+prevTrialEndTime];
                        end
                    end
                    pairIdx = (iChannelMotor-1)*length(CERE_CHANNELS) + ...
                             (iChannelCere);
                    pairsCoh{pairIdx} = thisPairCoh;
                end
            end
            timeAdd = 0;   
            for iPair = 1:length(pairsCoh)
                thisPairCoh = pairsCoh{iPair};
                thisPairCoh = fillmissing(thisPairCoh, 'nearest');
                totalSegCoh = totalSegCoh + thisPairCoh;
            end
            if any(isnan(totalSegCoh))
                100000000;
            end
            meanSegCoh = ...
                totalSegCoh/(length(MOTOR_CHANNELS)*length(CERE_CHANNELS));
            cohTrial = [cohTrial; meanSegCoh];
        else
            fprintf(strcat('Trig idx ', num2str(segTriggers(1)),'\n'));
            fprintf('#of pts < 1000 \n');
            timeAdd = length(segData(1, :))/1000;
        end
        fprintf(strcat('  Segment ', num2str(segment)));
        fprintf(strcat(" ", num2str(timeVec(end)), ' Sec', '\n'));
    end
    
    prevTrialEndTrig = triggerIndexes(end, 2)+prevTrialEndTrig;
    prevTrialEndTime = timeVec(end) + timeAdd;

    if trial == 1
        baselines = mean(cohTrial);
        subjectCohs = cohM(subjectIDstr);
        subjectCohs('Baseline') = baselines;
    end
    subjectCohs = cohM(subjectIDstr);
    subjectCohs(strcat('Trial',num2str(trial))) = cohTrial; 
end
subjectCohs('TimeVec') = timeVec;
subjectCohs('Triggers') = triggers;
end

cohM('Overlap') = overlapPercent;
save(strcat('./', 'cohs_eemdall_halfcomp'), 'cohM');



