%% �ڲ�ܽṹ��װ壬��һ����޶Ա�
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%����˫������ǻ������
%  ���� L1     l    Lv      l    L2  
%              ______________        
%             |     _|_  lout|      
%  -----------| lin _ _Din   |----------
%             |______|_______|       
% ֱ�� Dpipe       Dv       Dpipe 
%             |Linner| 
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
temp = (Fre<29) | (Fre>30 & Fre < 100);
Fre = Fre(temp);
massFlowE = massFlowE(temp);
isDamping = 1;
%��ͼ����
isXShowRealLength = 1;
isShowStraightPipe=1;%�Ƿ���ʾֱ��
isShowOnlyVessel=1;%�Ƿ���ʾ���ڼ������
inputData = [...
    %1    2  3     4   5   6     7          8      9     10
    %L1  ,L2,Dpipe,Dv ,l   ,Lv   ,Linner    ,Lin   ,Lout ,Din
    3.35,10,0.106,0.45,0.01,1.18 ,0.4     ,0.2  ,0.2  ,0.106*(3/4)
    3.35,10,0.106,0.45,0.01,1.18 ,0.6     ,0.2  ,0.2  ,0.106*(3/4)
    3.35,10,0.106,0.45,0.01,1.18 ,0.8     ,0.2  ,0.2  ,0.106*(3/4)
];%LinLout����Ϊ��

opt.frequency = 10;%����Ƶ��
opt.acousticVelocity = 345;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffDamping = 0.1;%����
opt.coeffFriction = 0.04;%�ܵ�Ħ��ϵ��
opt.meanFlowVelocity = 14.5;%�ܵ�ƽ������
opt.isUseStaightPipe = 0;%�����������ݾ���ķ���
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 1;
for i = 1:size(inputData,1)
    name{i} = sprintf('Linner:%g,Din:%g',inputData(i,7),inputData(i,10));
%     desp{i} = sprintf('L1:%g,L2:%g,Dpipe:%g,Dv:%g,l:%g,Lv:%g,Linner:%g,Lin:%g��Lout:%g��Din:%g'...
%         ,inputData(i,1),inputData(i,2),inputData(i,3),inputData(i,4)...
%         ,inputData(i,5),inputData(i,6),inputData(i,7),inputData(i,8)...
%         ,inputData(i,9),inputData(i,10));
    
    para(i).opt = opt;
    para(i).L1 = inputData(i,1);%L1(m)
    para(i).L2 = inputData(i,2);%������м����ӹܵ��ĳ��ȣ�m�� 
    para(i).Dpipe = inputData(i,3);%�ܵ�ֱ����m��
    para(i).Dv = inputData(i,4);
    para(i).l = inputData(i,5);%0.115;%�����ǰ�ܵ��ĳ���(m)   
    para(i).Lv = inputData(i,6);%[[0.157,0.25,0.5,0.75],[1:0.25:5]];%��һ������޵�ֱ����m��
    para(i).Linner = inputData(i,7);%0.5;%�ڶ�������޵�ֱ����m��
    para(i).Lin = inputData(i,8);
    para(i).Lout = inputData(i,9);%
    para(i).Din = inputData(i,10);%�װ���ڲ��ֱ��
    
    para(i).sectionL1 = 0:1:para(i).L1;
    para(i).sectionL2 = 0:1:para(i).L2;
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
    pressure1 = [];
    pressure2 = [];

    [pressure1,pressure2] = ...
        innerPipeVesselPulsationCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,...
        para(i).Lv,para(i).l,para(i).Dpipe,para(i).Dv,para(i).Din,...
        para(i).Linner,para(i).Lin,para(i).Lout,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,'isUseStaightPipe',1,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach);%,'coeffDamping',opt.coeffDamping
    plus1{i} = calcPuls(pressure1,dcpss);
    plus2{i} = calcPuls(pressure2,dcpss);
    plus{i} = [plus1{i},plus2{i}];
    
