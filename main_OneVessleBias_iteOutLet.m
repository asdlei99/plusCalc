%% ��λ����޵���
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%��λ����޵�������������
%   Detailed explanation goes here
%           |  L2
%        l  |     Lv    outlet
%   bias2___|_______________
%       |                   |
%       |lv2  V          lv1|  Dv
%       |___________________|
%                    l  |   bias1  
%                       |
%              inlet:   | L1 Dpipe 
%�����Ĵ��ݾ���
isOpening = 	0;%�ܵ��տ�
%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%����25�Ⱦ���ѹ����0.2MPaG���¶ȶ�Ӧ�ܶ�
rpm = 420;outDensity = 1.5608;multFre=[14,28,42];%����25�Ⱦ���ѹ����0.15MPaG���¶ȶ�Ӧ�ܶ�
Fs = 4096;
[massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,rpm...
	,0.14,1.075,outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',Fs,'oneSecond',6);

[FreRaw,AmpRaw,PhRaw,massFlowERaw] = frequencySpectrum(detrend(massFlowRaw),Fs);
% ��ȡ��ҪƵ��
[pks,locs] = findpeaks(AmpRaw,'SORTSTR','descend');
Fre = FreRaw(locs);
massFlowE = massFlowERaw(locs);
temp = 1:20;%(Fre<29) ;%| (Fre>30 & Fre < 100);
massFlowE = massFlowE(temp);
Fre = Fre(temp);

isDamping = 1;
%��ͼ����
isXShowRealLength = 1;
isShowStraightPipe=1;%�Ƿ���ʾֱ��
isShowOnlyVessel=1;%�Ƿ���ʾ���ڼ������

calcDatas = {};%��ͼ������
opt.frequency = 10;%����Ƶ��
opt.acousticVelocity = 345;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffDamping = nan;%����
opt.coeffFriction = 0.04;%�ܵ�Ħ��ϵ��
% opt.meanFlowVelocity = 14.5;%�ܵ�ƽ������
opt.isUseStaightPipe = 0;%�����������ݾ���ķ���
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 1;

L1 = 1.5;%L1(m)
L2 = 6;%������м����ӹܵ��ĳ��ȣ�m�� 
Lv = 1.1;%�ܵ�ֱ����m��
l = 0.01;
Dpipe = 0.098;%0.115;%�����ǰ�ܵ��ĳ���(m)   
Dv = 0.372;%[[0.157,0.25,0.5,0.75],[1:0.25:5]];%��һ������޵�ֱ����m��
lv1 = 0.45;%
lv2 = 0.45;
Dbias = 0;%


sectionL1 = 0:0.2:L1;
sectionL2 = 0:0.2:L2;


dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.3,0.7];
dcpss.fs = Fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������

dataCount = 1;
outletPressure = 1000+1000i;
for i = 1:length(outletPressure)
    %����ֱ�ܵĳ���
    straightPipeLength = L1 + 2*l+Lv + L2;
    %����ֱ�ܵķֶ�
    straightPipeSection = [sectionL1,...
                            L1 + 2*l+Lv + sectionL2];
    if isXShowRealLength
        X = straightPipeSection;
    else
        X = 1:length(Y);
    end
    %�ȶ�ֱ�ܽ��м���
    if i==1
        %����ֱ��
        %ֱ���ܳ�
        
        newSectionL2 = L1 + 2*l+Lv + sectionL2;
        temp = find(straightPipeLength>L1);%�ҵ���������ڵ�����
        sepratorIndex = temp(1);
        temp = straightPipePulsationCalc(massFlowE,Fre,time,straightPipeLength,straightPipeSection...
        ,'d',Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping...
        ,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity...
        ,'m',opt.mach,'notMach',opt.notMach...
        ,'isOpening',isOpening...
        );
        plusStraight = calcPuls(temp,dcpss);
        maxPlus1Straight(i) = max(plusStraight(1:sepratorIndex(i)));
        maxPlus2Straight(i) = max(plusStraight(sepratorIndex(i):end));

        calcDatas{dataCount,1} = X;
        calcDatas{dataCount,2} = plusStraight;
        calcDatas{dataCount,3} = sprintf('ֱ��');%�����������������
        dataCount = dataCount + 1;
    end

    pressure1 = [];
    pressure2 = [];

    % [pressure1,pressure2] = ...
    %     vesselBiasPulsationCalc(massFlowE,Fre,time,...
    %     L1,L2,...
    %     Lv,l,Dpipe,Dv,lv1,...
    %     lv2,Dbias,...
    %     sectionL1,sectionL2,...
    %     'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
    %     'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
    %     'm',opt.mach,'notMach',opt.notMach...
    %     ,'isOpening',isOpening...
    %     );%,'coeffDamping',opt.coeffDamping
    % plus1{i} = calcPuls(pressure1,dcpss);
    % plus2{i} = calcPuls(pressure2,dcpss);
    % plus{i} = [plus1{i},plus2{i}];
    
    % calcDatas{dataCount,1} = X;
    % calcDatas{dataCount,2} = plus{i};
    % calcDatas{dataCount,3} = sprintf('��������λ�����-lv1:%g,lv2:%g',inputData(i,7),inputData(i,8));%�����������������
    % dataCount = dataCount + 1;

