clear; clc; close all;

fs = 500; 
window_duration = 60; window_width = window_duration*fs;
ap_subjects = [];

% fig = figure('Position',[200,50,1440,840]);
subjects = [1 3 4 5 6 ...
            7 9 10 11 13 ...
            15 16 17 18 19 ...
            21 24 25]; % 22 23 
subjects = [1 5 6 7 9 10 ... 
    11 15 16 18 19 25];
subjects = 7;
subjectDataPts = zeros(length(subjects), 1);

for iSubject = 1:length(subjects)
subjectID = subjects(iSubject)
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end
% Determine max # of pts of the experiment across subjects
subjectDataDir = append(strcat('./subjects/', subjectIDstr, '/pxi/*.txt'));
nameList = dir(subjectDataDir); nTrials = length(nameList);
path = strcat('./subjects/', subjectIDstr, '/pxi/');
vel_hist = [];
for trial = 1:nTrials
    fileName = strcat([path,'Trial',num2str(trial),'.mat']);
    load(fileName); vel_hist = [vel_hist; ap_vel];
end
subjectDataPts(iSubject) = length(vel_hist)
end
maxSubjectDataPts = max(subjectDataPts);

for iSubject = 1:length(subjects)
subjectID = subjects(iSubject)
if subjectID < 10
   subjectIDstr = strcat('S0', num2str(subjectID));
else
   subjectIDstr = strcat('S', num2str(subjectID));
end
subjectDataDir = append(strcat('./subjects/', subjectIDstr, '/pxi/*.txt'));
nameList = dir(subjectDataDir); nTrials = length(nameList);
path = strcat('./subjects/', subjectIDstr, '/pxi/');

ap_var_total = []; 
for trial = 1:nTrials
    fileName = strcat([path,'Trial',num2str(trial),'.mat']);
    load(fileName);
    AP_variance = ap_vel.^2; 
    mean_AP_variance = mean(buffer(AP_variance, window_width));
    mean_AP_variance = mean_AP_variance(1:end-1);
    ap_var_total = [ap_var_total,mean_AP_variance];
end

dT = window_duration; % sec
ts = (dT:dT:dT*length(ap_var_total))/60; % min
T = ts(end); T1=T/7; T2=T1+(T*5/7); %T3 = T-T/7;
ts_old_pre = ts(ts<=T1);
ts_old_adapt = ts(logical((ts>=T1).*(ts<=T2)));
ts_old_post = ts(ts>=T2);
ts_new = 1:28;
ts_new_pre = ts_new(ts_new<=4);
ts_new_adapt = ts_new(logical((ts_new>=5).*(ts_new<=24)));
ts_new_post = ts_new(ts_new>=25);

ap_var_pre = ap_var_total(ts<=T1);
ap_var_adapt = ap_var_total(logical((ts>=T1).*(ts<=T2)));
ap_var_post = ap_var_total(ts>=T2); 

temp_pre = interp1(ts_old_pre, ap_var_pre, ts_new_pre);
temp_adapt = interp1(ts_old_adapt, ap_var_adapt, ts_new_adapt);
temp_post = interp1(ts_old_post, ap_var_post, ts_new_post);

ap_var_final = [temp_pre temp_adapt temp_post];
if iSubject == 17 || iSubject == 18
   iSubject = iSubject +2; 
end

ap = [temp_pre temp_adapt temp_post];
ap_subjects = [ap_subjects; ap];
end

figure('Position',[50,50,1840,280]);
x = ts_new; y = ap_subjects;
y = fillmissing(ap_subjects, 'pchip');
plot(x, y,'k','LineWidth', 4);
xticks([1:28]); xlim([1,28]); 
xlabel('Time (minute)'); 
ylabel('(deg/sec)^2'); 
set(gca,'FontSize',22); grid on;

111
ap_subjects_mean = nanmean(ap_subjects);
y = fillmissing(ap_subjects_mean, 'pchip');
ap_subjects_std = nanstd(ap_subjects); 
sigma = fillmissing(ap_subjects_std, 'pchip');
111
clear ts_new_adapt ts_new_pre ts_new_post
clear vel_hist temp_adapt temp_post temp_pre
clear ap ap_var_post ap_var_pre ap_vel
clear temp_adapt temp_post temp_pre
clear ts_old_adapt ts_old_pre ts_old_post
clear ap_var_final ap_var_total AP_variance
clear ap_subjects_mean ap_subjects_std ap_var_adapt


plot(ts_new, y, '-*');

figure('Position',[50,50,1840,280]);
x = ts_new; 
curve1 = y + sigma; 
curve2 = y - sigma;
x2 = [x, fliplr(x)]; inBetween = [curve1, fliplr(curve2)];
fill(x2, inBetween, 'k','FaceAlpha',0.2, ...
    'LineStyle','none'); hold on;
plot(x, y,'k','LineWidth', 4);
xticks([1:28]); xlim([1,28]); 
xlabel('Time (minute)'); 
ylabel('(deg/sec)^2'); 
set(gca,'FontSize',22); grid on;
