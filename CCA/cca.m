function [Wx, Wy, r] = cca(X,Y)
sx = size(X,1);
sy = size(Y,1);
z = [X;Y];
clear X Y

% z = gpuArray(z);
C = cov(z.');
clear z

disp(['cca 1']);
Cxx = C(1:sx, 1:sx) + 10^(-8)*eye(sx);
Cxy = C(1:sx, sx+1:sx+sy);
Cyx = Cxy';
Cyy = C(sx+1:sx+sy, sx+1:sx+sy) + 10^(-8)*eye(sy);
invCyy = inv(Cyy);

% --- Calcualte Wx and r ---
[Wx,r] = eig(inv(Cxx)*Cxy*invCyy*Cyx); % Basis in X
r = sqrt(real(r));      % Canonical correlations

clear C Cxx Cxy Cyy
disp(['cca 2']);
% --- Sort correlations ---

V = fliplr(Wx);		% reverse order of eigenvectors
r = flipud(diag(r));	% extract eigenvalues anr reverse their orrer
[r,I]= sort((real(r)));	% sort reversed eigenvalues in ascending order
r = flipud(r);		% restore sorted eigenvalues into descending order
for j = 1:length(I)
  Wx(:,j) = V(:,I(j));  % sort reversed eigenvectors in ascending order
end
clear V I
Wx = fliplr(Wx);	% restore sorted eigenvectors into descending order

% --- Calcualte Wy  ---
Wy = invCyy*Cyx*Wx;     % Basis in Y
Wy = Wy./repmat(sqrt(sum(abs(Wy).^2)),sy,1); % Normalize Wy

% Wx = gather(Wx); Wy = gather(Wy); r = gather(r);
end