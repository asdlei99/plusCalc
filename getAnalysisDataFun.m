function [ data ] = getAnalysisDataFun( type )
%��ȡ����������
    currentPath = fileparts(mfilename('fullpath'));
    switch(lower(type))
        case 'dvthrfre'%˫��ƴ��0m����
            [data.fre,data.mag]=getThrFreData();
        case 'dvsimfre'%˫��ƴ��0mģ��    
            [data.fre,data.mag]=getSimulationData(fullfile(currentPath,'originData\26��˫�ݼ��0�׶���.mat'));
        case 'dvexpfre'%˫��ƴ��0mʵ��
            [data.fre,data.mag]=getExpFreData();
        case 'strfre'%ֱ��ģ��
            [data.fre,data.mag]=getSimulationData(fullfile(currentPath,'originData\ֱ�ܶ�Ӧ26��˫�ݼ��0.9��.mat'));
        case 'ovsimfre'%����ģ��
            [data.fre,data.mag]=getSimulationData(fullfile(currentPath,'originData\26�׵���V=V1+V2.mat'));
    end
end

function [fre,mag] = getThrFreData()
    currentPath = fileparts(mfilename('fullpath'));
    load(fullfile(currentPath,'originData\����-0m���-fС��80.mat'));
    [fre,mag] = fft_byColumn(pppp,3600);
    mag = mag./1000;
end

function [fre,mag] = getExpFreData()
    currentPath = fileparts(mfilename('fullpath'));
    load(fullfile(currentPath,'originData\˫���޼�࿪��4.mat'));
    fre = dataStruct.subSpectrumData.Fre;
    mag = dataStruct.subSpectrumData.Mag;
end
