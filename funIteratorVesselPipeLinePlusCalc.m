function calcDatas = funIteratorVesselPipeLinePlusCalc(time,massFlow,Fs,plusBaseFrequency,acousticVelocity...
    ,L1,L2,l,Dpipe,Dv,Lv,IteratorValueName,varargin)
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
% 'xx',
iteCount = eval(sprintf('length(%s)',IteratorValueName));

% 
% xSection1��xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
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
