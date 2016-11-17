function [pressure1,pressure2] = inPerfPipeInletOrifVesselPulsationCalc(massFlowE,Frequency,time ...
    ,L1,L2,Dpipe,Dv,l,Lv,lc,lv,Dp,Lin,Lout,V,Din,lo...
     ,sectionL1,sectionL2,varargin)
%�������������ӿ׹ܣ��ӿװ�ṹ?
%      L1     l        Lv       l    L2  
%              _________________        
%             |   | dp(n)    |  |
%             |_ _|_ _ lc    |  |      
%  -----------|_ _ _ _   Din    |----------
%             |lin|lout      |  |
%             |___|__________|__|       
%    Dpipe            Dv           Dpipe 
%              
%
% lin �ڲ�׹���ڶγ��� ��ķ���ȹ�����ֱ��
% lout�ڲ�׹ܳ��ڶγ���
% lc �׹ܱں�
% dp �׹�ÿһ���׿׾�
% n  ���׸���
% Dp ��Ч��ķ���ȹ�����С��dp*n
% V  ��ķ���ȹ��������
% lv ��ķ���ȹ���������
% 
%
%       L1  l    Lv          l    L2  
%                   _____________        
%                  | dp(n)    |  |
%                  |_ _ lc    |  |      
%  ----------------|_ _   Din    |----------
%          lc_| |_ |lout      |  |
%           |     ||__________|__|       
%           |  Dp |
%        lv |  V  |
%           |     |
%           |_____|
%             lin
%  Dpipe           Dv               Dpipe
pp=varargin;
k = nan;
oumiga = nan;
a = 345;%����?

isDamping = 1;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%ʹ��ֱ�����۴��滺��ޣ���ô�����ʱ�൱������ֱ��ƴ��?
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)   
        case 'a' %����?
            a = val; 
        case 'acousticvelocity' %����?
            a = val;
        case 'acoustic' %����?
            a = val;
        case 'isdamping' %�Ƿ��������
            isDamping = val;   
        case 'friction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
            coeffFriction = val;
        case 'coefffriction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
            coeffFriction = val;
        case 'meanflowvelocity' %ƽ�����٣���������ϵ��ʱʹ��
            meanFlowVelocity = val;
        case 'flowvelocity' %ƽ�����٣���������ϵ��ʱʹ��
            meanFlowVelocity = val;
        case 'mach' %��������������������ʹ�ô�������Ĺ�ʽ����
            mach = val;
        case 'isusestaightpipe'
            isUseStaightPipe = val;%ʹ��ֱ���������
        case 'usestaightpipe'
            isUseStaightPipe = val;
        case 'm'
            mach = val;
        case 'notmach' %ǿ��������������趨
            notMach = val;
        otherwise
            error('��������%s',prop);
    end
end
if isnan(a)
    error('���ٱ��붨��');
end

count = 1;
pressureE1 = [];
for i = 1:length(Frequency)
    f = Frequency(i);
    %��ĩ�˹ܵ�?
    matrix_L2{count} = straightPipeTransferMatrix(L2,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
    matrix_Mv{count} = vesselHavePerfPipeInletOrifTransferMatrix(Dpipe,Dv,l,Lv,lc,lv,Dp,Lin,Lout,V,Din,lo ...
        ,'a',a,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity,'f',f ...
        ,'isUseStaightPipe',isUseStaightPipe,'m',mach,'notmach',notMach);
    matrix_L1{count} = straightPipeTransferMatrix(L1,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
    matrix_total = matrix_L2{count} * matrix_Mv{count} * matrix_L1{count};
    A = matrix_total(1,1);
    B = matrix_total(1,2);
    pressureE1(count) = ((-B/A)*massFlowE(count));
    count = count + 1;
end

count = 1;
pressure1 = [];
if ~isempty(sectionL1)
    for len = sectionL1
        count2 = 1;
        pTemp = [];
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrix_lx1 = straightPipeTransferMatrix(len,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach);
            pressureEi(count2) = matrix_lx1(1,1)*pressureE1(count2) + matrix_lx1(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end       
        pressure1(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end

count = 1;
pressure2 = [];
if ~isempty(sectionL2)
    for len = sectionL2
        count2 = 1;
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrix_lx2 = straightPipeTransferMatrix(len,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach);
            matrix_Xl2_total = matrix_lx2  * matrix_Mv{count2} * matrix_L1{count2};
        
            pressureEi(count2) = matrix_Xl2_total(1,1)*pressureE1(count2) + matrix_Xl2_total(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end
        pressure2(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end

end