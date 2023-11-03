clear; close all; clc;

%%
%{ 
Done:
Remove DC offset
Check ica-ed cerebellar eeg
Clean raw data in eeglab
Graphs EEGLAB ASR, pre-ica, post-ica; Send the graphs
Pow/Coherence 10/50 overlapping for 1 min window

To Do: 
Check relative changes in other regions (Frontal, P, Motor)
pre, tau, 1.5 taum 2*tau (adaptation process) 
Relative power band/total

Inividualized analysis
Cerebellar - balance - motor (side by side in a figure)
Show the triggers
ICA - thresholding vs no thresholding

Fix the boundary isse (pre, adapt, post)
No interpolation at the boundary
%}


%% Init
load('./powers_rm.mat');
COLORS = [217 81 78; 4 43 152; 45 168 216]/255; LN = 0.5; 

subjects = [1 3 5 6 ...
            7 9 10 11 13 ...
            15 16 17 18 19 ...
            21 22 23 24];  %9 15 19 21 25
% subjects = [21];

alphaCereSubjects = []; betaCereSubjects = []; deltaCereSubjects = [];
gammaCereSubjects = []; thetaCereSubjects = []; ttlCereSubjects = [];
alphaFrontSubjects = []; betaFrontSubjects = []; deltaFrontSubjects = [];
gammaFrontSubjects = []; thetaFrontSubjects = []; ttlFrontSubjects = [];
alphaMotSubjects = []; betaMotSubjects = []; deltaMotSubjects = [];
gammaMotSubjects = []; thetaMotSubjects = []; ttlMotSubjects = [];
alphaPSubjects = []; betaPSubjects = []; deltaPSubjects = [];
gammaPSubjects = []; thetaPSubjects = []; ttlPSubjects = [];
alphaOSubjects = []; betaOSubjects = []; deltaOSubjects = [];
gammaOSubjects = []; thetaOSubjects = []; ttlOSubjects = [];
subjectDataPts = zeros(length(subjects), 1);

% fig = figure('Position',[200,50,1440,840]);
for iSubject = 1:length(subjects)
subjectID = subjects(iSubject)
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end

% Determine max # of pts of the experiment across subjects
subjectPowers = powerM(subjectIDstr);
nTrials = subjectPowers.Count-7; gammaPowHist = [];
for trial = 1:nTrials
    trialIDstr = strcat('Trial',num2str(trial));
    trialPowers = subjectPowers(trialIDstr);
    gammaPowHist = [gammaPowHist, trialPowers.gamma];
end
cereGammaPow = mean(gammaPowHist([9,16,20],:));
ts = linspace(0, 28, length(cereGammaPow));
adapt_idx = logical((ts>=0) .* (ts<=28));
subjectDataPts(iSubject) = length(cereGammaPow(adapt_idx))
end
maxSubjectDataPts = max(subjectDataPts);

% figure('units','normalized','outerposition',[0 0 1 1]);
for iSubject = 1:length(subjects)
subjectID = subjects(iSubject);
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end

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

subjectPowers = powerM(subjectIDstr); 
nTrials = subjectPowers.Count-7;
baselineCere = subjectPowers('BaselineCere');
baselineFront = subjectPowers('BaselineFront');
baselineMotor = subjectPowers('BaselineMotor');
baselineP = subjectPowers('BaselineP');
baselineO = subjectPowers('BaselineO');
alphaPowHist = []; betaPowHist = [];  gammaPowHist = []; 
thetaPowHist = []; deltaPowHist = []; ttlPowHist = [];

% Link powers throughout the entire experiment for the current subject
for trial = 1:nTrials
    trialIDstr = strcat('Trial',num2str(trial));
    trialPowers = subjectPowers(trialIDstr);
    alphaPowHist = [alphaPowHist trialPowers.alpha];
    betaPowHist = [betaPowHist trialPowers.beta];
    deltaPowHist = [deltaPowHist trialPowers.delta];
    gammaPowHist = [gammaPowHist trialPowers.gamma];
    thetaPowHist = [thetaPowHist trialPowers.theta];
    ttlPowHist = [ttlPowHist trialPowers.total];
end

% Cerebellar
pwrMode = 'Abs'; % 'Abs', or 'Rel': band power/total power
[powCere, times, trigS, trigE] = getPowers(subjectPowers, maxSubjectDataPts, ...
                            ttlPowHist, alphaPowHist, betaPowHist, ...
                            deltaPowHist, thetaPowHist, gammaPowHist, ...
                            CERE, subjectID); 
trigs = [trigS trigE]; 
% Frontal
[powFront, times, trigS, trigE] = getPowers(subjectPowers, maxSubjectDataPts, ...
                            ttlPowHist, alphaPowHist, betaPowHist, ...
                            deltaPowHist, thetaPowHist, gammaPowHist, ...
                            FRONT, subjectID); 
