%% ���ƻ�����ں��װ�ṹ���ſװ�׾���С�仯������޺�����������仯���
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%���װ建��޵�������������
%   Detailed explanation goes here
%  L1  l    Lv1     Lv2   l  L2
%        __________________
%       |         |        |
% ------|     V1   d    V2 |-------
%       |_________|________|
%    Dpipe  Dv1    d   Dv2    Dpipe 

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
temp = Fre<100;%(Fre<29) | (Fre>30 & Fre < 100);
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
dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.4,0.5];
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������
LTotal = 0.951;
Lv1 = 0.1:0.05:(LTotal-0.1);
for i=1:length(Lv1)
    para(i).opt = opt;
    para(i).L1 = 2.94;
    para(i).L2 = 10;
    para(i).Dpipe = 0.106;
    para(i).Dv1 = 0.4;
    para(i).Dv2 = 0.4;
    para(i).l = 0.115;
    para(i).Lv1 = Lv1(i);
    para(i).Lv2 = LTotal - Lv1(i);
    para(i).d = 0.106/2;
    para(i).sectionL1 = 0:1:para(i).L1;
    para(i).sectionL2 = 0:1:para(i).L2;
end

for i = 1:length(para)
    pressure1 = [];
    pressure2 = [];

    [pressure1,pressure2] = ...
        vesselHaveOrificePulsationCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,...
        para(i).Lv1,para(i).Lv2,para(i).l,para(i).Dpipe,para(i).Dv1,para(i).Dv2,...
        para(i).d,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
        'meanFlowVelocity',opt.meanFlowVelocity);
    plus1{i} = calcPuls(pressure1,dcpss);
    plus2{i} = calcPuls(pressure2,dcpss);
    plus{i} = [plus1{i},plus2{i}];
    if i == 1
        [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).Lv1+para(i).Lv2,para(i).l,para(i).Dpipe,para(i).Dv1,...
            para(i).sectionL1,para(i).sectionL2,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
            'meanFlowVelocity',opt.meanFlowVelocity);
        plus1OV = calcPuls(pressure1OV,dcpss);
        plus2OV = calcPuls(pressure2OV,dcpss);
        plusOV = [plus1OV,plus2OV];
        maxPlus2OV = max(plus2OV);
        maxPlus1OV = max(plus1OV);
    end
    if isempty(plus1{i})
        maxPlus1(i) = nan;
    else
        maxPlus1(i) = max(plus1{i});
    end

    if isempty(plus2{i})
        maxPlus2(i) = nan;
    else
        maxPlus2(i) = max(plus2{i});
    end

    
    newSectionL2 = para(i).L1 + 2*para(i).l+para(i).Lv1 + para(i).Lv2 + para(i).sectionL2;

    realLengthSection{i} = [para(i).sectionL1,newSectionL2];

    L_straight(i) = para(i).L1 + para(i).L2 + para(i).Lv1 + para(i).Lv2 + 2*para(i).l;
    temp = find(realLengthSection{i}>para(i).L1);
    sepratorIndex(i) = temp(1);
    %temp = fun_straightPipe(massFlowE1,L_straight(i),para(i).Dpipe,para(i).opt,realLengthSection{i});
    temp = straightPipePulsationCalc(massFlowE,Fre,time,L_straight(i),realLengthSection{i}...
	,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity);
    temp = calcPuls(temp,dcpss);
    maxPlus1Straight(i) = max(temp(1:sepratorIndex(i)));
    maxPlus3Straight(i) = max(temp(sepratorIndex(i):end));
    plusStraight{i} = temp;
    temp2 = plus{i};
    temp(temp<1e-4) = 1;
    temp2(temp2<1e-4) = 1;
    reduceRate{i} = (temp - temp2)./temp;
    
    maxPlus1Straight(i) = max(temp(1:sepratorIndex(i)));
    maxPlus3Straight(i) = max(temp(sepratorIndex(i):end));

end

%% ��ͼ
figure
x = Lv1*1000;
y = maxPlus2./1000;
hold on;
h(1) = plot(x,y,'-r');
h(2) = plot([x(1) x(end)],[maxPlus2OV./1000 maxPlus2OV./1000],'--b');
xlabel('orifice location(mm)');
ylabel(sprintf('max peak-to-peak\n pressure pulsation(kPa)'));
ylim([0 7]);
box on;
grid on;
set(gcf,'color','w');