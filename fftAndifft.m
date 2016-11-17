massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));
time = massFlow(1:4096,1);
Fs = 1/(time(2)-time(1));
massFlowRaw = massFlow(1:4096,2);
[Fre,Mag,Ph,massFlowE] = fun_fft(detrend(massFlowRaw),Fs);
trData = changToWave(massFlowE,Fre,time);
figure
subplot(2,2,1)
plot(time,detrend(massFlowRaw));
title('��������');
subplot(2,2,2)
plot(Fre,Mag);
title('��������Ƶ��');
subplot(2,2,[3,4])
hold on;
plot(time,detrend(massFlowRaw),'-b');
plot(time,detrend(abs(trData)),'-r');
title('�Ա�');

set(gcf,'color','w');
