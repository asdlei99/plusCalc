%% ��������ÿ׹ܽṹ�뵥һ˳�ӻ���޶Ա�
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%������м����׹�,���˶��������׸��������Ե�ЧΪ��ķ���ȹ�����
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             |    dp(n1)    |    dp(n2)        |
%             |   ___ _ _ ___|___ _ _ ___ lc    |     
%  -----------|  |___ _ _ ___ ___ _ _ ___|Din   |----------
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
% rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%����25�Ⱦ���ѹ����0.2MPaG���¶ȶ�Ӧ�ܶ�
rpm = 420;outDensity = 1.5608;multFre=[14,28,42];%����25�Ⱦ���ѹ����0.15MPaG���¶ȶ�Ӧ�ܶ�
Fs = 4096;
[massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,rpm...
	,0.14,1.075,outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',Fs,'oneSecond',1);

%massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));

[FreRaw,AmpRaw,PhRaw,massFlowE] = frequencySpectrum(detrend(massFlowRaw,'constant'),Fs);
Fre = FreRaw;
% ��ȡ��ҪƵ��
[pks,locs] = findpeaks(AmpRaw,'SORTSTR','descend');
Fre = FreRaw(locs);
massFlowE = massFlowE(locs);
temp = [1:20];%(Fre<29) ;%| (Fre>30 & Fre < 100);
Fre = Fre(temp);
massFlowE = massFlowE(temp);
isDamping = 1;
%��ͼ����
isXShowRealLength = 1;
isShowStraightPipe=1;%�Ƿ���ʾֱ��
isShowOnlyVessel=1;%�Ƿ���ʾ���ڼ������

opt.frequency = 10;%����Ƶ��
opt.acousticVelocity = 345;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffDamping = 0.1;%����
opt.coeffFriction = 0.04;%�ܵ�Ħ��ϵ��
% opt.meanFlowVelocity =14.5;%14.5;%�ܵ�ƽ������
opt.isUseStaightPipe = 1;%�����������ݾ���ķ���
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 0;

variant_n1 = [5:90];              %variant_n = [6,6];sectionNum1 =[1,6];%��Ӧ��1������sectionNum2 =[1,1];%��Ӧ��2������
sectionNum1 =5.*ones(length(variant_n1),1);%��Ӧ��1������
sectionNum2 =5.*ones(length(variant_n1),1);%��Ӧ��2������
variant_n2 = [5:90];

iterateSize = length(variant_n1);
for i = 1:iterateSize    
    para(i).opt = opt;
    para(i).L1 = 3;%L1(m)
    para(i).L2 = 6;%L2��m������
    para(i).Dpipe = 0.098;%�ܵ�ֱ����m��
    para(i).vhpicStruct.l = 0.01;
    para(i).vhpicStruct.Dv = 0.372;%����޵�ֱ����m��
    para(i).vhpicStruct.Lv = 1.1;%������ܳ�
    para(i).vhpicStruct.lc = 0.005;%�ڲ�ܱں�
    para(i).vhpicStruct.dp = 0.013;%���׾�
    para(i).vhpicStruct.Lin = 0.25;%�ڲ����ڶγ���
    para(i).vhpicStruct.lp1 = 0.18;%�ڲ����ڶηǿ׹ܿ��׳���
    para(i).vhpicStruct.lp2 = 0.18;%�ڲ�ܳ��ڶο׹ܿ��׳���
    para(i).vhpicStruct.n1 = variant_n1(i);%��ڶο���
    para(i).vhpicStruct.n2 = variant_n2(i);%���ڶο���
    para(i).vhpicStruct.la1 = 0.02;%�׹���ڶο�����ڳ���
    para(i).vhpicStruct.la2 = 0.05;%�׹�
    para(i).vhpicStruct.lb1 = 0.05;
    para(i).vhpicStruct.lb2 = 0.02;
    para(i).vhpicStruct.Din = 0.053;
    para(i).vhpicStruct.Lout = 0.25;
    para(i).vhpicStruct.bp1 = para(i).vhpicStruct.n1.*(para(i).vhpicStruct.dp)^2./(4.*para(i).vhpicStruct.Din.*para(i).vhpicStruct.lp1);%������
    para(i).vhpicStruct.bp2 = para(i).vhpicStruct.n2.*(para(i).vhpicStruct.dp)^2./(4.*para(i).vhpicStruct.Din.*para(i).vhpicStruct.lp2);%������
    l = para(i).vhpicStruct.lp1;
    para(i).vhpicStruct.xSection1 = [0,ones(1,sectionNum1(i)).*(l/(sectionNum1(i)))];
    l = para(i).vhpicStruct.lp2;
    para(i).vhpicStruct.xSection2 = [0,ones(1,sectionNum2(i)).*(l/(sectionNum2(i)))];
    para(i).sectionL1 = 0:0.25:para(i).L1;
    para(i).sectionL2 = 0:0.25:para(i).L2;
