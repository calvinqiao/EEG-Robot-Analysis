function [X W] = whiten(X,fudgefactor)  
%  program  by  Xueyuan Xu and Luchang Li.
%[X W] = whiten(X,fudgefactor)  produces a matrix X of dimension [m by T] 
% which is an algorithm for adding White noise  .
% Note: > x: the observation matrix of dimension [m by T].
X = bsxfun(@minus, X, mean(X));  
A = X'*X;
% A = gpuArray(A);
[V,D] = eig(A); 
clear A
W = V*diag(1./(diag(D)+fudgefactor).^(1/2))*V';
clear D V
X = X*W;
% X = gather(X); 
% W = gather(W);
end 
