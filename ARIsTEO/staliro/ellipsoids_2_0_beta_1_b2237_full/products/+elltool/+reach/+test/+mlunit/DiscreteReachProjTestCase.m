% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef DiscreteReachProjTestCase < ...
        elltool.reach.test.mlunit.AReachProjTestCase
    methods
        function self = DiscreteReachProjTestCase(varargin)
            self = self@elltool.reach.test.mlunit.AReachProjTestCase(...
                elltool.linsys.LinSysDiscreteFactory(), ...
                elltool.reach.ReachDiscreteFactory(), ...
                varargin{:});
        end
    end
end