function oneCell = toOneCell( headerData,varargin )
%�Ѷ������ϲ�Ϊһ��cell�����ڱ���Ϊxls
%   headerData ��ͷ�������Ҫ������Ϊ{}
%   varargin ���ݾ���
oneCell = {};
while length(varargin)>0
    dataMat = varargin{1};
    varargin = varargin(2:end);
    numCell = num2cell(dataMat);
    oneCell = cellPush2Right(oneCell,numCell);
end
if length(headerData)>0
    if size(headerData,1)>1
        headerData = headerData';
    end
	oneCell = cellPush2Bottom(headerData,oneCell);
end

end

