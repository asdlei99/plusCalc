function [pressure1,pressure2] = innerPipeVesselPulsationCalc(massFlowE,Frequency,time ...
    ,L1,L2,Lv,l,Dpipe,Dv,Din,Linner,Lin,Lout...
     ,sectionL1,sectionL2,varargin)
%������ݹ��ݵ�����
%  ���� L1     l    Lv      l    L2  
%              ______________        
%             |     _|_  lout|      
%  -----------| lin _ _Din   |----------
%             |______|_______|       
% ֱ�� Dpipe       Dv       Dpipe 
%             |Linner| 
pp=varargin;
k = nan;
oumiga = nan;
a = 345;%����

isDamping = 1;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%ʹ��ֱ�����۴��滺��ޣ���ô�����ʱ�൱������ֱ��ƴ��
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
            
        % case 'sv' %h����޽���
        %     Sv = val;
        % case 'dv' %h����޽���
        %     Dvessel = val;
            
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
    %��ĩ�˹ܵ�
    matrix_L2{count} = straightPipeTransferMatrix(L2,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
    matrix_Mv{count} = vesselHaveInnerPipeTransferMatrix(Lv,l,Dv,Dpipe,Linner,Lin,Lout,Din ...
        ,'a',a,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity,'f',f,'a',a ...
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