% Motor
[powMotor, times, trigS, trigE] = getPowers(subjectPowers, maxSubjectDataPts, ...
                            ttlPowHist, alphaPowHist, betaPowHist, ...
                            deltaPowHist, thetaPowHist, gammaPowHist, ...
                            MOTOR, subjectID); 
% Parietal
[powParietal, times, trigS, trigE] = getPowers(subjectPowers, maxSubjectDataPts, ...
                            ttlPowHist, alphaPowHist, betaPowHist, ...
                            deltaPowHist, thetaPowHist, gammaPowHist, ...
                            PARIETAL, subjectID); 
                        
% O
[powO, times, trigS, trigE] = getPowers(subjectPowers, maxSubjectDataPts, ...
                            ttlPowHist, alphaPowHist, betaPowHist, ...
                            deltaPowHist, thetaPowHist, gammaPowHist, ...
                            O, subjectID);                         
res.time = times;
res.powCere = powCere;
res.powFront = powFront;
res.powParietal = powParietal;
res.powMotor = powMotor;
res.powO = powO;
res.trigs = trigs;
save(strcat('./results/res_0814/',subjectIDstr,'_EEG2.mat'), 'res');

% Rereference first; ICA next
% Check the boundary between quiet standing and adaptation
% Send summary

%% Final metrics for plotting
pltMode = 'Absolute Change';
[yl, alphaCereFinal, betaCereFinal, deltaCereFinal, ...
    gammaCereFinal, thetaCereFinal, ttlCereFinal] ...
  = getFinalMetrics(powCere, baselineCere, pltMode, pwrMode);

[yl, alphaFroFinal, betaFroFinal, deltaFroFinal, ...
    gammaFroFinal, thetaFroFinal, ttlFroFinal] ...
= getFinalMetrics(powFront, baselineFront, pltMode, pwrMode);

[yl, alphaMotFinal, betaMotFinal, deltaMotFinal, ...
    gammaMotFinal, thetaMotFinal, ttlMotFinal] ...
= getFinalMetrics(powMotor, baselineMotor, pltMode, pwrMode);

[yl, alphaPFinal, betaPFinal, deltaPFinal, ...
    gammaPFinal, thetaPFinal, ttlPFinal] ...
= getFinalMetrics(powParietal, baselineP, pltMode, pwrMode);

[yl, alphaOFinal, betaOFinal, deltaOFinal, ...
    gammaOFinal, thetaOFinal, ttlOFinal] ...
= getFinalMetrics(powO, baselineO, pltMode, pwrMode);

