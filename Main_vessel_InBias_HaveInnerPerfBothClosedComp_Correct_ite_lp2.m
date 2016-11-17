%% ��������ÿ׹ܽṹ�뵥һ˳�ӻ���޶Ա�
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%������м����׹�,���˶��������׸��������Ե�ЧΪ��ķ���ȹ�����(��������ƫ��)
%                 L1
%                     |
%                     |
%           l         |          Lv              l    L2  
%              _______|_________________________        
%             |    dp(n1)    |    dp(n2)        |
%             |   ___ _ _ ___|___ _ _ ___ lc    |     
%             |  |___ _ _ ___ ___ _ _ ___|Din   |----------
%             |   la1 lp1 la2|lb1 lp2 lb2       |
%             |______________|__________________|       
%                  Lin             Lout
%    Dpipe                   Dv                     Dpipe 
%              
%
% Lin �ڲ�׹���ڶγ��� 
% Lout�ڲ�׹ܳ��ڶγ���
% lc  �׹ܱں�
% dp  �׹�ÿһ���׿׾�
% n1  �׹���ڶο��׸�����    n2  �׹ܳ��ڶο��׸���
% la1 �׹���ڶξ���ڳ��� 
% la2 �׹���ڶξ���峤��
% lb1 �׹ܳ��ڶξ���峤��
% lb2 �׹ܳ��ڶξ࿪�׳���
% lp1 �׹���ڶο��׳���
% lp2 �׹ܳ��ڶο��׳���
% Din �׹ܹܾ���
% xSection1��xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
isOpening = 0;%�ܵ��տ�
%  rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%����25�Ⱦ���ѹ����0.2MPaG���¶ȶ�Ӧ�ܶ�
rpm = 420;outDensity = 1.5608;multFre=[14,28,42];%����25�Ⱦ���ѹ����0.15MPaG���¶ȶ�Ӧ�ܶ�
Fs = 4096;
[massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,rpm...
	,0.14,1.075,outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',Fs,'oneSecond',6);

%massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));

[FreRaw,AmpRaw,PhRaw,massFlowERaw] = frequencySpectrum(detrend(massFlowRaw,'constant'),Fs);

% ��ȡ��ҪƵ��
% massFlowE = massFlowERaw;
% Fre = FreRaw;

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

opt.acousticVelocity = 345;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffDamping = nan;%����
opt.coeffFriction = 0.04;%�ܵ�Ħ��ϵ��
% opt.meanFlowVelocity =14.5;%14.5;%�ܵ�ƽ������
opt.isUseStaightPipe = 1;%�����������ݾ���ķ���
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 1;


calcDatas = {};

iteData = [0.05:0.01:0.2];

for i = 1:length(iteData)     
    para(i).opt = opt;
    para(i).L1 = 1.5;%L1(m)
    para(i).L2 = 6;%L2��m������
    para(i).Dpipe = 0.098;%�ܵ�ֱ����m��
    para(i).vhpicStruct.l = 0.01;
    para(i).vhpicStruct.Dv = 0.372;%����޵�ֱ����m��
    para(i).vhpicStruct.Lv = 1.1;%������ܳ�
    para(i).vhpicStruct.lc = 0.005;%�ڲ�ܱں�
    para(i).vhpicStruct.dp = 0.013;%���׾�
    para(i).vhpicStruct.Lin = 0.25;%�ڲ����ڶγ���
    para(i).vhpicStruct.lp2 = iteData(i);%�ڲ����ڶηǿ׹ܿ��׳���
    para(i).vhpicStruct.lp1 = 0.16;%�ڲ�ܳ��ڶο׹ܿ��׳���
    para(i).vhpicStruct.n1 = 48;%��ڶο���
    para(i).vhpicStruct.n2 = 48;%���ڶο���
    para(i).vhpicStruct.lb2 = 0.03;%�׹���ڶο�����ڳ���
    para(i).vhpicStruct.lb1 = para(i).vhpicStruct.Lin - para(i).vhpicStruct.lb2 - para(i).vhpicStruct.lp2;%�׹�
    para(i).vhpicStruct.la2 = 0.06;
    para(i).vhpicStruct.la1 = 0.03;
    para(i).vhpicStruct.Din = 0.053;
    para(i).vhpicStruct.Lout = 0.25;
    sectionNum1 =[1];%��Ӧ��1������
    sectionNum2 =[1];%��Ӧ��2������
    para(i).vhpicStruct.bp1 = para(i).vhpicStruct.n1.*(para(i).vhpicStruct.dp)^2./(4.*para(i).vhpicStruct.Din.*para(i).vhpicStruct.lp1);%������
    para(i).vhpicStruct.bp2 = para(i).vhpicStruct.n2.*(para(i).vhpicStruct.dp)^2./(4.*para(i).vhpicStruct.Din.*para(i).vhpicStruct.lp2);%������
    lTmp = para(i).vhpicStruct.lp1;
    para(i).vhpicStruct.xSection1 = [0,ones(1,sectionNum1).*(lTmp/(sectionNum1))];
    lTmp = para(i).vhpicStruct.lp2;
    para(i).vhpicStruct.xSection2 = [0,ones(1,sectionNum2).*(lTmp/(sectionNum2))];
    para(i).sectionL1 = 0:0.25:para(i).L1;
    para(i).sectionL2 = 0:0.25:para(i).L2;
    para(i).vhpicStruct.lv1 = para(i).vhpicStruct.Lv./2-0.232;%232
    para(i).vhpicStruct.lv2 = 0;%���ڲ�ƫ��


    holepipeLength1 = para(i).vhpicStruct.Lin - para(i).vhpicStruct.la1 - para(i).vhpicStruct.la2;
    hl1 = sum(para(i).vhpicStruct.xSection1);
    if(~cmpfloat(holepipeLength1,hl1))
        error('�׹ܲ������ô���holepipeLength1=%.8f,hl1=%.8f;Lin:%g,la1:%g,la2:%g,sum(xSection1):%g,dp:%g'...
            ,holepipeLength1,hl1...
            ,para(i).vhpicStruct.Lin,para(i).vhpicStruct.la1,para(i).vhpicStruct.la2...
            ,sum(para(i).vhpicStruct.xSection1),para(i).vhpicStruct.dp);
    end
    name{i} = sprintf('lp1:%g',iteData(i));
