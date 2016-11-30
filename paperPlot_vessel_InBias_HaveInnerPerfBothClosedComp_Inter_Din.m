%% �����׹ܹܾ���Ҳ���ǵ���������
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
%             |    dp1(n1)   |    dp2(n2)       |
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
%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%����25�Ⱦ���ѹ����0.2MPaG���¶ȶ�Ӧ�ܶ�
rpm = 420;outDensity = 1.5608;multFre=[14,28,42];%����25�Ⱦ���ѹ����0.15MPaG���¶ȶ�Ӧ�ܶ�
Fs = 4096;
[massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,rpm...
	,0.14,1.075,outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',Fs,'oneSecond',6);

%massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));

[FreRaw,AmpRaw,PhRaw,massFlowERaw] = frequencySpectrum(detrend(massFlowRaw,'constant'),Fs);
FreRaw = [7,14,21,28,14*3];
% massFlowERaw = [0.02,0.2,0.02,0.04,0.025];
massFlowERaw = [0.02,0.2,0.03,0.003,0.007];

% ��ȡ��ҪƵ��
massFlowE = massFlowERaw;
Fre = FreRaw;

% [pks,locs] = findpeaks(AmpRaw,'SORTSTR','descend');
% Fre = FreRaw(locs);
% massFlowE = massFlowERaw(locs);
% temp = [1:20];%(Fre<29) ;%| (Fre>30 & Fre < 100);
% 
% massFlowE4Vessel = massFlowE;
% massFlowE = massFlowE(temp);
% Fre4Vessel = Fre;
% Fre = Fre(temp);

isDamping = 1;
%��ͼ����
isXShowRealLength = 1;
isShowStraightPipe=1;%�Ƿ���ʾֱ��
isShowOnlyVessel=1;%�Ƿ���ʾ���ڼ������

opt.acousticVelocity = 345;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffDamping = nan;%����
opt.coeffFriction = 0.04;%�ܵ�Ħ��ϵ��
SreaightMeanFlowVelocity =20;%14.5;%�ܵ�ƽ������
SreaightCoeffFriction = 0.03;
VesselMeanFlowVelocity =8;%14.5;%�����ƽ������
VesselCoeffFriction = 0.003;
PerfClosedMeanFlowVelocity =9;%14.5;%�����׹�ƽ������
PerfClosedCoeffFriction = 0.04;
PerfOpenMeanFlowVelocity =15;%14.5;%���ڿ׹�ƽ������
PerfOpenCoeffFriction = 0.035;
% opt.meanFlowVelocity =14.5;%14.5;%�ܵ�ƽ������
opt.isUseStaightPipe = 1;%�����������ݾ���ķ���
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 1;

variant_n1 = [24];%��ʵ��һȦ8����
sectionNum1 =[1];%��Ӧ��1������
sectionNum2 =[1];%��Ӧ��2������
variant_n2 = [24];
variant_lp2 = [0.16];
variant_dp1 = [0.013];
variant_dp2 = [0.013];
variant_Din = [0.098/2,0.098,0.098*2];
% variant_Lv1 = 0.568:0.02:0.84;
calcDatas = {};


