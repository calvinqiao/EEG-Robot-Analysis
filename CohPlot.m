clear; close all; clc;

load('./cohs_eemdall_halfcomp.mat');

COLORS = [217 81 78; 4 43 152; 45 168 216]/255;
subjects = [1 3 5 6 ...
            7 9 10 11 13 ...
            15 16 17 18 19 ...
            21 22 23 24 25];
N_PTS = 120;
alphaImgSubjects = []; betaImgSubjects = []; deltaImgSubjects = [];
gammaImgSubjects = []; thetaImgSubjects = []; ttlImgSubjects = [];
alphaMagSubjects = []; betaMagSubjects = []; deltaMagSubjects = [];
gammaMagSubjects = []; thetaMagSubjects = []; ttlMagSubjects = [];
LN = 3; windowTime = 1*N_PTS/round(1/(1-cohM('Overlap')));
subjectDataPts = zeros(length(subjects), 1);

for iSubject = 1:length(subjects)
subjectID = subjects(iSubject)
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end

% Determine max # of pts of the experiment across subjects
subjectCohs = cohM(subjectIDstr);
nTrials = subjectCohs.Count-3; gammaCohHist = [];
for trial = 1:nTrials
    trialIDstr = strcat('Trial',num2str(trial));
    trialCohs = subjectCohs(trialIDstr);
    gammaCohHist = [gammaCohHist; trialCohs(:,1)];
end
subjectDataPts(iSubject) = length(gammaCohHist);
end
maxSubjectDataPts = max(subjectDataPts)

% figure('Position',[200,50,1440,840]);
for iSubject = 1:length(subjects)

subjectID = subjects(iSubject);
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end

subjectCohs = cohM(subjectIDstr);
nTrials = subjectCohs.Count-3;
baseline = subjectCohs('Baseline');

alphaImgCohHist = []; betaImgCohHist = [];  gammaImgCohHist = []; 
thetaImgCohHist = []; deltaImgCohHist = []; ttlImgCohHist = [];
alphaMagCohHist = []; betaMagCohHist = [];  gammaMagCohHist = []; 
thetaMagCohHist = []; deltaMagCohHist = []; ttlMagCohHist = [];
for trial = 1:nTrials
    trialIDstr = strcat('Trial',num2str(trial));
    trialCohs = subjectCohs(trialIDstr);
    alphaImgCohHist = [alphaImgCohHist; trialCohs(:,1)];
    betaImgCohHist = [betaImgCohHist; trialCohs(:,2)];
    deltaImgCohHist = [deltaImgCohHist; trialCohs(:,3)];
    gammaImgCohHist = [gammaImgCohHist; trialCohs(:,4)];
    thetaImgCohHist = [thetaImgCohHist; trialCohs(:,5)];
    ttlImgCohHist = [ttlImgCohHist; trialCohs(:,6)];

    alphaMagCohHist = [alphaMagCohHist; trialCohs(:,7)];
    betaMagCohHist = [betaMagCohHist; trialCohs(:,8)];
    deltaMagCohHist = [deltaMagCohHist; trialCohs(:,9)];
    gammaMagCohHist = [gammaMagCohHist; trialCohs(:,10)];
    thetaMagCohHist = [thetaMagCohHist; trialCohs(:,11)];
    ttlMagCohHist = [ttlMagCohHist; trialCohs(:,12)];
end

% ts = linspace(0, round(length(alphaImgCohHist(1,:))*windowTime/60), length(alphaImgCohHist(1,:)));
% ts_new = linspace(0, 28, maxSubjectDataPts); 

ts = subjectCohs('TimeVec');  
[alphaImgCohs, betaImgCohs, deltaImgCohs, ...
 gammaImgCohs, thetaImgCohs, ttlImgCohs,times] = processCohs(...
    alphaImgCohHist, betaImgCohHist, deltaImgCohHist, ...
    gammaImgCohHist, thetaImgCohHist, ttlImgCohHist, ...
    ts, maxSubjectDataPts);

[alphaMagCohs, betaMagCohs, deltaMagCohs, ...
 gammaMagCohs, thetaMagCohs, ttlMagCohs,times] = processCohs(...
    alphaMagCohHist, betaMagCohHist, deltaMagCohHist, ...
    gammaMagCohHist, thetaMagCohHist, ttlMagCohHist, ...
    ts, maxSubjectDataPts);

% [alphaImgFnl, betaImgFnl, deltaImgFnl, gammaImgFnl, thetaImgFnl, ...
%  ttlImgFnl] = getFinalCohMetrics(...
%     alphaImgCohs, betaImgCohs, deltaImgCohs, ...
%     gammaImgCohs, thetaImgCohs, ttlImgCohs, baseline);
length(alphaImgCohs)
alphaImgSubjects = [alphaImgSubjects; alphaImgCohs'];
betaImgSubjects = [betaImgSubjects; betaImgCohs'];
deltaImgSubjects = [deltaImgSubjects; deltaImgCohs'];
gammaImgSubjects = [gammaImgSubjects; gammaImgCohs'];
thetaImgSubjects = [thetaImgSubjects; thetaImgCohs'];
ttlImgSubjects = [ttlImgSubjects; ttlImgCohs'];
alphaMagSubjects = [alphaMagSubjects; alphaMagCohs'];
betaMagSubjects = [betaMagSubjects; betaMagCohs'];
deltaMagSubjects = [deltaMagSubjects; deltaMagCohs'];
gammaMagSubjects = [gammaMagSubjects; gammaMagCohs'];
thetaMagSubjects = [thetaMagSubjects; thetaMagCohs'];
ttlMagSubjects = [ttlMagSubjects; ttlMagCohs'];
end

figure('Position',[200,50,1600,400]);
dataPlot = alphaMagSubjects; %([1:15, 17:20], :);
y = mean(dataPlot); x = times'; 
% curve1 = y + std(dataPlot); curve2 = y - std(dataPlot);
% x2 = [x, fliplr(x)]; inBetween = [curve1, fliplr(curve2)];
% fill(x2, inBetween, 'b'); hold on;
plot(x, y, 'k', 'LineWidth', 6);
xline([4, 24],'--');
xticks([0, 4, 8, 12, 16, 20, 24, 28]); xlim([0,28]);
xlabel('Time (minute)'); ylabel('Coherence'); 
set(gca,'FontSize',22); grid on;
222

figure('Position',[200,50,1440,840]);
for i = 1:19
    subplot(4,5,i);
    plot(x, dataPlot(i, :), 'k', 'LineWidth', 2); % hold on;
    xticks([0, 4, 24, 28]); xlim([0,28]);
    xlabel('Time (minute)'); ylabel('Coherence'); grid on; 
end
