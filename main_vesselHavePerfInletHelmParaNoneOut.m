%% ��������ÿ׹ܽṹ�뵥һ˳�ӻ���޶Ա�
%���ÿ׹ܵ���ڲ��ֻ���һ�ܿ��ף���ЧΪ��ķ���ȹ����������ڲ��ֲ����ף���Ϊ�ڲ��
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%�������������ӿ׹�,Lin���ֵ�ЧΪ��ķ���ȹ�����.Lout����Ϊ�ڲ忪�ڹܣ�������
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             | lc dp(n1) |                     |
%             |___ _ _ ___|___________          |     
%  -----------|___ _ _ ___ ___________ Din      |----------
%             |la1 lp1 la2|                     |
%             |___________|_____________________|       
%                  Lin         Lout
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
% V  ��ķ���ȹ�������� V=(Sv-S)*Lin
% lv ��Ч�������� V./((pi*Lin^2)./4)����һ����Ч׼ȷ��
% xSection1��xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��

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

opt.frequency = 10;%����Ƶ��
opt.acousticVelocity = 345;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffDamping = 0.1;%����
opt.coeffFriction = 0.04;%�ܵ�Ħ��ϵ��
opt.meanFlowVelocity = 14.5;%�ܵ�ƽ������
opt.isUseStaightPipe = 1;%�����������ݾ���ķ���
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 0;

variant_n1 = [4];              %variant_n = [6,6];sectionNum1 =[1,6];%��Ӧ��1������sectionNum2 =[1,1];%��Ӧ��2������
sectionNum1 =[1];%��Ӧ��1������
% sectionNum2 =[4];%��Ӧ��2������
% variant_n2 = [4];
% variant_lp2 = [0.16];
%  variant_lv = [5,1.5,0.955,0.5,0.25];
% variant_V = [0.01];%��Ч���Ϊ0.01ʱ����ͨ�׹ܾ���ļ�������Ϊ�ӽ�
% variant_dp = [0.02];
variant_lc = [0.005,0.2,0.3,0.4,0.5,0.6];%�൱�ڽ��׹ܵĿ׸�Ϊ�ڲ�Сϸ��

for i = 1:length(variant_lc)
    
    para(i).opt = opt;
    para(i).L1 = 3.85;%L1(m)
    para(i).L2 = 3;%L2��m������
    para(i).Dpipe = 0.106;%�ܵ�ֱ����m��
    para(i).vhpicStruct.l = 0.01;
    para(i).vhpicStruct.Dv = 0.45;%����޵�ֱ����m��
    para(i).vhpicStruct.Lv = 1.18;%������ܳ�
    para(i).vhpicStruct.lc = variant_lc(i);%�ڲ�ܱں�
    para(i).vhpicStruct.dp = 0.02;%���׾�
    para(i).vhpicStruct.Lin = 0.2;%�ڲ����ڶγ���
    para(i).vhpicStruct.lp1 = 0.04;%�ڲ����ڶγ���
%     para(i).vhpicStruct.lp2 = variant_lp2(i);%�ڲ�ܳ��ڶηǿ׹ܿ��׳���
    para(i).vhpicStruct.n1 = 4;%��ڶο���
%     para(i).vhpicStruct.n2 = variant_n2(i);%���ڶο���
    para(i).vhpicStruct.la1 = 0.01;%�׹���ڶο�����ڳ���
    para(i).vhpicStruct.la2 = 0.15;%�׹�
%     para(i).vhpicStruct.lb1 = 0.03;
%     para(i).vhpicStruct.lb2 = 0.01;
    para(i).vhpicStruct.Din = 0.106;
    para(i).vhpicStruct.Lout = 0.2;
    para(i).vhpicStruct.V = 0.01;%(pi.*para(i).vhpicStruct.Dv.^2./4-pi.*para(i).vhpicStruct.Din.^2./4)*para(i).vhpicStruct.Lin;  %0.03
    para(i).vhpicStruct.lv = 0.995;
    para(i).vhpicStruct.bp1 = para(i).vhpicStruct.n1.*(para(i).vhpicStruct.dp)^2./(4.*para(i).vhpicStruct.Din.*para(i).vhpicStruct.lp1);%������
    l = para(i).vhpicStruct.lp1;
