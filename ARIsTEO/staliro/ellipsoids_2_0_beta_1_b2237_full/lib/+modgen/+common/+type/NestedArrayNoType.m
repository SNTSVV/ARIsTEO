% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef NestedArrayNoType<modgen.common.type.ANestedArrayUnknownType
    methods
        function isPositive=isIncludedInto(~,~)
            isPositive=true;
        end
    end
    methods
        function isPositive=isEmptyTypeSet(~)
            isPositive=true;
        end        
        function isPositive=isContainedInCellType(~)
            isPositive=true;
        end
        function isPositive=isCellTypeContained(~)
            isPositive=false;
        end
        function typeSeqString=toTypeSequenceString(~)
            typeSeqString='no';
        end
    end
end
