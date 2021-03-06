% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef MDataGrid<modgen.gui.ADataGridBase
    properties (Access=protected)
        panelHandle
        isRowHeaderShown
        tableHandle
    end
    properties (Constant,GetAccess=private)
        COL_WIDTH=100
    end    
    methods
        function self=MDataGrid(varargin)
            [reg,~,panelHandle,isRowHeaderShown]=...
                modgen.common.parseparext(varargin,...
                {'panelHandle','showRowHeader';...
                [],false;...
                @(x)ishandle(x)&&strcmp(get(x,'Type'),'uipanel'),...
                @(x)islogical(x)&&isscalar(x)},...
                'isObligatoryPropVec',[true,false]);
            self=self@modgen.gui.ADataGridBase(reg{:});
            self.panelHandle=panelHandle;
            self.isRowHeaderShown=isRowHeaderShown;
        end
        function putData(self,colNameList,dataCMat,varargin)
            
%             parentHandle=modgen.gui.getparentfigure(self.panelHandle);
%             positionVec=modgen.gui.getInUnits(self.panelHandle,...
%                 'position','Normalized');        
            parentHandle=self.panelHandle;
            positionVec=[0 0 1 1];
            nCols=length(colNameList);
            colFormatList = repmat({'char'},1,nCols);
            isColumnEditableVec=false(1,nCols);
            colWidthList=repmat({self.COL_WIDTH},1,nCols);
            self.tableHandle = uitable('Units','normalized','Position',...
            positionVec, 'Data', dataCMat,... 
            'ColumnName', colNameList,...
            'ColumnFormat', colFormatList,...
            'ColumnEditable', isColumnEditableVec,...
            'Parent',parentHandle,...
            'ColumnWidth',colWidthList);
        end
    end
end
