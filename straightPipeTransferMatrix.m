function [M,k,coeffDamping] = straightPipeTransferMatrix(L,varargin )
%ֱ�ܴ��ݾ���
% 
pp=varargin;
k = nan;
oumiga = nan;
f = nan;
a = nan;%����
S = nan;
Dpipe = nan;
isDamping = 0;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
dynViscosity = nan;
density = nan;
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach
calcWay2 = 0;%ʹ������һ�ּ��㴫�ݾ���ķ�����������Pulsation and Vibration Analysis of Compressor / Page.421,equ��10-34��
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 's' %����
            S = val;
            Dpipe = (4*S/pi)^0.5;
        case 'd' %�ܵ�ֱ��
            Dpipe = val;
            S = (pi.*Dpipe^2)./4;
        case 'k' %����
        	k = val;
        case 'oumiga' %ԲƵ��
        	oumiga = val;
        case 'f' %����Ƶ��
        	f = val;
        case 'a' %����
        	a = val; 
        case 'acousticvelocity' %����
        	a = val;
        case 'acoustic' %����
        	a = val;
        case 'isdamping' %�Ƿ��������
            isDamping = val;   
        case 'coeffdamping' %����ϵ��
            coeffDamping = val;
        case 'damping' %����ϵ��
            coeffDamping = val;
        case 'friction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
            coeffFriction = val;
        case 'coefffriction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
            coeffFriction = val;
        case 'meanflowvelocity' %ƽ�����٣���������ϵ��ʱʹ��
            meanFlowVelocity = val;
        case 'flowvelocity' %ƽ�����٣���������ϵ��ʱʹ��
            meanFlowVelocity = val;
        case 'mach'%��������������������ʹ�ô�������Ĺ�ʽ����
            mach = val;
        case 'm'
            mach = val;
        case 'notmach'
            notMach = val;
        case 'calcway2'
            calcWay2 = val;
        case 'dynvis'%����ѧճ��pa-s
            dynViscosity = val;
        case 'dynviscosity'%����ѧճ��pa-s
            dynViscosity = val;
        case 'density'%�ܶ�
            density = val;
        otherwise
       		error('��������%s',prop);
    end
end
if isnan(a)
    error('���ٱ��붨��');
end
if isnan(S)
    error('���ӻ���޵Ĺܵ��������Ҫ���塮S��,���塮d��ֱ��');
end
%����û�û�ж���k��ô��Ҫ�����������м���
if isnan(k)
	if isnan(oumiga)
		if isnan(f)
			error('��û������kʱ��������Ҫ����oumiga,f,acoustic�е�����');
		else
			oumiga = 2.*f.*pi;
		end
	end
	k = oumiga./a;
end

if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('����Ҫ�������ᣬ��û�ж�������ϵ������Ҫ���塰coeffFriction���ܵ�Ħ��ϵ��');
        end
        if isnan(meanFlowVelocity)
            error('����Ҫ�������ᣬ��û�ж�������ϵ������Ҫ���塰meanFlowVelocity��ƽ������');
        end
        coeffDamping = (4*coeffFriction*meanFlowVelocity/Dpipe)/(2*a);
    end
end
if ~notMach
    if isnan(mach)
        if isnan(meanFlowVelocity)
            mach = 0;
        else
            mach = meanFlowVelocity / a;
        end
    end
end
%% ����
if isDamping
    if calcWay2
        %���⹫ʽ
        if isnan(dynViscosity)
            error('ʹ��calcWay2������Ҫ���嶯��ѧճ������dynvis');
        end
        if isnan(density)
            error('ʹ��calcWay2������Ҫ�����ܶ�����density');
        end
        if isnan(mach)
            if isnan(meanFlowVelocity)
                mach = 0;
            else
                mach = meanFlowVelocity / a;
            end
        end
        Acoeff = (2/(a*Dpipe)) * (pi * dynViscosity * f / density)^0.5;
        Kcoeff = (Acoeff + 1i*k) / (1-mach^2);
        Ecoeff = exp(-Kcoeff * L * mach);
        MA = cosh(Kcoeff * L)*Ecoeff;
        MB = (density * a / S)*sinh(Kcoeff * L)*Ecoeff;
        MC = (S/(density * a))*sinh(Kcoeff * L)*Ecoeff;
        MD = MA;
        M = [MD/(MD*MA-MB*MC),-MB/((density*S)*(MD*MA-MB*MC));...
            (density*S)*MC/(MB*MC-MA*MD),-MA/(MB*MC-MA*MD)];
    else
        %������ʽ
        if notMach
            M = [cosh(coeffDamping.*L).*cos(k.*L)+1i*sinh(coeffDamping.*L).*sin(k*L)...
                ,-(a./S)*(sinh(coeffDamping.*L).*cos(k.*L) + 1i.*cosh(coeffDamping.*L).*sin(k.*L))...%1iΪ�����鲿
                ;...x
                -(S./a).*( sinh(coeffDamping.*L).*cos(k.*L) + 1i.*cosh(coeffDamping.*L).*sin(k.*L) )...
                ,cosh(coeffDamping.*L).*cos(k.*L)+1i.*sinh(coeffDamping.*L).*sin(k.*L)];
        else
            if isnan(mach)
                error('�붨�������');
            end
            mm = 1-mach.^2;
            M = [cosh(coeffDamping.*L./mm).*cos(k.*L./mm)+1i*sinh(coeffDamping.*L./mm).*sin(k*L./mm)...
                ,-(a./S)*(sinh(coeffDamping.*L./mm).*cos(k.*L./mm) + 1i.*cosh(coeffDamping.*L./mm).*sin(k.*L./mm))...%1iΪ�����鲿
                ;...x
                -(S./a).*( sinh(coeffDamping.*L./mm).*cos(k.*L./mm) + 1i.*cosh(coeffDamping.*L./mm).*sin(k.*L./mm) )...
                ,cosh(coeffDamping.*L./mm).*cos(k.*L./mm)+1i.*sinh(coeffDamping.*L./mm).*sin(k.*L./mm)];
        end
    end
else
    if notMach
        M = [cos(k.*L),-1i.*(a./S).*sin(k.*L);...
            -1i.*(S./a).*sin(k.*L),cos(k.*L)];
    else
        mm = 1-mach.^2;
        M = [cos(k.*L./mm),-1i.*(a./S).*sin(k.*L./mm);...
            -1i.*(S./a).*sin(k.*L./mm),cos(k.*L./mm)];
    end
end
end

