function res  = getLengthOrDiameter( V,data,LOrD )
%���������ó���ֱ��
%   LOrD Ϊ1ʱ��������ǳ��ȡ�
%   LOrD Ϊ2ʱ�������ֱ��
L = nan;
D = nan;
if 1 == LOrD
	L = data;
else
	D = data;
end
if isnan(L)
	res = V./(pi.*D.^2./4);
else
	res = (4.*V./(L.*pi)).^0.5;
end
end

