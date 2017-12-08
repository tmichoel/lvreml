function [X,alpha2,B,sigma2] = lvreml(Y,S,nx)
% LVREML - Restricted maximum-likelihood solution for linear mixed models with known and latent variance components 

ng = size(Y,2); % number of genes, samples

% Center Y and get overlap matrix
Y = bsxfun(@minus,Y,mean(Y));
C = (Y*Y')/ng;

% Full SVD of known covariates
[U,G,V] = svd(S);
nc2 = rank(G); % number of linearly independent covariates

% Split in space spanned by covariates and orthogonal complement
G1 = G(1:nc2,1:nc2);
U1 = U(:,1:nc2);
U2 = U(:,nc2+1:end);
V1 = V(:,1:nc2);

C11 = U1'*C*U1;
C22 = U2'*C*U2;

% Get reml estimate for X, pulled-back to original space
[Vx,Ex] = eig(C22);
[Evx,t] = sort(diag(Ex),'descend');
X = U2*Vx(:,t(1:nx));
alpha2 = Evx(1:nx);

% Get estimate for residual variance
sigma2 = mean(Evx(nx+1:end));

% Get estimate for covariate covariance matrix
V1G = V1/G1; % V1*inv(G1);
B = V1G*(C11-sigma2*eye(nc2))*V1G';
