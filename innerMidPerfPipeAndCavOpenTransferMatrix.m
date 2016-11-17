function M = innerMidPerfPipeAndCavOpenTransferMatrix(n1,dp,Din,Dv,lp1,lc,la1,la2,xSection1,varargin)
%�ڲ�׹���ڲ��֣���ڲ��뻺�����ڹ������ӣ���ĩ�˿��ڣ���������
% n1 �׹ܴ�����
% dp �׹ܴ��׿׾�
% Din ���ܹܾ�
% lp1 ���ײ��ֳ���
% k ����
% M1 ���ڵ������
% R0 ϵ��Ĭ��0.0055
% lc �׹ܱں�
% xSection1 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
% xSection1 =[0,1,1,1,1,1,1,1,1,1]
%�������ݾ���ֻ��ʾ���ײ���
%      ------------------------|----------|
%     |    ----- -- -- --dp----|          |lc
%-----|   Din                             |------
%     |    ----- -- --n1-- ----|          |
%      la1_______lp1____la2____|__________|
%
% lp �׹ܳ��ȣ��ӵ�һ���������𣬵����һ�����׽���������79ҳͼ4.5.1��

pp = varargin;
k = nan;
oumiga = nan;
f = nan;
a = 345;%����
R0 = 0.0055;% ?
meanFlowVelocity = nan;
M1 = nan;%�ܵ������
M2 = nan;%����������
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'k' %����
        	k = val;
        case 'oumiga' %ԲƵ��
        	oumiga = val;
        case 'f' %����Ƶ��
        	f = val;
        case 'a'
        	a = val;
        case 'acousticvelocity'
        	a = val;
        case 'acoustic'
        	a = val;
        case 'meanflowvelocity'
            meanFlowVelocity = val;
        case 'm1'
            M1 = val;
        case 'm2'
            M2 = val;
        case 'r0'
            R0 = val;
        otherwise
       		error('��������%s',prop);
    end
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
Sp = pi*Din.^2./4;%�׹ܹܾ������
Sv = pi*Dv.^2./4;%����޽����
if isnan(M1)
    if isnan(meanFlowVelocity)
        error('���ٱ������');
    end
    if isnan(a)
        error('���ٱ������');
    end
    M1 = meanFlowVelocity./a;
    M2 = M1 .* Sp ./ (Sv-Sp);
end
coeffD = calcD(n1,dp,Din,Dv,lp1,k,M1,M2,R0,lc,xSection1);
coeffR = calcR(coeffD);
coeffT = calcT(k,la1,la2,coeffR);
coeffFM = coeffT(2,2)*coeffT(1,1)-coeffT(1,2)*coeffT(2,1);

A = coeffT(2,2)./coeffFM;
B = (-a./Sp)*coeffT(1,2)./coeffFM;
C = (Sp./a*coeffT(2,1))./(-coeffFM);
D = -coeffT(1,1)./(-coeffFM);
M = [A,B;C,D];%[p2,m2]�׹ܳ��ڶˣ����ײ��֣����ڻ�����ڵ�ѹ��=M*[p1,m1]
end
 
