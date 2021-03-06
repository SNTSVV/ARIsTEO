% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function binary( varargin )

%BINARY Declares an binary variable.
%   BINARY VARIABLE x
%   where x is a valid MATLAB variable name, declares a scalar variable for
%   the current CVX problem, and constraints it to the set {0,1}. Put
%   another way, it is equivalent to
%       integer variable x
%       0 <= x <= 1
%
%   BINARY VARIABLE x(SZ), where SZ is a size vector, declares an array of
%   size SZ and constrains each element to be binary. Structure modifiers
%   such as "symmetric", "toeplitz", etc. are also permitted.
%
%   BINARY VARIABLES x y(SZ) z ... can be used to declare multiple binary 
%   variables. Note however that structure modifiers are not permitted in
%   this case.
%
%   Obviously, binary variables are NOT convex. Problems with binary 
%   variables can only be handled by solvers with explicit support for
%   them; in particular, neither of the free solvers SeDuMi nor SDPT3
%   provide binary support.
%
%   Examples:
%      binary variable x
%      binary variable x(100)
%
%   See also INTEGER, VARIABLE, VARIABLES.

if nargin < 2 || ~iscellstr( varargin ),
    error( 'Syntax: binary variable <variable>   or   binary variables <variables>' );
elseif strcmpi( varargin{1}, 'variable' ),
    evalin( 'caller', sprintf( '%s ', 'variable', varargin{2:end}, ' binary' ) );
elseif strcmpi( varargin{1}, 'variables' ),
    for k = 2 : nargin,
        evalin( 'caller', sprintf( '%s ', 'variable', varargin{k}, ' binary' ) );
    end
else
    error( 'Syntax: binary variable <variable>   or   binary variables <variables>' );
end

% Copyright 2012 CVX Research, Inc.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