%%
%     para(i).opt = opt;
%     para(i).L1 = 3.85;%L1(m)
%     para(i).L2 = 10;%L2��m������
%     para(i).Dpipe = 0.106;%�ܵ�ֱ����m��
%     para(i).vhpicStruct.l = 0.01;
%     para(i).vhpicStruct.Dv = 0.45;%����޵�ֱ����m��
%     para(i).vhpicStruct.Lv = 1.18;%������ܳ�
%     para(i).vhpicStruct.lc = 0.005;%�ڲ�ܱں�
%     para(i).vhpicStruct.dp = 0.02;%���׾�
%     para(i).vhpicStruct.lp1 = 0.04;%�ڲ����ڶηǿ׹ܿ��׳���
%     para(i).vhpicStruct.Lin = 0.2;%�ڲ����ڶγ���
%     para(i).vhpicStruct.n1 = 20;%��ڶο���
%         para(i).vhpicStruct.Din = 0.106;
%     para(i).vhpicStruct.lp2 = variant_lp2(i);%�ڲ�ܳ��ڶηǿ׹ܿ��׳���
%     para(i).vhpicStruct.bp1 = para(i).vhpicStruct.n1.*(para(i).vhpicStruct.dp)^2./(4.*para(i).vhpicStruct.Din.*para(i).vhpicStruct.lp1);%������
%     para(i).vhpicStruct.n2 = variant_n2(i);%���ڶο���
%     para(i).vhpicStruct.la1 = 0.01;%�׹���ڶο�����ڳ���,����������lp1��Ӱ��ʱ�����뱣֤la1ʼ�ղ��䣬��la2ʼ�ղ���
%     para(i).vhpicStruct.la2 = para(i).vhpicStruct.Lin-para(i).vhpicStruct.la1-para(i).vhpicStruct.lp1;%�ٶ���֤��ڶ�la1ʼ�ղ��䣬0.15
% %     para(i).vhpicStruct.lb1 = 0.04;
% %     para(i).vhpicStruct.lb2 = 0.02;
%     para(i).vhpicStruct.Lout = 0.2;
% %     para(i).vhpicStruct.bp1 = para(i).vhpicStruct.n1.*(para(i).vhpicStruct.dp)^2./(4.*para(i).vhpicStruct.Din.*para(i).vhpicStruct.lp1);%������
%     l = para(i).vhpicStruct.lp1;
%      para(i).vhpicStruct.xSection1 = [0,ones(1,sectionNum1(i)).*(l/(sectionNum1(i)))];
% %     l = para(i).vhpicStruct.lp2;
% %     para(i).vhpicStruct.xSection2 = [0,ones(1,sectionNum1(i)).*(l/(sectionNum1(i)))];
%     para(i).sectionL1 = 0:0.5:para(i).L1;
%     para(i).sectionL2 = 0:0.5:para(i).L2;
    
    holepipeLength1 = para(i).vhpicStruct.Lin - para(i).vhpicStruct.la1 - para(i).vhpicStruct.la2;
    hl1 = sum(para(i).vhpicStruct.xSection1);
    if(~cmpfloat(holepipeLength1,hl1))
        error('�׹ܲ������ô���holepipeLength1=%.8f,hl1=%.8f;Lin:%g,la1:%g,la2:%g,sum(xSection1):%g,dp:%g'...
            ,holepipeLength1,hl1...
            ,para(i).vhpicStruct.Lin,para(i).vhpicStruct.la1,para(i).vhpicStruct.la2...
            ,sum(para(i).vhpicStruct.xSection1),para(i).vhpicStruct.dp);
    end
    name{i} = sprintf('n1:%g',variant_n1(i));
end

dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.3,0.7];
dcpss.fs = Fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������

