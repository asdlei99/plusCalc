%% 缓冲罐内置孔管结构与单一顺接缓冲罐对比
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%缓冲罐中间插入孔管,两端堵死，开孔个数不足以等效为亥姆霍兹共鸣器
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
% Lin 内插孔管入口段长度 
% Lout内插孔管出口段长度
% lc  孔管壁厚
% dp  孔管每一个孔孔径
% n1  孔管入口段开孔个数；    n2  孔管出口段开孔个数
% la1 孔管入口段距入口长度 
% la2 孔管入口段距隔板长度
% lb1 孔管出口段距隔板长度
% lb2 孔管出口段距开孔长度
% lp1 孔管入口段开孔长度
% lp2 孔管出口段开孔长度
% Din 孔管管径；
% xSection1，xSection2 孔管每圈孔的间距，从0开始算，x的长度为孔管孔的圈数+1，x的值是当前一圈孔和上一圈孔的距离，如果间距一样，那么x里的值都一样
isOpening = 0;%管道闭口
pr = 1.5;
% rpm = 300;multFre=[10,20,30];%环境25度绝热压缩到0.2MPaG的温度对应密度
 rpm = 420;multFre=[14,28,42];%环境25度绝热压缩到0.15MPaG的温度对应密度
Fs = 4096;
[massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,rpm...
	,0.14,1.075,1.293*pr,'rcv',0.15,'k',1.4,'pr',pr,'fs',Fs,'oneSecond',1);

%massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));

[FreRaw,AmpRaw,PhRaw,massFlowE] = frequencySpectrum(detrend(massFlowRaw,'constant'),Fs);
Fre = FreRaw;
% 提取主要频率
[pks,locs] = findpeaks(AmpRaw,'SORTSTR','descend');
Fre = FreRaw(locs);
massFlowE = massFlowE(locs);
temp = [1:20];%(Fre<29) ;%| (Fre>30 & Fre < 100);
Fre = Fre(temp);
massFlowE = massFlowE(temp);
isDamping = 1;
%绘图参数
isXShowRealLength = 1;
isShowStraightPipe=1;%是否显示直管
isShowOnlyVessel=1;%是否显示无内件缓冲罐

opt.frequency = 10;%脉动频率
opt.acousticVelocity = 345;%声速
opt.isDamping = isDamping;%是否计算阻尼
opt.coeffDamping = 0.1;%阻尼
opt.coeffFriction = 0.04;%管道摩察系数
% opt.meanFlowVelocity =14.5;%14.5;%管道平均流速
opt.isUseStaightPipe = 1;%计算容器传递矩阵的方法
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 0;

% variant_n1 = [68];              %variant_n = [6,6];sectionNum1 =[1,6];%对应孔1的组数sectionNum2 =[1,1];%对应孔2的组数
sectionNum1 =1;%对应孔1的组数
sectionNum2 =1;%对应孔2的组数
% variant_n2 = [68];
% variant_lp2 = [0.16];
variant_Lv = [0.55:0.05:1.15];

Vvessel = 0.12;

for i = 1:length(variant_Lv)
%%     
    para(i).opt = opt;
    para(i).L1 = 3;%L1(m)
    para(i).L2 = 6;%L2（m）长度
    para(i).Dpipe = 0.098;%管道直径（m）
    para(i).vhpicStruct.l = 0.01;
    para(i).vhpicStruct.Dv = (4*(Vvessel / variant_Lv(i))/pi)^0.5;%缓冲罐的直径（m）
    para(i).vhpicStruct.Lv = variant_Lv(i);%缓冲罐总长
%     para(i).vhpicStruct.lc = 0.005;%内插管壁厚
%     para(i).vhpicStruct.dp = 0.013;%开孔径
%     para(i).vhpicStruct.Lin = 0.25;%内插管入口段长度
%     para(i).vhpicStruct.lp1 = 0.16;%内插管入口段非孔管开孔长度
%     para(i).vhpicStruct.lp2 = 0.16;%内插管出口段孔管开孔长度
%     para(i).vhpicStruct.n1 = 68;%入口段孔数
%     para(i).vhpicStruct.n2 = 68;%出口段孔数
%     para(i).vhpicStruct.la1 = 0.03;%孔管入口段靠近入口长度
%     para(i).vhpicStruct.la2 = 0.06;%孔管
%     para(i).vhpicStruct.lb1 = 0.06;
%     para(i).vhpicStruct.lb2 = 0.03;
%     para(i).vhpicStruct.Din = 0.053;
%     para(i).vhpicStruct.Lout = 0.25;
%     l = para(i).vhpicStruct.lp1;
%     para(i).vhpicStruct.xSection1 = [0,ones(1,sectionNum1).*(l/(sectionNum1))];
%     l = para(i).vhpicStruct.lp2;
%     para(i).vhpicStruct.xSection2 = [0,ones(1,sectionNum2).*(l/(sectionNum2))];
    para(i).sectionL1 = 0:0.25:para(i).L1;
    para(i).sectionL2 = 0:0.25:para(i).L2;

    
