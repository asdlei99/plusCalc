function [massFlow,time,meanMassFlow,meanFlowVelocity] = massFlowMaker(DCylinder,dPipe,rpm...
	,crank,connectingRod,densityOutlet,varargin)
%������������
%   alpha �����϶�ݻ�
%   pressureRadio ѹ���ȣ�����ѹ��/����ѹ����
alpha=0.25;%�����϶�ݻ�
pressureRadio=2;%ѹ���ȣ�����ѹ��/����ѹ����
k=1.4;%����ָ��
% DCylinder=250/1000;%�׾�m
% dPipe=98/1000;%���ھ�m
% rpm=300;%ת��r/min
% crank=140/1000;%������
% connectingRod=1075;%���˳���
fs = 200;
oneSecond = 0;
while length(varargin)>=2
    prop =varargin{1};
    val=varargin{2};
    varargin=varargin(3:end);
    switch lower(prop)
        case 'relativeclearancevolume' %
            alpha = val;
        case 'rcv' %
            alpha = val;
        case 'pressureradio'
            pressureRadio = val;
        case 'pr'
            pressureRadio = val;
        case 'k'
            k = val;
        case 'fs'
        	fs = val;
        case 'onesecond'
            oneSecond = val;
        otherwise
        	error('��������:%s',prop);
    end
end
rps = rpm / 60;
spr = 1 / rps;%һת��Ҫ����
secNumPerRound = spr*fs;
sectionRang=linspace(0,360,secNumPerRound);
beita=asind(1-2.*(1+alpha).*(pressureRadio.^(-(1/k)))+2.*alpha);%�ǶȲ��ǻ���
alphac=270+beita;%�ǲ���������Ŀ�����
alphacx=90+beita;%�����������Ŀ�����
%˫�������������ٶ����ߣ��ǲ��������
ACylinder=(pi.*(DCylinder.^2))/4;%����ͨ�����
APipe=(pi.*(dPipe.^2))/4;%�ܵ�ͨ�����
b=ACylinder/APipe;
lameda=crank/connectingRod;%������/���˳�
oumiga=(pi.*rpm)/30;%�����Ľ��ٶ�rad/s

%��������
massFlow=zeros(size(sectionRang));
for i=1:length(sectionRang)%�ǲ൥����
    alpha=sectionRang(i);
    if (alpha<alphacx&&alpha>=0)
        v11=0;
    elseif (alpha<=180&&alpha>=alphacx)
        v11=b.*crank.*oumiga.*abs((sind(alpha)+(lameda/2).*sind(2.*alpha)));
    elseif (alpha<=alphac&&alpha>180)
        v11=0;
    elseif (alpha<=360&&alpha>=alphac)  
        v11=b.*crank.*oumiga.*abs((sind(alpha)+(lameda/2).*sind(2.*alpha)));
    end
    massFlow(i)=v11;
end

massFlow = massFlow.*densityOutlet.*APipe;
time = 0:1/fs:((length(massFlow)-1)/fs);
meanMassFlow = trapz(time,massFlow);
meanMassFlow = meanMassFlow/time(end);
meanFlowVelocity = (meanMassFlow/densityOutlet/APipe);
if oneSecond
    while length(massFlow) < fs+1
        massFlow = [massFlow,massFlow];
    end
    massFlow = massFlow(1:fs+1);
    time = 0:1/fs:1;
end

% for i=1:length(sectionRang)%�ǲ൥����
%     alpha=sectionRang(i);
%     if (alpha<=alphacx && alpha>=0)
%         v11=0;
%     elseif (alpha<=180 && alpha>alphacx)
%         v11=densityOutlet .* ACylinder .* crank .* oumiga .* abs((sind(alpha)+(lameda/2).*sind(2.*alpha)));
%     elseif (alpha<=alphac && alpha>180)
%         v11=0;
%     elseif (alpha<=360&&alpha>alphac)  
%         v11=densityOutlet .* ACylinder .* crank .* oumiga.*abs((sind(alpha)+(lameda/2).*sind(2.*alpha)));
%     end
%     massFlow(i)=v11;
% end

end