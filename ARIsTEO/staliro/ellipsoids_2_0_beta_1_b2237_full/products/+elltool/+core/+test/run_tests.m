% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
suite = mlunitext.test_suite.fromTestCaseNameList({...
    'elltool.core.test.mlunit.EllipsoidIntUnionTC',...
    'elltool.core.test.mlunit.EllipsoidTestCase',...
    'elltool.core.test.mlunit.EllipsoidSecTestCase',...
    'elltool.core.test.mlunit.HyperplaneTestCase',...
    'elltool.core.test.mlunit.GenEllipsoidPlotTestCase',...
    'elltool.core.test.mlunit.GenEllipsoidTestCase',...
    'elltool.core.test.mlunit.ElliIntUnionTCMultiDim',...
    'elltool.core.test.mlunit.EllTCMultiDim',...
    'elltool.core.test.mlunit.EllSecTCMultiDim',...
    'elltool.core.test.mlunit.MPTIntegrationTestCase',...
	'elltool.core.test.mlunit.EllipsoidPlotTestCase',...
	'elltool.core.test.mlunit.EllAuxTestCase',...
    'elltool.core.test.mlunit.HyperplanePlotTestCase',...
    'elltool.core.test.mlunit.EllipsoidMinkPlotTestCase',...
    'elltool.core.test.mlunit.EllipsoidBasicSecondTC',...
    'elltool.core.test.mlunit.EllipsoidDispStructTC',...
    'elltool.core.test.mlunit.HyperplaneDispStructTC'}, varargin);
%
result=runner.run(suite);
