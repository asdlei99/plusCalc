%% �������۷�����˫����޺͵�ͬ����ĵ�����޵ĶԱ�
% ˫�޵����������һ��������������Ӱ��
% 
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
[time,massFlow,Fre,massFlowE ] = getMassFlowData('N',4096,'isfindpeaks',1);
Fs = 1/(time(2)-time(1));
% [los]=find(Fre>19 & Fre <21);
% Fre(los) = Fre(los)./1.5;

temp =Fre>5 & Fre<20.1;%Fre<20 | (Fre>22&Fre<60);% Fre>9.5 & Fre<10.1;%Fre<20 | (Fre>22&Fre<80);
%temp =Fre<20 | (Fre>22&Fre<60);% Fre>9.5 & Fre<10.1;%Fre<20 | (Fre>22&Fre<80);
Fre = Fre(temp);

massFlowE = massFlowE(temp);
opt.acousticVelocity = 345;%����
opt.isDamping = 1;%�Ƿ��������
opt.coeffFriction = 0.05;%�ܵ�Ħ��ϵ��
opt.meanFlowVelocity = 14.6;%�ܵ�ƽ������
opt.isUseStaightPipe = 1;%�����������ݾ���ķ���

dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.4,0.7];
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������
%%�����趨
Lv1 = 0.05:0.01:0.4;
Lv2 = 0.05:0.01:0.4;
for i=1:length(Lv1)
    for j=1:length(Lv2)
        paraDV(i,j).opt = opt;
        paraDV(i,j).L1 = 13;%L1(m)
        paraDV(i,j).L2 = 0;%������м����ӹܵ��ĳ��ȣ�m��
        paraDV(i,j).L3 = 13;
        paraDV(i,j).Dpipe = 0.157;%�ܵ�ֱ����m��
        paraDV(i,j).Dv1 = 0.5;
        paraDV(i,j).Dv2 = 0.5;    
        paraDV(i,j).l = 0.115;%0.115;%�����ǰ�ܵ��ĳ���(m)   
        paraDV(i,j).Lv1 = Lv1(i);%[[0.157,0.25,0.5,0.75],[1:0.25:5]];%��һ������޵�ֱ����m��
        paraDV(i,j).Lv2 = Lv2(j);%0.5;%�ڶ�������޵�ֱ����m��

        paraDV(i,j).sectionL1 = 0:1:paraDV(i,j).L1;
        paraDV(i,j).sectionL2 = 0:1:paraDV(i,j).L2;
        paraDV(i,j).sectionL3 = 0:1:paraDV(i,j).L3;
        VDV1(i,j) = (pi*paraDV(i,j).Dv1^2/4)*paraDV(i,j).Lv1;%+2*((1/3)*(pi*paraDV(i,j).Dv1^2/4)*paraDV(i,j).l);
        VDV2(i,j) = (pi*paraDV(i,j).Dv2^2/4)*paraDV(i,j).Lv2;%+2*((1/3)*(pi*paraDV(i,j).Dv2^2/4)*paraDV(i,j).l);
        VDV(i,j) = VDV1(i,j)+VDV2(i,j);
        paraOV(i,j).L1 = 13;
        paraOV(i,j).L2 = 13;
        paraOV(i,j).Lv = Lv1(i)+Lv2(j);
        paraOV(i,j).Dv = 0.5;
        paraOV(i,j).l = 0.115;
        paraOV(i,j).Dpipe = 0.157;%�ܵ�ֱ����m��
        paraOV(i,j).sectionL1 = 0:1:paraOV(i,j).L1;
        paraOV(i,j).sectionL2 = 0:1:paraOV(i,j).L2;
        VOV(i,j) = (pi*paraOV(i,j).Dv^2/4)*paraOV(i,j).Lv;%+2*((1/3)*(pi*paraOV(i,j).Dv^2/4)*paraOV(i,j).l);
    end
