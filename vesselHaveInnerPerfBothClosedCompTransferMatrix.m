function M = vesselHaveInnerPerfBothClosedCompTransferMatrix(Dpipe,Dv,l,Lv1,Lv2,...
    lc,dp1,dp2,lp1,lp2,n1,n2,la1,la2,lb1,lb2,Din,xSection1,xSection2,varargin)
%������м����׹�,���˶��������׸��������Ե�ЧΪ��ķ���ȹ�����
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             |    dp(n1)    |    dp(n2)        |
%             |   ___ _ _ ___|___ _ _ ___ lc    |     
%  -----------|  |___ _ _ ___ ___ _ _ ___|Din   |----------
%             |   la1 lp1 la2|lb1 lp2 lb2       |
%             |______________|__________________|       
%                  Lin             Lout
%    Dpipe                   Dv                     Dpipe 
%              
%
% Lin �ڲ�׹���ڶγ��� 
% Lout�ڲ�׹ܳ��ڶγ���
% lc  �׹ܱں�
% dp  �׹�ÿһ���׿׾�
% n1  �׹���ڶο��׸�����    n2  �׹ܳ��ڶο��׸���
% la1 �׹���ڶξ���ڳ��� 
% la2 �׹���ڶξ���峤��
% lb1 �׹ܳ��ڶξ���峤��
% lb2 �׹ܳ��ڶξ࿪�׳���
% lp1 �׹���ڶο��׳���
% lp2 �׹ܳ��ڶο��׳���
% Din �׹ܹܾ���
% xSection1��xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
pp=varargin;
k = nan;
oumiga = nan;
f = nan;
a = nan;%����
isDamping = 1;%Ĭ��ʹ������
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
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
        case 'notmach'
            notMach = val;
        otherwise
       		error('��������%s',prop);
    end
end
% 
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
Sv = pi .* Dv.^2 ./ 4;%����޽����
Sp = pi*Din.^2./4;%�׹ܹܾ������
Sv_p = Sv-Sp;%ȥ���׹ܵĻ���޽����
Dv_inner = (4*Sv_p/pi).^0.5;%��������ֱ��
mfvStraight = nan;
mfvVessel = nan;
mfvInnerPipe = nan;
mfvVessel_Inner = nan;
if ~isnan(meanFlowVelocity)
    if 1 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity*S/Sv;
        mfvVessel_Inner = meanFlowVelocity*S/Sv_p;
        mfvInnerPipe = meanFlowVelocity*S/Sp;
        meanFlowVelocity = [meanFlowVelocity,mfvVessel,mfvVessel_Inner,mfvInnerPipe];
    elseif 2 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity(2);
        mfvVessel_Inner = meanFlowVelocity*S/Sv_p;
        mfvInnerPipe = meanFlowVelocity*S/Sp;
        meanFlowVelocity = [meanFlowVelocity,mfvVessel_Inner,mfvInnerPipe];
    elseif 3 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity(2);
        mfvVessel_Inner = meanFlowVelocity(3);
        mfvInnerPipe = meanFlowVelocity*S/Sp;
        mfvInnerPipe = [meanFlowVelocity,mfvInnerPipe];
    elseif 4 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity(2);
        mfvVessel_Inner = meanFlowVelocity(3);
        mfvInnerPipe = meanFlowVelocity(4);
    end
else 
    error(['��ָ�����٣������ǹܵ����뻺���ʱ�����٣�',...
    '����Ҫָ����������٣�����ʹ��һ������4��Ԫ�ص�����[pipe��vessel,vessel_Inner,InnerPipe]']);
end