for i = 1:length(variant_Din)     
    para(i).opt = opt;
    para(i).L1 = 3.5;%L1(m)
    para(i).L2 = 6;%L2��m������
    para(i).Dpipe = 0.098;%�ܵ�ֱ����m��
    para(i).vhpicStruct.l = 0.01;
    para(i).vhpicStruct.Dv = 0.372;%����޵�ֱ����m��
    para(i).vhpicStruct.Lv = 1.1;%������ܳ� 
    para(i).vhpicStruct.Lv1 =para(i).vhpicStruct.Lv./2;%�����ǻ1�ܳ�
    para(i).vhpicStruct.Lv2 = para(i).vhpicStruct.Lv-para(i).vhpicStruct.Lv1;%�����ǻ2�ܳ�
    para(i).vhpicStruct.lc = 0.005;%�ڲ�ܱں�
    para(i).vhpicStruct.dp1 = variant_dp1;%���׾�
    para(i).vhpicStruct.dp2 = variant_dp2;%���׾�
    para(i).vhpicStruct.Lin = 0.25;%�ڲ����ڶγ���
    para(i).vhpicStruct.lp1 = 0.16;%�ڲ����ڶηǿ׹ܿ��׳���
    para(i).vhpicStruct.lp2 = 0.16;%�ڲ�ܳ��ڶο׹ܿ��׳���
    para(i).vhpicStruct.n1 = variant_n1;%��ڶο���
    para(i).vhpicStruct.n2 = variant_n2;%���ڶο���
    para(i).vhpicStruct.la1 = 0.03;%�׹���ڶο�����ڳ���
    para(i).vhpicStruct.la2 = 0.06;%�׹�
    para(i).vhpicStruct.lb1 = 0.06;
    para(i).vhpicStruct.lb2 = 0.03;
    para(i).vhpicStruct.Din = variant_Din(i);
    para(i).vhpicStruct.Lout = 0.25;
    para(i).vhpicStruct.bp1 = variant_n1.*(variant_dp1)^2./(4.*variant_Din(i).*para(i).vhpicStruct.lp1);%������
    para(i).vhpicStruct.bp2 = variant_n2.*(variant_dp2)^2./(4.*variant_Din(i).*para(i).vhpicStruct.lp2);%������
    para(i).vhpicStruct.nc1 = 8;%����һȦ��8����
    para(i).vhpicStruct.nc2 = 8;%����һȦ��8����
    para(i).vhpicStruct.Cloum1 = variant_n1./para(i).vhpicStruct.nc1;%����һ�˹̶����׳��ȵĿ׹����ܿ�����Ȧ��
    para(i).vhpicStruct.Cloum2 = variant_n2./para(i).vhpicStruct.nc2;
    para(i).vhpicStruct.s1 = ((para(i).vhpicStruct.lp1./para(i).vhpicStruct.Cloum1)-variant_dp1)./2;%����������֮������Ĭ�ϵȼ��
    para(i).vhpicStruct.s2 = ((para(i).vhpicStruct.lp2./para(i).vhpicStruct.Cloum2)-variant_dp2)./2;
    para(i).vhpicStruct.sc1 = (pi.*variant_Din(i) - para(i).vhpicStruct.nc1.*para(i).vhpicStruct.dp1)./para(i).vhpicStruct.nc1;%һ�ܿ��ף����ڿ׼��
    para(i).vhpicStruct.sc2 = (pi.*variant_Din(i) - para(i).vhpicStruct.nc2.*para(i).vhpicStruct.dp2)./para(i).vhpicStruct.nc2;
    l = para(i).vhpicStruct.lp1;
    para(i).vhpicStruct.xSection1 = [0,ones(1,sectionNum1).*(l/(sectionNum1))];
    l = para(i).vhpicStruct.lp2;
    para(i).vhpicStruct.xSection2 = [0,ones(1,sectionNum2).*(l/(sectionNum2))];
    para(i).sectionL1 = 0:0.25:para(i).L1;
    para(i).sectionL2 = 0:0.25:para(i).L2;
    para(i).vhpicStruct.lv1 = para(i).vhpicStruct.Lv./2-0.232;%232
    para(i).vhpicStruct.lv2 = 0;%���ڲ�ƫ��
    para(i).vhpicStruct.Dbias = 0;%���ڲ��

    holepipeLength1 = para(i).vhpicStruct.Lin - para(i).vhpicStruct.la1 - para(i).vhpicStruct.la2;
    hl1 = sum(para(i).vhpicStruct.xSection1);
    if(~cmpfloat(holepipeLength1,hl1))
        error('�׹ܲ������ô���holepipeLength1=%.8f,hl1=%.8f;Lin:%g,la1:%g,la2:%g,sum(xSection1):%g,dp:%g'...
            ,holepipeLength1,hl1...
            ,para(i).vhpicStruct.Lin,para(i).vhpicStruct.la1,para(i).vhpicStruct.la2...
            ,sum(para(i).vhpicStruct.xSection1),para(i).vhpicStruct.dp);
    end
    name{i} = sprintf('Din:%g',variant_Din(i));
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
        newSectionL2 = para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv+ para(i).sectionL2;
        temp = find(straightPipeLength>para(i).L1);%�ҵ���������ڵ�����
        sepratorIndex = temp(1);
        temp = straightPipePulsationCalc(massFlowE,Fre,time,straightPipeLength,straightPipeSection...
        ,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping...
        ,'friction',SreaightCoeffFriction,'meanFlowVelocity',SreaightMeanFlowVelocity...
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
    
    calcDatas{dataCount,1} = sprintf('���ƫ���ڲ�׹����˶��������,Din:%g',variant_Din(i));
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
%     calcDatas{dataCount,1} = sprintf('���ƫ���ڲ�׹ܿ��ڻ����,n1:%g,n2:%g',variant_n1(i),variant_n2(i));
%     calcDatas{dataCount,2} = X;
%     calcDatas{dataCount,3} = plusOpenIB{i};
%     calcDatas{dataCount,4} = multFreAmpValueOpendIB{i}(1,:);
%     calcDatas{dataCount,5} = multFreAmpValueOpendIB{i}(2,:);
%     calcDatas{dataCount,6} = multFreAmpValueOpendIB{i}(3,:);
%     dataCount = dataCount + 1;

    %���㵥һ��������ƫ��
    if i == 1
        
        [pressure1Temp,pressure2Temp] = vesselBiasStraightPulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).vhpicStruct.Lv1+para(i).vhpicStruct.Lv2,para(i).vhpicStruct.l,para(i).Dpipe,para(i).vhpicStruct.Dv,...
            para(i).vhpicStruct.lv1,para(i).vhpicStruct.Dbias,...
            para(i).sectionL1,para(i).sectionL2,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',VesselCoeffFriction,...
            'meanFlowVelocity',VesselMeanFlowVelocity,'isUseStaightPipe',1,...
            'm',para(i).opt.mach,'notMach',para(i).opt.notMach,...
            'isOpening',isOpening);
        plusOVIB = [calcPuls(pressure1Temp,dcpss),calcPuls(pressure2Temp,dcpss)];
        multFreAmpValue_OVIB{i} = calcWaveFreAmplitude([pressure1Temp,pressure2Temp],Fs,multFre,'freErr',1);

        calcDatas{dataCount,1} = sprintf('���ڼ������-���ڴ�λ����˳��');
	    calcDatas{dataCount,2} = X;
	    calcDatas{dataCount,3} = plusOVIB;
	    calcDatas{dataCount,4} = multFreAmpValue_OVIB{i}(1,:);
	    calcDatas{dataCount,5} = multFreAmpValue_OVIB{i}(2,:);
	    calcDatas{dataCount,6} = multFreAmpValue_OVIB{i}(3,:);
    	dataCount = dataCount + 1;
        
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
%         [pressure1Temp,pressure2Temp] = vesselStraightBiasPulsationCalc(massFlowE,Fre,time...
%         ,para(i).L1,para(i).L2...
%         ,para(i).vhpicStruct.Lv,para(i).vhpicStruct.l,para(i).Dpipe,para(i).vhpicStruct.Dv...
%         ,para(i).vhpicStruct.lv2,0 ...
%         ,para(i).sectionL1,para(i).sectionL2,...
%         'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
%         'meanFlowVelocity',para(i).opt.meanFlowVelocity,'isUseStaightPipe',1,...
%         'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
%         ,'isOpening',isOpening...
%         );%,'coeffDamping',opt.coeffDamping
%         plusOVIB = [calcPuls(pressure1Temp,dcpss),calcPuls(pressure2Temp,dcpss)];
%         multFreAmpValue_OVIB{i} = calcWaveFreAmplitude([pressure1Temp,pressure2Temp],Fs,multFre,'freErr',1);
%         calcDatas{dataCount,1} = sprintf('���ڼ������-����˳�ӳ��ڴ�λ');
% 	    calcDatas{dataCount,2} = X;
% 	    calcDatas{dataCount,3} = plusOVIB;
% 	    calcDatas{dataCount,4} = multFreAmpValue_OVIB{i}(1,:);
% 	    calcDatas{dataCount,5} = multFreAmpValue_OVIB{i}(2,:);
% 	    calcDatas{dataCount,6} = multFreAmpValue_OVIB{i}(3,:);
%     	dataCount = dataCount + 1;
    end
