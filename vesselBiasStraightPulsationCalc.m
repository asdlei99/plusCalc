function [pressure1,pressure2] = vesselBiasStraightPulsationCalc(massFlowE,Frequency,time ...
,L1,L2,Lv,l,Dpipe,Dv,lv1,Dbias,sectionL1,sectionL2,varargin)
%�������ڴ�λ������˳�ӵ�������������
% Dbias ƫ�ù��ڲ��뻺��޵Ĺܾ������ƫ�ù�û���ڲ��绺��ޣ�DbiasΪ0
%   Detailed explanation goes here
%   inlet   |  L1
%        l  |     Lv    
%   bias2___|_______________
%       |                   |  Dpipe
%       |lv1  V          lv2|�������� L2  
%       |___________________| outlet
%           Dv              l     
%�����Ĵ��ݾ���
pp=varargin;
a = nan;%����


isDamping = 0;
isOpening = 1;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%ʹ��ֱ�����۴��滺��ޣ���ô�����ʱ�൱������ֱ��ƴ��
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach
outletPressure = nan;%ָ������ѹ��
outletMassFlow = nan;%ָ��������������
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'd' %�ܵ�ֱ��
            Dpipe = val;
        case 'a'
        	a = val;
        case 'acousticvelocity'
        	a = val;
        case 'acoustic'
        	a = val;
        case 'isdamping' %�Ƿ��������
            isDamping = val;   
        case 'friction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ�ã����������һ������Ϊ2����������һ������ֱ�ܵģ��ڶ���������޵�
            coeffFriction = val;
        case 'coefffriction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ�ã����������һ������Ϊ2����������һ������ֱ�ܵģ��ڶ���������޵�
            coeffFriction = val;
        case 'meanflowvelocity' %ƽ�����٣���������ϵ��ʱʹ�ã����������һ������Ϊ2����������һ������ֱ�ܵģ��ڶ���������޵�
            meanFlowVelocity = val;
        case 'flowvelocity' %ƽ�����٣���������ϵ��ʱʹ��,ע�������������ֻ��һ����ֵʱ�������ٴ�����޵Ĺܵ������٣������ǻ�����������
            meanFlowVelocity = val;
        case 'isusestaightpipe'
            isUseStaightPipe = val;%ʹ��ֱ���������
        case 'usestaightpipe'
            isUseStaightPipe = val;
        case 'mach' %��������������������ʹ�ô�������Ĺ�ʽ����
            mach = val;
        case 'm'
            mach = val;
        case 'notmach'
            notMach = val;
        case 'isopening'
            isOpening = val;
        case 'outletpressure'
            outletPressure = val;
        case 'outletmassflow'
            outletMassFlow = val;
        otherwise
       		error('��������%s',prop);
    end
end
if isnan(outletPressure)
    if isOpening
        outletPressure = 0;
    end
end
if isnan(outletMassFlow)
    if ~isOpening
        outletMassFlow = 0;
    end
end
%����û�û�ж���k��ô��Ҫ�����������м���
if isnan(a)
    error('���ٱ��붨��');
end
count = 1;
pressureE1 = [];
for i = 1:length(Frequency)
    f = Frequency(i);
    %��ĩ�˹ܵ�
    matrix_L2{count} = straightPipeTransferMatrix(L2,'f',f,'a',a,'d',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
    matrix_Mv{count} = vesselBiasStraightTransferMatrix(Lv,l,lv1,Dbias ...
        ,'a',a,'d',Dpipe,'dv',Dv,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity,'f',f ...
        ,'isUseStaightPipe',isUseStaightPipe,'m',mach,'notmach',notMach);
    matrix_L1{count} = straightPipeTransferMatrix(L1,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
    matrix_total = matrix_L2{count} * matrix_Mv{count} * matrix_L1{count};
    A = matrix_total(1,1);
    B = matrix_total(1,2);
    C = matrix_total(2,1);
    D = matrix_total(2,2);

    
    if ~isnan(outletPressure)
        if length(outletPressure) > 1
            pressureE1(count) = (outletPressure(count)-(B*massFlowE(count)))/A;
        else
            pressureE1(count) = (outletPressure-(B*massFlowE(count)))/A;
        end
    elseif ~isnan(outletMassFlow)
        if length(outletMassFlow) > 1
            pressureE1(count) = (outletMassFlow(count)-(D*massFlowE(count)))/C;
        else
            pressureE1(count) = (outletMassFlow-(D*massFlowE(count)))/C;
        end
    end
%     if(isOpening)
%         pressureE1(count) = ((-B/A)*massFlowE(count));
%     else
% %         m2 = 50-1i.*50;%�ܵ�ĩ����������
% %         pressureE1(count) = m2+((-D/C)*massFlowE(count));
% %         p2 = 50+1000i;
% %         pressureE1(count) = p2+((-B/A)*massFlowE(count));
%             pressureE1(count) = ((-D/C)*massFlowE(count));    
%     end
    count = count + 1;
end

count = 1;
pressure1 = [];
if ~isempty(sectionL1)
    for len = sectionL1
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrix_lx1 = straightPipeTransferMatrix(len,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach);
            pressureEi(i) = matrix_lx1(1,1)*pressureE1(i) + matrix_lx1(1,2)*massFlowE(i);
        end       
        pressure1(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end

count = 1;
pressure2 = [];
if ~isempty(sectionL2)
    for len = sectionL2
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrix_lx2 = straightPipeTransferMatrix(len,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach);
            matrix_Xl2_total = matrix_lx2  * matrix_Mv{i} * matrix_L1{i};
        
            pressureEi(i) = matrix_Xl2_total(1,1)*pressureE1(i) + matrix_Xl2_total(1,2)*massFlowE(i);
        end
        pressure2(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end
end