%% ˫�ݼ��仯�Ա�
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%  ���� L1     l    Lv1   l   L2  l    Lv2   l     L3
%              __________         __________
%             |          |       |          |
%  -----------|          |-------|          |-------------
%             |__________|       |__________|  
%  ֱ�� Dpipe       Dv1    Dpipe       Dv2          Dpipe
%% ����������ȡ

[time,massFlow,Fre,massFlowE ] = getMassFlowData('N',4096,'isfindpeaks',1);
Fs = 1/(time(2)-time(1));

% ��ȡ��ҪƵ��
temp = Fre<60;%Fre<20 | (Fre>22&Fre<60);%(Fre<24) | (Fre>30 & Fre < 40);
Fre = Fre(temp);
massFlowE = massFlowE(temp);
multFre=[10,20,30];
%% ������������
isXShowRealLength = 1;
isSaveXls = 0;
isXLength = 1;%���X���Ǿ��뽫�ᰴ��ʵ�ʳߴ������ơ�
isShowStraightPipe = 1;%�Ƿ����ֱ�ܶԱ�
titleText = '���ڹܳ�1m�ܳ�26�ף�������޼�಻ͬ��������Ӱ��';
isShowL2Plus = 0;%����ʾL2������
isDamping = 1;
%%
inputData = [...
    %1  2  3  4     5   6   7  8  9  
    %L1,L2,L3,Dpipe,Dv1,Dv2,l,Lv1,Lv2
     15,0,13,0.157,0.5,0.5,0.115,1,1 ...
  %  ;13,0.5,13,0.157,0.5,0.5,0.115,1,1 ...
  %  ;13,0.9,13,0.157,0.5,0.5,0.115,1,1 ...
%     ;13,2.5,13,0.157,0.5,0.5,0.115,1,1 ...
%     ;13,4,13,0.157,0.5,0.5,0.115,1,1 ...
%     ;13,5.5,13,0.157,0.5,0.5,0.115,1,1 ...
    
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
    xTickLabel{i} = sprintf('���%gm',inputData(i,2));
end
opt.frequency = 10;%����Ƶ��
opt.acousticVelocity = 345;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffFriction = 0.03;%�ܵ�Ħ��ϵ��
opt.meanFlowVelocity = 14.6;%�ܵ�ƽ������
opt.isUseStaightPipe = 0;%�����������ݾ���ķ���

for i = 1:size(inputData,1)
    name{i} = sprintf('L1:%g,L2:%g,L3:%g',inputData(i,1),inputData(i,2),inputData(i,3));
    desp{i} = sprintf('L1:%g,L2:%g,L3:%g,Dpipe:%g,Dv1:%g,Dv2:%g,l:%g,Lv1:%g,Lv2:%g'...
        ,inputData(i,1),inputData(i,2),inputData(i,3),inputData(i,4),inputData(i,5)...
        ,inputData(i,6),inputData(i,7),inputData(i,8),inputData(i,9));
    
    para(i).opt = opt;
    para(i).L1 = inputData(i,1);%L1(m)
    para(i).L2 = inputData(i,2);%������м����ӹܵ��ĳ��ȣ�m��
    para(i).L3 = inputData(i,3);
    para(i).Dpipe = inputData(i,4);%�ܵ�ֱ����m��
    para(i).Dv1 = inputData(i,5);
    para(i).Dv2 = inputData(i,6);    
    para(i).l = inputData(i,7);%0.115;%�����ǰ�ܵ��ĳ���(m)   
    para(i).Lv1 = inputData(i,8);%[[0.157,0.25,0.5,0.75],[1:0.25:5]];%��һ������޵�ֱ����m��
    para(i).Lv2 = inputData(i,9);%0.5;%�ڶ�������޵�ֱ����m��
    
    para(i).sectionL1 = 0:1:para(i).L1;
    para(i).sectionL2 = 0:1:para(i).L2;
    para(i).sectionL3 = 0:1:para(i).L3;

end
% L2 = totalLength-L1;
% sectionL1 = 0:L1;
% sectionL2 = 0:L2;
%% ���㲻ͬ����޼���µ�����ѹ��
% [oneVesselPlusL1,oneVesselPlusL2] = fun_oneTank(massFlowE1,L1,L2,Lv,l,Dpipe,Dv,opt,sectionL1,sectionL2);

% maxL1 = max(oneVesselPlusL1);
% maxL2 = max(oneVesselPlusL2);
xlsDataToBeWrite = {};

dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.5,0.6];
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
    %����ֱ��
    newSectionL2 = para(i).L1 + 2*para(i).l+para(i).Lv1 + para(i).sectionL2;
    newSectionL3 = para(i).L1+4*para(i).l+para(i).Lv1+para(i).Lv2+para(i).L2 + para(i).sectionL3;
    realLengthSection{i} = [para(i).sectionL1,newSectionL2,newSectionL3];

    L_straight(i) = para(i).L1 + para(i).L2 + para(i).L3 + para(i).Lv1 + para(i).Lv2 + 4*para(i).l;
    temp = find(realLengthSection{i}>para(i).L1);
    sepratorIndex(i) = temp(1);
    %temp = fun_straightPipe(massFlowE1,L_straight(i),para(i).Dpipe,para(i).opt,realLengthSection{i});
    pressureStraight = straightPipePulsationCalc(massFlowE,Fre,time,L_straight(i),realLengthSection{i}...
	,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity);
    temp = calcPuls(pressureStraight,dcpss);
    maxPlus1Straight(i) = max(temp(1:sepratorIndex(i)));
    maxPlus3Straight(i) = max(temp(sepratorIndex(i):end));
    multFreAmpValue_straightPipe{i} = calcWaveFreAmplitude(pressureStraight,Fs,multFre,'freErr',1);
    plusStraight{i} = temp;
    if isXShowRealLength
        X = realLengthSection{i};
    else
        X = 1:length(plusStraight{i});
    end
    calcDatas{dataCount,1} = sprintf('ֱ��-%gm',L_straight(i));
    calcDatas{dataCount,2} = X;
    calcDatas{dataCount,3} = plusStraight{i};
    calcDatas{dataCount,4} = multFreAmpValue_straightPipe{i}(1,:);
    calcDatas{dataCount,5} = multFreAmpValue_straightPipe{i}(2,:);
    calcDatas{dataCount,6} = multFreAmpValue_straightPipe{i}(3,:);
    dataCount = dataCount + 1;
        