if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('����Ҫ�������ᣬ��û�ж�������ϵ�����趨�塰coeffFriction���ܵ�Ħ��ϵ��');
        end
        if isnan(meanFlowVelocity)
            error('����Ҫ�������ᣬ��û�ж�������ϵ�����趨�塰meanFlowVelocity��ƽ������');
        end
        if length(meanFlowVelocity) < 4
            error('��meanFlowVelocity��ƽ�����ٵĳ��ȹ�С������Ϊ4');
        end
        Dtemp = [Dpipe,Dv,Dv_inner,Din];
        coeffDamping = (4.*coeffFriction.*meanFlowVelocity./Dtemp)./(2.*a);       
    end
    if length(coeffDamping)<4
        %���뿼��4��
        coeffDamping(2) = (4.*coeffFriction.*mfvVessel./Dv)./(2.*a);
        coeffDamping(3) = (4.*coeffFriction.*mfvVessel./Dv_inner)./(2.*a);
        coeffDamping(4) = (4.*coeffFriction.*mfvVessel./Din)./(2.*a);
    end
end


mach = meanFlowVelocity./a;%���,mach(1)ֱ��mach��mach(2)�����mach:mach(3)���ڲ�ܵĻ���޵�mach:mach(4)�ڲ�ܵ�mach

optMach.notMach = notMach;
optMach.machStraight = mach(1);
optMach.machVessel = mach(2);
optMach.machVesselWithInnerPipe = mach(3);
optMach.machInnerPipe = mach(4);

optDamping.isDamping = isDamping;
if isDamping
    optDamping.coeffDampStraight = coeffDamping(1);
    optDamping.coeffDampVessel = coeffDamping(2);%����޵�����ϵ��
    optDamping.coeffDampVesselWithInnerPipe = coeffDamping(3);%����޵�����ϵ��
    optDamping.coeffDampInnerPipe = coeffDamping(4);%����޵�����ϵ��
    
    optDamping.mfvStraight = meanFlowVelocity(1);
    optDamping.mfvVessel = meanFlowVelocity(2);
    optDamping.mfvVesselWithInnerPipe = meanFlowVelocity(3);
    optDamping.mfvInnerPipe = meanFlowVelocity(4);
else
    optDamping.coeffDampStraight = nan;
    optDamping.coeffDampVessel = nan;%����޵�����ϵ��
    optDamping.coeffDampVesselWithInnerPipe = nan;%����޵�����ϵ��
    optDamping.coeffDampInnerPipe = nan;%����޵�����ϵ��
    
    optDamping.mfvStraight = mfvStraight;
    optDamping.mfvVessel = mfvVessel;
    optDamping.mfvVesselWithInnerPipe = mfvVessel_Inner;
    optDamping.mfvInnerPipe = mfvInnerPipe;
end



M1 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMach.machStraight,'notmach',optMach.notMach);
M2 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMach.machStraight,'notmach',optMach.notMach);
    
Mv = haveInnerPerforatedPipeBCCompTransferMatrix(a,k,Dv,Dv_inner,Lv1,Lv2,...
    lc,dp1,dp2,lp1,lp2,n1,n2,la1,la2,lb1,lb2,Din,xSection1,xSection2,optDamping,optMach);
M = M2 * Mv * M1 ;

end
function M = haveInnerPerforatedPipeBCCompTransferMatrix(a,k,Dv,Dv_inner,Lv1,Lv2 ...
    ,lc,dp1,dp2,lp1,lp2,n1,n2,la1,la2,lb1,lb2,Din,xSection1,xSection2,optDamping,optMach)
