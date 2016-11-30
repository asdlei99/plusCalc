function resCell = fun_vesselInBiasHaveInnerPerfBothClosedComp_ite_perforatedRate

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
    ,L1,L2,l,Dpipe,Dv,Lv,Lv1,lc ...
    ,dp1,dp2,n1,n2,la1,la2,lb1,lb2,Din,Lin,Lout
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
%% ��������ÿ׹ܽṹ�뵥һ˳�ӻ���޶Ա�
% massFlow Ϊ�������������
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
%{[]   ,'xֵ','ѹ������','1��Ƶ','2��Ƶ','3��Ƶ','��ǰѹ���������ֵ','�޺�ѹ���������ֵ'
% 'ֱ��',
% 'xx'

iteCount = eval(sprintf('length(%s)',IteratorValueName));

% 
% xSection1��xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
Lv2 = Lv - Lv1;%��ȡ�������һ�߳�
[multFre,varargin]= takeVararginProperty('multfre',varargin,[10,20,30]);
[isOpening,varargin]= takeVararginProperty('isOpening',varargin,1);
[useCalcTopFreIndex,varargin]= takeVararginProperty('isOpening',varargin,nan);

[FreRaw,AmpRaw,PhRaw,massFlowE] = frequencySpectrum(detrend(massFlow,'constant'),Fs);
Fre = FreRaw;
% ��ȡ��ҪƵ��
[pks,locs] = findpeaks(AmpRaw,'SORTSTR','descend');
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
opt.meanFlowVelocity =14.5;%14.5;%�ܵ�ƽ������
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
for i=1:iteCount
    para(i).sectionL1 = 0:accuracy:para(i).L1;
    para(i).sectionL2 = 0:accuracy:para(i).L2;
end

dataCount = 2;
calcDatas{1,2} = 'xֵ';
calcDatas{1,3} = 'ѹ������';
calcDatas{1,4} = '1��Ƶ';
calcDatas{1,5} = '2��Ƶ';
calcDatas{1,6} = '3��Ƶ';
calcDatas{1,7} = '��ǰѹ���������ֵ';
calcDatas{1,8} = '�޺�ѹ���������ֵ';
for i = 1:iteCount
    if i==1
        %����ֱ��
        %ֱ���ܳ�
        straightPipeLength = para(i).L1 + 2*para(i).l+para(i).Lv + para(i).L2;
        straightPipeSection = [para(i).sectionL1,...
                                para(i).L1 + 2*para(i).l+para(i).Lv + para(i).sectionL2];
    
        temp = find(para(i).L1>straightPipeSection);%�ҵ���������ڵ�����
        sepratorIndex = temp(end);
        temp = straightPipePulsationCalc(massFlowE,Fre,time,straightPipeLength,straightPipeSection...
        ,'d',para(i).Dpipe,'a',opt.acousticVelocity,'isDamping',opt.isDamping...
        ,'friction',opt.coeffFriction,'meanFlowVelocity',opt.meanFlowVelocity...
        ,'m',opt.mach,'notMach',opt.notMach,...
        'isOpening',isOpening);
        plusStraight = calcPuls(temp,dcpss);
        maxPlus1Straight(i) = max(plusStraight(1:sepratorIndex(i)));
        maxPlus2Straight(i) = max(plusStraight(sepratorIndex(i):end));
        multFreAmpValue_straightPipe{i} = calcWaveFreAmplitude(temp,Fs,multFre,'freErr',1);

        X = straightPipeSection;
        calcDatas{dataCount,1} = sprintf('ֱ��');
        calcDatas{dataCount,2} = X;
        calcDatas{dataCount,3} = plusStraight;
        calcDatas{dataCount,4} = multFreAmpValue_straightPipe{i}(1,:);
        calcDatas{dataCount,5} = multFreAmpValue_straightPipe{i}(2,:);
        calcDatas{dataCount,6} = multFreAmpValue_straightPipe{i}(3,:);
        calcDatas{dataCount,7} = maxPlus1Straight(i);
        calcDatas{dataCount,8} = maxPlus2Straight(i);
        dataCount = dataCount + 1;
    end
    
     %���㵥һ�����

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
        temp = eval(sprintf('%s(i)',IteratorValueName));
        calcDatas{dataCount,1} = sprintf('��һ�����,%s:%g',IteratorValueName,temp);
        calcDatas{dataCount,2} = X;
        calcDatas{dataCount,3} = plusOV{i};
        calcDatas{dataCount,4} = multFreAmpValue_OV{i}(1,:);
        calcDatas{dataCount,5} = multFreAmpValue_OV{i}(2,:);
        calcDatas{dataCount,6} = multFreAmpValue_OV{i}(3,:);
        calcDatas{dataCount,7} = maxPlus1;
        calcDatas{dataCount,8} = maxPlus2;
        dataCount = dataCount + 1;

end