%     temp2 = plus{i};
%     temp(temp<1e-4) = 1;
%     temp2(temp2<1e-4) = 1;
%     reduceRate{i} = (temp - temp2)./temp;

    
    pressure1 = [];
    pressure2 = [];
    pressure3 = [];
    [pressure1,pressure2,pressure3] = ...
        doubleVesselPulsationCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,para(i).L3,...
        para(i).Lv1,para(i).Lv2,para(i).l,para(i).Dpipe,para(i).Dv1,para(i).Dv2,...
        para(i).sectionL1,para(i).sectionL2,para(i).sectionL3,...
        'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
        'meanFlowVelocity',opt.meanFlowVelocity);
    plus1{i} = calcPuls(pressure1,dcpss);
    plus2{i} = calcPuls(pressure2,dcpss);
    plus3{i} = calcPuls(pressure3,dcpss);
    plus{i} = [plus1{i},plus2{i},plus3{i}];
    multFreAmpValueVesselPulsation{i} = calcWaveFreAmplitude([pressure1,pressure2,pressure3],Fs,multFre,'freErr',1);
    calcDatas{dataCount,1} = sprintf('˫��,L1:%g,L2:%g,L3:%g',para(i).L1,para(i).L2,para(i).L3);
    calcDatas{dataCount,2} = X;
    calcDatas{dataCount,3} = plus{i};
    calcDatas{dataCount,4} = multFreAmpValueVesselPulsation{i}(1,:);
    calcDatas{dataCount,5} = multFreAmpValueVesselPulsation{i}(2,:);
    calcDatas{dataCount,6} = multFreAmpValueVesselPulsation{i}(3,:);
    dataCount = dataCount + 1;
    
