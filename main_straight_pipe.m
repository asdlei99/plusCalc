%%
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%% ��ʼ����
%
dynViscosity = 0.02 * 10^-3;%����ճ�� 60��
rpm = 420;outDensity = 1.5608;multFre=[14,28,42];%����25�Ⱦ���ѹ����0.15MPaG���¶ȶ�Ӧ�ܶ�
Fs = 4096;
[massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,rpm...
	,0.14,1.075,outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',Fs,'oneSecond',6);
[FreRaw,AmpRaw,PhRaw,massFlowERaw] = frequencySpectrum(detrend(massFlowRaw,'constant'),Fs);
FreRaw = [7,14,21,28,14*3];
massFlowERaw = [0.02,0.2,0.03,0.05,0.007];
% ��ȡ��ҪƵ��
massFlowE = massFlowERaw;
Fre = FreRaw;

acousticVelocity = 345;%���٣�m/s��
isDamping = 1;
coeffFriction = 0.02;
meanFlowVelocity = 25.5;
L=10.62;%L3(m)
Dpipe = 0.098;%�ܵ�ֱ����m��
isOpening = 0;
dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.25,0.75];
dcpss.sigma = 2.8;
dcpss.fs = Fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������

mach = meanFlowVelocity / acousticVelocity;
calcWay2 = 0;

dataCount = 2;
calcDatas{1,2} = 'xֵ';
calcDatas{1,3} = 'ѹ������';
calcDatas{1,4} = '1��Ƶ';
calcDatas{1,5} = '2��Ƶ';
calcDatas{1,6} = '3��Ƶ';
%% ��������ѹ��
notmach = 1;
isDamping = 0;
sectionL = [[2.5,3.5],[4.29,5.08],[5.87,6.37,6.87,7.37,7.87,8.37,8.87,9.37,9.87,10.37]];

pressure = straightPipePulsationCalc(massFlowE,Fre,time,L,sectionL...
	,'d',Dpipe,'a'...
    ,acousticVelocity,'isDamping',isDamping,'friction',coeffFriction,'meanFlowVelocity',meanFlowVelocity ...
    ,'notmach',notmach,'m',mach,'isOpening',isOpening...
    );
[plus,filterData] = calcPuls(pressure,dcpss);
multFreAmpValue_straightPipe = calcWaveFreAmplitude(pressure,Fs,multFre,'freErr',1);
calcDatas{dataCount,1} = sprintf('ֱ��-������-�������');
calcDatas{dataCount,2} = sectionL;
calcDatas{dataCount,3} = plus;
calcDatas{dataCount,4} = multFreAmpValue_straightPipe(1,:);
calcDatas{dataCount,5} = multFreAmpValue_straightPipe(2,:);
calcDatas{dataCount,6} = multFreAmpValue_straightPipe(3,:);
dataCount = dataCount + 1;

%%
notmach = 1;
isDamping = 1;
pressure = straightPipePulsationCalc(massFlowE,Fre,time,L,sectionL...
	,'d',Dpipe,'a'...
    ,acousticVelocity,'isDamping',isDamping,'friction',coeffFriction,'meanFlowVelocity',meanFlowVelocity ...
    ,'notmach',notmach,'m',mach,'isOpening',isOpening...
    ,'calcWay2',calcWay2,'density',outDensity,'dynViscosity',dynViscosity...
    );
[plus,filterData] = calcPuls(pressure,dcpss);
multFreAmpValue_straightPipe = calcWaveFreAmplitude(pressure,Fs,multFre,'freErr',1);
calcDatas{dataCount,1} = sprintf('ֱ��-������-�������');
calcDatas{dataCount,2} = sectionL;
calcDatas{dataCount,3} = plus;
calcDatas{dataCount,4} = multFreAmpValue_straightPipe(1,:);
calcDatas{dataCount,5} = multFreAmpValue_straightPipe(2,:);
calcDatas{dataCount,6} = multFreAmpValue_straightPipe(3,:);
dataCount = dataCount + 1;
%%
notmach = 0;
isDamping = 1;
pressure = straightPipePulsationCalc(massFlowE,Fre,time,L,sectionL...
	,'d',Dpipe,'a'...
    ,acousticVelocity,'isDamping',isDamping,'friction',coeffFriction,'meanFlowVelocity',meanFlowVelocity ...
    ,'notmach',notmach,'m',mach,'isOpening',isOpening...
    ,'calcWay2',calcWay2,'density',outDensity,'dynViscosity',dynViscosity...
    );
[plus,filterData] = calcPuls(pressure,dcpss);
multFreAmpValue_straightPipe = calcWaveFreAmplitude(pressure,Fs,multFre,'freErr',1);
calcDatas{dataCount,1} = sprintf('ֱ��-������-�������');
calcDatas{dataCount,2} = sectionL;
calcDatas{dataCount,3} = plus;
calcDatas{dataCount,4} = multFreAmpValue_straightPipe(1,:);
calcDatas{dataCount,5} = multFreAmpValue_straightPipe(2,:);
calcDatas{dataCount,6} = multFreAmpValue_straightPipe(3,:);
dataCount = dataCount + 1;
%%
massFlowE(4) = 0.1;
notmach = 0;
isDamping = 1;
pressure = straightPipePulsationCalc(massFlowE,Fre,time,L,sectionL...
	,'d',Dpipe,'a'...
    ,acousticVelocity,'isDamping',isDamping,'friction',coeffFriction,'meanFlowVelocity',meanFlowVelocity ...
    ,'notmach',notmach,'m',mach,'isOpening',isOpening...
    ,'calcWay2',calcWay2,'density',outDensity,'dynViscosity',dynViscosity...
    );
[plus,filterData] = calcPuls(pressure,dcpss);
multFreAmpValue_straightPipe = calcWaveFreAmplitude(pressure,Fs,multFre,'freErr',1);
calcDatas{dataCount,1} = sprintf('ֱ��-������-�������-����Ƶ���һ��');
calcDatas{dataCount,2} = sectionL;
calcDatas{dataCount,3} = plus;
calcDatas{dataCount,4} = multFreAmpValue_straightPipe(1,:);
calcDatas{dataCount,5} = multFreAmpValue_straightPipe(2,:);
calcDatas{dataCount,6} = multFreAmpValue_straightPipe(3,:);
dataCount = dataCount + 1;
%%

ignoreHeader = 1;
%����ѹ������
figure 
plotDataCells(calcDatas,'xcol',2,'ycol',3,'legendcol',1,'ignoreHeader',ignoreHeader);
title('����ѹ�����ֵ');
%����1��Ƶ
figure
plotDataCells(calcDatas,'xcol',2,'ycol',4,'legendcol',1,'ignoreHeader',ignoreHeader);
title('ѹ��1��Ƶ');
%����2��Ƶ
figure
plotDataCells(calcDatas,'xcol',2,'ycol',5,'legendcol',1,'ignoreHeader',ignoreHeader);
title('ѹ��2��Ƶ');
%����3��Ƶ
% figure
% plotDataCells(calcDatas,'xcol',2,'ycol',6,'legendcol',1,'ignoreHeader',ignoreHeader);
% title('ѹ��3��Ƶ');

