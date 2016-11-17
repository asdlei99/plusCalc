function [M,k] = vesselTransferMatrix(L,l,varargin )
%�����Ĵ��ݾ���
%      L1     l         Lv      l    L2  
%              ______________        
%             |              |
%             |              |      
%  -----------|              |----------
%             |              |
%             |______________|       
%        Dpipe      Dv           Dpipe 

pp=varargin;
k = nan;
oumiga = nan;
f = nan;
a = nan;%����
S = nan;
Sv = nan;

Dpipe = nan;
Dvessel = nan;
isDamping = 1;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 0;%ʹ��ֱ�����۴��滺��ޣ���ô�����ʱ�൱������ֱ��ƴ��
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach


while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 's' %����
            S = val;
        case 'd' %�ܵ�ֱ��
            Dpipe = val;
            S = (pi.*Dpipe.^2)./4;
        case 'sv' %h����޽���
            Sv = val;
        case 'dv' %h����޽���
            Dvessel = val;
            Sv = (pi.*Dvessel.^2)./4;
        case 'k'
            k = val;
        case 'oumiga'
            oumiga = val;
        case 'f'
            f = val;
        case 'a'
            a = val;
        case 'acousticvelocity'
            a = val;
        case 'acoustic'
            a = val;
        case 'isdamping' %�Ƿ��������
            isDamping = val;   
        case 'coeffdamping' %����ϵ������һ������Ϊ2����������һ������ֱ�ܵģ��ڶ���������޵�
            coeffDamping = val;
        case 'damping' %����ϵ������һ������Ϊ2����������һ������ֱ�ܵģ��ڶ���������޵�
            coeffDamping = val;
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
        otherwise
            error('��������%s',prop);
    end
end
%����û�û�ж���k��ô��Ҫ�����������м���
if isnan(a)
    error('���ٱ��붨��');
end
if isnan(S)
    error('���ӻ���޵Ĺܵ��������Ҫ���塮S��,���塮d��ֱ��');
end
if isnan(Sv)
    error('����޵Ľ������Ҫ���塮Sv��,���塮dv��ֱ��');
end
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
%��������
if ~isnan(meanFlowVelocity)
    if 1 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity.*S./Sv;
        meanFlowVelocity = [meanFlowVelocity,mfvVessel];
    end
end
if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('����Ҫ�������ᣬ��û�ж�������ϵ������Ҫ���塰coeffFriction���ܵ�Ħ��ϵ��');
        end
        if isnan(meanFlowVelocity)
            error('����Ҫ�������ᣬ��û�ж�������ϵ������Ҫ���塰meanFlowVelocity��ƽ������');
        end

        if isnan(Dpipe)
            Dpipe = (4.*S./pi).^0.5;
        end
        if isnan(Dvessel)
            Dvessel = (4.*Sv./pi).^0.5;
        end
        Dtemp = [Dpipe,Dvessel];
        coeffDamping = (4.*coeffFriction.*meanFlowVelocity./Dtemp)./(2.*a);       
    end
    if isUseStaightPipe
        if isnan(meanFlowVelocity)
            error('ʹ��ֱ�ܵ�Ч�����������������Ҫ����ƽ������');
        end
    end
end
if ~notMach%����ʹ�����
    if isnan(mach)
        if ~isnan(meanFlowVelocity)
            mach = meanFlowVelocity./a;
        end
    elseif(length(mach) == 1)
          mach(2) = meanFlowVelocity(2)/a;
    end
else
    mach = nan;
end
optMachStraight.notMach = notMach;
optMachStraight.mach = mach(1);
optMachVessel.notMach = notMach;
if(notMach)
    if(length(mach) == 1)
        optMachVessel.mach = mach(1);
    end
else
    optMachVessel.mach = mach(2);
end

%ǰ�ܵ����ݾ���
M1 = straightPipeTransferMatrix(l,'k',k,'S',S,'a',a,...
    'isDamping',isDamping,'coeffDamping',coeffDamping(1)...
    ,'mach',optMachStraight.mach,'notmach',optMachStraight.notMach);
%����޴��ݾ���
%�����������
optDamp.isDamping = 0;
optDamp.coeffDamping = coeffDamping(2);
optDamp.meanFlowVelocity = meanFlowVelocity(2);
Mv = vesselMatrix(isUseStaightPipe,L,k,S,Sv,a...
    ,optDamp,optMachVessel);
%��ܵ����ݾ���
M2 = straightPipeTransferMatrix(l,'k',k,'S',S,'a',a,...
    'isDamping',isDamping,'coeffDamping',coeffDamping(1)...
    ,'mach',optMachStraight.mach,'notmach',optMachStraight.notMach);

%M = [1,0;0,1];
M = M2*Mv*M1;
end

function Mv = vesselMatrix(isUseStaightPipe,L,k,S,Sv,a,optDamping,optMach)
    if ~isstruct(optDamping)
        if isnan(optDamping)
            optDamping.isDamping = 0;
            optDamping.coeffDamping = 0;
            optDamping.meanFlowVelocity = 10;
        end
    end
    if ~isstruct(optMach)
        if isnan(optMach)
            optMach.notMach = 1;
            optMach.mach = 0;
        end
    end
    if isUseStaightPipe
        ML = straightPipeTransferMatrix(L,'k',k,'S',Sv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
        A = 0;
        B = 0;
        %����������Ͳ�����������Ա侶�Ĵ��ݾ�����Ӱ��
        if optMach.notMach
            A = optDamping.coeffDamping*optDamping.meanFlowVelocity/Sv;
            B = A;           
            Mv = [1,B;0,1]*ML*[1,A;0,1];
            return;
        end
        RM = sudReduceTransferMatrix(Sv,S,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach);
        LM = sudEnlargeTransferMatrix(S,Sv,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach);
        Mv = RM*ML*LM;
        return;
    end
    %ʹ���ݻ����ݾ���
    V = Sv*L;
    Mv = [1,0;-1i.*V.*k./a,1];
end