%������װ建���
    if i == 1
        [pressure1OrificeP,pressure2OrificeP] = ...
        vesselHaveOrificePulsationCalc(massFlowE,Fre,time,...
                para(i).L1,para(i).L2,...
                para(i).Linner,para(i).Lv-para(i).Linner,...
                para(i).l,para(i).Dpipe,para(i).Dv,para(i).Dv,para(i).Din,...
                para(i).sectionL1,para(i).sectionL2,...
                'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
                'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
                'm',para(i).opt.mach,'notMach',para(i).opt.notMach);
        plus1Orifice = calcPuls(pressure1OrificeP,dcpss);
        plus2Orifice = calcPuls(pressure2OrificeP,dcpss);
        plusOrifice = [plus1Orifice,plus2Orifice];
    end

    if i == 2
        [pressure1OrificeP2,pressure2OrificeP2] = ...
        vesselHaveOrificePulsationCalc(massFlowE,Fre,time,...
                para(i).L1,para(i).L2,...
                para(i).Linner,para(i).Lv-para(i).Linner,...
                para(i).l,para(i).Dpipe,para(i).Dv,para(i).Dv,para(i).Din,...
                para(i).sectionL1,para(i).sectionL2,...
                'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
                'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
                'm',para(i).opt.mach,'notMach',para(i).opt.notMach);
        plus1Orifice2 = calcPuls(pressure1OrificeP2,dcpss);
        plus2Orifice2 = calcPuls(pressure2OrificeP2,dcpss);
        plusOrifice2 = [plus1Orifice2,plus2Orifice2];
    end
    
    if i == 3
        [pressure1OrificeP3,pressure2OrificeP3] = ...
        vesselHaveOrificePulsationCalc(massFlowE,Fre,time,...
                para(i).L1,para(i).L2,...
                para(i).Linner,para(i).Lv-para(i).Linner,...
                para(i).l,para(i).Dpipe,para(i).Dv,para(i).Dv,para(i).Din,...
                para(i).sectionL1,para(i).sectionL2,...
                'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
                'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
                'm',para(i).opt.mach,'notMach',para(i).opt.notMach);
        plus1Orifice3 = calcPuls(pressure1OrificeP3,dcpss);
        plus2Orifice3 = calcPuls(pressure2OrificeP3,dcpss);
        plusOrifice3 = [plus1Orifice3,plus2Orifice3];
    end
    %���㵥һ�����
    if i == 1
        [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).Lv,para(i).l,para(i).Dpipe,para(i).Dv,...
            para(i).sectionL1,para(i).sectionL2,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
            'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
            'm',para(i).opt.mach,'notMach',para(i).opt.notMach);
        plus1OV = calcPuls(pressure1OV,dcpss);
        plus2OV = calcPuls(pressure2OV,dcpss);
        plusOV = [plus1OV,plus2OV];
    end
    if i==1
        %����ֱ��
        %ֱ���ܳ�
        straightPipeLength = para(i).L1 + 2*para(i).l+para(i).Lv + para(i).L2;
        straightPipeSection = [para(i).sectionL1,...
                                para(i).L1 + 2*para(i).l+para(i).Lv + para(i).sectionL2];
        newSectionL2 = para(i).L1 + 2*para(i).l+para(i).Lv + para(i).sectionL2;
        temp = find(straightPipeLength>para(i).L1);%�ҵ���������ڵ�����
        sepratorIndex = temp(1);
        temp = straightPipePulsationCalc(massFlowE,Fre,time,straightPipeLength,straightPipeSection...
        ,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping...
        ,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity...
        ,'m',para(i).opt.mach,'notMach',para(i).opt.notMach...
        );
        plusStraight = calcPuls(temp,dcpss);
        maxPlus1Straight(i) = max(plusStraight(1:sepratorIndex));
        maxPlus2Straight(i) = max(plusStraight(sepratorIndex:end));
        vesselRangeStartLength = para(i).L1;
        vesselRangeEndLength = para(i).L1 + 2*para(i).l+para(i).Lv;
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
%���������������Ʊ�
for i = 1:length(para)
    compare_with_straight{i} =  (plusStraight - plus{i})./plusStraight;
    compare_with_surge_volume{i} = (plusOV - plus{i})./plusOV;
end

marker_style = {'-o','-d','-<','-s','->','-<','-p','-*','-v','-^','-+','-x','-h'};
color_style = [...
    245,18,103;...
    36,100,196;...
    18,175,134;...
    237,144,10;... 
    131,54,229;...
    
    255,99,56;...
    ]./255;
market_style_length = length(marker_style);
color_style_length = size(color_style,1);
marker_index = 0;
color_index = 0;

