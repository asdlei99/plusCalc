%% 双容间距变化对比
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%  长度 L1     l    Lv1   l   L2  l    Lv2   l     L3
%              __________         __________
%             |          |       |          |
%  -----------|          |-------|          |-------------
%             |__________|       |__________|  
%  直径 Dpipe       Dv1    Dpipe       Dv2          Dpipe
%% 质量流量获取
massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));
time = massFlow(:,1);
massFlow = massFlow(:,2);
[~,index] = intersect(time,0:0.005:2);%稀疏
massFlow = massFlow(1:4096);
massFlowE1 = fft(detrend(massFlow));

%% 基本参数设置

isSaveXls = 0;
isXLength = 1;%如果X轴是距离将会按照实际尺寸来绘制。
isShowStraightPipe = 0;%是否加入直管对比
titleText = '进口管长1m总长26米，两缓冲罐间距不同对脉动的影响';
isShowL2Plus = 1;%不显示L2的脉动
isDamping = 1;
%%
inputData = [...
    %1  2  3  4     5   6   7  8  9  
    %L1,L2,L3,Dpipe,Dv1,Dv2,l,Lv1,Lv2
     13,0,13,0.157,0.5,0.5,0.115,1,1 ...
    ;13,0.5,13,0.157,0.5,0.5,0.115,1,1 ...
    ;13,0.9,13,0.157,0.5,0.5,0.115,1,1 ...
    ;13,2.5,13,0.157,0.5,0.5,0.115,1,1 ...
    ;13,4,13,0.157,0.5,0.5,0.115,1,1 ...
    ;13,5.5,13,0.157,0.5,0.5,0.115,1,1 ...
    
%  1,0.25,25.75,0.157,0.5,0.5,0.115,1,1 ...
% ;1,2.25,23.75,0.157,0.5,0.5,0.115,1,1 ...
% ;1,5,21,0.157,0.5,0.5,0.115,1,1 ...
% ;1,7.75,18.25,0.157,0.5,0.5,0.115,1,1 ...
% ;1,9.75,16.25,0.157,0.5,0.5,0.115,1,1 ...
% ;1,12,14,0.157,0.5,0.5,0.115,1,1 ...
% ;1,13.75,12.25,0.157,0.5,0.5,0.115,1,1 ...
% ;1,20,6,0.157,0.5,0.5,0.115,1,1 ...
%%

];
for i=1:size(inputData,1)
    xTick(i) = inputData(i,2);
    xTickLabel{i} = sprintf('间距%gm',inputData(i,2));
end
opt.frequency = 10;%脉动频率
opt.acousticVelocity = 345;%声速
opt.isDamping = isDamping;%是否计算阻尼
opt.coeffFriction = 0.03;%管道摩察系数
opt.meanFlowVelocity = 14.6;%管道平均流速
opt.isUseStaightPipe = 0;%计算容器传递矩阵的方法

for i = 1:size(inputData,1)
    name{i} = sprintf('L1:%g,L2:%g,L3:%g',inputData(i,1),inputData(i,2),inputData(i,3));
    desp{i} = sprintf('L1:%g,L2:%g,L3:%g,Dpipe:%g,Dv1:%g,Dv2:%g,l:%g,Lv1:%g,Lv2:%g'...
        ,inputData(i,1),inputData(i,2),inputData(i,3),inputData(i,4),inputData(i,5)...
        ,inputData(i,6),inputData(i,7),inputData(i,8),inputData(i,9));
    
    para(i).opt = opt;
    para(i).L1 = inputData(i,1);%L1(m)
    para(i).L2 = inputData(i,2);%缓冲罐中间连接管道的长度（m）
    para(i).L3 = inputData(i,3);
    para(i).Dpipe = inputData(i,4);%管道直径（m）
    para(i).Dv1 = inputData(i,5);
    para(i).Dv2 = inputData(i,6);    
    para(i).l = inputData(i,7);%0.115;%缓冲罐前管道的长度(m)   
    para(i).Lv1 = inputData(i,8);%[[0.157,0.25,0.5,0.75],[1:0.25:5]];%第一个缓冲罐的直径（m）
    para(i).Lv2 = inputData(i,9);%0.5;%第二个缓冲罐的直径（m）
    
    para(i).sectionL1 = 0:1:para(i).L1;
    para(i).sectionL2 = 0:1:para(i).L2;
    para(i).sectionL3 = 0:1:para(i).L3;

end
% L2 = totalLength-L1;
% sectionL1 = 0:L1;
% sectionL2 = 0:L2;
%% 计算不同缓冲罐间隔下的脉动压力
% [oneVesselPlusL1,oneVesselPlusL2] = fun_oneTank(massFlowE1,L1,L2,Lv,l,Dpipe,Dv,opt,sectionL1,sectionL2);

% maxL1 = max(oneVesselPlusL1);
% maxL2 = max(oneVesselPlusL2);
xlsDataToBeWrite = {};

