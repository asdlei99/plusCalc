clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%% ѹ������������
DCylinder=250/1000;%�׾�m
dPipe=98/1000;%���ھ�m
crank=140/1000;%������
connectingRod=1.075;%���˳���
k=1.4;%����ָ��
%% �������
fs = 1/0.0035;
totalSecond = 5;
totalPoints = fs*totalSecond+1;
time = linspace(0,totalSecond,totalPoints);%0:1/fs:totalSecond;
periodIndex = time < (1/5);
periodIndex = find(periodIndex ==1);
%% ����Ϊ��������Ϊ�������
massFlowSin = 0.5.*abs(sin(10*pi*time));
[freSin,magSin] = frequencySpectrum(massFlowSin,fs);
figure
subplot(2,1,1)
plot(time(periodIndex),massFlowSin(periodIndex));
subplot(2,1,2)
plotSpectrum(freSin,magSin);
xlim([0,50]);
set(gcf,'color','w');
%% �ɱ����


%% �ı�ת�ٶ���Ӱ��
rcv = 0.4;% �����϶�ݻ�
pressureRadio=1.5;%ѹ���ȣ�����ѹ��/����ѹ����
outDensity =1.293*pressureRadio;% 1.9167;%%����25�Ⱦ���ѹ����0.2���¶ȶ�Ӧ�ܶ�
rpm = 200:10:500;
for i=1:length(rpm)
    [massFlowRPM{i},~,meanMassFlowRPM{i}] = massFlowMaker(DCylinder,dPipe,rpm(i)...
        ,crank,connectingRod,outDensity,'rcv',rcv,'k',k,'pr',pressureRadio,'fs',fs);
    while length(massFlowRPM{i})<totalPoints %����1s������
        massFlowRPM{i} = [massFlowRPM{i},massFlowRPM{i}];
    end
    massFlowRPM{i} = massFlowRPM{i}(1:totalPoints);
end

figure
hold on;
for i=1:length(rpm)
    periodIndex = time < (1 / (rpm(i) / 60));
    periodIndex = find(periodIndex ==1);
    x = ones(1,length(periodIndex)).*rpm(i);
    y = time(periodIndex);
    z = massFlowRPM{i}(periodIndex);
   	plot3(x,y,z);
    xlabel('rpm');
    ylabel('time(s)');
    zlabel('mass flow(kg/s)');
end
grid on;
view(-68,56);
set(gcf,'color','w');

figure
hold on;
for i=1:length(rpm)
    bseFre = rpm(i)/60*2;
    [fre,amp] = frequencySpectrum(massFlowRPM{i},fs);
    ans = calcWaveFreAmplitude(massFlowRPM{i},fs,[bseFre,bseFre*2]);
    ampValue(:,i) = ans';
    index = fre < 50;
    index = find(index == 1);
    x = ones(1,length(index)).*rpm(i);
    y = fre(index);
    z = amp(index);
    
   	plot3(x,y,z);
    xlabel('rpm');
    ylabel('frequency(Hz)');
    zlabel('mass flow(kg/s)');
end
view(-117,44);
set(gcf,'color','w');

figure
hold on;
plot(rpm,ampValue(1,:),'r');
plot(rpm,ampValue(2,:),'b');
title(sprintf('ת�ٺͱ�Ƶ���ϵ-��϶:%g,ѹ�ȣ�%g',rcv,pressureRadio));
set(gcf,'color','w');