%% Link the results across subjects
alphaCereSubjects = [alphaCereSubjects; alphaCereFinal'];
betaCereSubjects = [betaCereSubjects; betaCereFinal'];
deltaCereSubjects = [deltaCereSubjects; deltaCereFinal'];
gammaCereSubjects = [gammaCereSubjects; gammaCereFinal'];
thetaCereSubjects = [thetaCereSubjects; thetaCereFinal'];
ttlCereSubjects = [ttlCereSubjects; ttlCereFinal'];

alphaFrontSubjects = [alphaFrontSubjects; alphaFroFinal'];
betaFrontSubjects = [betaFrontSubjects; betaFroFinal'];
deltaFrontSubjects = [deltaFrontSubjects; deltaFroFinal'];
gammaFrontSubjects = [gammaFrontSubjects; gammaFroFinal'];
thetaFrontSubjects = [thetaFrontSubjects; thetaFroFinal'];
ttlFrontSubjects = [ttlFrontSubjects; ttlFroFinal'];

alphaMotSubjects = [alphaMotSubjects; alphaMotFinal'];
betaMotSubjects = [betaMotSubjects; betaMotFinal'];
deltaMotSubjects = [deltaMotSubjects; deltaMotFinal'];
gammaMotSubjects = [gammaMotSubjects; gammaMotFinal'];
thetaMotSubjects = [thetaMotSubjects; thetaMotFinal'];
ttlMotSubjects = [ttlMotSubjects; ttlMotFinal'];

alphaPSubjects = [alphaPSubjects; alphaPFinal'];
betaPSubjects = [betaPSubjects; betaPFinal'];
deltaPSubjects = [deltaPSubjects; deltaPFinal'];
gammaPSubjects = [gammaPSubjects; gammaPFinal'];
thetaPSubjects = [thetaPSubjects; thetaPFinal'];
ttlPSubjects = [ttlPSubjects; ttlPFinal'];

alphaOSubjects = [alphaOSubjects; alphaOFinal'];
betaOSubjects = [betaOSubjects; betaOFinal'];
deltaOSubjects = [deltaOSubjects; deltaOFinal'];
gammaOSubjects = [gammaOSubjects; gammaOFinal'];
thetaOSubjects = [thetaOSubjects; thetaOFinal'];
ttlOSubjects = [ttlOSubjects; ttlOFinal'];
end
111
% xticks([0,4,24,28]); xlim([0,28]);
% xlabel('Time (minute)'); ylabel(yl); 
% set(gca,'FontSize',28); grid on;

% legend('S01','S02','S03','S04','S05','S06','S07','S08','S09','S10','S11');
% saveas(gcf,strcat('./results/eeg/vg/cp_',freq,'_vg.png'));
% saveas(gcf,strcat('./results/eeg/vg/cp_',freq,'_vg.fig'));
% Synchronization of Sensory Gamma Oscillations Promotes Multisensory Communication
% Frequency specific modulation of human somatosensory cortex

%% Plot subject-averaged results
figure('Position',[200,50,1440,280]);
dataPlot = ttlCereSubjects; 
x = times'; y = nanmean(dataPlot); 
sigma = nanstd(ttlCereSubjects); 
curve1 = y + sigma; 
curve2 = y - sigma;
x2 = [x, fliplr(x)]; inBetween = [curve1, fliplr(curve2)];
fill(x2, inBetween, 'k','FaceAlpha',0.2, ...
    'LineStyle','none'); hold on;
plot(x, y, 'k', 'LineWidth', 6);
% xline([4, 24],'--');
xticks([0, 4, 24, 28]); xlim([0,28]);
% xlabel('Time (minute)'); 
ylabel('mV^2/Hz'); ylim([0,240]);
% ylabel(yl); 
set(gca,'FontSize',22); grid on;
222

%% Cross band plot
gray1 = [.8 .8 .8]; gray2 = [.6 .6 .6];
figure('Position',[200,50,1600,800]); x = times'; 
y = nanmean(ttlCereSubjects); 
plot(x, y, 'k', 'LineWidth', 4); hold on;
y = nanmean(ttlFrontSubjects); 
plot(x, y, 'LineWidth', 4, 'Color', gray1); hold on;
y = nanmean(ttlMotSubjects); 
plot(x, y, 'LineWidth', 4, 'Color', gray2); hold on;
xticks([0, 4, 24, 28]); xlim([0,28]);
xlabel('Time (minute)'); ylabel(yl); 
set(gca,'FontSize',22); grid on;
% title('Total power change across brain regions');
legend('Cerebellar', 'Frontal', 'Motor');

%% Within band plot
PlotPowersSub(times, ttlCereSubjects, ...
             deltaCereSubjects, ...
             thetaCereSubjects, ...
             alphaCereSubjects, ...
             betaCereSubjects, ...
             gammaCereSubjects, yl);

%%
figure('Position',[200,50,1440,840]);
x = times'; lw = 4;
dataPlot = deltaCereSubjects; y = nanmean(dataPlot); 
plot(x, y, 'LineWidth', lw); hold on;
dataPlot = thetaCereSubjects; y = nanmean(dataPlot); 
plot(x, y, 'LineWidth', lw); hold on;
dataPlot = alphaCereSubjects; y = nanmean(dataPlot); 
plot(x, y, 'LineWidth', lw); hold on;
dataPlot = betaCereSubjects; y = nanmean(dataPlot); 
plot(x, y, 'LineWidth', lw); hold on;
dataPlot = gammaCereSubjects; y = nanmean(dataPlot); 
plot(x, y, 'LineWidth', lw); hold on;
xline([4, 24],'--'); 
legend('Delta','Theta','Alpha','Beta','Gamma');
xticks([0, 4, 8, 12, 16, 20, 24, 28]); xlim([0,28]);
xlabel('Time (minute)'); ylabel(yl); 
set(gca,'FontSize',22); grid on;
222

figure('Position',[200,50,1440,840]); 
x = times'; lw = 1;
for i = 1:18
    subplot(5,4,i);
%     y = deltaCereSubjects(i,:); 
%     plot(x, y, 'LineWidth', lw); hold on;
%     y = deltaCereSubjects(i,:); 
%     plot(x, y, 'LineWidth', lw); hold on;
%     y = alphaCereSubjects(i,:); 
%     plot(x, y, 'LineWidth', lw); hold on;
%     y = betaCereSubjects(i,:); 
%     plot(x, y, 'LineWidth', lw); hold on;
%     y = gammaCereSubjects(i,:); 
%     plot(x, y, 'LineWidth', lw); hold on;
    y = ttlCereSubjects(i,:); 
    plot(x, y, 'LineWidth', lw); hold on;
end

xticks([0, 4, 24, 28]); xlim([0,28]);
xlabel('Time (minute)'); ylabel(yl); grid on; 

figure('Position',[200,50,1440,840]);
for i = 1:19
    y = deltaCereSubjects(i,:); 
    plot(x, y, 'k', 'LineWidth', lw); hold on;
end