end
%% ����˫����޵�����
for i=1:length(Lv1)
    for j=1:length(Lv2)
        [pressure1DV,pressure2DV,pressure3DV] = ...
                doubleVesselPulsationCalc(massFlowE,Fre,time,...
                paraDV(i,j).L1,paraDV(i,j).L2,paraDV(i,j).L3,...
                paraDV(i,j).Lv1,paraDV(i,j).Lv2,paraDV(i,j).l,paraDV(i,j).Dpipe,paraDV(i,j).Dv1,paraDV(i,j).Dv2,...
                paraDV(i,j).sectionL1,paraDV(i,j).sectionL2,paraDV(i,j).sectionL3,...
                'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
                'meanFlowVelocity',opt.meanFlowVelocity);
        plus1DV{i,j} = calcPuls(pressure1DV,dcpss);
        plus2DV{i,j} = calcPuls(pressure2DV,dcpss);
        plus3DV{i,j} = calcPuls(pressure3DV,dcpss);
        aheadMaxPlusDV(i,j) = max(plus1DV{i,j});%��ǰ�����������
        afterMaxPlusDV(i,j) = max(plus3DV{i,j});%�޺������������
        [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
            paraOV(i,j).L1,paraOV(i,j).L2,paraOV(i,j).Lv,paraOV(i,j).l,paraOV(i,j).Dpipe,paraOV(i,j).Dv ...
            ,paraOV(i,j).sectionL1,paraOV(i,j).sectionL2 ...
            ,'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity);
        plus1OV{i,j} = calcPuls(pressure1OV,dcpss);
        plus2OV{i,j} = calcPuls(pressure2OV,dcpss);
        aheadMaxPlusOV(i,j) = max(plus1OV{i,j});%��ǰ�����������
        afterMaxPlusOV(i,j) = max(plus2OV{i,j});%�޺������������
    end
end

if 1
    figure
    [X,Y] = meshgrid(VDV1(:,1),VDV2(1,:));
    Z1 = (-(afterMaxPlusDV'-afterMaxPlusOV')./afterMaxPlusOV')*100;
    if 1
        hold on;
        [C1,h1] = contourf(X,Y,Z1);
        colorbar;
        set(h1,'LevelStep',1);
        set(h1,'LabelSpacing',180);
        % quiver(X,Y,Dx,Dy);
%        clabel(C1,h1,'FontSize',8,'FontName','Times New Roman');
%         
%         [C2,h2] = contour(X,Y,VDV');
%         set(h2,'LineStyle','--','LineColor',[0,0,0]./255,'LineWidth',1);
%         hc = clabel(C2,h2,'FontSize',8,'FontName','Times New Roman','Color',[235,235,235]./255);
%         %set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'));
%         set(h2,'LabelSpacing',180);
%         %set(hc,'FontSize',8,'FontName','Times New Roman');
%         %colormap
        caxis([-6 2]);
        
        box on;
    else
        surfc(X,Y,Z1);
    end
    xlabel('V1(m^3)');
    ylabel('V2(m^3)');
    %title('��ǰ�޺�ͬ������ͬ�����һ�������������Ч���Ա�');
    drawnow
    
    set(gcf,'position',[200,200,350,250]);
    set(gca,'FontName','times new roman');
    set(gcf,'color','w');
    set(gca,'FontUnits','points','FontSize',8,'FontName','Times New Roman');
    set(get(gca,'XLabel'),'FontUnits','points','FontSize',12,'FontName','Times New Roman');
    set(get(gca,'YLabel'),'FontUnits','points','FontSize',12,'FontName','Times New Roman');
    set(get(gca,'ZLabel'),'FontUnits','points','FontSize',12,'FontName','Times New Roman');
    set(gcf,'unit','centimeter','position',[2 2 8 5]);
    axis square;
end
load('matlab2015ColorMap.mat');
colormap(colorMap2015);

figure
[X,Y] = meshgrid(VDV1(:,1),VDV2(1,:));
Z1 = (-(aheadMaxPlusDV'-aheadMaxPlusOV')./aheadMaxPlusOV')*100;
%Z1 = aheadMaxPlusDV'-aheadMaxPlusOV';
% [Dx,Dy]=gradient(Z1,200,200);
if 0
    hold on;
    [C1,h1] = contourf(X,Y,Z1);
    %set(h1,'LevelStep',0.025);
    % quiver(X,Y,Dx,Dy);
     clabel(C1,h1,'FontSize',8,'FontName','Times New Roman');
%     set(h1,'LabelSpacing',180);
%     [C2,h2] = contour(X,Y,VDV');
%     set(h2,'LineStyle','--','LineColor',[0,0,0]./255,'LineWidth',1);
%     clabel(C2,h2,'Color',[0,0,0]./255,'FontSize',8,'FontName','Times New Roman');
%     set(h2,'LabelSpacing',180);
%     set(hc,'FontUnits','points','FontSize',8,'FontName','Times New Roman');
    %set(h2,'ShowText','on','TextStep',get(h2,'LevelStep'))
    %colormap
    %plot([0.1,0.1],[0.8,0.8],':');
    %caxis([0 4])
    colorbar;
    box on;
else
    surfc(X,Y,Z1);
end
xlabel('V1(m^3)');
ylabel('V2(m^3)');
%title('��ǰ�޺�ͬ������ͬ�����һ�������������Ч���Ա�');
drawnow

load('matlab2015ColorMap.mat');
colormap(colorMap2015);
set(gcf,'position',[200,200,350,250]);
set(gca,'FontName','times new roman');
set(gcf,'color','w');
set(gca,'FontUnits','points','FontSize',8,'FontName','Times New Roman');
set(get(gca,'XLabel'),'FontUnits','points','FontSize',12,'FontName','Times New Roman');
set(get(gca,'YLabel'),'FontUnits','points','FontSize',12,'FontName','Times New Roman');
set(get(gca,'ZLabel'),'FontUnits','points','FontSize',12,'FontName','Times New Roman');