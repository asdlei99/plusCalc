%% ��֤����-
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%���װ建��޵�������������
%   Detailed explanation goes here
%           |  L2
%        l  | 
%  bias2 ___|_______________
%       |         |        |
%   Dv2 |     V2   d    V1 |  Dv1
%       |_________|________|
%                    l  |   bias1  
%                       |
%              inlet:   | L1 Dpipe 

massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));
N = 4096;
time = massFlow(1:N,1);
massFlowRaw = massFlow(1:N,2);
Fs = 1/(time(2)-time(1));
[FreRaw,AmpRaw,PhRaw,massFlowE] = fun_fft(detrend(massFlowRaw),Fs);
% ��ȡ��ҪƵ��
[pks,locs] = findpeaks(AmpRaw);
Fre = FreRaw(locs);
massFlowE = massFlowE(locs);
temp = Fre < 100;%(Fre<29) | (Fre>30 & Fre < 100);
Fre = Fre(temp);
massFlowE = massFlowE(temp);
isDamping = 1;
%��ͼ����
isXLength = 1;
isShowStraightPipe=1;%�Ƿ���ʾֱ��
isShowOnlyVessel=1;%�Ƿ���ʾ���ڼ������

opt.acousticVelocity = 345;%����
opt.isDamping = 1;%�Ƿ��������
opt.coeffFriction = 0.05;%�ܵ�Ħ��ϵ��
opt.meanFlowVelocity = 14.6;%�ܵ�ƽ������
opt.isUseStaightPipe = 1;%�����������ݾ���ķ���
density = 2.09;%�����ܶ�
dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.4,0.5];
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������
isUseStaightPipe = 1;

for i=1
    para(i).opt = opt;
    para(i).L1 = 2.94;
    para(i).L2 = 10;
    para(i).Dpipe = 0.106;
    para(i).Dv1 = 0.45;
    para(i).Dv2 = 0.45;
    para(i).l = 0.115;
    para(i).Lv1 = 0.4755;
    para(i).Lv2 = 0.4755;
    para(i).bias1 = 0.3;
    para(i).bias2 = 0.3;
    para(i).sectionL1 = 0:1:para(i).L1;
    para(i).sectionL2 = 0:1:para(i).L2;
end
for i = 1:length(para)
    [pressure1OV,pressure2OV] = oneVesselBiasPulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).Lv1+para(i).Lv2,para(i).l,para(i).Dpipe,para(i).Dv1,para(i).bias1,para(i).bias2,...
            para(i).sectionL1,para(i).sectionL2,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
            'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',isUseStaightPipe);
    plus1OV = calcPuls(pressure1OV,dcpss);
    plus2OV = calcPuls(pressure2OV,dcpss);
    plusOV = [plus1OV,plus2OV];
    [pressure1,pressure2]  = vesselBiasHaveOrificePulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).Lv1,para(i).Lv2,para(i).l,para(i).Dpipe,para(i).Dv1,para(i).Dv2,...
            para(i).Dv1,para(i).bias1,para(i).bias2,...
            para(i).sectionL1,para(i).sectionL2,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
            'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',isUseStaightPipe);
    plus1 = calcPuls(pressure1,dcpss);
    plus2 = calcPuls(pressure2,dcpss);
    plus = [plus1,plus2];
end
figure
plot(plusOV)
hold on;
plot(plus,'-o')