function D = calcD(n1,dp,Din,Dv,lp1,k,M1,M2,R0,lc,xSection1)
% n2 �׹ܴ�����
% dp �׹ܴ��׿׾�
% Din ���ܹܾ�
% lp2 ���ײ��ֳ���
% k ����
% M1 ���ڵ������
% R0 ϵ��Ĭ��0.0055
% lc �׹ܱں�
% xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
% xSection2=[0,1,1,1,1,1,1,1,1,1]

    bp2 = n1.*dp^2./(4.*Din.*lp1);%������
    rp = dp/2;
    kr = k.*rp;
    if kr <= M1 %M1Ϊ���������    
        Cg = 12^(k.*rp./(M1-1));
    else
        Cg = 1;
    end  
    sig0 = calcSigma0(dp);
    if M1 == 0
         kp = (R0+1i.*k.*(lc+sig0.*dp))./bp2;%kpΪ�������迹��
    elseif M1>0
        kp = (R0+0.48.*abs(kr-M1)+1i.*k.*(lc+Cg.*sig0.*dp))./bp2;
    else
        error('�����M1����С��0');
    end
    
    a1 = -2.*M1.*(1i.*k+2./(Din.*kp))./(1-M1^2);
    a2 = 1.*(k^2-4.*1i.*k./(Din.*kp))./(1-M1^2);
    a3 = 4.*M1./(Din.*kp)./(1-M1^2);
    a4 = 4.*1i.*k./(Din.*kp)./(1-M1^2);
    a5 = M2.*4.*Din./((Dv.^2-(Din+2.*lc).^2).*kp)./(1-M2^2);
    a6 = 4.*1i.*k.*Din./((Dv.^2-(Din+2.*lc).^2).*kp)./(1-M2^2);
    a7 = -2.*M2.*(1i.*k+2.*Din./((Dv.^2-(Din+2.*lc).^2).*kp))./(1-M2^2);
    a8 = (k.^2-4.*1i.*k.*Din./((Dv.^2-(Din+2.*lc).^2).*kp))./(1-M2^2);
    B = [-a1,-a3,-a2,-a4;-a5,-a7,-a6,-a8;1,0,0,0;0,1,0,0];
    [V,W] = eig(B);
    count = 1;
    for x = xSection1
            D{count} = [V(3,1).*exp(W(1,1).*x),V(3,2).*exp(W(2,2).*x),V(3,3).*exp(W(3,3).*x),V(3,4).*exp(W(4,4).*x);...
            -V(1,1).*exp(W(1,1).*x)./(1i.*k+M1.*W(1,1)),-V(1,2).*exp(W(2,2).*x)./(1i.*k+M1.*W(2,2)),...
            -V(1,3).*exp(W(3,3).*x)./(1i.*k+M1.*W(3,3)),-V(1,4).*exp(W(4,4).*x)./(1i.*k+M1.*W(4,4));...
            V(4,1).*exp(W(1,1).*x),V(4,2).*exp(W(2,2).*x),V(4,3).*exp(W(3,3).*x),V(4,4).*exp(W(4,4).*x);...
            -V(2,1).*exp(W(1,1).*x)./(1i.*k+M2.*W(1,1)),-V(2,2).*exp(W(2,2).*x)./(1i.*k+M2.*W(2,2)),...
            -V(2,3).*exp(W(3,3).*x)./(1i.*k+M2.*W(3,3)),-V(2,4).*exp(W(4,4).*x)./(1i.*k+M2.*W(4,4));...
           ];
       count = count + 1;
    end

end

function sig0 = calcSigma0(bp)
    sig0 = 0.8216*(1-1.5443*bp^0.5+0.3508*bp+0.1935*bp^1.5);%���׹ܵĶ˲�����ϵ����������С��40%��
if bp >= 0.4
	error('�����ʲ��ܴ���40%');
end
end

function R = calcR(D)
%���������R���ܵ�R����R1��R2����Rn�������Ľ��
    sizeD = length(D);
    for i=1:sizeD
        if i==sizeD
            break;
        end
        RSection{i} = D{i}*inv(D{i+1});
    end
    sizeR = length(RSection);
     R = RSection{1};
    for i=2:sizeR
        R = R * RSection{i};
    end
end

function Tmn = calcTmn(m,n,k,la2,lp1,R)
%lb1 ��������޴��׾���
%lb2 ���������޴��׾���
    E = 1i.*tan(k.*(lp1+la2));
    F = -1i.*tan(k.*la2);
    P = (R(m,3)+F.*R(m,4)).*(R(4,n)-E.*R(3,n));
    Q = E.*R(3,3)-E.*F.*R(3,4)-R(4,3)-F.*R(4,4);
    Tmn = R(m,n)+(P)./(Q);
end

function T = calcT(k,la2,lp1,R)
    T = [calcTmn(1,1,k,la2,lp1,R),calcTmn(1,2,k,la2,lp1,R);...
        calcTmn(2,1,k,la2,lp1,R),calcTmn(2,2,k,la2,lp1,R)];
end