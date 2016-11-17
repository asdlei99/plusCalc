%% ��λ����޽ṹ�뵥һ˳�ӻ���޶Ա�
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
temp = [1:20];%(Fre<29) ;%| (Fre>30 & Fre < 100);

massFlowE4Vessel = massFlowE;
massFlowE = massFlowE(temp);
Fre4Vessel = Fre;
Fre = Fre(temp);
isDamping = 1;
%��ͼ����
isXShowRealLength = 1;
isShowStraightPipe=1;%�Ƿ���ʾֱ��
isShowOnlyVessel=1;%�Ƿ���ʾ���ڼ������
inputData = [...
    %1    2  3     4   5   6     7          8      9     
    %L1  ,L2,Lv   ,l   ,Dpipe,Dv ,lv1    ,lv2   ,Dbias
    1.5 ,6,1.1,0.01,0.098,0.372,0.55-0.232   ,0.55-0.232  , 0 
    1.5 ,6,1.1,0.01,0.098,0.372,0.45  ,0.45 , 0
];%LinLout����Ϊ��
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
for i = 1:size(inputData,1)
    name{i} = sprintf('lv1:%g,lv2:%g',inputData(i,7),inputData(i,8));
%     desp{i} = sprintf('L1:%g,L2:%g,Dpipe:%g,Dv:%g,l:%g,Lv:%g,Linner:%g,Lin:%g��Lout:%g��Din:%g'...
%         ,inputData(i,1),inputData(i,2),inputData(i,3),inputData(i,4)...
%         ,inputData(i,5),inputData(i,6),inputData(i,7),inputData(i,8)...
%         ,inputData(i,9),inputData(i,10));
    
    para(i).opt = opt;
    para(i).L1 = inputData(i,1);%L1(m)
    para(i).L2 = inputData(i,2);%������м����ӹܵ��ĳ��ȣ�m�� 
    para(i).Lv = inputData(i,3);%�ܵ�ֱ����m��
    para(i).l = inputData(i,4);
    para(i).Dpipe = inputData(i,5);%0.115;%�����ǰ�ܵ��ĳ���(m)   
    para(i).Dv = inputData(i,6);%[[0.157,0.25,0.5,0.75],[1:0.25:5]];%��һ������޵�ֱ����m��
    para(i).lv1 = inputData(i,7);%
    para(i).lv2 = inputData(i,8);
    para(i).Dbias = inputData(i,9);%

    
    para(i).sectionL1 = 0:0.2:para(i).L1;
    para(i).sectionL2 = 0:0.2:para(i).L2;
end

dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.3,0.7];
dcpss.fs = Fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������

dataCount = 1;
for i = 1:length(para)
    %����ֱ�ܵĳ���
    straightPipeLength = para(i).L1 + 2*para(i).l+para(i).Lv + para(i).L2;
    %����ֱ�ܵķֶ�
    straightPipeSection = [para(i).sectionL1,...
                            para(i).L1 + 2*para(i).l+para(i).Lv + para(i).sectionL2];
    if isXShowRealLength
        X = straightPipeSection;
    else
        X = 1:length(Y);
    end
    %�ȶ�ֱ�ܽ��м���
    if i==1
        %����ֱ��
        %ֱ���ܳ�
        
        newSectionL2 = para(i).L1 + 2*para(i).l+para(i).Lv + para(i).sectionL2;
        temp = find(straightPipeLength>para(i).L1);%�ҵ���������ڵ�����
        sepratorIndex = temp(1);
        temp = straightPipePulsationCalc(massFlowE,Fre,time,straightPipeLength,straightPipeSection...
        ,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping...
        ,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity...
        ,'m',para(i).opt.mach,'notMach',para(i).opt.notMach...
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

    [pressure1,pressure2] = ...
        vesselBiasPulsationCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,...
        para(i).Lv,para(i).l,para(i).Dpipe,para(i).Dv,para(i).lv1,...
        para(i).lv2,para(i).Dbias,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,'isUseStaightPipe',1,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
        ,'isOpening',isOpening...
        );%,'coeffDamping',opt.coeffDamping
    plus1{i} = calcPuls(pressure1,dcpss);
    plus2{i} = calcPuls(pressure2,dcpss);
    plus{i} = [plus1{i},plus2{i}];
    
    calcDatas{dataCount,1} = X;
    calcDatas{dataCount,2} = plus{i};
    calcDatas{dataCount,3} = sprintf('��������λ�����-lv1:%g,lv2:%g',inputData(i,7),inputData(i,8));%�����������������
    dataCount = dataCount + 1;

    %�������˳�ӳ���ƫ��
    [pressure1OSB,pressure2OSB] = ...
        vesselStraightBiasPulsationCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,...
        para(i).Lv,para(i).l,para(i).Dpipe,para(i).Dv,...
        para(i).lv2,para(i).Dbias,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,'isUseStaightPipe',1,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
        ,'isOpening',isOpening...
        );%,'coeffDamping',opt.coeffDamping
    plus1OSB{i} = calcPuls(pressure1OSB,dcpss);
    plus2OSB{i} = calcPuls(pressure2OSB,dcpss);
    plusOSB{i} = [plus1OSB{i},plus2OSB{i}];

    calcDatas{dataCount,1} = X;
    calcDatas{dataCount,2} = plusOSB{i};
    calcDatas{dataCount,3} = sprintf('��˳�������-lv1:%g,lv2:%g',inputData(i,7),inputData(i,8));%�����������������
    dataCount = dataCount + 1;
    
    %�������ƫ�ó��ڴ�λ
    [pressure1OBS,pressure2OBS] = ...
        vesselBiasStraightPulsationCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,...
        para(i).Lv,para(i).l,para(i).Dpipe,para(i).Dv,...
        para(i).lv2,para(i).Dbias,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,'isUseStaightPipe',1,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
        ,'isOpening',isOpening...
        );%,'coeffDamping',opt.coeffDamping
    plus1OBS{i} = calcPuls(pressure1OBS,dcpss);
    plus2OBS{i} = calcPuls(pressure2OBS,dcpss);
    plusOBS{i} = [plus1OBS{i},plus2OBS{i}];

    calcDatas{dataCount,1} = X;
    calcDatas{dataCount,2} = plusOBS{i};
    calcDatas{dataCount,3} = sprintf('��˳�������-lv1:%g,lv2:%g',inputData(i,7),inputData(i,8));%�����������������
    dataCount = dataCount + 1;
    %���㵥һ�����
    if i == 1
        [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).Lv,para(i).l,para(i).Dpipe,para(i).Dv,...
            para(i).sectionL1,para(i).sectionL2,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
            'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
            'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
            ,'isOpening',isOpening...
            );
        plus1OV = calcPuls(pressure1OV,dcpss);
        plus2OV = calcPuls(pressure2OV,dcpss);
        plusOV = [plus1OV,plus2OV];

        calcDatas{dataCount,1} = X;
        calcDatas{dataCount,2} = plusOV;
        calcDatas{dataCount,3} = sprintf('˳�ӻ����');%�����������������
        dataCount = dataCount + 1;
    end
    
    %��������������
    temp = plusStraight;
    temp2 = plus{i};

    temp(temp<1e-4) = 1;
    temp2(temp<1e-4) = 1;%tempС��1e-4ʱ��temp2Ҳ����Ϊ1.
    reduceRate{i} = (temp - temp2)./temp;

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

end

figure
handleCur = plotDataCells(calcDatas);