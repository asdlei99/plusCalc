function [pressure1,pressure2] = vesselHavePerfInletNoneOutCalc(massFlowE,Frequency,time ...
    ,L1,L2,Dpipe,vhpicStruct,sectionL1,sectionL2,varargin)
%�������������ӿ׹�,���׸��������Ե�ЧΪ��ķ���ȹ�����.Lout����Ϊ�ڲ忪�ڹܣ�������
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             | lc dp(n1) |                     |
%             |___ _ _ ___|___________          |     
%  -----------|___ _ _ ___ ___________ Din      |----------
%             |la1 lp1 la2|                     |
%             |___________|_____________________|       
%                  Lin         Lout
%    Dpipe                   Dv                     Dpipe 
%              
%
% Lin �ڲ�׹���ڶγ��� 
% Lout�ڲ�ܳ��ڶγ���
% lc  �׹ܱں�
% dp  �׹�ÿһ���׿׾�
% n1  �׹���ڶο��׸����� 
% la1 �׹���ڶξ���ڳ��� 
% la2 �׹���ڶξ���峤��
% lp1 �׹���ڶο��׳���
% Din �׹ܹܾ���
% xSection1 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��

pp=varargin;
k = nan;
oumiga = nan;
a = 345;%����

isDamping = 1;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach
isOpening = 1;
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'a' %����
            a = val; 
        case 'acousticvelocity' %����
            a = val;
        case 'acoustic' %����
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
        case 'mach' %����������������������ʹ�ô��������Ĺ�ʽ����
            mach = val;
        case 'm'
            mach = val;
        case 'notmach' %ǿ���������������趨
            notMach = val;
        case 'k' %����
        	k = val;
        case 'oumiga' %ԲƵ��
        	oumiga = val;
        case 'isopening'%�ܵ�ĩ���Ƿ�Ϊ�޷����(����)�����Ϊ0������Ϊ�տڣ���������
            isOpening = val;
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
    %��ĩ�˹ܵ�
    matrix_L2{count} = straightPipeTransferMatrix(L2,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach,'coeffDamping',coeffDamping,'k',k,'oumiga',oumiga);
    matrix_Mv{count} = vesselHavePerfInletNoneOutTransferMatrix(Dpipe,vhpicStruct.Dv,vhpicStruct.l,vhpicStruct.Lv...
        ,vhpicStruct.lc,vhpicStruct.dp,vhpicStruct.lp1,vhpicStruct.n1...
        ,vhpicStruct.la1,vhpicStruct.la2,vhpicStruct.Din,vhpicStruct.Lout...
        ,vhpicStruct.xSection1...
        ,'f',f,'a',a,'k',k,'oumiga',oumiga...
        ,'coeffDamping',coeffDamping,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity);
    matrix_L1{count} = straightPipeTransferMatrix(L1,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach,'coeffDamping',coeffDamping,'k',k,'oumiga',oumiga);
    matrix_total = matrix_L2{count} * matrix_Mv{count} * matrix_L1{count};
    A = matrix_total(1,1);
    B = matrix_total(1,2);
    C = matrix_total(2,1);
    D = matrix_total(2,2);
    if(isOpening)
        pressureE1(count) = ((-B/A)*massFlowE(count));
    else
        pressureE1(count) = ((-D/C)*massFlowE(count));
    end
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