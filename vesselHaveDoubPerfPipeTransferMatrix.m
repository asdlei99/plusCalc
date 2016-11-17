function M = vesselHaveDoubPerfPipeTransferMatrix(Dpipe,Dv,l,Lv,...
    lc1,lc2,lv1,lv2,dp1,dp2,n1,n2,Lin,Lout,Li,Lo,V1,V2,Din1,Din2,varargin)

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
Mv = haveDoubPerforatedPipeTransferMatrix(a,k,Dpipe,Dv,Lv,...
    lc1,lc2,lv1,lv2,dp1,dp2,n1,n2,Lin,Lout,Li,Lo,V1,V2,Din1,Din2,optDamping,optMachVessel,mfvVessel);
M = M2 * Mv * M1;
end
%���ﶼ����ֱ�ܵ�???
function M = haveDoubPerforatedPipeTransferMatrix(a,k,Dpipe,Dv,Lv ...
    ,lc1,lc2,lv1,lv2,dp1,dp2,n1,n2,Lin,Lout,Li,Lo,V1,V2,Din1,Din2,optDamping,optMach,mfvVessel)
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
%     L1   l              Lv           l    L2  
%                   ___________        
%                  |dp1(n1)    |dp2(n2)
%                  |_ _ lc1 _ _|lc2        
%  ----------------|_ _Din1 _ _|------------------
%         lc1_| |_ |Lout   Din2| _| |_ lc2 
%           |     ||________Li_|| Dp2 |  
%           | Dp1 |             |     |
%        lv1|  V1 |             | V2  |lv2
%           |     |             |     |
%           |_____|             |_____|
%             Lin                 Lo
%  Dpipe               Dv               Dpipe
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
    
    Lv1 = Lv - Lin - Lout-Li-Lo;%������ڲ�׹��޽��ӵ�����???
    if ((Lv1 < 0))
        error('���ȳߴ�����');
    end
    Mv1 = straightPipeTransferMatrix(Lv1,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    %��??�侶�Ĵ��ݾ�???
    Sv = pi.* Dv.^2 ./ 4;
    Spipe = pi.* Dpipe.^2 ./ 4;
    %SinnerPipe = pi .* Din.^2 ./ 4;
    %mfvInnerPipe = mfvVessel .* Sv ./ SinnerPipe;%�ڲ�ܵ�ƽ����??
    %LM = sudEnlargeTransferMatrix(Spipe,Sv,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach,'notMach',optMach.notMach);
    %LM = sudReduceTransferMatrix(Spipe,Sv,1,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach);
%    RM = sudReduceTransferMatrix(Sv,Spipe,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach,'notMach',optMach.notMach);
    %RM = sudReduceTransferMatrix(Sv,Spipe,0,a,'coeffdamping',optDamping.coeffDamping,'mach',optMach.mach);
    %�ڲ��ǻ�崫�ݾ�???���
    innerLM = innerPipeCavityTransferMatrix(Dv,Din1,Lout,'a',a,'k',k);
     %�ڲ��ǻ�崫�ݾ�???�ұ�
    innerRM = innerPipeCavityTransferMatrix(Dv,Din2,Li,'a',a,'k',k);
    %�ڲ�����Ĺܵ����ݾ���
    innerPipeDampingCoeff = Dv^3 / Din1^3 * optDamping.coeffDamping;%����ϵ���Ĵ�???
    innerPML = straightPipeTransferMatrix(Lout,'k',k,'d',Din1,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',innerPipeDampingCoeff...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    %�ڲ���Ҳ�Ĺܵ����ݾ��� 
    innerPipeDampingCoeff = Dv^3 / Din2^3 * optDamping.coeffDamping;%����ϵ���Ĵ�???
    innerPMR = straightPipeTransferMatrix(Li,'k',k,'d',Din2,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',innerPipeDampingCoeff...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    %innerPML = [1,0;0,1]; 
    %��ķ���ȹ��������ݾ�???
    HML = HelmholtzResonatorTransferMatrix(V1,lv1,lc1,dp1,n1,'a',a,'k',k);
    HMR = HelmholtzResonatorTransferMatrix(V2,lv2,lc2,dp2,n2,'a',a,'k',k);

    M = HMR * innerPMR * innerRM * Mv1 * innerLM * innerPML * HML;
end