function [ fre,mag ] = getSimulationData( matPath,structSection )
%��ȡģ�������
%  structSection  �ṹ����ֶΣ����û�����ã�Ĭ��ΪrawData
if nargin == 1
    structSection = 'rawData';
end
load(matPath);
dsData = getfield(dataStruct,structSection);
mag = dsData.Mag;
fre = dsData.Fre;
end

