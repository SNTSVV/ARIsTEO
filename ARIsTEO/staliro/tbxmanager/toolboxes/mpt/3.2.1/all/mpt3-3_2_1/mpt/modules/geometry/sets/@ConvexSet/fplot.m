% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function h = fplot(obj, varargin)
%
% Plot a single function over a convex set or over an array of convex sets.
%
% P.fplot() -- plots the single function of the object "P"
% P.fplot('fname') -- plots function of given name
% P.fplot('opt1', value1, ...) -- plots the only function with options
% P.fplot('fname', 'opt1', value1, ...) -- plots a given function with options
% h = P.fplot(...) -- returns handle of the plot
%
% All sets must be bounded and non-empty. Throws an error if at least one
% element of the array violates these assumptions.
%
% Options:
%  'color': color of the function
%     string, default=[] (in which case colormap is employed)
%  'position': which element of the function value to plot
%     integer, default=1
%  'show_set': if true, the underlying set will be plotted as well
%     logical, default=false
%  'alpha': transparency (1=opaque, 0=complete transparency)
%     numeric, default=1
%  'edgealpha': transparency of edges (1=opaque, 0=complete transparency)
%     double, default=1
%  'wire': if true, only plots the wire frame
%     logical, default=false
%  'linestyle': style of lines, same as in matlab's plot
%     string, default='-'
%  'linewidth': width of lines, same as in matlab's plot
%     numeric, default=1
%  'edgecolor': color of edges
%     string/numeric, default='k'
%  'showgrid': if true, the grid will be shown
%     logical, default=false
%  'contour': if true, contour lines of the function will be plotted
%     logical, default=false
%  'colormap': color map to use
%     string or a function handle, default='mpt'
%  'colororder': either 'fixed' or 'random'
%     string, default='fixed'

% Implementation:
% ---------------
%
% ConvexSet/fplot is the main (and only) official fplot method for
% convex set and all derived classes. Hence even Polyhedron/fplot goes
% via ConvexSet/fplot.
%
% ConvexSet/fplot is just a dispatcher whose sole purpose is to:
%  1) perform error checks (dimension, boundedness, emptinies)
%  2) parse input arguments
%  3) validate inputs
%  4) call obj(i).fplot_internal() for each element of the array
%
% The actual plotting is done via fplot_internal(). Notes:
%  * This internal helper plots just a single set. Does not handle arrays!
%  * No error checks are performed (was already done in ConvexSet/fplot)
%  * No imput parsing (done in ConvexSet/fplot)
%  * The syntax must be "h = fplot_internal(obj, function_name, options)".
%     Must return a vector of handles. "options" must be a structure
%     generated by inputParser in ConvexSet/fplot. All inputs are
%     mandatory.
%  * If a class defines a custom plotting behavior, then the helper must be
%    declared as a protected method in the class constructor as follows:
% 	    methods (Access=protected)
%           % just include the function prototype here
% 	    	h = fplot_internal(obj, function_name, options)
% 	    end
%     Then place the actual implementation directly into the class main
%     directory (do not store it into @class/private/ !)
%  * ConvexSet/fplot_internal is very general and plots arbitrary convex
%    sets. That's why we have no YSet/fplot_internal.
%
% Notes:
% ------
%  * do NOT introduce fplot() methods in subclasses of ConvexSet!
%  * you MUST declare the prototype of fplot_internal as a protected
%    method in the class constructor if you want to redefine it
%  * if nargout=0, then no handle(s) must be returned
%  * the validation code is shared with ConvexSet/feval

global MPTOPTIONS

%% error checks
error(nargoutchk(0,1,nargout));
if any([obj.Dim]>=3)
    error('Can only plot functions over 2D sets.');
end
if any(~obj.isBounded)
	error('Can only plot bounded polyhedra.');
end
if any(obj.isEmptySet)
	error('Cannot plot function over empty sets.');
end

%% parsing
if mod(numel(varargin), 2)==0
	% P.fplot('opt1', value1, ...)
	start_idx = 1;
	function_name = '';
elseif numel(varargin)>0
	% P.fplot('function_name', 'option', value, ...)
	start_idx = 2;
	function_name = varargin{1};
end
ip = inputParser;
ip.KeepUnmatched = true;
ip.addParamValue('color',  [], @validate_color);
ip.addParamValue('wire',       false,  @(x) islogical(x) || x==1 || x==0);
ip.addParamValue('linestyle',  '-', @validate_linestyle);
ip.addParamValue('linewidth',  1,   @isnumeric);
ip.addParamValue('edgecolor', 'k', @validate_color);
ip.addParamValue('edgealpha', 1, @(x) isnumeric(x) && x>=0 && x<=1);
ip.addParamValue('alpha',      1, @(x) isnumeric(x) && x>=0 && x<=1);
ip.addParamValue('contour',    false, @(x) islogical(x) || x==1 || x==0);
ip.addParamValue('grid',  20,   @isnumeric);
ip.addParamValue('contourGrid',  30,   @isnumeric);
ip.addParamValue('colormap', 'mpt', @(x) (isnumeric(x) && size(x, 2)==3) || ischar(x)); 
ip.addParamValue('colororder', 'fixed', @(x) isequal(x, 'fixed') || isequal(x, 'random'));
ip.addParamValue('showgrid', false, @islogical);
% show_set=true plots the underlying polyhedron
ip.addParamValue('show_set', false, @islogical);
% position=i plots the i-th element f(i) of f=fun(x)
ip.addParamValue('position', 1, @validate_indexset);

% internal parameters
ip.addParamValue('use_hold', true, @islogical);
ip.addParamValue('use_3dview', true, @islogical);
ip.addParamValue('array_index', 1);

ip.parse(varargin{start_idx:end});
options = ip.Results;

%% validation
[function_name, msg] = obj.validateFunctionName(function_name);
error(msg); % the error is only thrown if msg is not empty

fun = obj(1).getFunction(function_name);
if (isa(fun, 'AffFunction') || isa(fun, 'QuadFunction')) && ...
		options.position>fun.R
	error('The position index must be less than %d.', fun.R+1);
end

%% plotting
% hold the plot for the first element of the array
if options.use_hold
	prevHold = ishold;
	if ~ishold,
		newplot;
	end
	hold('on');
end

% plot the array
tic
h = [];
for i=1:numel(obj)
	if toc > MPTOPTIONS.report_period,
		% refresh the plot every 2 seconds
		drawnow;
		tic;
	end
	if numel(obj)>1
		options.array_index = i;
	end
	hi = obj(i).fplot_internal(function_name, options);
	h = [h; hi];
end

if options.use_hold && ~prevHold
	hold('off');
end
if options.use_3dview && any([obj.Dim] >= 2)
	view(3);
	axis tight
end
grid on

if nargout==0
	clear h
end


end