%������м����׹�,���˶��������׸��������Ե�ЧΪ��ķ���ȹ�����
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             |    dp(n1)    |    dp(n2)        |
%             |   ___ _ _ ___|___ _ _ ___ lc    |     
%  -----------|  |___ _ _ ___ ___ _ _ ___|Din   |----------
%             |   la1 lp1 la2|lb1 lp2 lb2       |
%             |______________|__________________|       
%                  Lin             Lout
%    Dpipe                   Dv                     Dpipe 
%section  1                              2   ����޷ֵ�������              
%
% Lin �ڲ�׹���ڶγ��� 
% Lout�ڲ�׹ܳ��ڶγ���
% lc  �׹ܱں�
% dp  �׹�ÿһ���׿׾�
% n1  �׹���ڶο��׸�����    n2  �׹ܳ��ڶο��׸���
% la1 �׹���ڶξ���ڳ��� 
% la2 �׹���ڶξ���峤��
% lb1 �׹ܳ��ڶξ���峤��
% lb2 �׹ܳ��ڶξ࿪�׳���
% lp1 �׹���ڶο��׳���
% lp2 �׹ܳ��ڶο��׳���
% Din �׹ܹܾ���
% xSection1��xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��

   if ~isstruct(optDamping)
        if isnan(optDamping)
            error('optDamping����Ϊ��');
        end
    end
    if ~isstruct(optMach)
        if isnan(optMach)
            error('optMach����Ϊ��');
        end
    end
    % ������ڲ����׹ܵĲ���
    Lin = la1 + lp1 + la2;
    Lout = lb1 + lp2 + lb2;
%     Lv1 = Lv/2 - Lin;%������ڲ�׹��޽��ӵ�����
%     Lv2 = Lv/2 - Lout;%������ڲ�׹��޽��ӵ�����
%    
%     if ((Lv1 < 0))
%         error('���ȳߴ�����');
%     end
    Cav1 = Lv1 - Lin;%ǻ1�ǻ��β���
    Cav2 = Lv2 - Lout;%ǻ2�ǻ��β���
    Mv2 = straightPipeTransferMatrix(Cav2,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampVessel...
                ,'mach',optMach.machVessel,'notmach',optMach.notMach);
    %lb2����Ӧ�Ļ����ǻ��
    Mstr2 = straightPipeTransferMatrix(lb2,'k',k,'d',Dv_inner,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampVesselWithInnerPipe...
                ,'mach',optMach.machVesselWithInnerPipe,'notmach',optMach.notMach);
    %�ڲ�׹ܳ��ڶζ�Ӧlp2
    Mp2 = innerPerfPipeOpenTransferMatrix(n2,dp2,Din,Dv,lp2,lc,lb1,lb2,xSection2...
        ,'k',k,'a',a,'meanflowvelocity',optDamping.mfvInnerPipe...
        ,'M1',optMach.machInnerPipe,'M2',optMach.machVesselWithInnerPipe);
    %�ڲ�׹ܸ�������Ӧla2+lb1
    Mstr = straightPipeTransferMatrix(la2+lb1,'k',k,'d',Din,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampInnerPipe...
                ,'mach',optMach.machInnerPipe,'notmach',optMach.notMach);
    %�ڲ�׹���ڶζ�Ӧlp1
    Mp1 = innerPerfPipeOpenInletClosedTransferMatrix(n1,dp1,Din,Dv,lp1,lc,la1,la2,xSection1...
        ,'k',k,'a',a,'meanflowvelocity',optDamping.mfvInnerPipe...
        ,'M1',optMach.machInnerPipe,'M2',optMach.machVesselWithInnerPipe);
    %�ڲ�׹�����ڹ����Ӳ��ֶ�Ӧla1
    Mstr1 = straightPipeTransferMatrix(la1,'k',k,'d',Dv_inner,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampInnerPipe...
                ,'mach',optMach.machInnerPipe,'notmach',optMach.notMach);
    %��ڿ׹�ǰ�˿��ſ�ǻ��Ӧ
    Mv1 = straightPipeTransferMatrix(Cav1,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampVessel...
                ,'mach',optMach.machVessel,'notmach',optMach.notMach);
      
%     %�ڲ��ǻ�崫�ݾ���-�ұ߶�Ӧlb1+lp2
%     Mca = innerPipeCavityTransferMatrix(Dv,Din,lb1+lp2,'a',a,'k',k);

    
    M = Mv2 * Mstr2 * Mp2 * Mstr * Mp1 * Mstr1* Mv1;
    %M = Mv2 * Mp1 * Mstr1* Mv1;
end
