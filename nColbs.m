function N = nColbs(a)
%N_COLBS Summary of this function goes here
%   Detailed explanation goes here
Theta = [15010.8331426491;-29346.0255326788;38219.3177356824;-15237.2254024907;126417.241992450];
sz = size(a);
a = a(:);
A = [ones(length(a), 1) a a.^2 a.^3  exp(-a*40.68)];

N = A * Theta;

N = N / 1.414280751350991e+05; %norm
N = reshape(N, sz);
end

