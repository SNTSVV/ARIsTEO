% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = ne(X,Y)
%NE (overloaded)
%
%    F = set(ne(x,y))
%
%   See also SDPVAR/AND, SDPVAR/OR, BINVAR, BINARY

% Author Johan L�fberg
% $Id: ne.m,v 1.4 2009-02-25 12:29:25 joloef Exp $

% Models NE using logic constraints

% bin1 = isa(X,'sdpvar') | isa(X,'double');
% bin2 = isa(Y,'sdpvar') | isa(Y,'double');
%
% if ~(bin1 & bin2)
%     error('Not equal can only be applied to integer data')
% end

if isa(X,'sdpvar') & isa(Y,'sdpvar') & is(X,'binary') & is(Y,'binary')
    F = set(X + Y == 1);
elseif isa(X,'sdpvar') & is(X,'binary') &  isa(Y,'double') &  ismember(Y,[0 1])
    zv = find((Y == 0));
    ov = find((Y == 1));
    lhs = 0;
    if ~isempty(zv)
        lhs = lhs + sum(extsubsref(X,zv));
    end
    if ~isempty(ov)
        lhs = lhs + sum(1-extsubsref(X,ov));
    end
    F = set(lhs >=1);
else
    F = set((X<=Y-0.5) | (X>=Y+0.5));
end