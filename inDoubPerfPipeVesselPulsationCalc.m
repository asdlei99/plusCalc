function [pressure1,pressure2] = inDoubPerfPipeVesselPulsationCalc(massFlowE,Frequency,time ...
    ,L1,L2,Dpipe,Dv,l,Lv,lc1,lc2,lv1,lv2,dp1,dp2,n1,n2,Lin,Lout,Li,Lo,V1,V2,Din1,Din2...
     ,sectionL1,sectionL2,varargin)
%�������������ӿ׹ܣ��ӿװ�ṹ?
%      L1     l        Lv        l    L2  
%              __________________        
%             |   | dp1(n1)  |   |dp2(n2)
%             |_ _|_ _ lc1_ _|_ _|lc2      
%  -----------|_ _ _ _ Din1 _ _ _|----------
%             |Lin|Lout   Li |Lo |Din2
%             |___|__________|___|       
%    Dpipe            Dv           Dpipe 
%              
%
% Lin ����ڲ�׹���ڶγ��� ��Ч��ķ���ȹ�����ֱ����Li �Ҳ��ڲ�׹���ڶγ��� ��Ч��ķ���ȹ�����ֱ��
% Lout����ڲ�׹ܳ��ڶγ��ȣ�Lo �Ҳ��ڲ�׹ܳ��ڶγ���
% lc1 ���׹ܱں�
% lc2 �Ҳ�׹ܱں�
% dp1 ���׹�ÿһ���׿׾���dp2 �Ҳ�׹�ÿһ���׿׾�
% n1  ���׹ܿ��׸�����    n2  �Ҳ�׹ܿ��׸���
% Dp1 ���׹ܵ�Ч��ķ���ȹ�����С��dp1*n1��Dp2 �Ҳ�׹ܵ�Ч��ķ���ȹ�����С��dp2*n2
% V1  ��ລķ���ȹ����������V2  �Ҳລķ���ȹ��������
% lv1 ���׹ܵ�Ч��ķ���ȹ��������ȣ�lv2 �Ҳ�׹ܵ�Ч��ķ���ȹ���������
% Din1���׹ܹܾ��� Din2�Ҳ�׹ܹܾ�
%
%       L1  l    Lv          l    L2  
%                   ___________        
%                  |dp1(n1)    |dp2(n2)
%                  |_ _ lc1 _ _|lc2        
%  ----------------|_ _Din1 _ _|----------------
%         lc1_| |_ |Lout   Din2| _| |_ lc2 
%           |     ||________Li_|| Dp2 |  
%           | Dp1 |             |     |
%        lv1|  V1 |             | V2  |lv2
%           |     |             |     |
%           |_____|             |_____|
%             Lin                 Lo
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
    matrix_Mv{count} = vesselHaveDoubPerfPipeTransferMatrix(Dpipe,Dv,l,Lv,lc1,lc2,lv1,lv2,dp1,dp2,n1,n2,Lin,Lout,Li,Lo,V1,V2,Din1,Din2 ...
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