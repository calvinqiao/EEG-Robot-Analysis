% clc; clear; close all;
% Recorded at 500 Hz
nTrials = 2; dt = 1/500;

subjects = [24]; % 22 23 
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
% ap_vel = []; delays = [];
halts_total = [];
ap_vel = []; delays = []; ap_pos = [];
for i = 1:nTrials
    
    data = readmatrix(strcat([path,'Trial',num2str(i),'.txt']));
    triggers = data(:,45);
    halts_trial = double((ischange(triggers)==1));
    halts_total = [halts_total; halts_trial];
    % plot(triggers);
    indexes_raw = find(ischange(triggers)==1); 
    indexes_raw = indexes_raw(1:2:end);

    indexes = zeros(length(indexes_raw)/2, 2);
    for j = 1:length(indexes_raw)
        if mod(j,2)==1
            i_row = ceil(j/2);
            indexes(i_row,1) = indexes_raw(j);
        end
        if mod(j,2)==0
            i_row = j/2;
            indexes(i_row,2) = indexes_raw(j);
        end
    end
%     delay = data(:,50);
    % plot(delay)
    ap_deg_raw = data(:,1); %plot(ap_deg_raw)
    temp = load('S22_trigs.mat'); 
    trigs = temp.trigs_downsampled;
    
    for k = 1:i_row
%         k
%        if i == 4 && (k == i_row-1)
%            continue
%        end
%        if i == 3 && k == 1
%            continue
%        end
       s = indexes(k,1); e = indexes(k,2);
       ap_pos = [ap_pos; ap_deg_raw(s:e,1)];
       ap_vel = [ap_vel; diff(ap_deg_raw(s:e,1))/dt];
%        delays = [delays; delay(s:e-1,1)];
    end
    fileName = strcat([path,'Trial',num2str(i),'.mat'])
    save(fileName, 'ap_vel');
    totalTime = sum((indexes(:,2)-indexes(:,1)))/500
end
end
% overlapPercent = 1;
% buf = buffer(halts_total, 60*1/dt);
% halts = ceil(sum(buf)/2); 
% plot(halts, '-o', 'LineWidth', 3); hold on; grid on;
% xlim([0,110]);

times = (dt:dt:length(ap_vel)*dt)/60;
figure('Position',[200,50,288,220]);
plot(times, ap_vel.^2);
xticks([0, 4, 24, 28]); xlim([0,28]);
ylabel('(deg/sec)^2'); %ylim([0,240]);
set(gca,'FontSize',14); grid on;




