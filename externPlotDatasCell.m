function res = externPlotDatasCell(datasCell,varargin)
% []     ,'x','title1','title2','title3'
% 'data1',[x],[y]     ,[y]     ,[y]
% 'data2',[x],[y]     ,[y]     ,[y]
% 'data3',[x],[y]     ,[y]     ,[y]
%
% 'data1','data1' ,'data1' ,'data1' ,[],'data2','data2' ,'data2' ,'data2' ...
% 'x'    ,'title1','title2','title3',[],'x'    ,'title1','title2','title3',[]
%  1     , xx     ,  xx    , xx     ,[], 1     , xx     ,  xx    , xx     ,
%  2     , xx     ,  xx    , xx     ,[], 1     , xx     ,  xx    , xx     ,
%  3     , xx     ,  xx    , xx     ,[], 1     , xx     ,  xx    , xx     ,
%  4     , xx     ,  xx    , xx     ,[], 1     , xx     ,  xx    , xx     ,
%  ......
%  ����,'x','title1','title2','title3'��paramLegend,�����Զ���cell,���߶���paramLegendIndex
%  ������'data1','data1' ,'data1' ,'data1'��dataLegend,�����Զ���cell
%  dataRowsIndex Ϊ���ݶ�Ӧ������������������Ϊ�ֲ���Ĭ�ϳ��˵�һ����ĵڶ��е����һ��ΪdataRowsIndex
%                �������������������һ�п������¶���dataRowsIndex
%  paramIndex Ϊÿ������ϵ�ж�Ӧ�ı����������������зֲ���Ĭ�ϳ��˵�һ����ĵڶ��е����һ��ΪparamIndex
%                �������������������ĳһ�б������������¶���paramIndex
%  paramLegend Ϊparam��Ӧ��������Ĭ�ϵ�һ�дӵڶ��е����һ��ΪparamLegend
%  dataLegend Ϊdata��Ӧ��������Ĭ�ϵ�һ�дӵڶ��е����һ��ΪdataLegend
%

dataRowsIndexs = [2:size(datasCell,1)];
dataColumnIndex = [2:size(datasCell,2)];


dataParamLegend = {};
dataNameLegend = {};
while length(varargin)>=2
    prop =varargin{1};
    val=varargin{2};
    varargin=varargin(3:end);
    switch lower(prop)
    	case 'datarowsindexs'
    		dataRowsIndexs = val;
    	case 'datacolumnindex'
    		dataColumnIndex = val;
        case 'dataparamlegend' %�Ƿ�����0
            dataParamLegend = val;
        case 'datanamelegend'
            dataNameLegend = val;
    end
end
if isempty(dataNameLegend)
    dataNameLegend = cell(length(dataRowsIndexs),1);
end
if isempty(dataParamLegend)
    dataParamLegend = cell(1,length(dataColumnIndex));
end
res = {};
externCells = {};
count = 1;
for i = dataRowsIndexs
    rowCell = datasCell(i,dataColumnIndex);
    externCells = exOneDataCells(rowCell,dataParamLegend,dataNameLegend{count});
    if count == 1
        res = cellPush2Right(res,externCells);
    else
        res = cellPush2Right(res,{''},externCells);
    end
    count = count + 1;
end
end


function exCell = exOneDataCells(rowDataCell,paramLegend,dataName)
colCount = size(rowDataCell,2);

exCell(2,:) = paramLegend;

for i=1:colCount
    exCell{1,i} = dataName;
	rowIndex = 3;
	data = rowDataCell{i};
	if ~(size(data,1) > 1)
		data = data';
    end
    
	exCell(rowIndex:(length(data)+rowIndex-1),i) = mat2cell(data,ones(length(data),1),[1]);
end

end