for i = 1:length(para)
    pressure1Closed = [];
    pressure2Closed = [];

    [pressure1Closed,pressure2Closed] = ...
        vesselHaveInnerPerfBothClosedCompCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,para(i).Dpipe...
        ,para(i).vhpicStruct,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach,...
        'isOpening',isOpening);%,'coeffDamping',para(i).opt.coeffDamping,
    plus1Closed{i} = calcPuls(pressure1Closed,dcpss);
    plus2Closed{i} = calcPuls(pressure2Closed,dcpss);
    plusClosed{i} = [plus1Closed{i},plus2Closed{i}];
    multFreAmpValueClosed{i} = calcWaveFreAmplitude([pressure1Closed,pressure2Closed],Fs,multFre,'freErr',1);
    
    [pressure1Open,pressure2Open] = ...
        vesselHaveInnerPerfInCloOutOpenCompCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,para(i).Dpipe...
        ,para(i).vhpicStruct,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach...
        ,'isOpening',isOpening);%,'coeffDamping',opt.coeffDamping
    plus1Open{i} = calcPuls(pressure1Open,dcpss);
    plus2Open{i} = calcPuls(pressure2Open,dcpss);
    plusOpen{i} = [plus1Open{i},plus2Open{i}];
    multFreAmpValueOpend{i} = calcWaveFreAmplitude([pressure1Open,pressure2Open],Fs,multFre,'freErr',1);
    %���㻺������ÿ׹ܸ����ڲ��
%     if i == 1
%         [pressure1PI,pressure2PI] = vesselHavePerfInletNoneOutCalc(massFlowE,Fre,time,...
%             para(i).L1,para(i).L2,para(i).Dpipe...
%         ,para(i).vhpicStruct,...
%         para(i).sectionL1,para(i).sectionL2,...
%         'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
%         'meanFlowVelocity',para(i).opt.meanFlowVelocity,...
%         'm',para(i).opt.mach,'notMach',para(i).opt.notMach,...
%         'isOpening',isOpening);
%         plus1PI = calcPuls(pressure1PI,dcpss);
%         plus2PI = calcPuls(pressure2PI,dcpss);
%         plusPI = [plus1PI,plus2PI];
%         multFreAmpValue_PI{i} = calcWaveFreAmplitude([pressure1PI,pressure2PI],Fs,[10,20,30],'freErr',1);
%     end
    %���㵥һ�����
    if i == 1
        [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).vhpicStruct.Lv,para(i).vhpicStruct.l,para(i).Dpipe,para(i).vhpicStruct.Dv,...
            para(i).sectionL1,para(i).sectionL2,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
            'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
            'm',para(i).opt.mach,'notMach',para(i).opt.notMach,...
            'isOpening',isOpening);
        plus1OV = calcPuls(pressure1OV,dcpss);
        plus2OV = calcPuls(pressure2OV,dcpss);
        plusOV = [plus1OV,plus2OV];
        multFreAmpValue_OV{i} = calcWaveFreAmplitude([pressure1OV,pressure2OV],Fs,multFre,'freErr',1);
    end
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
    end
    %��������������
    temp = plusStraight;
    temp2 = plusClosed{i};

    temp(temp<1e-4) = 1;
    temp2(temp<1e-4) = 1;%tempС��1e-4ʱ��temp2Ҳ����Ϊ1.
    reduceRate{i} = (temp - temp2)./temp;

    if isempty(plus1Closed{i})
        maxPlus1(i) = nan;
    else
        maxPlus1(i) = max(plus1Closed{i});
    end

    if isempty(plus2Closed{i})
        maxPlus2(i) = nan;
    else
        maxPlus2(i) = max(plus2Closed{i});
    end  

end

%% ���Ʊտڵ�����άͼ
figure
hold on;
for i=1:iterateSize
	Z = plusClosed{i};
	if isXShowRealLength
        X = straightPipeSection;
    else
        X = 1:length(Z);
    end
    Y = ones(length(Z),1) .* variant_n1(i);
    plot3(X,Y,Z);
end
xlabel('����');
ylabel('����');
zlabel('����ѹ��');
title('�տ�');
view(17,44);
set(gcf,'color','w');
%% ���ƿ��ڵ�����άͼ
figure
hold on;
for i=1:iterateSize
	Z = plusOpen{i};
	if isXShowRealLength
        X = straightPipeSection;
    else
        X = 1:length(Z);
    end
    Y = ones(length(Z),1) .* variant_n1(i);
    plot3(X,Y,Z);
end
xlabel('����');
ylabel('����');
zlabel('����ѹ��');
title('����');
view(17,44);
set(gcf,'color','w');
% marker_style = {'-o','-d','-<','-s','->','-<','-p','-*','-v','-^','-+','-x','-h'};
% color_style = [...
%     245,18,103;...
%     36,100,196;...
%     18,175,134;...
%     237,144,10;... 
%     131,54,229;...
    
%     255,99,56;...
%     ]./255;
% market_style_length = length(marker_style);
% color_style_length = size(color_style,1);
% marker_index = 0;
% color_index = 0;

