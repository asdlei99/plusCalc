%% �������ݾ�������ü�������
%������ݹ��ݵ�����
%   massFlowE1 ����fft�������������ֱ�Ӷ�������������ȥֱ��fft
%  ���� L1     l    Lv1   l    L2  
%              __________        
%             |          |      
%  -----------|          |----------
%             |__________|       
% ֱ�� Dpipe       Dv1       Dpipe       
%   
%   opt.frequency Ƶ�� Hz
%   opt.acousticVelocity ���� 366m/s
massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));
time = massFlow(:,1);
massFlow = massFlow(:,2);
massFlowE1 = fft(detrend(massFlow));
isDamping = 1;%�Ƿ��������
coeffFriction = 0.02;%�ܵ�Ħ��ϵ��
meanFlowVelocity = 14.6;%�ܵ�ƽ������
totalLength = 26;
L1 = 1;
Lv = 1;%����޳���
l = 0.115;%����޷�ͷ����
Dpipe = 0.157;%�ܵ�ֱ����m��
Dv = 0.5;%����޵�ֱ����m��
opt.frequency = 10;
opt.acousticVelocity = 366;
opt.isDamping = isDamping;
opt.coeffFriction = coeffFriction;
opt.meanFlowVelocity = meanFlowVelocity;
opt.isUseStaightPipe = 0;
L2 = totalLength-L1;
sectionL1 = 0:L1;
sectionL2 = 0:L2;
% ʹ�û���޴��ݾ�����������ʽ����Ĵ��ݾ���
textLegend{1} = '����޴��ݾ�����������ʽ';
[plusL1{1},plusL2{1}] = fun_oneTank(massFlowE1,L1,L2,Lv,l,Dpipe,Dv,opt,sectionL1,sectionL2);

textLegend{2} = 'ֱ���������޴��ݾ�����������ʽ';
opt.isUseStaightPipe = 1;
[plusL1{2},plusL2{2}] = fun_oneTank(massFlowE1,L1,L2,Lv,l,Dpipe,Dv,opt,sectionL1,sectionL2);

textLegend{3} = '����޴��ݾ�����������ʽ';
opt.isDamping = 0;
opt.isUseStaightPipe = 0;
[plusL1{3},plusL2{3}] = fun_oneTank(massFlowE1,L1,L2,Lv,l,Dpipe,Dv,opt,sectionL1,sectionL2);

textLegend{4} = 'ֱ���������޴��ݾ�����������ʽ';
opt.isDamping = 0;
opt.isUseStaightPipe = 1;
[plusL1{4},plusL2{4}] = fun_oneTank(massFlowE1,L1,L2,Lv,l,Dpipe,Dv,opt,sectionL1,sectionL2);

figure
h = [];
hold on;
X = 1:(length(plusL1{1}) + length(plusL2{1}));
h(1) = plot(X,[plusL1{1},plusL2{1}],'color',[64,98,237]./255,'LineWidth',2);
h(2) = plot(X,[plusL1{2},plusL2{2}],'color',[108,194,78]./255,'LineWidth',2);
h(3) = plot(X,[plusL1{3},plusL2{3}],'color',[147,52,234]./255);
h(4) = plot(X,[plusL1{4},plusL2{4}],'color',[49,201,113]./255);
grid on;
ylabel('maximum pulsating pressure(kPa)');
xlabel('mea point');
legend(h,textLegend);
title('example vessel transfer matrix');
set(gcf,'color','w');