%     holepipeLength1 = para(i).vhpicStruct.Lin - para(i).vhpicStruct.la1 - para(i).vhpicStruct.la2;
%     hl1 = sum(para(i).vhpicStruct.xSection1);
%     if(~cmpfloat(holepipeLength1,hl1))
%         error('孔管参数设置错误：holepipeLength1=%.8f,hl1=%.8f;Lin:%g,la1:%g,la2:%g,sum(xSection1):%g,dp:%g'...
%             ,holepipeLength1,hl1...
%             ,para(i).vhpicStruct.Lin,para(i).vhpicStruct.la1,para(i).vhpicStruct.la2...
%             ,sum(para(i).vhpicStruct.xSection1),para(i).vhpicStruct.dp);
%     end
%     name{i} = sprintf('n1:%g',variant_Lv(i));
end

dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.3,0.7];
dcpss.fs = Fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%通过频率5Hz
dcpss.f_stop = 5;%截止频率3Hz
dcpss.rp = 0.1;%边带区衰减DB数设置
dcpss.rs = 30;%截止区衰减DB数设置

dataCount = 2;
calcDatas{1,2} = 'x值';
calcDatas{1,3} = '压力脉动';
calcDatas{1,4} = '1倍频';
calcDatas{1,5} = '2倍频';
calcDatas{1,6} = '3倍频';
calcDatas{1,7} = '罐前压力脉动最大值';
calcDatas{1,8} = '罐后压力脉动最大值';
for i = 1:length(para)
    if i==1
        %计算直管
        %直管总长
        straightPipeLength = para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).L2;
        straightPipeSection = [para(i).sectionL1,...
                                para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).sectionL2];
        newSectionL2 = para(i).L1 + 2*para(i).vhpicStruct.l+para(i).vhpicStruct.Lv + para(i).sectionL2;
        temp = find(straightPipeLength>para(i).L1);%找到缓冲罐所在的索引
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
        calcDatas{dataCount,1} = sprintf('直管');
        calcDatas{dataCount,2} = X;
        calcDatas{dataCount,3} = plusStraight;
        calcDatas{dataCount,4} = multFreAmpValue_straightPipe{i}(1,:);
        calcDatas{dataCount,5} = multFreAmpValue_straightPipe{i}(2,:);
        calcDatas{dataCount,6} = multFreAmpValue_straightPipe{i}(3,:);
        calcDatas{dataCount,7} = maxPlus1Straight(i);
        calcDatas{dataCount,8} = maxPlus2Straight(i);
        dataCount = dataCount + 1;
    end
    
     %计算单一缓冲罐

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
        plusOV{i} = [plus1OV,plus2OV];
        if isempty(plus1OV)
            maxPlus1 = nan;
        else
            maxPlus1= max(plus1OV);
        end
        if isempty(plus2OV)
            maxPlus2 = nan;
        else
            maxPlus2 = max(plus2OV);
        end  
        
        multFreAmpValue_OV{i} = calcWaveFreAmplitude([pressure1OV,pressure2OV],Fs,multFre,'freErr',1);
        calcDatas{dataCount,1} = sprintf('单一缓冲罐,lv:%g',variant_Lv(i));
        calcDatas{dataCount,2} = X;
        calcDatas{dataCount,3} = plusOV{i};
        calcDatas{dataCount,4} = multFreAmpValue_OV{i}(1,:);
        calcDatas{dataCount,5} = multFreAmpValue_OV{i}(2,:);
        calcDatas{dataCount,6} = multFreAmpValue_OV{i}(3,:);
        calcDatas{dataCount,7} = maxPlus1;
        calcDatas{dataCount,8} = maxPlus2;
        dataCount = dataCount + 1;

    
   
 

end
ignoreHeader = 1;
figure 
plotDataCells(calcDatas,'xcol',2,'ycol',3,'legendcol',1,'ignoreHeader',ignoreHeader);
title('脉动压力峰峰值');
figure 
plotDataCells(calcDatas,'xcol',2,'ycol',4,'legendcol',1,'ignoreHeader',ignoreHeader);
title('1倍频');
figure 
plotDataCells(calcDatas,'xcol',2,'ycol',5,'legendcol',1,'ignoreHeader',ignoreHeader);
title('2倍频');

figure
plot(variant_Lv,cell2mat(calcDatas(3:1:end,7)));
xlabel('Lv(m)');ylabel('PP-pressure(Pa)');
title('直进直出缓冲罐-罐前脉动');
set(gcf,'color','w');
figure
plot(variant_Lv,cell2mat(calcDatas(3:1:end,8)));
xlabel('Lv(m)');ylabel('PP-pressure(Pa)');
title('直进直出缓冲罐-罐后脉动');
set(gcf,'color','w');
