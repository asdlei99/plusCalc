function M = vesselHaveInnerEnlargeTransferMatrix(Lv,l,Dv,Dpipe,Linner ...
    ,Le,Dr1,Dr2,varargin)

%�����ڲ��������Źܵ�����
%  ���� L1     l    Lv      l    L2  
%              ______________        
%             |      |Le(Lc) |
%             |     /        |      
%  -----------|Dr1     Dr2   |----------
%             |     \        |
%             |______|_______|       
% ֱ�� Dpipe      Dv           Dpipe 
%             |Linner| 
pp=varargin;
k = nan;
oumiga = nan;
f = nan;
a = nan;%����
isDamping = 1;%Ĭ��ʹ������
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
S = pi .* Dpipe.^2 ./ 4;
Sv = pi .* Dv.^2 ./ 4;
mfvVessel = nan;
if ~isnan(meanFlowVelocity)
    if 1 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity.*S./Sv;
        meanFlowVelocity = [meanFlowVelocity,mfvVessel];
    end
else 
    error(['��Ҫָ�����٣������ǹܵ����뻺���ʱ�����٣�',...
    '����Ҫָ����������٣�����ʹ��һ����������Ԫ�ص�����[pipe��vessel]']);
end
mfvVessel = meanFlowVelocity(2);
if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('����Ҫ�������ᣬ��û�ж�������ϵ������Ҫ���塰coeffFriction���ܵ�Ħ��ϵ��');
        end
        if isnan(meanFlowVelocity)
            error('����Ҫ�������ᣬ��û�ж�������ϵ������Ҫ���塰meanFlowVelocity��ƽ������');
        end
        Dtemp = [Dpipe,Dv];
        coeffDamping = (4.*coeffFriction.*meanFlowVelocity./Dtemp)./(2.*a);       
    end
    if length(coeffDamping)<2
        %���뿼������
        coeffDamping(2) = (4.*coeffFriction.*mfvVessel./Dv)./(2.*a);
    end
    if isUseStaightPipe
        if isnan(meanFlowVelocity)
            error('ʹ��ֱ�ܵ�Ч�����������������Ҫ����ƽ������');
        end
    end
end
if length(meanFlowVelocity) < 2
    if isnan(coeffDamping) < 2
        error('������ȫ������meanFlowVelocity����coeffDamping��Ҫ����һ��');
    end
end
if ~notMach%����ʹ�����
    if isnan(mach)%���û�����������
        if ~isnan(meanFlowVelocity)%���������ƽ������
            mach = meanFlowVelocity./a;
        end
    elseif(length(mach) == 1)%������������������������ĳ���Ϊ1��˵��ֻ������һ�������������޵������û�����ã���ô���㻺��޵��������֮ǰ����ѻ���޵�ƽ�����������ˣ�����ֱ����meanFlowVelocity(2)
          mach(2) = meanFlowVelocity(2)/a;
    end
else
    mach = nan;%������ʹ����գ���ô���������Ϊnan
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

M1 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMachStraight.mach,'notmach',optMachStraight.notMach);
M2 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMachStraight.mach,'notmach',optMachStraight.notMach);
optDamping.isDamping = isDamping;
optDamping.coeffDamping = coeffDamping(2);%����޵�����ϵ��
optDamping.meanFlowVelocity = meanFlowVelocity(2);%�����ƽ������
Mv = haveInnerReduceTransferMatrix(a,k,Lv,Dv,Dpipe,Linner ...
    ,Le,Dr1,Dr2,optDamping,optMachVessel,mfvVessel);
M = M2 * Mv * M1;
end
%���ﶼ����ֱ�ܵ�Ч
function M = haveInnerReduceTransferMatrix(a,k,Lv,Dv,Dpipe,Linner ...
    ,Le,Dr1,Dr2,optDamping,optMach,mfvVessel)
%  ���� L1     l    Lv      l    L2  
%              _____Le(Lc)___       
%             |      |       |
%             |     /        |      
%  -----------|Dr1     Dr2   |----------
%             |     \        |
%             |______|_______|       
% ֱ�� Dpipe      Dv           Dpipe 
%             |Linner| 
%section        1          2   ����޷ֵ���������
    if ~isstruct(optDamping)
        if isnan(optDamping)
            optDamping.isDamping = 0;
            optDamping.coeffDamping = 0;%ע�⣬����ǻ���޵�ף��ϵ��
            optDamping.meanFlowVelocity = 10;
        end
    end
    if ~isstruct(optMach)
        if isnan(optMach)
            optMach.notMach = 1;
            optMach.mach = 0;
        end
    end
    
    Lv2 = Lv - Linner;
    if (Lv2 < 0)
        error('���ȳߴ�����');
    end

    Mv1 = straightPipeTransferMatrix(Linner-Le,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);

    Mv2 = straightPipeTransferMatrix(Lv-Linner,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    %���ٱ侶�Ĵ��ݾ���
    Sv = pi.* Dv.^2 ./ 4;
    Spipe = pi.* Dpipe.^2 ./ 4;
    %SinnerPipe = pi .* Din.^2 ./ 4;
    %mfvInnerPipe = mfvVessel .* Sv ./ SinnerPipe;%�ڲ�ܵ�ƽ������
    %RM = sudReduceTransferMatrix(Spipe,Sv,1,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach);
    %LM = sudReduceTransferMatrix(Sv,Spipe,0,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach);
    %�ɽ����ܵ��������ڴ����ٱ侶�Ĵ��ݾ���
    LM = sudEnlargeTransferMatrix(Spipe,Sv,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach,'notMach',optMach.notMach);
    RM = sudReduceTransferMatrix(Sv,Spipe,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach,'notMach',optMach.notMach);
    Sv = pi.* Dv.^2 ./ 4;
    Sr2 = pi.* Dr2.^2 ./ 4;
    RMr = sudEnlargeTransferMatrix(Sr2,Sv,a...
        ,'coeffdamping',optDamping.coeffDamping...
        ,'mach',optMach.mach,'notmach',optMach.notMach);
    %�ڲ��ǻ�����
    innerLMEnlarge = innerEnlargeCavityTransferMatrix(Dv,Dr1,Le,'a',a,'k',k);
    %�ڲ��������ܴ��ݾ���
    innerEnlarge = innerEnlargeTransferMatrix(Dr1,Dr2,Le,'a',a,'k',k);
    M = RM * Mv2 * RMr * innerEnlarge * innerLMEnlarge *  Mv1 * LM;
end