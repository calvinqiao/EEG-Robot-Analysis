function [reconstructed_clean] = EEMD_CCA(input_eeg, num_IMFs, fs)
    addpath('./EEMD/'); addpath('./CCA/')
    input_eeg = double(input_eeg);

%     if fs >= 1000
%         input_eeg = (resample(input_eeg.', 1, 4)).';
%         fs = fs/4;
%     end
    fs
    
%     input_eeg = single(input_eeg);
    [postEEMD, num_IMFs] = EEMD_mdecompose(input_eeg, 0.2, ...
        10, fs, num_IMFs); 
    % clear input_eeg
    postEEMD = single(postEEMD);
    
%     postEEMD = gpuArray(postEEMD);
    [decomposed_data, B_mc, W_mc] = myCCA(postEEMD, fs, 1);
%     clear postEEMD
    decomposed_data = real(decomposed_data);
    
    nrows = size(decomposed_data, 1);
    clean_data = zero_artifacts(...
        decomposed_data, round(nrows*1/2):nrows);
%     clear decomposed_data
    
    clean_data = inv(W_mc{1,1}')*inv(B_mc(:,:,1))*clean_data;
    reconstructed_clean = real(multiEEG_1_recon(clean_data, clean_data, input_eeg, num_IMFs, fs));
    % reconstructed_clean = gather(reconstructed_clean);
end