end

dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.3,0.7];
dcpss.fs = Fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������

dataCount = 2;
calcDatas{1,2} = 'xֵ';
calcDatas{1,3} = 'ѹ������';
calcDatas{1,4} = '1��Ƶ';
calcDatas{1,5} = '2��Ƶ';
calcDatas{1,6} = '3��Ƶ';
for i = 1:length(para)
    
    if i==1
        %����ֱ��
        %ֱ���ܳ�
        straightPipeLength = para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).L2;
        straightPipeSection = [para(i).sectionL1,...
                                para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).sectionL2];
        newSectionL2 = para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).sectionL2;
        temp = find(straightPipeLength>para(i).L1);%�ҵ���������ڵ�����
        sepratorIndex = temp(1);
        temp = straightPipePulsationCalc(massFlowE,Fre,time,straightPipeLength,straightPipeSection...
        ,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping...
        ,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity...
        ,'m',para(i).opt.mach,'notMach',para(i).opt.notMach,...
        'isOpening',isOpening);
        plusStraight = calcPuls(temp,dcpss);
        maxPlus1Straight(i) = max(plusStraight(1:sepratorIndex(i)));
        maxPlus2Straight(i) = max(plusStraight(sepratorIndex(i):end));
        multFreAmpValue_straightPipe{i} = calcWaveFreAmplitude(temp,Fs,multFre,'freErr',1);

        if isXShowRealLength
            X = straightPipeSection;
        else
            X = 1:length(plusStraight);
        end
        calcDatas{dataCount,1} = sprintf('ֱ��');
        calcDatas{dataCount,2} = X;
        calcDatas{dataCount,3} = plusStraight;
        calcDatas{dataCount,4} = multFreAmpValue_straightPipe{i}(1,:);
        calcDatas{dataCount,5} = multFreAmpValue_straightPipe{i}(2,:);
        calcDatas{dataCount,6} = multFreAmpValue_straightPipe{i}(3,:);
        dataCount = dataCount + 1;
    end

    
    pressure1ClosedIB = [];
    pressure2ClosedIB = [];

    [pressure1ClosedIB,pressure2ClosedIB] = ...
        vesselInBiasHaveInnerPerfBothClosedCompCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,para(i).Dpipe...
        ,para(i).vhpicStruct,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach,...
        'isOpening',isOpening);%,'coeffDamping',para(i).opt.coeffDamping,
    plus1ClosedIB{i} = calcPuls(pressure1ClosedIB,dcpss);
    plus2ClosedIB{i} = calcPuls(pressure2ClosedIB,dcpss);
    plusClosedIB{i} = [plus1ClosedIB{i},plus2ClosedIB{i}];
    multFreAmpValueClosedIB{i} = calcWaveFreAmplitude([pressure1ClosedIB,pressure2ClosedIB],Fs,multFre,'freErr',1);
    
    calcDatas{dataCount,1} = sprintf('���ƫ���ڲ�׹����˶��������,lp1:%g',iteData(i));
    calcDatas{dataCount,2} = X;
    calcDatas{dataCount,3} = plusClosedIB{i};
    calcDatas{dataCount,4} = multFreAmpValueClosedIB{i}(1,:);
    calcDatas{dataCount,5} = multFreAmpValueClosedIB{i}(2,:);
    calcDatas{dataCount,6} = multFreAmpValueClosedIB{i}(3,:);
    dataCount = dataCount + 1;