end
    
%     %��������������
%     temp = plusOVIB;
%     temp2 = plusOpenIB{i};
% 
%     temp(temp<1e-4) = 1;
%     temp2(temp<1e-4) = 1;%tempС��1e-4ʱ��temp2Ҳ����Ϊ1.
%     reduceRate{i} = (temp - temp2)./temp;
% 
%     if isempty(plus1ClosedIB{i})
%         maxPlus1(i) = nan;
%     else
%         maxPlus1(i) = max(plus1ClosedIB{i});
%     end
% 
%     if isempty(plus2ClosedIB{i})
%         maxPlus2(i) = nan;
%     else
%         maxPlus2(i) = max(plus2ClosedIB{i});
%     end  


ignoreHeader = 1;
%����ѹ������
figure 
plotDataCells(calcDatas,'xcol',2,'ycol',3,'legendcol',1,'ignoreHeader',ignoreHeader);
title('����ѹ�����ֵ');
%����1��Ƶ
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

result = externPlotDatasCell(calcDatas,'dataRowsIndexs',[2:size(calcDatas,1)]...
    ,'dataColumnIndex',[2:size(calcDatas,2)]...
    ,'dataParamLegend',calcDatas(1,2:size(calcDatas,2))...
    ,'dataNameLegend',calcDatas(2:size(calcDatas,1)),1);