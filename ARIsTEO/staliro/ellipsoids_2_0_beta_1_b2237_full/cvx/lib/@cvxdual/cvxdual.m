% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = cvxdual( prob, name )
error( nargchk( 2, 2, nargin ) );

%
% Check problem
%

if ~isa( prob, 'cvxprob' ),
    error( 'First argument must be a cvxprob object.' );
end

%
% Create the object
%

y = class( struct( 'problem_', prob, 'name_', name ), 'cvxdual', cvxobj );

% Copyright 2012 CVX Research, Inc.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
