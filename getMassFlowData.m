function [ time,massFlow,Fre,massFlowE ] = getMassFlowData(varargin )
%��ȡ��������
%   ���������ȡ��������������

pp=varargin;
N = 4096;
isFindPeaks = 1;
isSin = 0;
sinAmp = nan;
Fs = nan;
sinFre = nan;
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'n' %��������
            N = val;
        case 'isfindpeaks'
            isFindPeaks = val;
        case 'sin'
            sinAmp = val;%����һ����һsin����
        case'sinfre'
            sinFre = val;
        case 'fs'
            Fs = val;
    end
end
if isSin
    time = 0:1/Fs:((1/Fs)*(N-1))
    massFlow = sinAmp.*sin(2*pi*sinFre*time)
else
    currentPath = fileparts(mfilename('fullpath'));
    massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));
    N = 4096;
    time = massFlow(1:N,1);
    massFlowRaw = massFlow(1:N,2);
    Fs = 1/(time(2)-time(1));
    [FreRaw,AmpRaw,~,massFlowE] = fun_fft(detrend(massFlowRaw),Fs);
    % ��ȡ��ҪƵ��
    if isFindPeaks
        [~,locs] = findpeaks(AmpRaw);
        Fre = FreRaw(locs);
        massFlowE = massFlowE(locs);
    end
    temp = Fre<80;%Fre<20 | (Fre>22&Fre<80);
    Fre = Fre(temp);
    massFlowE = massFlowE(temp);
end
end

