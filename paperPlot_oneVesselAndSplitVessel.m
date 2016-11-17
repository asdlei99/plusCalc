%% �������۷�����˫����޺͵�ͬ����ĵ�����޵ĶԱ�
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

temp =Fre>5 & Fre<20.1;%Fre<20 | (Fre>22&Fre<80);
Fre = Fre(temp);

massFlowE = massFlowE(temp);
opt.acousticVelocity = 345;%����
opt.isDamping = 1;%�Ƿ��������
opt.coeffFriction = 0.05;%�ܵ�Ħ��ϵ��
opt.meanFlowVelocity = 14.6;%�ܵ�ƽ������
opt.isUseStaightPipe = 1;%�����������ݾ���ķ���

dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.4,0.5];
dcpss.isHp = 0;
dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
dcpss.f_stop = 5;%��ֹƵ��3Hz
dcpss.rp = 0.1;%�ߴ���˥��DB������
dcpss.rs = 30;%��ֹ��˥��DB������
%%�����趨
Lv1 = 0.3:0.1:4;
for i=1:length(Lv1)
    paraDV(i).opt = opt;
    paraDV(i).L1 = 13;%L1(m)
    paraDV(i).L2 = 0;%������м����ӹܵ��ĳ��ȣ�m��
    paraDV(i).L3 = 13;
    paraDV(i).Dpipe = 0.157;%�ܵ�ֱ����m��
    paraDV(i).Dv1 = 0.5;
    paraDV(i).Dv2 = 0.5;    
    paraDV(i).l = 0.115;%0.115;%�����ǰ�ܵ��ĳ���(m)   
    paraDV(i).Lv1 = Lv1(i);%[[0.157,0.25,0.5,0.75],[1:0.25:5]];%��һ������޵�ֱ����m��
    paraDV(i).Lv2 = Lv1(i);%0.5;%�ڶ�������޵�ֱ����m��
    
    paraDV(i).sectionL1 = 0:1:paraDV(i).L1;
    paraDV(i).sectionL2 = 0:1:paraDV(i).L2;
    paraDV(i).sectionL3 = 0:1:paraDV(i).L3;
    VDV(i) = ((pi*paraDV(i).Dv1^2)/4)*paraDV(i).Lv1 ...
        +((pi*paraDV(i).Dv2^2)/4)*paraDV(i).Lv2;
        %4*((2/5)*pi*paraDV(i).l*(paraDV(i).Dv1^2+paraDV(i).Dpipe^2+paraDV(i).Dv1*paraDV(i).Dpipe))...

    
    paraOV(i).L1 = 13;
    paraOV(i).L2 = 13;
    paraOV(i).Lv = paraDV(i).Lv1+paraDV(i).Lv2;
    paraOV(i).Dv = 0.5;
    paraOV(i).l = 0.115;
    paraOV(i).Dpipe = 0.157;%�ܵ�ֱ����m��
    paraOV(i).sectionL1 = 0:1:paraOV(i).L1;
    paraOV(i).sectionL2 = 0:1:paraOV(i).L2;
    VOV(i) = ((pi*paraOV(i).Dv^2)/4)*paraOV(i).Lv;
    %+2*((2/5)*pi*paraOV(i).l*(paraOV(i).Dv^2+paraOV(i).Dpipe^2+paraOV(i).Dv*paraOV(i).Dpipe));
end
%% ����˫����޵�����
for i = 1:length(paraDV)
    [pressure1DV,pressure2DV,pressure3DV] = ...
            doubleVesselPulsationCalc(massFlowE,Fre,time,...
            paraDV(i).L1,paraDV(i).L2,paraDV(i).L3,...
            paraDV(i).Lv1,paraDV(i).Lv2,paraDV(i).l,paraDV(i).Dpipe,paraDV(i).Dv1,paraDV(i).Dv2,...
            paraDV(i).sectionL1,paraDV(i).sectionL2,paraDV(i).sectionL3,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
            'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightpipe',opt.isUseStaightPipe);
    plus1DV{i} = calcPuls(pressure1DV,dcpss);
    plus2DV{i} = calcPuls(pressure2DV,dcpss);
    plus3DV{i} = calcPuls(pressure3DV,dcpss);
    aheadMaxPlusDV(i) = max(plus1DV{i});%��ǰ�����������
    afterMaxPlusDV(i) = max(plus3DV{i});%�޺������������
    [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
        paraOV(i).L1,paraOV(i).L2,paraOV(i).Lv,paraOV(i).l,paraOV(i).Dpipe,paraOV(i).Dv ...
        ,paraOV(i).sectionL1,paraOV(i).sectionL2 ...
        ,'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity);
    plus1OV{i} = calcPuls(pressure1OV,dcpss);
    plus2OV{i} = calcPuls(pressure2OV,dcpss);
    aheadMaxPlusOV(i) = max(plus1OV{i});%��ǰ�����������
    afterMaxPlusOV(i) = max(plus2OV{i});%�޺������������
end

%% ���㵥����޵�����
figure
h(1) = plot(VDV,aheadMaxPlusDV./1000,'.-r');
hold on;
h(2) = plot(VOV,aheadMaxPlusOV./1000,'-b','LineWidth',1.5);
legend(h,{'TTE','STE'});
xlabel('volume(m^3)');
ylabel(sprintf('max peak-to-peak \n pressure pulation(kPa)'));
set(gcf,'color','w');
set(gcf,'unit','pixels','position',[200,200,300,200]);
figure
h(1) = plot(VDV,afterMaxPlusDV./1000,'.-r');
hold on;
h(2) = plot(VOV,afterMaxPlusOV./1000,'-b','LineWidth',1.5);
legend(h,{'TTE','STE'});
xlabel('volume(m^3)');
ylabel(sprintf('max peak-to-peak \n pressure pulation(kPa)'));
set(gcf,'color','w');
set(gcf,'unit','pixels','position',[200,200,300,200]);