%     [pressure1OpenIB,pressure2OpenIB] = ...
%         vesselInBiasHaveInnerPerfInCloOutOpenCompCalc(massFlowE,Fre,time,...
%         para(i).L1,para(i).L2,para(i).Dpipe...
%         ,para(i).vhpicStruct,...
%         para(i).sectionL1,para(i).sectionL2,...
%         'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
%         'meanFlowVelocity',para(i).opt.meanFlowVelocity,...
%         'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
%         ,'isOpening',isOpening);%,'coeffDamping',opt.coeffDamping
%     plus1OpenIB{i} = calcPuls(pressure1OpenIB,dcpss);
%     plus2OpenIB{i} = calcPuls(pressure2OpenIB,dcpss);
%     plusOpenIB{i} = [plus1OpenIB{i},plus2OpenIB{i}];
%     multFreAmpValueOpendIB{i} = calcWaveFreAmplitude([pressure1OpenIB,pressure2OpenIB],Fs,multFre,'freErr',1);
%     calcDatas{dataCount,1} = sprintf('���ƫ���ڲ�׹ܿ��ڻ����,lp1:%g',iteData(i));
%     calcDatas{dataCount,2} = X;
%     calcDatas{dataCount,3} = plusOpenIB{i};
%     calcDatas{dataCount,4} = multFreAmpValueOpendIB{i}(1,:);
%     calcDatas{dataCount,5} = multFreAmpValueOpendIB{i}(2,:);
%     calcDatas{dataCount,6} = multFreAmpValueOpendIB{i}(3,:);
%     dataCount = dataCount + 1;

     %���㵥һ��������ƫ��
     if i == 1
