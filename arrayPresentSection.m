function d = arrayPresentSection( data,sec )
%��ȡһ��array�İٷֱȵ�����
%   sec��һ������Ϊ2�����ݣ�0����ǰ�δӵ�һ���㿪ʼ�㣬1�����㵽���һ���㣬�����һ��Ϊ0.1��������10%��ʼ����
lowIndex = floor(sec(1)*length(data))+1;
upIndex = floor(sec(2)*length(data));
d = data(lowIndex:upIndex);
end

