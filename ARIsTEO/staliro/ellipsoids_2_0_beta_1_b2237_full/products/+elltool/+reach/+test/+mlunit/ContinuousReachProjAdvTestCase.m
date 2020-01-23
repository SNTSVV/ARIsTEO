% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef ContinuousReachProjAdvTestCase < ...
        elltool.reach.test.mlunit.AReachProjAdvTestCase
    methods
        function self = ContinuousReachProjAdvTestCase(varargin)
            self = self@elltool.reach.test.mlunit.AReachProjAdvTestCase(...
                elltool.linsys.LinSysContinuousFactory(), ...
                elltool.reach.ReachContinuousFactory(), ...
                varargin{:});
        end
    end
end