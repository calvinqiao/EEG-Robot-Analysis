function [Comp_save, B,W ] = myCCA(X,fs,tlag)
%  % program  by  Xueyuan Xu and Luchang Li.
% [Comp, B,W ] = myCCA(X,fs�� tlag) produces a matrix Comp of dimension [m by T] 
% which is an estimate of clean signals processed by the CCA algorithm.
% Note: > X: the observation matrix of dimension [m by T].
%       > m: sensor number.
%       > T: signal length.
%       > threshold: the autocorrelation of independent vectors below the threshold are judged as noise-related components
%       > W: demixing matrix.
Mlags = 1;
[numOfCV, T] = size(X);
for j = 1: length(Mlags)
    Y = zeros(numOfCV, T, Mlags(j)+1);
    W = cell(Mlags(j)+2, 1); % save whiten matrices for reconstruction

    % [tempY, tempW] = whiten(X', 0.001);
    wX = X'; wX = bsxfun(@minus, wX, mean(wX));  
    A = wX'*wX; [V,D] = eig(A); 
    tempW = V*diag(1./(diag(D)+0.001).^(1/2))*V';
    tempY = wX*tempW;
    clear A D V wX
    Y(:,:,1) = tempY'; W{1,1} = tempW; 
    disp(['First whiten done...']); 
    clear tempY tempW
    
    for i = 1: Mlags(j)
        %  tempX = timedelay(X, i*tlag);
        L = size(X,2); t = i*tlag;
        tempX = [X(:,L-t+1:end) X(:,1:L-t)];
        disp(['Time delay done...']); % time lags i.
        
%         [tempY, tempW] = whiten(tempX', 0.001); 
        wX = tempX'; wX = bsxfun(@minus, wX, mean(wX));  
        A = wX'*wX; [V,D] = eig(A); 
        tempW = V*diag(1./(diag(D)+0.001).^(1/2))*V';
        tempY = wX*tempW;
        clear A D V wX
        Y(:, :, i+1) = tempY'; W{i+1, 1} = tempW;
        disp(['Second whiten done...']);
        clear tempY tempW
    end 
    W{3, 1} = mean(X');
    clear tempX X
    
    % CCA
    disp(['CCA starts...']);  
    Y1 = squeeze(Y(:,:,1)); Y2 = squeeze(Y(:,:,1));
    [Wx, Wy, r] = cca(Y1, Y2);
    B(:, :, 1) = Wx';
    B(:, :, 2) = Wy';
    Comp = cell(Mlags(j)+1, 1);
    for i = 1: (Mlags(j)+1)
        Comp{i, 1} = B(:, :, i)*Y(:, :, i);
    end
    W31 = W{3, 1}';
    W31 = W31(:, ones(T, 1));
    for i = 1 : Mlags(j)+1
        Comp{i,1} = Comp{i,1}+B(:, :, i)*W{1,1}'*W31;
    end 
    Comp_save = real(Comp{1, 1});
    disp(['CCA done...']);
end    