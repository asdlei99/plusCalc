function M = vesselHavePerfPipeInletOrifTransferMatrix(Dpipe,Dv,l,Lv,...
    lc,lv,Dp,Lin,Lout,V,Din,lo,varargin)

%�������������ӿ׹ܣ��ӿװ�ṹ?
%      L1     l        Lv       l    L2  
%              _________________        
%             |   | dp(n)    |lo|
%             |_ _|_ _ lc    |  |      
%  -----------|_ _ _ _   Din    |----------
%             |Lin|Lout      |  |
%             |___|__________|__|       
%    Dpipe            Dv           Dpipe 
%              
%
% Lin �ڲ�׹���ڶγ��� ��ķ���ȹ�����ֱ��
% Lout�ڲ�׹ܳ��ڶγ���
% lc �׹ܱں�
% dp �׹�ÿһ���׿׾�
% n  ���׸���
% Dp ��Ч��ķ���ȹ�����С��dp*n
% V  ��ķ���ȹ��������
% lv ��ķ���ȹ���������
% lo �װ���뻺��޳��ڵľ���
%
%       L1  l    Lv          l    L2  
%                   _____________        
%                  | dp(n)    |lo|
%                  |_ _ lc    |  |      
%  ----------------|_ _   Din    |----------
%          lc_| |_ |Lout      |  |
%           |     ||__________|__|       
%           |  Dp |
%        lv |  V  |
%           |     |
%           |_____|
%             Lin
%  Dpipe           Dv               Dpipe

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
        case 'coeffdamping' %����ϵ����
            coeffDamping = val;
        case 'damping' %����ϵ����
            coeffDamping = val;
        case 'friction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
            coeffFriction = val;
        case 'coefffriction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
            coeffFriction = val;
        case 'meanflowvelocity' %ƽ����
            meanFlowVelocity = val;
        case 'flowvelocity' %ƽ����
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

if isnan(a)
    error('���ٱ��붨��');
end
if isnan(k)
	if isnan(oumiga)
		if isnan(f)
			error('��û������kʱ�����ٶ���oumiga,f,acoustic�е�����');
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
    error(['��ָ�����٣������ǹܵ����뻺���ʱ�����٣�',...
    '����Ҫָ����������٣�����ʹ��һ����������Ԫ�ص�����[pipe��vessel]']);
end
mfvVessel = meanFlowVelocity(2);
if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('����Ҫ�������ᣬ��û�ж�������ϵ�����趨�塰coeffFriction���ܵ�Ħ��ϵ��');
        end
        if isnan(meanFlowVelocity)
            error('����Ҫ�������ᣬ��û�ж�������ϵ�����趨�塰meanFlowVelocity��ƽ������');
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
            error('ʹ��ֱ�ܵ�Ч����������������趨��ƽ������');
        end
    end
end
if length(meanFlowVelocity) < 2
    if isnan(coeffDamping) < 2
        error('������ȫ������meanFlowVelocity����coeffDamping');
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

M1 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMachStraight.mach,'notmach',optMachStraight.notMach);
M2 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMachStraight.mach,'notmach',optMachStraight.notMach);
optDamping.isDamping = isDamping;
optDamping.coeffDamping = coeffDamping(2);%����޵�����ϵ��
optDamping.meanFlowVelocity = meanFlowVelocity(2);%�����ƽ����???
Mv = havePerforatedPipeInletOrifTransferMatrix(a,k,Dpipe,Dv,Lv,...
    lc,lv,Dp,Lin,Lout,V,Din,lo,optDamping,optMachVessel,mfvVessel);
M = M2 * Mv * M1;
end
%���ﶼ����ֱ�ܵ�???
function M = havePerforatedPipeInletOrifTransferMatrix(a,k,Dpipe,Dv,Lv ...
    ,lc,lv,Dp,Lin,Lout,V,Din,lo,optDamping,optMach,mfvVessel)
%�������������ӿ׹ܣ��ӿװ�ṹ?
%      L1     l        Lv       l    L2  
%              _________________        
%             |   | dp(n)    |lo|
%             |_ _|_ _ lc    |  |      
%  -----------|_ _ _ _   Din    |----------
%             |Lin|Lout      |  |
%             |___|__________|__|       
%    Dpipe            Dv           Dpipe 
%              
%
% Lin �ڲ�׹���ڶγ��� ��ķ���ȹ�����ֱ��
% Lout�ڲ�׹ܳ��ڶγ���
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
%                  | dp(n)    |lo|
%                  |_ _ lc    |  |      
%  ----------------|_ _   Din    |----------
%          lc_| |_ |Lout      |  |
%           |     ||__________|__|       
%           |  Dp |
%        lv |  V  |
%           |     |
%           |_____|
%             Lin
%  Dpipe           Dv               Dpipe
%section  1                           2   ����޷ֵ�������
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
    
    Lv1 = Lv - Lin - Lout-lo;%������ڲ�׹��޽��ӵ�����???
    if ((Lv1 < 0))
        error('���ȳߴ�����');
    end
    Mv1 = straightPipeTransferMatrix(Lv1,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    Mv2 = straightPipeTransferMatrix(lo,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    
    %��??�侶�Ĵ��ݾ�???
    Sv = pi.* Dv.^2 ./ 4;
    Spipe = pi.* Dpipe.^2 ./ 4;
    %SinnerPipe = pi .* Din.^2 ./ 4;
    %mfvInnerPipe = mfvVessel .* Sv ./ SinnerPipe;%�ڲ�ܵ�ƽ����??
    %LM = sudEnlargeTransferMatrix(Spipe,Sv,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach,'notMach',optMach.notMach);
    %LM = sudReduceTransferMatrix(Spipe,Sv,1,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach);
    RM = sudReduceTransferMatrix(Sv,Spipe,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach,'notMach',optMach.notMach);
    %RM = sudReduceTransferMatrix(Sv,Spipe,0,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach);
    %�ڲ��ǻ�崫�ݾ�???���
    innerLM = innerPipeCavityTransferMatrix(Dv,Din,Lout,'a',a,'k',k);
    %�ڲ�ܵĹܵ���??����
    innerPipeDampingCoeff = Dv^3 / Din^3 * optDamping.coeffDamping;%����ϵ���Ĵ�???
    innerPM = straightPipeTransferMatrix(Lout,'k',k,'d',Din,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',innerPipeDampingCoeff...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    %innerPML = [1,0;0,1]; 
    %��ķ���ȹ��������ݾ�???
    HM = HelmholtzResonatorTransferMatrix(V,lv,lc,Dp,'a',a,'k',k);
    %�װ����
    OM = orificeTransferMatrix(Dv,Din,mfvVessel);
    M = RM * Mv2 * OM * Mv1 * innerLM * innerPM * HM;
end