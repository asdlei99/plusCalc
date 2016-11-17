function splitData = splitNoneZero( data )
%�ֽ��0���ݵ�һ���������Լ�ȫ����0��������
%[1,0,2,0,1] =>
%
%[1,0,0,0,0]
%[0,0,2,0,0]
%[0,0,0,0,1]

index = find(data~=0);
n = length(data);
for i=1:length(index)
    splitData(:,i) = zeros(n,1);
    splitData(index(i),i) = data(index(i));
end

end

