%% ��Ŀ��Lin����ʵ�ǵ���Lv1-Lin����
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
%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%����25�Ⱦ���ѹ����0.2MPaG���¶ȶ�Ӧ�ܶ�
rpm = 420;outDensity = 1.5608;multFre=[14,28,42];%����25�Ⱦ���ѹ����0.15MPaG���¶ȶ�Ӧ�ܶ�
Fs = 4096;
[massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,rpm...
	,0.14,1.075,outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',Fs,'oneSecond',6);

%massFlow = load(fullfile(currentPath,'mass_flow_0.1478_NorthZone.txt'));

[FreRaw,AmpRaw,PhRaw,massFlowERaw] = frequencySpectrum(detrend(massFlowRaw,'constant'),Fs);
FreRaw = [7,14,21,28,14*3];
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

variant_n1 = [32];              %variant_n = [6,6];sectionNum1 =[1,6];%��Ӧ��1������sectionNum2 =[1,1];%��Ӧ��2������
sectionNum1 =[1];%��Ӧ��1������
sectionNum2 =[1];%��Ӧ��2������
variant_n2 = [32];
variant_Lv1 = 0.26:0.1:0.84;
calcDatas = {};


for i = 1:length(variant_Lv1)     
    para(i).opt = opt;
    para(i).L1 = 3.5;%L1(m)
    para(i).L2 = 6;%L2��m������
    para(i).Dpipe = 0.098;%�ܵ�ֱ����m��
    para(i).vhpicStruct.l = 0.01;
    para(i).vhpicStruct.Dv = 0.372;%����޵�ֱ����m��
    para(i).vhpicStruct.Lv = 1.1;%������ܳ� 
    para(i).vhpicStruct.Lv1 =variant_Lv1(i);%�����ǻ1�ܳ�
    para(i).vhpicStruct.Lv2 = para(i).vhpicStruct.Lv-para(i).vhpicStruct.Lv1;%�����ǻ2�ܳ�
    para(i).vhpicStruct.lc = 0.005;%�ڲ�ܱں�
    para(i).vhpicStruct.dp1 = 0.013;%���׾�
    para(i).vhpicStruct.dp2 = 0.013;%���׾�
    para(i).vhpicStruct.Lin = 0.25;%�ڲ����ڶγ���
    para(i).vhpicStruct.lp1 = 0.16;%�ڲ����ڶηǿ׹ܿ��׳���
    para(i).vhpicStruct.lp2 = 0.16;%�ڲ�ܳ��ڶο׹ܿ��׳���
    para(i).vhpicStruct.n1 = variant_n1;%��ڶο���
    para(