%     if isSaveXls
%         tableHeader = {};
%         for k=1:length(para(i).sectionL1)
%             tableHeader = cellPush2Right(tableHeader,{sprintf('L1:%g',para(i).sectionL1(k))});
%         end
%         for k=1:length(para(i).sectionL2)
%             tableHeader = cellPush2Right(tableHeader,{sprintf('L2:%g',para(i).sectionL2(k))});
%         end
%         for k=1:length(para(i).sectionL3)
%             tableHeader = cellPush2Right(tableHeader,{sprintf('L3:%g',para(i).sectionL3(k))});
%         end
%         xlsDataToBeWrite = toOneCell(tableHeader,pressure1,pressure2,pressure3);
%         xlswrite(fullfile(currentPath,[name{i},'.xls']),xlsDataToBeWrite);
%     end
    
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

    temp =  plusStraight{i};
    temp2 = plus{i};
    temp(temp<1e-4) = 1;
    temp2(temp2<1e-4) = 1;
    reduceRate{i} = (temp - temp2)./temp;
    
    maxPlus1Straight(i) = max(temp(1:sepratorIndex(i)));
    maxPlus3Straight(i) = max(temp(sepratorIndex(i):end));
%     newSectionL2 = para(i).L1 + 2*para(i).l+para(i).Lv1 + para(i).sectionL2;
%     newSectionL3 = para(i).L1+4*para(i).l+para(i).Lv1+para(i).Lv2+para(i).L2 + para(i).sectionL3;
%     realLengthSection{i} = [para(i).sectionL1,newSectionL2,newSectionL3];
% 
%     L_straight(i) = para(i).L1 + para(i).L2 + para(i).L3 + para(i).Lv1 + para(i).Lv2 + 4*para(i).l;
%     temp = find(realLengthSection{i}>para(i).L1);
%     sepratorIndex(i) = temp(1);
%     %temp = fun_straightPipe(massFlowE1,L_straight(i),para(i).Dpipe,para(i).opt,realLengthSection{i});
%     temp = straightPipePulsationCalc(massFlowE,Fre,time,L_straight(i),realLengthSection{i}...
% 	,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity);
%     temp = calcPuls(temp,dcpss);
%     maxPlus1Straight(i) = max(temp(1:sepratorIndex(i)));
%     maxPlus3Straight(i) = max(temp(sepratorIndex(i):end));
%     plusStraight{i} = temp;
%     temp2 = plus{i};
%     temp(temp<1e-4) = 1;
%     temp2(temp2<1e-4) = 1;
%     reduceRate{i} = (temp - temp2)./temp;
%     
%     maxPlus1Straight(i) = max(temp(1:sepratorIndex(i)));
%     maxPlus3Straight(i) = max(temp(sepratorIndex(i):end));

end
if isShowStraightPipe
    maxPlus1 = [maxPlus1Straight(1,:);maxPlus1];
    maxPlus3 = [maxPlus3Straight(1,:);maxPlus3];
end

%% ��ͼ
ignoreHeader = 1;
%����ѹ������
figure 
plotDataCells(calcDatas,'xcol',2,'ycol',3,'legendcol',1,'ignoreHeader',ignoreHeader);
title('����ѹ�����ֵ');
%����1��Ƶ
figure
plotDataCells(calcDatas,'xcol',2,'ycol',4,'legendcol',1,'ignoreHeader',ignoreHeader);
title('ѹ��1��Ƶ');
%����2��Ƶ
figure
plotDataCells(calcDatas,'xcol',2,'ycol',5,'legendcol',1,'ignoreHeader',ignoreHeader);
title('ѹ��2��Ƶ');
%����3��Ƶ
figure
plotDataCells(calcDatas,'xcol',2,'ycol',6,'legendcol',1,'ignoreHeader',ignoreHeader);
title('ѹ��3��Ƶ');

