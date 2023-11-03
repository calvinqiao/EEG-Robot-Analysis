clear; clc; close all;

fs = 500; 
ap_subjects = [];

fig = figure('Position',[200,50,1440,840]);
subjects = [1 3 4 5 6 ...
            7 9 10 11 13 ...
            15 16 17 18 19 ...
            21 24 25]; % 22 23 
subjects = 21;

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

% Check the t points for velocity
% Make sure vel is zero in the first 4 minutes
ap_var_total = []; ap_vel_total = []; 

for trial = 1:nTrials
    fileName = strcat([path,'Trial',num2str(trial),'.mat']);
    load(fileName);
    AP_variance = ap_vel.^2; 
    ap_var_total = [ap_var_total; AP_variance];
    ap_vel_total = [ap_vel_total; ap_vel];
end

dT = 1/fs; % sec
ts = (dT:dT:dT*length(ap_var_total)); % sec
subplot(2,1,1);
plot(ts, ap_var_total, 'LineWidth', 2); title('deg/s squared')
subplot(2,1,2);
plot(ts, ap_vel_total, 'LineWidth', 2); title('deg/s')

res.ap_var_final = ap_var_final;
res.time = ts_new;
save(strcat('./results/res_0814/', ...
     subjectIDstr,'_vel.mat'), 'res');
end

xlabel('Time (minute)'); ylabel('Vel Variance (deg/sec)^2');
xlim([0,28]); xticks([0,4,24,28]);
set(gca,'FontSize',28); grid on;

ap_subjects_mean = nanmean(ap_subjects);
ap_subjects_mean = fillmissing(ap_subjects_mean, 'pchip');
ap_subjects_std = nanstd(ap_subjects); 
ap_subjects_std = fillmissing(ap_subjects_std, 'pchip');

figure('Position',[200,50,1440,840]);
% idx = logical(ts_new >=4 .* ts_new <=24);
y = ap_subjects_mean; x = ts_new; 
curve1 = y + ap_subjects_std; 
curve2 = y - ap_subjects_std;
x2 = [x, fliplr(x)]; inBetween = [curve1, fliplr(curve2)];
fill(x2, inBetween, 'b'); hold on;
plot(x, y,'g','LineWidth', 3);
xticks([0, 4, 24, 28]); xlim([0,28]);
xlabel('Time (minute)'); ylabel('Velocity Variance (deg/sec)^2'); 
set(gca,'FontSize',28); grid on;

% indices_adapt = logical((ts >= 4) .* (ts <= 24));
% adapt = ap_var_total(indices_adapt);
% 
% b = -0.05206; %-1/tau = b; tau = -1/b
% tau = -1/b; % 19 minutes