% figure
% marker_index = 0;
% color_index = 0;
% h = [];
% textLegend = {};
% hold on;
% plotCount = 1;

% for i = 1:length(para)
    
%     YClose = plusClosed{i};
%     YClose = YClose./1000;
%     YClose=YClose';
%     YOpen = plusOpen{i};
%     YOpen = YOpen./1000;
%     YOpen=YOpen';
%     if isXShowRealLength
%         X = straightPipeSection;
%     else
%         X = 1:length(YClose);
%     end
%     if i==1 
%         h(plotCount) = plot(X,plusStraight./1000,'-r','LineWidth',1.5);
%         textLegend{plotCount} = 'ֱ��';
%         plotCount = plotCount + 1;
%     end
%     if i==1
%         %��ʾ�����
%         h(plotCount) = plot(X,plusOV./1000,'-b','LineWidth',1.5);
%         textLegend{plotCount} = '��һ�����';
%         plotCount = plotCount + 1;
%     end
%     marker_index = marker_index + 1;
%     if marker_index > market_style_length
%         marker_index = 1;
%     end
%     color_index = color_index + 1;
%     if color_index > color_style_length
%         color_index = 1;
%     end
%     h(plotCount) = plot(X,YClose,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
%     textLegend{plotCount} = [name{i} '-close'];
%     plotCount = plotCount + 1;
%     marker_index = marker_index + 1;
%     if marker_index > market_style_length
%         marker_index = 1;
%     end
%     color_index = color_index + 1;
%     if color_index > color_style_length
%         color_index = 1;
%     end
    
%     h(plotCount) = plot(X,YOpen,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
%     textLegend{plotCount} = [name{i} '-open'];
%     plotCount = plotCount + 1;
% end
% legend(h,textLegend,0);
% set(gcf,'color','w');


% figure
% marker_index = 0;
% color_index = 0;
% h = [];
% textLegend = {};
% hold on;
% plotCount = 1;

% for i = 1:length(para)
%     marker_index = marker_index + 1;
%     if marker_index > market_style_length
%         marker_index = 1;
%     end
%     color_index = color_index + 1;
%     if color_index > color_style_length
%         color_index = 1;
%     end
%     YClose = multFreAmpValueClosed{i}(1,:);
%     YClose = YClose./1000;
%     YClose=YClose';
%     YOpen = multFreAmpValueOpend{i}(1,:);
%     YOpen = YOpen./1000;
%     YOpen=YOpen';
%     if isXShowRealLength
%         X = straightPipeSection;
%     else
%         X = 1:length(YClose);
%     end
%     if i==1 
%         h(plotCount) = plot(X,multFreAmpValue_straightPipe{i}(1,:)./1000,'-r','LineWidth',1.5);
%         textLegend{plotCount} = 'ֱ��';
%         plotCount = plotCount + 1;
%     end
%     if i==1
%         %��ʾ�����
%         h(plotCount) = plot(X,multFreAmpValue_OV{i}(1,:)./1000,'-b','LineWidth',1.5);
%         textLegend{plotCount} = '��һ�����';
%         plotCount = plotCount + 1;
%     end
%     if i==0
%         %��ʾ���ÿ׹ܸ����ڲ��
%         h(plotCount) = plot(X, multFreAmpValue_PI{i}(1,:)./1000,'-g','LineWidth',1.5);
%         textLegend{plotCount} = '���ÿ׹ܸ����ڲ��';
%         plotCount = plotCount + 1;
%     end
    
%     marker_index = marker_index + 1;
%     if marker_index > market_style_length
%         marker_index = 1;
%     end
%     color_index = color_index + 1;
%     if color_index > color_style_length
%         color_index = 1;
%     end
%     h(plotCount) = plot(X,YClose,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
%     textLegend{plotCount} = [name{i} '-close'];
%     plotCount = plotCount + 1;
    
%     marker_index = marker_index + 1;
%     if marker_index > market_style_length
%         marker_index = 1;
%     end
%     color_index = color_index + 1;
%     if color_index > color_style_length
%         color_index = 1;
%     end 
%     h(plotCount) = plot(X,YOpen,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
%     textLegend{plotCount} = [name{i} '-open'];
%     plotCount = plotCount + 1;
% end
% legend(h,textLegend,0);
% set(gcf,'color','w');