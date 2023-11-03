clear; close all; clc;


%% Init
load('./necks_0919.mat');
COLORS = [217 81 78; 4 43 152; 45 168 216]/255; LN = 0.5; 
subjects = [1 3 4 5 6 ...
            7 9 10 11 13 ...
            15 16 17 18 19 ...
            21 22 23 24 25]; 
c1Subjects = []; c2Subjects = [];
subjectDataPts = zeros(length(subjects), 1);

for iSubject = 1:length(subjects)
subjectID = subjects(iSubject);
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end

subjectNecks = neckM(subjectIDstr);
nTrials = subjectNecks.Count-3; c1AmpHist = [];
for trial = 1:nTrials
    trialIDstr = strcat('Trial',num2str(trial));
    trialNecks = subjectNecks(trialIDstr);
    c1AmpHist = [c1AmpHist, trialNecks.amps];
end
neckAmp = mean(c1AmpHist);
subjectDataPts(iSubject) = length(neckAmp);
end
maxSubjectDataPts = max(subjectDataPts)

for iSubject = 1:length(subjects)
subjectID = subjects(iSubject);
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end

subjectNecks = neckM(subjectIDstr); 
nTrials = subjectNecks.Count-3;
baseline = subjectNecks('Baseline');
c1NeckHist = []; c2NeckHist = [];

% Link powers throughout the entire experiment for the current subject
for trial = 1:nTrials
    trialIDstr = strcat('Trial',num2str(trial));
    trialNecks = subjectNecks(trialIDstr);
    c1NeckHist = [c1NeckHist trialNecks.amps(1,:)];
    c2NeckHist = [c2NeckHist trialNecks.amps(2,:)];
end

pwrMode = 'Abs'; % 'Abs', or 'Rel': band power/total power
[neck1, neck2, times, trigS, trigE] = getNecks(subjectNecks, ...
                            maxSubjectDataPts, ...
                            c1NeckHist, c2NeckHist); 
trigs = [trigS trigE];  

%% Final metrics for plotting 
pltMode = 'Absolute Change';
[yl, neck1Final] ...
  = getNeckFinal(neck1, baseline, pltMode, 1);
[y2, neck2Final] ...
  = getNeckFinal(neck2, baseline, pltMode, 2);

%% Link the results across subjects
c1Subjects = [c1Subjects; neck1Final'];
c2Subjects = [c2Subjects; neck2Final'];

end


%% Plot subject-averaged results
figure('Position',[200,50,1440,840]);
dataPlot = c2Subjects;
y = mean(dataPlot); x = times'; 
plot(x, y, 'k', 'LineWidth', 6);
xline([4, 24],'--');
xticks([0, 4, 8, 12, 16, 20, 24, 28]); xlim([0,28]);
xlabel('Time (minute)'); ylabel(yl); 
set(gca,'FontSize',22); grid on;
figure('Position',[200,50,1440,840]);
for i = 1:20
    subplot(4,5,i);
    plot(x, dataPlot(i, :), 'k', 'LineWidth', 2); % hold on;
    xticks([0, 4, 24, 28]); xlim([0,28]);
    xlabel('Time (minute)'); ylabel(yl); grid on; 
end