% marker_style = {'-o','-d','-<','-s','->','-<','-p','-*','-v','-^','-+','-x','-h'};
% color_style = [...
%     245,18,103;...
%     36,100,196;...
%     18,175,134;...
%     237,144,10;... 
%     131,54,229;...
%     
%     255,99,56;...
%     ]./255;
% market_style_length = length(marker_style);
% color_style_length = size(color_style,1);
% marker_index = 0;
% color_index = 0;
% 
% figure
% marker_index = 0;
% color_index = 0;
% h = [];
% textLegend = {};
% hold on;
% if isShowStraightPipe
%     h(1) = plot(realLengthSection{i},plusStraight{i}./1000,'-r','LineWidth',1.5);
%     textLegend = ['ֱ��',name{i}];
% else
%     textLegend = name;
% end
% for i = 1:length(para)
%     marker_index = marker_index + 1;
%     if marker_index > market_style_length
%         marker_index = 1;
%     end
%     color_index = color_index + 1;
%     if color_index > color_style_length
%         color_index = 1;
%     end
%     if isShowL2Plus
%         Y = plus{i};
%     else
%         Y = [plus1{i},plus3{i}];
%     end
%     Y = Y./1000;
%     Y=Y';
%     if isXLength
%         newSectionL2 = para(i).L1 + 2*para(i).l+para(i).Lv1 + para(i).sectionL2;
%         newSectionL3 = para(i).L1+4*para(i).l+para(i).Lv1+para(i).Lv2+para(i).L2 + para(i).sectionL3;
%         if isShowL2Plus
%             X = realLengthSection{i};
%         else
%             X = [para(i).sectionL1,newSectionL3];
%         end
%     else
%         X = 1:length(Y);
%     end
%     if isShowStraightPipe
%         h(i+1) = plot(X,Y,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
%     else
%         h(i) = plot(X,Y,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
%     end
% end
% legend(h,textLegend,0);
% grid on;
% if isXLength
%     xlabel('����(m)');
% else
%     xlabel('���');
% end
% ylabel('����ѹ�����ֵ(kPa)');
% title(titleText);
% set(gcf,'color','w');
% 
% 
% h = [];
% marker_index = 1;
% color_index = 1;    
% barMaxPlusBefore = maxPlus1./1000;
% barMaxPlusMiddle = maxPlus2./1000;
% barMaxPlusAfter = maxPlus3./1000;  
% figure
% hold on;
% if isempty(xTick)
%     X = 1:length(para); 
% else
%     X = xTick;
% end
% h(1) = plot(X,barMaxPlusBefore,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
% % h(2) = plot([X(1),X(end)],[maxL1./1000,maxL1./1000],'-','color',color_style(color_index,:));
% marker_index = 2;
% color_index = 2; 
% h(3) = plot(X,barMaxPlusAfter,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
% % h(4) = plot([X(1),X(end)],[maxL2./1000,maxL2./1000],'-','color',color_style(color_index,:));
% marker_index = 3;
% color_index = 3; 
% h(5) = plot(X,barMaxPlusMiddle,marker_style{marker_index},'color',color_style(color_index,:),'LineWidth',1.5);
% title('����޼��������������Ӱ��');
% ylabel('����ѹ�����ֵ(kPa)');
% xlabel('����޼��(m)');
% if isempty(xTick)
%     set(gca,'XTick',0:size(inputData,1));
%     set(gca,'XTickLabel',xTickLabel);
% end
% legend(h,{'�����ǰ�ܵ��������ֵ','�������ǰ�ܵ��������ֵ','����޺�ܵ��������ֵ','������޺�ܵ��������ֵ','���ӹܵ��������ֵ'});
% grid on;
% set(gcf,'color','w');
% 
% % close all;
% % simulationL1Max = [4.603,5.695,8.266,7.92,4.14,4.933];
% % simulationL3Max = [3.364,5.167,6.583,6.589,10.06,3.601];
% % 
% % 
% % figure
% % 
% % subplot(1,2,1)
% % h = [];
% % X = sec;
% % hold on;
% % h(1) = plot(X,barMaxPlusBefore,'color',[191,191,191]./255,'LineWidth',2);
% % h(2) = plot(X,simulationL1Max,'color',[46,77,234]./255,'LineWidth',2);
% % ylabel('maximum pulsating pressure(kPa)');
% % xlabel('distance between buffer tank(m)');
% % legend(h,{'theory data','simulation data'});
% % title('pre buffer tank pipeline');
% % grid on;
% % 
% % subplot(1,2,2)
% % h = [];
% % X = sec;
% % hold on;
% % h(1) = plot(X,barMaxPlusAfter,'color',[191,191,191]./255,'LineWidth',2);
% % h(2) = plot(X,simulationL3Max,'color',[255,31,70]./255,'LineWidth',2);
% % ylabel('maximum pulsating pressure(kPa)');
% % xlabel('distance between buffer tank(m)');
% % legend(h,{'theory data','simulation data'});
% % title('after buffer tank pipeline');
% % grid on;
% % set(gcf,'color','w');