%     %�������˳�ӳ���ƫ��
%     [pressure1OSB,pressure2OSB] = ...
%         vesselStraightBiasPulsationCalc(massFlowE,Fre,time,...
%         L1,L2,...
%         Lv,l,Dpipe,Dv,...
%         lv2,Dbias,...
%         sectionL1,sectionL2,...
%         'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
%         'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
%         'm',opt.mach,'notMach',opt.notMach...
%         ,'isOpening',isOpening...
%         );%,'coeffDamping',opt.coeffDamping
%     plus1OSB{i} = calcPuls(pressure1OSB,dcpss);
%     plus2OSB{i} = calcPuls(pressure2OSB,dcpss);
%     plusOSB{i} = [plus1OSB{i},plus2OSB{i}];
% 
%     calcDatas{dataCount,1} = X;
%     calcDatas{dataCount,2} = plusOSB{i};
%     calcDatas{dataCount,3} = sprintf('��˳�������-lv1:%g,lv2:%g',inputData(i,7),inputData(i,8));%�����������������
%     dataCount = dataCount + 1;
    
    %�������ƫ�ó��ڴ�λ
    [pressure1OBS,pressure2OBS] = ...
        vesselBiasStraightPulsationCalc(massFlowE,Fre,time,...
        L1,L2,...
        Lv,l,Dpipe,Dv,...
        lv2,Dbias,...
        sectionL1,sectionL2,...
        'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
        'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
        'm',opt.mach,'notMach',opt.notMach...
        ,'isOpening',isOpening...
        ,'outletpressure',outletPressure(i)...
        );%,'coeffDamping',opt.coeffDamping
    plus1OBS{i} = calcPuls(pressure1OBS,dcpss);
    plus2OBS{i} = calcPuls(pressure2OBS,dcpss);
    plusOBS{i} = [plus1OBS{i},plus2OBS{i}];

    calcDatas{dataCount,1} = X;
    calcDatas{dataCount,2} = plusOBS{i};
    calcDatas{dataCount,3} = sprintf('��˳�������-p:%g',outletPressure(i));%�����������������
    dataCount = dataCount + 1;
    % %���㵥һ�����
    % if i == 1
    %     [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
    %         L1,L2,...
    %         Lv,l,Dpipe,Dv,...
    %         sectionL1,sectionL2,...
    %         'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
    %         'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
    %         'm',opt.mach,'notMach',opt.notMach...
    %         ,'isOpening',isOpening...
    %         );
    %     plus1OV = calcPuls(pressure1OV,dcpss);
    %     plus2OV = calcPuls(pressure2OV,dcpss);
    %     plusOV = [plus1OV,plus2OV];

    %     calcDatas{dataCount,1} = X;
    %     calcDatas{dataCount,2} = plusOV;
    %     calcDatas{dataCount,3} = sprintf('˳�ӻ����');%�����������������
    %     dataCount = dataCount + 1;
    % end
    
    %��������������
    % temp = plusStraight;
    % temp2 = plus{i};

    % temp(temp<1e-4) = 1;
    % temp2(temp<1e-4) = 1;%tempС��1e-4ʱ��temp2Ҳ����Ϊ1.
    % reduceRate{i} = (temp - temp2)./temp;

    % if isempty(plus1{i})
    %     maxPlus1(i) = nan;
    % else
    %     maxPlus1(i) = max(plus1{i});
    % end

    % if isempty(plus2{i})
    %     maxPlus2(i) = nan;
    % else
    %     maxPlus2(i) = max(plus2{i});
    % end  

end

figure
handleCur = plotDataCells(calcDatas);