for i = 1:length(para)
    pressure1 = [];
    pressure2 = [];
    pressure3 = [];
    [plus1{i},plus2{i},plus3{i},pressure1,pressure2,pressure3] = ...
        fun_doubleTank(massFlowE1,para(i).L1,para(i).L2,para(i).L3,...
        para(i).Lv1,para(i).Lv2,para(i).l,para(i).Dpipe,para(i).Dv1,para(i).Dv2,...
        para(i).opt,para(i).sectionL1,para(i).sectionL2,para(i).sectionL3);
    plus{i} = [plus1{i},plus2{i},plus3{i}];
    if isSaveXls
        tableHeader = {};
        for k=1:length(para(i).sectionL1)
            tableHeader = cellPush2Right(tableHeader,{sprintf('L1:%g',para(i).sectionL1(k))});
        end
        for k=1:length(para(i).sectionL2)
            tableHeader = cellPush2Right(tableHeader,{sprintf('L2:%g',para(i).sectionL2(k))});
        end
        for k=1:length(para(i).sectionL3)
            tableHeader = cellPush2Right(tableHeader,{sprintf('L3:%g',para(i).sectionL3(k))});
        end
        xlsDataToBeWrite = toOneCell(tableHeader,pressure1,pressure2,pressure3);
        xlswrite(fullfile(currentPath,[name{i},'.xls']),xlsDataToBeWrite);
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

    if isempty(plus3{i})
        maxPlus3(i) = nan;
    else
        maxPlus3(i) = max(plus3{i});
    end
    
    newSectionL2 = para(i).L1 + 2*para(i).l+para(i).Lv1 + para(i).sectionL2;
    newSectionL3 = para(i).L1+4*para(i).l+para(i).Lv1+para(i).Lv2+para(i).L2 + para(i).sectionL3;
    realLengthSection{i} = [para(i).sectionL1,newSectionL2,newSectionL3];

    L_straight(i) = para(i).L1 + para(i).L2 + para(i).L3 + para(i).Lv1 + para(i).Lv2 + 4*para(i).l;
    temp = find(realLengthSection{i}>para(i).L1);
    sepratorIndex(i) = temp(1);
    temp = fun_straightPipe(massFlowE1,L_straight(i),para(i).Dpipe,para(i).opt,realLengthSection{i});
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
if isShowStraightPipe
    maxPlus1 = [maxPlus1Straight(1,:);maxPlus1];
    maxPlus3 = [maxPlus3Straight(1,:);maxPlus3];
end

%% 绘图
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
if isShowStraightPipe
    h(1) = plot(sectionL{i},plusStraight{i}./1000,'-r','LineWidth',1.5);
    textLegend = ['直管',name{i}];
else
    textLegend = name;
end
for i = 1:length(para)
    marker_index = marker_index + 1;
    if marker_index > market_style_length
        marker_index = 1;
    end
    color_index = color_index + 1;
    if color_index > color_style_length
        color_index = 1;
    end
    if isShowL2Plus
        Y = plus{i};
    else
        Y = [plus1{i},plus3{i}];
    end
    Y = Y./1000;
    Y=Y';
    if isXLength
        newSectionL2 = para(i).L1 + 2*para(i).l+para(i).Lv1 + para(i).sectionL2;
        newSectionL3 = para(i).L1+4*para(i).l+para(i).Lv1+para(i).Lv2+para(i).L2 + para(i).sectionL3;
        if isShowL2Plus
            X = realLengthSection{i};
        else
            X = [para(i).sectionL1,newSectionL3];
        end
    else
        X = 1:length(Y);
    end
    if isShowStraightPipe
        h(i+1) = plot(X,Y,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
    else
        h(i) = plot(X,Y,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
    end
end
legend(h,textLegend,0);
grid on;
if isXLength
    xlabel('距离(m)');
else
    xlabel('测点');
end
ylabel('脉动压力峰峰值(kPa)');
title(titleText);
set(gcf,'color','w');


h = [];
marker_index = 1;
color_index = 1;    
barMaxPlusBefore = maxPlus1./1000;
barMaxPlusMiddle = maxPlus2./1000;
barMaxPlusAfter = maxPlus3./1000;  
figure
hold on;
if isempty(xTick)
    X = 1:length(para); 
else
    X = xTick;
end
h(1) = plot(X,barMaxPlusBefore,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
% h(2) = plot([X(1),X(end)],[maxL1./1000,maxL1./1000],'-','color',color_style(color_index,:));
marker_index = 2;
color_index = 2; 
h(3) = plot(X,barMaxPlusAfter,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
% h(4) = plot([X(1),X(end)],[maxL2./1000,maxL2./1000],'-','color',color_style(color_index,:));
marker_index = 3;
color_index = 3; 
h(5) = plot(X,barMaxPlusMiddle,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
title('缓冲罐间隔对气流脉动的影响');
ylabel('脉动压力最大值(kPa)');
xlabel('缓冲罐间距(m)');
if isempty(xTick)
    set(gca,'XTick',0:size(inputData,1));
    set(gca,'XTickLabel',xTickLabel);
end
legend(h,{'缓冲罐前管道脉动最大值','单缓冲罐前管道脉动最大值','缓冲罐后管道脉动最大值','单缓冲罐后管道脉动最大值','连接管道脉动最大值'});
grid on;
set(gcf,'color','w');

% close all;
% simulationL1Max = [4.603,5.695,8.266,7.92,4.14,4.933];
% simulationL3Max = [3.364,5.167,6.583,6.589,10.06,3.601];
% 
% 
% figure
% 
% subplot(1,2,1)
% h = [];
% X = sec;
% hold on;
% h(1) = plot(X,barMaxPlusBefore,'color',[191,191,191]./255,'LineWidth',2);
% h(2) = plot(X,simulationL1Max,'color',[46,77,234]./255,'LineWidth',2);
% ylabel('maximum pulsating pressure(kPa)');
% xlabel('distance between buffer tank(m)');
% legend(h,{'theory data','simulation data'});
% title('pre buffer tank pipeline');
% grid on;
% 
% subplot(1,2,2)
% h = [];
% X = sec;
% hold on;
% h(1) = plot(X,barMaxPlusAfter,'color',[191,191,191]./255,'LineWidth',2);
% h(2) = plot(X,simulationL3Max,'color',[255,31,70]./255,'LineWidth',2);
% ylabel('maximum pulsating pressure(kPa)');
% xlabel('distance between buffer tank(m)');
% legend(h,{'theory data','simulation data'});
% title('after buffer tank pipeline');
% grid on;
% set(gcf,'color','w');

