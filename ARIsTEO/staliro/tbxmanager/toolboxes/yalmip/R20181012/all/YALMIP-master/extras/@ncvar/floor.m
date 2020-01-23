% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function varargout=ceil(varargin)
%FLOOR (overloaded)

switch class(varargin{1})

    case 'sdpvar' % Overloaded operator for SDPVAR objects. Pass on args and save them.

        x = varargin{1};
        [n,m] = size(x);
        x = reshape(x,n*m,1);
        y = [];
        for i = 1:n*m
            y = [y;yalmip('addextendedvariable',mfilename,extsubsref(x,i))];
        end
        y = reshape(y,n,m);
        varargout{1} = y;
        
    case 'char' % YALMIP send 'graph' when it wants the epigraph or hypograph
        switch varargin{1}
            case {'milp','graph'}
                % Description using epigraphs
                t = varargin{2};
                X = varargin{3};
                
                c = intvar(1,1);
                F = (x-1 <= c <= x);

                varargout{1} = F;
                varargout{2} = struct('convexity','milp','monotonicity','milp','definiteness','milp');
                varargout{3} = X;
                
            otherwise
                error('SDPVAR/SORT called with CHAR argument?');
        end
    otherwise
        error('Strange type on first argument in SDPVAR/SORT');
end