figure
marker_index = 0;
color_index = 0;
h = [];
textLegend = {};
hold on;
plotCount = 1;

for i = 1:length(para)
    marker_index = marker_index + 1;
    if marker_index > market_style_length
        marker_index = 1;
    end
    color_index = color_index + 1;
    if color_index > color_style_length
        color_index = 1;
    end
    Y = plus{i};
    Y = Y./1000;
    Y=Y';
    if isXShowRealLength
        X = straightPipeSection;
    else
        X = 1:length(Y);
    end
    if i==1 
        h(plotCount) = plot(X,plusStraight./1000,'-r','LineWidth',1.5);
        textLegend{plotCount} = 'ֱ��';
        plotCount = plotCount + 1;
    end
    if i==1
        %��ʾ�����
        h(plotCount) = plot(X,plusOV./1000,'-b','LineWidth',1.5);
        textLegend{plotCount} = '��һ�����';
        plotCount = plotCount + 1;
    end
    if i==1
        %��ʾ�װ�
        h(plotCount) = plot(X,plusOrifice./1000,':r','LineWidth',1.5);
        textLegend{plotCount} = '��������ÿװ�(Linner0.4)';
        plotCount = plotCount + 1;
    end
    if i==1
        %��ʾ�װ�
        h(plotCount) = plot(X,plusOrifice2./1000,':b','LineWidth',1.5);
        textLegend{plotCount} = '��������ÿװ�(Linner0.6)';
        plotCount = plotCount + 1;
    end
    if i==1
        %��ʾ�װ�
        h(plotCount) = plot(X,plusOrifice3./1000,':g','LineWidth',1.5);
        textLegend{plotCount} = '��������ÿװ�(Linner0.8)';
        plotCount = plotCount + 1;
    end
    h(plotCount) = plot(X,Y,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
    textLegend{plotCount} = name{i};
    plotCount = plotCount + 1;
    
end
ax = axis;
fill([vesselRangeStartLength,vesselRangeEndLength,vesselRangeEndLength,vesselRangeStartLength,vesselRangeStartLength]...
    ,[ax(3),ax(3),ax(4),ax(4),ax(3)],'r','FaceColor','r','FaceAlpha',0.2...
    ,'EdgeColor','r','EdgeAlpha',0.5);
box on;
axis on;
legend(h,textLegend,0);
set(gcf,'color','w');
xlabel('����/m');
ylabel('ѹ���������ֵ/kPa');
box on;
grid on;
set(gcf,'Units','pixels','position',[200,200,550,350]);
axis on;
%set(gca,'Units','pixels','position',[65,40,230,190]);
%set(hl,'Units','pixels','position',[130,110,165,42]);


figure
marker_index = 0;
color_index = 0;
h = [];
textLegend = {};
hold on;
plotCount = 1;
for i = 1:length(para)
    marker_index = marker_index + 1;
    if marker_index > market_style_length
        marker_index = 1;
    end
    color_index = color_index + 1;
    if color_index > color_style_length
        color_index = 1;
    end
    Y = compare_with_straight{i};
    Y = Y.*100;
    Y(Y<-300) = 0;
    Y(Y>300) = 0;
    if isXShowRealLength
        X = straightPipeSection;
    else
        X = 1:length(Y);
    end
    h(plotCount) = plot(X,Y,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
    textLegend{plotCount} = name{i};
    plotCount = plotCount + 1;
    
end
title('compare with straight')
legend(h,textLegend,0);
set(gcf,'color','w');

figure
marker_index = 0;
color_index = 0;
h = [];
textLegend = {};
hold on;
plotCount = 1;
for i = 1:length(para)
    marker_index = marker_index + 1;
    if marker_index > market_style_length
        marker_index = 1;
    end
    color_index = color_index + 1;
    if color_index > color_style_length
        color_index = 1;
    end
    Y = compare_with_surge_volume{i};
    Y = Y.*100;
    Y(Y<-50) = 0;
    Y(Y>100) = 0;
    if isXShowRealLength
        X = straightPipeSection;
    else
        X = 1:length(Y);
    end
    h(plotCount) = plot(X,Y,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
    textLegend{plotCount} = name{i};
    plotCount = plotCount + 1;
    
end
title('compare with surge volume')
legend(h,textLegend,0);
set(gcf,'color','w');