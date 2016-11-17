function [M,k,coeffDamping] = straightPipeTransferMatrix(L,varargin )
%直管传递矩阵
% 
pp=varargin;
k = nan;
oumiga = nan;
f = nan;
a = nan;%声速
S = nan;
Dpipe = nan;
isDamping = 0;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
mach = nan;
notMach = 0;%强制不使用mach
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 's' %截面
            S = val;
        case 'd' %管道直径
            Dpipe = val;
            S = (pi.*Dpipe^2)./4;
        case 'k' %波数
        	k = val;
        case 'oumiga' %圆频率
        	oumiga = val;
        case 'f' %脉动频率
        	f = val;
        case 'a' %声速
        	a = val; 
        case 'acousticvelocity' %声速
        	a = val;
        case 'acoustic' %声速
        	a = val;
        case 'isdamping' %是否包含阻尼
            isDamping = val;   
        case 'coeffdamping' %阻尼系数
            coeffDamping = val;
        case 'damping' %阻尼系数
            coeffDamping = val;
        case 'friction' %管道摩擦系数，计算阻尼系数时使用
            coeffFriction = val;
        case 'coefffriction' %管道摩擦系数，计算阻尼系数时使用
            coeffFriction = val;
        case 'meanflowvelocity' %平均流速，计算阻尼系数时使用
            meanFlowVelocity = val;
        case 'flowvelocity' %平均流速，计算阻尼系数时使用
            meanFlowVelocity = val;
        case 'mach'%马赫数，加入马赫数将会使用带马赫数的公式计算
            mach = val;
        case 'm'
            mach = val;
        case 'notmach'
            notMach = val;
        otherwise
       		error('参数错误%s',prop);
    end
end
if isnan(a)
    error('声速必须定义');
end
if isnan(S)
    error('连接缓冲罐的管道截面积需要定义‘S’,或定义‘d’直径');
end
%如果用户没有定义k那么需要根据其他进行计算
if isnan(k)
	if isnan(oumiga)
		if isnan(f)
			error('在没有输入k时，至少需要定义oumiga,f,acoustic中的两个');
		else
			oumiga = 2.*f.*pi;
		end
	end
	k = oumiga./a;
end
if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('若需要计算阻尼，且没有定义阻尼系数，需要定义“coeffFriction”管道摩擦系数');
        end
        if isnan(meanFlowVelocity)
            error('若需要计算阻尼，且没有定义阻尼系数，需要定义“meanFlowVelocity”平均流速');
        end

        if isnan(Dpipe)
            Dpipe = (4*S/pi)^0.5;
        end
        coeffDamping = (4*coeffFriction*meanFlowVelocity/Dpipe)/(2*a);
    end
end
if ~notMach%允许使用马赫
    if isnan(mach)
        if ~isnan(a) && ~isnan(meanFlowVelocity)
            mach = meanFlowVelocity./a;
        end
    end
else
    mach = nan;
end
%% 计算
if isDamping
    if isnan(mach)
        M = [cosh(coeffDamping.*L).*cos(k.*L)+1i*sinh(coeffDamping.*L).*sin(k*L)...
            ,-(a./S)*(sinh(coeffDamping.*L).*cos(k.*L) + 1i.*cosh(coeffDamping.*L).*sin(k.*L))...%1i为复数虚部
            ;...x
            -(S./a).*( sinh(coeffDamping.*L).*cos(k.*L) + 1i.*cosh(coeffDamping.*L).*sin(k.*L) )...
            ,cosh(coeffDamping.*L).*cos(k.*L)+1i.*sinh(coeffDamping.*L).*sin(k.*L)];
    else
        mm = 1-mach.^2;
        M = [cosh(coeffDamping.*L./mm).*cos(k.*L./mm)+1i*sinh(coeffDamping.*L./mm).*sin(k*L./mm)...
            ,-(a./S)*(sinh(coeffDamping.*L./mm).*cos(k.*L./mm) + 1i.*cosh(coeffDamping.*L./mm).*sin(k.*L./mm))...%1i为复数虚部
            ;...x
            -(S./a).*( sinh(coeffDamping.*L./mm).*cos(k.*L./mm) + 1i.*cosh(coeffDamping.*L./mm).*sin(k.*L./mm) )...
            ,cosh(coeffDamping.*L./mm).*cos(k.*L./mm)+1i.*sinh(coeffDamping.*L./mm).*sin(k.*L./mm)];
    end
else
    if isnan(mach)
        M = [cos(k.*L),-1i.*(a./S).*sin(k.*L);...
            -1i.*(S./a).*sin(k.*L),cos(k.*L)];
    else
        mm = 1-mach.^2;
        M = [cos(k.*L./mm),-1i.*(a./S).*sin(k.*L./mm);...
            -1i.*(S./a).*sin(k.*L./mm),cos(k.*L./mm)];
    end
end
end

