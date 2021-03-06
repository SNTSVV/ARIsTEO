% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% INPUTS:
%   HA - hybrid automaton as defined in hasimulate
%   hh - a trajectory of the hybrid automaton
%   locHis - the location history
%   opt - options
%       opt{1}(1) - 0 : 0 use quadprog (default)
%                   1 : 1 use cvx (cvx and sedumi must be installed)
%       opt{1}(2) - 0 : take into account system dyanmics (default)
%                   1 : do not take into account the system dynamics when
%                       computing distance from guards
%       opt{2}(1) - Tolerance to regard a value as zero 
%                   (default value 10^-3)
%       opt{2}(2) - the simulation time to consider past a switching 
%                   guard (not used in this version)
%       opt{2}(3) - 0 : give equal weight to all dimensions
%                   1 : give 0 weight to the dimensions that do not have
%                       any constraints (default)
%
% OUTPUTS:
%   d_his - the minimum distance found in each discrete location along the
%       simulation path. Note d_his(1) contains the minimum distance of the
%       whole trajectory at the initial condition x0
%   M_his - is the matrix of the lyapunov function in each discrete 
%       location along thesimulation path.
%   x_his - is the point of the continuous trajectory on the switching
%       surface. x_his(1,:) contains x0.
%

% (C) Georgios Fainekos

% History:

function [d_his,M_his,x_his] = computeRobNeighborhoods(HA,hh,locHis, opt)

if nargin<4
    opt_gd = [0 0];
    RobTestPres = 10^-3; % Presicion to regarded as zero
    t_e = 0.05;
    opt_w = 1;
else
    opt_gd = opt{1};
    RobTestPres = opt{2}(1); % Presicion to regarded as zero
    t_e = opt{2}(2);
    opt_w = opt{2}(3);
end

% Initialize
nloc = length(HA.loc);
nhis = length(locHis);
M_bis = cell(nloc,2);
M_his = cell(nhis,1);
d_his = zeros(nhis,1);
x_his = zeros(nhis,length(hh(1,3:end)));
nhh = length(hh);
nos = length(hh(1,3:end));
distHis = zeros(nhh,1);
distPrevLoc = inf;
kk = nhis;
cloc = locHis(kk);
dist = inf;
cG = [];

% Compute neighborhood in last location
% get weights for the optimization of the ellipsoids
if opt_w
    oc = getWeights(cloc,HA);
else
    oc = ones(1,nos);
end
% Compute ellipsoid
[MM,RR] = computeLyap(HA.loc(cloc).A,oc);
M_bis{cloc,1} = MM;
M_bis{cloc,2} = RR;
M_his{end} = MM;
% update location dynamics
RInv = inv(RR);
Anew = RR*HA.loc(cloc).A*RInv; %#ok<MINV>
bnew = RR*HA.loc(cloc).b;

% find the active guards
actGuards = HA.adjList{cloc};

% compute min distance
ii_last = [];
for ii = nhh:-1:1
    % ii
    xx = hh(ii,3:end)';
    % Find out which is the guard that you crossed
    if locHis(kk)~=hh(ii,1)
        d_his(kk) = dist;
        % simulate the system pass the guard set
        % this executes only after the back-propagation of distance in 
        % each loaction has been completed
%         if ~isempty(ii_last)
%             [id,t_in,d_new] = simulateafterguard(hh(ii,3:end),RR,HA.loc(cloc).A,HA.loc(cloc).b,HA.guards(cloc,cG).A,HA.guards(cloc,cG).b,MM,dist^2,t_e,'ode45');
%             if id==0
%                 dist = d_new;
%             end
%         end
        ii_last = ii;
        kk = kk-1;