%     para(i).vhpicStruct.xSection1 = [0,ones(1,sectionNum1(i)).*(l/(sectionNum1(i)))];
    para(i).vhpicStruct.xSection1 = [0,ones(1,4).*(l/(4))];
%     l = para(i).vhpicStruct.lp2;
%     para(i).vhpicStruct.xSection2 = [0,ones(1,sectionNum2(i)).*(l/(sectionNum2(i)))];
%     para(i).vhpicStruct.xSection2
    para(i).sectionL1 = 0:0.5:para(i).L1;
    para(i).sectionL2 = 0:0.5:para(i).L2;
    
    holepipeLength1 = para(i).vhpicStruct.Lin - para(i).vhpicStruct.la1 - para(i).vhpicStruct.la2;
    hl1 = sum(para(i).vhpicStruct.xSection1);
    if(~cmpfloat(holepipeLength1,hl1))
        error('�׹ܲ������ô���holepipeLength1=%.8f,hl1=%.8f;Lin:%g,la1:%g,la2:%g,sum(xSection1):%g,dp:%g'...
            ,holepipeLength1,hl1...
            ,para(i).vhpicStruct.Lin,para(i).vhpicStruct.la1,para(i).vhpicStruct.la2...
            ,sum(para(i).vhpicStruct.xSection1),para(i).vhpicStruct.dp);
    end
    
%     holepipeLength2 = para(i).vhpicStruct.Lout - para(i).vhpicStruct.lb1 - para(i).vhpicStruct.lb2;
%     hl2 = sum(para(i).vhpicStruct.xSection2);
%     if(holepipeLength2 ~= hl2)
%         error('�׹ܲ������ô���holepipeLength2=%g,hl2=%g;Lout:%g,lb1:%g,lb2:%g,sum(xSection2):%g,dp:%g'...
%             ,holepipeLength2,hl2...
%             ,para(i).vhpicStruct.Lout,para(i).vhpicStruct.lb1,para(i).vhpicStruct.lb2...
%             ,sum(para(i).vhpicStruct.xSection2),para(i).vhpicStruct.dp);
%     end
    name{i} = sprintf('lc:%g',variant_lc(i));
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
        vesselHavePerfInletHelmParaNoneOutCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,para(i).Dpipe...
        ,para(i).vhpicStruct,...
        para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',para(i).opt.coeffFriction,...
        'meanFlowVelocity',para(i).opt.meanFlowVelocity,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach);%,'coeffDamping',opt.coeffDamping
    plus1{i} = calcPuls(pressure1,dcpss);
    plus2{i} = calcPuls(pressure2,dcpss);
    plus{i} = [plus1{i},plus2{i}];
    

    %���㵥һ�����
    if i == 1
        [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).vhpicStruct.Lv,para(i).vhpicStruct.l,para(i).Dpipe,para(i).vhpicStruct.Dv,...
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
        straightPipeLength = para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).L2;
        straightPipeSection = [para(i).sectionL1,...
                                para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).sectionL2];
        newSectionL2 = para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).sectionL2;
        temp = find(straightPipeLength>para(i).L1);%�ҵ���������ڵ�����
        sepratorIndex = temp(1);
        temp = straightPipePulsationCalc(massFlowE,Fre,time,straightPipeLength,straightPipeSection...
        ,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping...
        ,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity...
        ,'m',para(i).opt.mach,'notMach',para(i).opt.notMach...
        );
        plusStraight = calcPuls(temp,dcpss);
        maxPlus1Straight(i) = max(plusStraight(1:sepratorIndex(i)));
        maxPlus2Straight(i) = max(plusStraight(sepratorIndex(i):end));
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

    h(plotCount) = plot(X,Y,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
    textLegend{plotCount} = name{i};
    plotCount = plotCount + 1;
    
end
legend(h,textLegend,0);
set(gcf,'color','w');

figure
Y = maxPlus1;
Y = Y./1000;
X = 1:length(Y);
hBar = bar(X,Y);
set(gca,'XTickLabel',name);
set(gcf,'color','w');

figure
Y = maxPlus2;
Y = Y./1000;
X = 1:length(Y);
hBar = bar(X,Y);
set(gca,'XTickLabel',name);
set(gcf,'color','w');