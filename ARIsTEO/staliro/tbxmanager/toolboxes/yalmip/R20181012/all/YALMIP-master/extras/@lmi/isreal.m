% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function YESNO = isreal(F)
%ISREAL (overloaded)

F = flatten(F);
if isempty(F.clauses)
    YESNO = 1;
else
    YESNO = 1;
    i = 1;
    while (i<=length(F.clauses)) & YESNO
        Fi = F.clauses{i};
        YESNO =  YESNO & is(Fi.data,'real');
        i = i+1;
    end   
end

