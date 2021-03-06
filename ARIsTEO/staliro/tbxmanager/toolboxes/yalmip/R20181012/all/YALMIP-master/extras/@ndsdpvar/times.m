% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = times(X,Y)
% times (overloaded)

if isa(X,'ndsdpvar')
    dim = X.dim;
    X = sdpvar(X);
else
    X = X(:);
end
if isa(Y,'ndsdpvar')
    dim = Y.dim;
    Y = sdpvar(Y);
else
    Y = Y(:);
end

F = X.*Y;
F = reshape(F,dim);