function [plusData,filterData] = calcPuls( pressure,dcpss )
%������������
%   pressure �����ԭʼѹ��
%   �������ã���getDefaultCalcPulsSetStruct�ɻ�ȡĬ�ϵ����ýṹ��
if nargin < 2 
	dcpss = getDefaultCalcPulsSetStruct();
end
%ȷ�����ݸ���
if (1 == size(pressure,2) || 1 == size(pressure,1))
	DATA_COUNT = 1;
end
if dcpss.dim
	DATA_COUNT = size(pressure,2);
else
	DATA_COUNT = size(pressure,1);
end
%�Ȱ�����ת�Ƶ�cell��
for ii = 1:DATA_COUNT
	if 1 == dcpss.dim
		filterData{ii} = pressure(ii,:);
	else
		filterData{ii} = pressure(:,ii);
	end
end
%�Ƿ����sigma�˲�
if ~isnan(dcpss.sigma)
	filterData = cellfun(@(xx) sigmaFilter(xx,dcpss.sigma),filterData,'UniformOutput',0);
end
%���и�ͨ�˲�
if dcpss.isHp
	if isnan(dcpss.fs)
		error('�����˸�ͨ�˲�����Ҫ���ò���Ƶ�ʣ�fs');
	end
	filterData = cellfun(@(xx) highp(xx,dcpss.f_pass,dcpss.f_stop,dcpss.rp,dcpss.rs,dcpss.fs) ...
		,filterData,'UniformOutput',0);
end
%������
filterData = cellfun(@(xx) arrayPresentSection(xx,dcpss.calcSection),filterData,'UniformOutput',0);
plusData = cellfun(@(xx) max(xx) - min(xx),filterData);

end