%         if locHis(kk)~=hh(ii,1) % assertion - this part should never be reached
%             error('History does not match the hybrid automaton trajectory');
%         end
        % get new location
        cloc = locHis(kk);
        % update distances
        distPrevLoc = dist;
        dist = inf;
        % update ellipsoid
        if opt_w
            oc = getWeights(cloc,HA);
        else
            oc = ones(1,nos);
        end
        MMold = MM;
        if isempty(M_bis{cloc})
            [MM,RR] = computeLyap(HA.loc(cloc).A,oc);
            M_his{kk} = MM;
        else
            MM = M_bis{cloc,1};
            RR = M_bis{cloc,2};
            M_his{kk} = MM;
        end
        % Keep previous min distance
        % update location dynamics
        RInv = inv(RR);
        Anew = RR*HA.loc(cloc).A*RInv; %#ok<MINV>
        bnew = RR*HA.loc(cloc).b;
        % find the active guards
        actGuards = HA.adjList{cloc};
        % crossed guard
        icG = find(actGuards == locHis(kk+1));
        cG = actGuards(icG);
        actGuards(icG) = [];
        % Compute the point that lies on the guard between the current and
        % the next continuous state
        xa = hh(ii+1,3:end)'; % Get the point after crossing the guard
        [xInt,noh] = findPointOnGuard(xx,xa,HA.guards(cloc,cG).A,HA.guards(cloc,cG).b); 
        x_his(kk+1,:) = xInt;
        % New ellipsoid
        if isempty(find((MMold-MM)>1e-10, 1)) 
            % then we consider the two ellipsoids to be the same
            M12 = MMold;
        else
            % M12 = inv(RR')*MMold*RInv;
            M12 = RR'\MMold*RInv; %#ok<MINV>
        end
        if noh==1
            % Compute orthonormal vector to switching surface
            ww = changeGuardCoord(HA.guards(cloc,cG).A,RInv)';
            vv = [sign(ww(1))*(abs(ww(1))+norm(ww,2)); ww(2:nos)];
            VV = eye(nos)-(2/(vv'*vv)).*(vv*vv');
        end
    end
    zz = RR*xx;
    % find distance from unsafe set
    cc = changeGuardCoord(HA.unsafe.A,RInv);
    dist = min(dist,DistFromGuards(zz,cc,HA.unsafe.b,Anew,bnew,opt_gd));
    % find distance from guards (take into account the vector fields)
    noag = length(actGuards);
    for jj = 1:noag 
        nloc = actGuards(jj);
        cc = changeGuardCoord(HA.guards(cloc,nloc).A,RInv);
        dist = min(dist,DistFromGuards(zz,cc,HA.guards(cloc,nloc).b,Anew,bnew,opt_gd));
    end
    % compute the distance from the crossed guard
    if ~isempty(cG)
        if noh==1
            cc = changeGuardCoord(HA.guards(cloc,cG).A,RInv);
            tempdist = DistFromGuards(zz,cc,HA.guards(cloc,cG).b,Anew,bnew,opt_gd);
            if tempdist<dist
                z2p = ProjOnPlane(zz,cc,HA.guards(cloc,cG).b);
                if ((zz'-z2p')*M12*(zz-z2p))<distPrevLoc^2 
                    zproj = VV\(z2p-RR*xInt);
                    zproj = zproj(2:end);
                    M12p = (VV'*M12*VV);
                    M12p = M12p(2:end,2:end);
                    % make sure the matrix is symmetric
                    M12p = (M12p+M12p')/2;
                    nosp = size(M12p,1); 
                    val = DistFromEll(zproj,zeros(nosp,1),M12p,distPrevLoc^2); 
                    if ~isreal(val)
                        if norm(val)<=RobTestPres
                            disp(['ComputeRobNeighborhoods: Complex value found in the distance computation'])
                            disp(['at location ',num2str(cloc),' at sample ',num2str(ii),'. You may want to increase the precision of CVX.'])
                            disp('Currently, the distance is set to 0.')
                            val = 0;
                        else
                            disp(['ComputeRobNeighborhoods: Complex value found in the distance computation'])
                            disp(['at location ',num2str(cloc),' at sample ',num2str(ii),'. You may want to increase the precision of CVX.'])
                            error('ComputeRobNeighborhoods: You must increase the precision of CVX')
                        end
                    end
                    dist = min(dist,sqrt(tempdist^2+val^2));
                else
                    dist = tempdist;
                end
            end
        else
            % Solve a semidefinite program
            cc = changeGuardCoord(HA.guards(cloc,cG).A,RInv);
            tempdist = DistFromGuards(zz,cc,HA.guards(cloc,cG).b,Anew,bnew,opt_gd);
            if tempdist<dist
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % NOTE: change in order to take into account the dynamics 
                val = DistFromHPandEll(zz,cc,HA.guards(cloc,cG).b,RR*xInt,M12,distPrevLoc^2);
                    if ~isreal(val)
                        if norm(val)<=RobTestPres
                            disp(['ComputeRobNeighborhoods: Complex value found in the distance computation'])
                            disp(['at location ',num2str(cloc),' at sample ',num2str(ii),'. You may want to increase the precision of CVX.'])
                            disp('Currently, the distance is set to 0.')
                            val = 0;
                        else
                            error('ComputeRobNeighborhoods: You must increase the precision of CVX')
                        end
                    end
                dist = min(dist,val); 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
    end
    % keep history
    distHis(ii) = dist;
end
d_his(1) = dist;
x_his(1,:) = hh(1,3:end);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Auxiliary functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change the coordinates of a guard
function cnew = changeGuardCoord(cA,RInv)
if isa(cA,'double')
    cnew = cA*RInv;
else
    nn = length(cA);
    cnew = cell(nn,1);
    for ii = 1:nn
        cnew{ii}= cA{ii}*RInv;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSUMPTION:
%   x0 is the point before the guard becomes active and 
%   x1 is the point after the guard becomes active
%
% OUTPUTS: 
%   - xi: the interpolated point on the hyperplane
%   - nn: the number of hyperplanes in the guard
%
% NOTE: verified function
function [xi,nn] = findPointOnGuard(x0,x1,cc,dd)
nn = size(cc,1);
aa = zeros(1,nn);
for ii=1:nn
    denom = cc(ii,:)*(x1-x0);
    if abs(denom)<10^-15
        % hyperplane parallel to line
        aa(ii) = inf;
    else
        aa(ii) = (cc(ii,:)*x1-dd(ii))/denom;
    end
end
% get the hyperplanes that intersect with the line x0x1 between x0 and x1
ii = aa<=0&aa>=1;
aa(ii) = []; % aa should never be empty!
ww = min(aa);
xi = ww*x0+(1-ww)*x1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the weights for the solution of the ricatti function
%
% INPUTS:
%   cloc - current location
%   HA - the hybrid automaton
% 
% OUTPUTS:
%   ww - the wight vector
function ww = getWeights(cloc,HA)
ll = HA.adjList{cloc};
ww = sum(abs(HA.guards(cloc,ll(1)).A),1);
for ii = 2:length(ll)
    ww = ww+sum(abs(HA.guards(cloc,ll(ii)).A),1);
end
% ww = ww/norm(ww);
