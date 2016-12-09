function resCell = fun_vesselInBiasHaveInnerPerfBothClosedComp_ite_perforatedRate(varargin)
[isDamping,varargin]= takeVararginProperty('isDamping',varargin,1);

%���������ʵ���ز���
currentPath = fileparts(mfilename('fullpath'));
isOpening = 0;%�ܵ��տ�
%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%����25�Ⱦ���ѹ����0.2MPaG���¶ȶ�Ӧ�ܶ�
rpm = 420;outDensity = 1.5608;multFre=[14,28,42];%����25�Ⱦ���ѹ����0.15MPaG���¶ȶ�Ӧ�ܶ�
Fs = 4096;
[massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,rpm...
    ,0.14,1.075,outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',Fs,'oneSecond',6);
[FreRaw,AmpRaw,PhRaw,massFlowERaw] = frequencySpectrum(detrend(massFlowRaw,'constant'),Fs);
FreRaw = [7,14,21,28,14*3];
massFlowERaw = [0.02,0.2,0.03,0.003,0.007];
% ��ȡ��ҪƵ��
massFlowE = massFlowERaw;
Fre = FreRaw;
%%����


opt.acousticVelocity = 345;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffDamping = nan;%����
opt.coeffFriction = 0.04;%�ܵ�Ħ��ϵ��
opt.SreaightMeanFlowVelocity =20;%14.5;%�ܵ�ƽ������
opt.SreaightCoeffFriction = 0.03;
opt.VesselMeanFlowVelocity =8;%14.5;%�����ƽ������
opt.VesselCoeffFriction = 0.003;
opt.PerfClosedMeanFlowVelocity =9;%14.5;%�����׹�ƽ������
opt.PerfClosedCoeffFriction = 0.04;
opt.PerfOpenMeanFlowVelocity =15;%14.5;%���ڿ׹�ƽ������
opt.PerfOpenCoeffFriction = 0.035;

opt.isUseStaightPipe = 1;%�����������ݾ���ķ���
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 1;

L1 = 3.5;%L1(m)
L2 = 6;%L2��m������
Dpipe = 0.098;%�ܵ�ֱ����m��
l = 0.01;
Dv = 0.372;%����޵�ֱ����m��
Lv = 1.1;%������ܳ� 
Lv1 =Lv./2;%�����ǻ1�ܳ�
Lv2 = Lv-Lv1;%�����ǻ2�ܳ�
lc = 0.005;%�ڲ�ܱں�
dp1 = variant_dp1;%���׾�
dp2 = variant_dp2;%���׾�
%     Lin = 0.25;%�ڲ����ڶγ���
lp1 = variant_lp1(i);%�ڲ����ڶηǿ׹ܿ��׳���
lp2 = variant_lp2(i);%�ڲ�ܳ��ڶο׹ܿ��׳���
n1 = variant_n1;%��ڶο���
n2 = variant_n2;%���ڶο���
la1 = 0.03;%�׹���ڶο�����ڳ���
lb2 = 0.06;
la2 = 0.06;
lb1 = 0.03;
Din = variant_Din;
%     Lout = 0.25;
Lin = la1+lp1+la2;
Lout = lb1+lp2+lb2;
bp1 = variant_n1.*(variant_dp1)^2./(4.*variant_Din.*variant_lp1(i));%������
bp2 = variant_n2.*(variant_dp2)^2./(4.*variant_Din.*variant_lp2(i));%������
nc1 = 8;%����һȦ��8����
nc2 = 8;%����һȦ��8����
Cloum1 = variant_n1./nc1;%����һ�˹̶����׳��ȵĿ׹����ܿ�����Ȧ��
Cloum2 = variant_n2./nc2;
s1 = ((variant_lp1(i)./Cloum1)-variant_dp1)./2;%����������֮������Ĭ�ϵȼ��
s2 = ((variant_lp2(i)./Cloum2)-variant_dp2)./2;
sc1 = (pi.*variant_Din - nc1.*dp1)./nc1;%һ�ܿ��ף����ڿ׼��
sc2 = (pi.*variant_Din - nc2.*dp2)./nc2;
l = lp1;
xSection1 = [0,ones(1,sectionNum1).*(l/(sectionNum1))];
l = lp2;
xSection2 = [0,ones(1,sectionNum2).*(l/(sectionNum2))];
sectionL1 = 0:0.25:L1;
sectionL2 = 0:0.25:L2;
lv1 = Lv./2-0.232;%232
lv2 = 0;%���ڲ�ƫ��
Dbias = 0;%���ڲ��
end


function data = calcPerforatingRatios(n,dp,Din,lp)
% ���㿪����
% n ����
% dp �׹�ÿһ���׿׾�
% Din �׹ܹܾ�
% lp �׹ܿ��׳���
data = (n.*(dp).^2)./(4.*Din.*lp);%������
end


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


function calcDatas = funIteratorVesselPipeLinePlusCalc(time,massFlow,Fs,plusBaseFrequency,acousticVelocity...
    ,meanFlowVelocity ...
    ,L1,L2,l,Dpipe,Dv,Lv,Lv1,lc ...
    ,dp1,dp2,n1,n2,la1,la2,lb1,lb2,Din ...
    ,IteratorValueName,varargin)
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
% ��������ÿ׹ܽṹ�뵥һ˳�ӻ���޶Ա�
% massFlow Ϊ�������������
% meanFlowVelocity ��ڹܵ�������
% Fs ���������Ĳ�����
% plusBaseFrequency ��������Ƶ��
% acousticVelocity ����
% L1 ��ڹܵ�����
% L2 ���ڹܵ�����
% l  ������������������
% Dpipe  �ܾ�
% Dv  �����ֱ��
% Lv ����޳���
% Lv1 �����ǻ1�ܳ�
% lc �ڲ�ܱں�
% dp1 ���׾�1
% dp2 ���׾�2
% n1 ��ڶο���
% n2 ���ڶο���
% la1 �׹���ڶο�����ڳ���
% la2
% lb1
% lb2
% Din
% Lin
% Lout
% IteratorValueName �������Ȳ�Ϊ1�ı�����������Ҫ�����ı�����
% vararginȡֵ��
% 'multfre':��Ҫ����ı�Ƶ(vector)([10,20,30])
% 'isOpening'��(bool)(1) �Ƿ񿪿�
% 'useCalcTopFreIndex':�����������Ƶ��������[1:20]����ǰ20������Ƶ�ʽ��м��㣬nanΪȫ������
% 'isDamping' �Ƿ�������
% 'coeffDamping' ����ϵ��
% 'coeffFriction' �ܵ�Ħ��ϵ��
% 'dcpss' �����������ֵ������,���Ϊ'default',������һ��Ĭ��ֵ,����Ӧ���������ã�
%       dcpss = getDefaultCalcPulsSetStruct();
%       dcpss.calcSection = [0.3,0.7];
%       dcpss.fs = Fs;
%       dcpss.isHp = 0;
%       dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
%       dcpss.f_stop = 5;%��ֹƵ��3Hz
%       dcpss.rp = 0.1;%�ߴ���˥��DB������
%       dcpss.rs = 30;%��ֹ��˥��DB������
%  'accuracy' ����ľ���Ĭ��Ϊ1������ÿ��1mȡһ����
% ���ص�cell
% {[]   ,'xֵ','ѹ������','1��Ƶ','2��Ƶ','3��Ƶ','��ǰѹ���������ֵ','�޺�ѹ���������ֵ'
% 'ֱ��',
% 'xx'

iteCount = eval(sprintf('length(%s)',IteratorValueName));

% 
% xSection1��xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
Lv2 = Lv - Lv1;%��ȡ�������һ�߳�
[multFre,varargin]= takeVararginProperty('multfre',varargin,[10,20,30]);
[isOpening,varargin]= takeVararginProperty('isOpening',varargin,1);
[useCalcTopFreIndex,varargin]= takeVararginProperty('isOpening',varargin,nan);

[FreRaw,AmpRaw,~,massFlowE] = frequencySpectrum(detrend(massFlow,'constant'),Fs);
Fre = FreRaw;
% ��ȡ��ҪƵ��
[~,locs] = findpeaks(AmpRaw,'SORTSTR','descend');
Fre = FreRaw(locs);
massFlowE = massFlowE(locs);

if ~isnan(useCalcTopFreIndex)
    Fre = Fre(useCalcTopFreIndex);
    massFlowE = massFlowE(useCalcTopFreIndex);
end
%�Ƿ������
[isDamping,varargin]= takeVararginProperty('isDamping',varargin,1);
%����ϵ��
[coeffDamping,varargin]= takeVararginProperty('coeffDamping',varargin,1);
%�ܵ�Ħ��ϵ��
[coeffFriction,varargin]= takeVararginProperty('coeffFriction',varargin,1);
%�����������ֵ������
[dcpss,varargin]= takeVararginProperty('dcpss',varargin,'default');
%����ľ���Ĭ��Ϊ1������ÿ��1mȡһ����
[accuracy,varargin]= takeVararginProperty('accuracy',varargin,1);

[sectionNum1,varargin]= takeVararginProperty('sectionNum1',varargin,1);
[sectionNum2,varargin]= takeVararginProperty('sectionNum2',varargin,1);
%L1 L2�ļ��
[sectionL1Interval,varargin]= takeVararginProperty('sectionL1Interval',varargin,0.5);
[sectionL2Interval,varargin]= takeVararginProperty('sectionL2Interval',varargin,0.5);
[lv1,varargin]= takeVararginProperty('lv1',varargin,0);%ƫ�ó���
[lv2,varargin]= takeVararginProperty('lv2',varargin,0);
[Dbias,varargin]= takeVararginProperty('Dbias',varargin,0);%�ڲ�ܳ�
if ~isstruct(dcpss)
    dcpss = getDefaultCalcPulsSetStruct();
    dcpss.calcSection = [0.3,0.7];
    dcpss.fs = Fs;
    dcpss.isHp = 0;
    dcpss.f_pass = 7;%ͨ��Ƶ��5Hz
    dcpss.f_stop = 5;%��ֹƵ��3Hz
    dcpss.rp = 0.1;%�ߴ���˥��DB������
    dcpss.rs = 30;%��ֹ��˥��DB������
end


opt.frequency = plusBaseFrequency;%����Ƶ��
opt.acousticVelocity = acousticVelocity;%����
opt.isDamping = isDamping;%�Ƿ��������
opt.coeffDamping = coeffDamping;%����
opt.coeffFriction = coeffFriction;%�ܵ�Ħ��ϵ��
opt.meanFlowVelocity =meanFlowVelocity;%14.5;%�ܵ�ƽ������
opt.isUseStaightPipe = 1;%�����������ݾ���ķ���
opt.mach = opt.meanFlowVelocity / opt.acousticVelocity;
opt.notMach = 0;

para(1:iteCount).opt = opt;
para(1:iteCount).L1 = L1;%L1(m)
para(1:iteCount).L2 = L2;%L2��m������
para(1:iteCount).Dpipe = Dpipe;%�ܵ�ֱ����m��
para(1:iteCount).l = l;
para(1:iteCount).Dv = Dv;%����޵�ֱ����m��
para(1:iteCount).Lv = Lv;%������ܳ�

para(1:iteCount).Lv1 = Lv1;%�����ǻ1�ܳ�
para(1:iteCount).Lv2 = Lv2;%�����ǻ2�ܳ�
para(1:iteCount).lc = lc;%�ڲ�ܱں�
para(1:iteCount).dp1 = dp1;%���׾�
para(1:iteCount).dp2 = dp2;%���׾�
para(1:iteCount).lp1 = lp1;%�ڲ����ڶηǿ׹ܿ��׳���
para(1:iteCount).lp2 = lp2;%�ڲ����ڶηǿ׹ܿ��׳���
para(1:iteCount).n1 = n1;%��ڶο���
para(1:iteCount).n2 = n2;%���ڶο���
para(1:iteCount).la1 = la1;%�׹���ڶο�����ڳ���
para(1:iteCount).la2 = la2;%�׹�
para(1:iteCount).lb1 = lb1;%�׹�
para(1:iteCount).lb2 = lb2;%�׹�
para(1:iteCount).Din = Din;%�׹�
para(1:iteCount).Lin = para(1:iteCount).la1 + para(1:iteCount).lp1 +para(1:iteCount).la2;%�ڲ����ڶγ���
para(1:iteCount).Lout = para(1:iteCount).lb1 + para(1:iteCount).lp2 +para(1:iteCount).lb2;%�ڲ����ڶγ���
para(1:iteCount).bp1 = calcPerforatingRatios(n1,dp1,Din,lp1);%������
para(1:iteCount).bp2 = calcPerforatingRatios(n2,dp2,Din,lp2);%������



for i=1:iteCount
    para(i).sectionL1 = 0:accuracy:para(i).L1;
    para(i).sectionL2 = 0:accuracy:para(i).L2;
    para(i).xSection1 = [0,ones(1,sectionNum1).*(para(i).lp1/(sectionNum1))];
    para(i).xSection2 = [0,ones(1,sectionNum2).*(para(i).lp2/(sectionNum2))];

    holepipeLength1 = para(i).Lin - para(i).la1 - para(i).la2;
    hl1 = sum(para(i).xSection1);
    if(~cmpfloat(holepipeLength1,hl1))
        error('�׹ܲ������ô���holepipeLength1=%.8f,hl1=%.8f;Lin:%g,la1:%g,la2:%g,sum(xSection1):%g,dp:%g'...
            ,holepipeLength1,hl1...
            ,para(i).Lin,para(i).la1,para(i).la2...
            ,sum(para(i).xSection1),para(i).dp);
    end

end

dataCount = 2; index = 2;

index = index + 1; rawIndex = index;
calcDatas{1,rawIndex} = 'rawData';

index = index + 1; xIndex = index;
calcDatas{1,xIndex} = 'xֵ';

index = index + 1; plusIndex = index;
calcDatas{1,plusIndex} = 'ѹ������';

index = index + 1; fre1Index = index;
calcDatas{1,fre1Index} = '1��Ƶ';

index = index + 1; fre2Index = index;
calcDatas{1,fre2Index} = '2��Ƶ';

index = index + 1; fre3Index = index;
calcDatas{1,fre3Index} = '3��Ƶ';

index = index + 1; preMaxPlusIndex = index;
calcDatas{1,preMaxPlusIndex} = '��ǰѹ���������ֵ';

index = index + 1; backMaxPlusIndex = index;
calcDatas{1,backMaxPlusIndex} = '�޺�ѹ���������ֵ';

index = index + 1; indexDp = index;
calcDatas{1,indexDp} = 'Dp'; 

index = index + 1; indexDin = index;
calcDatas{1,indexDin} = 'Din';

index = index + 1; indexlp = index;
calcDatas{1,indexlp} = 'lp';

index = index + 1; indexn1 = index;
calcDatas{1,indexn1} = 'n1';

index = index + 1; indexlb1 = index;
calcDatas{1,indexlb1} = 'lb1';

index = index + 1; indexla1 = index;
calcDatas{1,indexla1} = 'la1';

for i = 1:iteCount
    
     %���㵥һ�����
     X = [para(i).sectionL1,para(i).L1 + 2*para(i).l+para(i).Lv + para(i).sectionL2];
     if 1 == i
        [pressure1OV,pressure2OV] = oneVesselPulsationCalc(massFlowE,Fre,time,...
            para(i).L1,para(i).L2,...
            para(i).Lv,para(i).l,para(i).Dpipe,para(i).Dv,...
            para(i).sectionL1,para(i).sectionL2,...
            'a',opt.acousticVelocity,'isDamping',opt.isDamping,'friction',opt.coeffFriction,...
            'meanFlowVelocity',opt.meanFlowVelocity,'isUseStaightPipe',1,...
            'm',opt.mach,'notMach',opt.notMach,...
            'isOpening',isOpening);
        
        plus1OV = calcPuls(pressure1OV,dcpss);
        plus2OV = calcPuls(pressure2OV,dcpss);
        plusOV = [plus1OV,plus2OV];
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
        
        multFreAmpValue_OV = calcWaveFreAmplitude([pressure1OV,pressure2OV],Fs,multFre,'freErr',1);
        temp = eval(sprintf('%s(i)',IteratorValueName));
        calcDatas{dataCount,rawIndex} = [pressure1OV,pressure2OV];
        calcDatas{dataCount,xIndex} = X;
        calcDatas{dataCount,plusIndex} = [plus1OV,plus2OV];
        calcDatas{dataCount,fre1Index} = multFreAmpValue_OV(1,:);
        calcDatas{dataCount,fre2Index} = multFreAmpValue_OV(2,:);
        calcDatas{dataCount,fre3Index} = multFreAmpValue_OV(3,:);
        calcDatas{dataCount,preMaxPlusIndex} = maxPlus1;
        calcDatas{dataCount,backMaxPlusIndex} = maxPlus2;
        calcDatas{dataCount,backMaxPlusIndex} = maxPlus2;
        dataCount = dataCount + 1;
    end
    %����׹ܵ�����
    vhpicStruct.l  = para(i).l;
    vhpicStruct.Dv = para(i).Dv;
    vhpicStruct.Lv = para(i).Lv;
    vhpicStruct.Lv1 = para(i).Lv1;
    vhpicStruct.Lv2 = para(i).Lv2;
    vhpicStruct.lc   = para(i).lc  ;
    vhpicStruct.dp1  = para(i).dp1 ;
    vhpicStruct.dp2  = para(i).dp2 ;
    vhpicStruct.Lin  = para(i).Lin ;
    vhpicStruct.lp1  = para(i).lp1 ;
    vhpicStruct.lp2  = para(i).lp2 ;
    vhpicStruct.n1   = para(i).n1  ;
    vhpicStruct.n2   = para(i).n2  ;
    vhpicStruct.la1  = para(i).la1 ;
    vhpicStruct.la2  = para(i).la2 ;
    vhpicStruct.lb1  = para(i).lb1 ;
    vhpicStruct.lb2  = para(i).lb2 ;
    vhpicStruct.Din  = para(i).Din ;
    vhpicStruct.Lout = para(i).Lout;
    vhpicStruct.bp1 = para(i).bp1;
    vhpicStruct.bp2 = para(i).bp2;
    vhpicStruct.nc1 = para(i).nc1;
    vhpicStruct.nc2 = para(i).nc2;
    vhpicStruct.xSection1 = para(i).xSection1;
    vhpicStruct.xSection2 = para(i).xSection2;
    vhpicStruct.lv1 = lv1;
    vhpicStruct.lv2 = lv2;
    vhpicStruct.Dbias = Dbias;
    [pressure1ClosedIB,pressure2ClosedIB] = ...
         vesselInBiasHaveInnerPerfBothClosedCompCalc(massFlowE,Fre,time,...
        para(i).L1,para(i).L2,para(i).Dpipe...
        ,vhpicStruct...
        ,para(i).sectionL1,para(i).sectionL2,...
        'a',para(i).opt.acousticVelocity,'isDamping',para(i).opt.isDamping,'friction',PerfClosedCoeffFriction,...
        'meanFlowVelocity',PerfClosedMeanFlowVelocity,...
        'm',para(i).opt.mach,'notMach',para(i).opt.notMach,...
        'isOpening',isOpening);%,'coeffDamping',para(i).opt.coeffDamping,
end
end
