% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function p = update_eval_bounds(p);

if ~isempty(p.evalVariables)
    for i = 1:length(p.evalMap)
        p = update_one_eval_bound(p,i);
        p = update_one_inverseeval_bound(p,i);
    end
end