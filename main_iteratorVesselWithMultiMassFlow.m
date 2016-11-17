function recorderCell = main_iteratorVesselWithMultiMassFlow
%������һ������ڲ�ͬת���µ����
rcv = 0.11;% �����϶�ݻ�
pressureRadio=1.5;%ѹ���ȣ�����ѹ��/����ѹ����
k=1.4;%����ָ��
DCylinder=250/1000;%�׾�m
dPipe=98/1000;%���ھ�m
crank=140/1000;%������
connectingRod=1.075;%���˳���
%50deg,0.15MPa(A),Density=1.617
outDensity = 1.617;%1.9167;%����25�Ⱦ���ѹ����0.2���¶ȶ�Ӧ�ܶ�
fs = 600;
acousticVelocity = 345;%����
L1 = 3;
L2 = 6;
l = 0.01;
Dpipe = 0.098;%�ܵ�ֱ����m��
Dv = 0.372;%����޵�ֱ����m��
Lv = 1.1;%������ܳ�
rpm = 250:500;
useCalcTopFreIndex = [1:20];%�����������Ƶ��������[1:20]����ǰ20������Ƶ�ʽ��м��㣬nanΪȫ������
accuracy = 1;%����ľ���Ĭ��Ϊ1������ÿ��1mȡһ����
isDamping = 1;%�Ƿ�������
isOpening = 0;%�Ƿ񿪿�
coeffFriction = 0.04;%�ܵ�Ħ��ϵ��
dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.3,0.7];
dcpss.fs = fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������
totalSecond = 5;
%%
totalPoints = fs*totalSecond+1;

index = 1;index_rpm = index;
recorderCell{1,index_rpm} = 'ת��';

index = index + 1;index_mass = index;
recorderCell{1,index_mass} = '��������';

index = index + 1;index_time = index;
recorderCell{1,index_time} = 'ʱ��';

index = index + 1;index_avg_mass = index;
recorderCell{1,index_avg_mass} = '��Ч��������';

index = index + 1;index_des = index;
recorderCell{1,index_des} = '����';
index = index + 1;index_x = index;
recorderCell{1,index_x} = 'xֵ';
index = index + 1;index_plus = index;
recorderCell{1,index_plus} = 'ѹ������';
index = index + 1;index_1fre = index;
recorderCell{1,index_1fre} = '1��Ƶ';
index = index + 1;index_2fre = index;
recorderCell{1,index_2fre} = '2��Ƶ';
index = index + 1;index_3fre = index;
recorderCell{1,index_3fre} = '3��Ƶ';
index = index + 1;index_beforemaxPlus = index;
recorderCell{1,index_beforemaxPlus} = '��ǰѹ���������ֵ';
index = index + 1;index_aftermaxPlus = index;
recorderCell{1,index_aftermaxPlus} = '�޺�ѹ���������ֵ';

recorderCell{1,index_des+8} = '����';
recorderCell{1,index_x+8} = 'xֵ';
recorderCell{1,index_plus+8} = 'ѹ������';
recorderCell{1,index_1fre+8} = '1��Ƶ';
recorderCell{1,index_2fre+8} = '2��Ƶ';
recorderCell{1,index_3fre+8} = '3��Ƶ';
recorderCell{1,index_beforemaxPlus+8} = '��ǰѹ���������ֵ';
recorderCell{1,index_aftermaxPlus+8} = '�޺�ѹ���������ֵ';
for i=1:length(rpm)
    recorderCell{i+1,index_rpm} = rpm(i);
    [massFlow,~,recorderCell{i+1,index_avg_mass}] = ...
        massFlowMaker(DCylinder,dPipe,rpm(i)...
        ,crank,connectingRod,outDensity,'rcv',rcv,'k',k,'pr',pressureRadio,'fs',fs);
    while length(massFlow)<totalPoints %����ָ�����ȵ�����
        massFlow = [massFlow,massFlow];
    end
    massFlow = massFlow(1:totalPoints);
    time = linspace(0,totalSecond,totalPoints);%0:1/fs:totalSecond;
    recorderCell{i+1,index_mass} = massFlow;
    recorderCell{i+1,index_time} = time;
    
    calcDatas = funIteratorVesselPipeLinePlusCalc(time,massFlow...
        ,fs,rpm(i)/60*2,acousticVelocity,L1,L2,l,Dpipe,Dv,Lv,'Dv'...
        ,'multfre',[rpm(i)/60*2,rpm(i)/60*2*2,rpm(i)/60*2*3]...%����ı�Ƶ
        ,'isOpening',isOpening...
        ,'useCalcTopFreIndex',useCalcTopFreIndex...
        ,'isDamping',isDamping...
        ,'coeffFriction',coeffFriction...
        ,'accuracy',accuracy...
        ,'dcpss',dcpss...
    );
    recorderCell{i+1,index_des} = calcDatas{3,1};
    recorderCell{i+1,index_x} = calcDatas{3,2};
    recorderCell{i+1,index_plus} = calcDatas{3,3};
    recorderCell{i+1,index_1fre} = calcDatas{3,4};
    recorderCell{i+1,index_2fre} = calcDatas{3,5};
    recorderCell{i+1,index_3fre} = calcDatas{3,6};
    recorderCell{i+1,index_beforemaxPlus} = calcDatas{3,7};
    recorderCell{i+1,index_aftermaxPlus} = calcDatas{3,8};
    
    recorderCell{i+1,index_des+8} = calcDatas{2,1};
    recorderCell{i+1,index_x+8} = calcDatas{2,2};
    recorderCell{i+1,index_plus+8} = calcDatas{2,3};
    recorderCell{i+1,index_1fre+8} = calcDatas{2,4};
    recorderCell{i+1,index_2fre+8} = calcDatas{2,5};
    recorderCell{i+1,index_3fre+8} = calcDatas{2,6};
    recorderCell{i+1,index_beforemaxPlus+8} = calcDatas{2,7};
    recorderCell{i+1,index_aftermaxPlus+8} = calcDatas{2,8};
    
end

currentPath = fileparts(mfilename('fullpath'));
savePath = fullfile(currentPath,'iteratorVesselWithMultiMassFlowRes.mat');
save(savePath,'recorderCell');
%system('shutdown -s');
end