%         [pressure1Temp,pressure2Temp] = vesselBiasStraightPulsationCalc(massFlowE4Vessel,Fre4Vessel,time,...
%             para(i).L1,para(i).L2,...
%             para(i).vhpicStruct.Lv,para(i).vhpicStruct.l,para(i).Dpipe,para(i).vhpicStruct.Dv,...
%             para(i).vhpicStruct.lv1,0,...%��0��ָ����
%             para(i).sectionL1,para(i).sectionL2,...
%             'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
%             'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
%             'm',para(i).opt.mach,'notMach',para(i).opt.notMach,...
%             'isOpening',isOpening);
%         plusOVIB = [calcPuls(pressure1Temp,dcpss),calcPuls(pressure2Temp,dcpss)];
%         multFreAmpValue_OVIB{i} = calcWaveFreAmplitude([pressure1Temp,pressure2Temp],Fs,multFre,'freErr',1);
% 
%         calcDatas{dataCount,1} = sprintf('���ڼ������-���ڴ�λ����˳��');
% 	    calcDatas{dataCount,2} = X;
% 	    calcDatas{dataCount,3} = plusOVIB;
% 	    calcDatas{dataCount,4} = multFreAmpValue_OVIB{i}(1,:);
% 	    calcDatas{dataCount,5} = multFreAmpValue_OVIB{i}(2,:);
% 	    calcDatas{dataCount,6} = multFreAmpValue_OVIB{i}(3,:);
%     	dataCount = dataCount + 1;
%         
%         [pressure1Temp,pressure2Temp] = vesselBiasPulsationCalc(massFlowE4Vessel,Fre4Vessel,time,...
%         para(i).L1,para(i).L2,...
%         para(i).vhpicStruct.Lv,para(i).vhpicStruct.l,para(i).Dpipe,para(i).vhpicStruct.Dv...
%         ,para(i).vhpicStruct.lv1,...
%         para(i).vhpicStruct.lv2,0,...
%         para(i).sectionL1,para(i).sectionL2,...
%         'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
%         'meanFlowVelocity',para(i).opt.meanFlowVelocity,'isUseStaightPipe',1,...
%         'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
%         ,'isOpening',isOpening...
%         );%,'coeffDamping',opt.coeffDamping
%         plusOVIB = [calcPuls(pressure1Temp,dcpss),calcPuls(pressure2Temp,dcpss)];
%         multFreAmpValue_OVIB{i} = calcWaveFreAmplitude([pressure1Temp,pressure2Temp],Fs,multFre,'freErr',1);
%         calcDatas{dataCount,1} = sprintf('���ڼ������-�����ڴ�λ');
% 	    calcDatas{dataCount,2} = X;
% 	    calcDatas{dataCount,3} = plusOVIB;
% 	    calcDatas{dataCount,4} = multFreAmpValue_OVIB{i}(1,:);
% 	    calcDatas{dataCount,5} = multFreAmpValue_OVIB{i}(2,:);
% 	    calcDatas{dataCount,6} = multFreAmpValue_OVIB{i}(3,:);
%     	dataCount = dataCount + 1;
%         
        [pressure1Temp,pressure2Temp] = vesselStraightBiasPulsationCalc(massFlowE,Fre,time...
        ,para(i).L1,para(i).L2...
        ,para(i).vhpicStruct.Lv,para(i).vhpicStruct.l,para(i).Dpipe,para(i).vhpicStruct.Dv...
        ,para(i).vhpicStruct.lv2,0 ...
        ,para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,'isUseStaightPipe',1,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
        ,'isOpening',isOpening...
        );%,'coeffDamping',opt.coeffDamping
        plus1OVIB = calcPuls(pressure1Temp,dcpss);
        plus2OVIB = calcPuls(pressure2Temp,dcpss);
        plusOVIB = [plus1OVIB,plus2OVIB];
        multFreAmpValue_OVIB{i} = calcWaveFreAmplitude([pressure1Temp,pressure2Temp],Fs,multFre,'freErr',1);
        calcDatas{dataCount,1} = sprintf('���ڼ������-����˳�ӳ��ڴ�λ');
	    calcDatas{dataCount,2} = X;
	    calcDatas{dataCount,3} = plusOVIB;
	    calcDatas{dataCount,4} = multFreAmpValue_OVIB{i}(1,:);
	    calcDatas{dataCount,5} = multFreAmpValue_OVIB{i}(2,:);
	    calcDatas{dataCount,6} = multFreAmpValue_OVIB{i}(3,:);
    	dataCount = dataCount + 1;
        if isempty(plus1OVIB)
            maxOVPlus1(i) = nan;
        else
            maxOVPlus1(i) = max(plus1OVIB);
        end

        if isempty(plus2OVIB)
            maxOVPlus2(i) = nan;
        else
            maxOVPlus2(i) = max(plus2OVIB);
        end  
    end
    
    %��������������
%     temp = plusOVIB;
%     temp2 = plusOpenIB{i};
% 
%     temp(temp<1e-4) = 1;
%     temp2(temp<1e-4) = 1;%tempС��1e-4ʱ��temp2Ҳ����Ϊ1.
%     reduceRate{i} = (temp - temp2)./temp;

    if isempty(plus1ClosedIB{i})
        maxPlus1(i) = nan;
    else
        maxPlus1(i) = max(plus1ClosedIB{i});
    end

    if isempty(plus2ClosedIB{i})
        maxPlus2(i) = nan;
    else
        maxPlus2(i) = max(plus2ClosedIB{i});
    end  

end

figure
plot(iteData,maxPlus1);
set(gcf,'color','w');

figure
plot(iteData,maxPlus2.*3.9./1000,'LineWidth',1.5);
xlabel('�׹ܿ��׶γ���(m)');
ylabel('��ϵ���ѹ���������ֵ(kPa)');
set(gcf,'color','w');
set(gcf,'position',[100,100,300,250]);
xlim([0.05,0.2]);
ignoreHeader = 1;
%����ѹ������
figure 
plotDataCells(calcDatas,'xcol',2,'ycol',3,'legendcol',1,'ignoreHeader',ignoreHeader);
title('����ѹ�����ֵ');
% %����1��Ƶ
% figure
% plotDataCells(calcDatas,'xcol',2,'ycol',4,'legendcol',1,'ignoreHeader',ignoreHeader);
% title('ѹ��1��Ƶ');
% %����2��Ƶ
% figure
% plotDataCells(calcDatas,'xcol',2,'ycol',5,'legendcol',1,'ignoreHeader',ignoreHeader);
% title('ѹ��2��Ƶ');
% %����3��Ƶ
% figure
% plotDataCells(calcDatas,'xcol',2,'ycol',6,'legendcol',1,'ignoreHeader',ignoreHeader);
% title('ѹ��3��Ƶ');
