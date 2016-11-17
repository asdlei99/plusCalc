function M = innerPerfPipeDoubOpenLefCavTransferMatrix(n1,dp,Din,Dv,lp1,lc,la1,la2,varargin)
%�׹�ĩ�˿��ڴ�ǻ�岿�־����Ӧ��lp1��
%�ڲ�׹ܣ��׹ܿ��������Ƿǳ��٣��޷��ȼ�Ϊ��ķ���ȹ��������ҿ׹ܳ��ڿ��ڣ������ȫ��,�����������ס�A study on the transmission loss of straight‐through type reactive mufflers��
% n1 �׹ܴ�����
% dp �׹ܴ��׿׾�
% Din ���ܹܾ�
% lp1 ���ײ��ֳ���
% k ����
% M1 ���ڵ������
% R0 ϵ��Ĭ��0.0055
% lc �׹ܱں�
%�������ݾ���ֻ��ʾ���ײ���
%      -----------------------------------|
%     |          lc   ----- -- -- --dp----|
%-----|           Din                     |------
%     |               ----- -- --n1-- ----|
%     |________________la1_____lp1____la2_|
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
% coeffD = calcD(n2,dp,Din,Dv,lp2,k,M1,M2,R0,lc,xSection2);
% coeffR = calcR(coeffD);
% coeffT = calcT(k,lb1,lb2,coeffR);

[Ta8,Tb8,Tc8,Td8] = calcT1(n1,dp,Din,Dv,la1,la2,lp1,k,M1,M2,R0,lc);
% coeffFM = Td2*Ta2-Tb2*Tc2;



% A = Td2./coeffFM;
% B = (-a./(Sv-Sp))*Tb2./coeffFM;
% C = (((Sv-Sp)./a)*Tc2)./(-coeffFM);
% D = -((Sv-Sp)./Sp).*Ta2./(-coeffFM);
M = [Ta8,Tb8;Tc8,Td8];
M = inv(M);%[p2,m2]�׹ܳ��ڶˣ����ײ��֣����ڻ�����ڵ�ѹ��=M*[p1,m1]
end
 
function [Ta8,Tb8,Tc8,Td8] = calcT1(n1,dp,Din,Dv,la1,la2,lp1,k,M1,M2,R0,lc)
% n1 �׹ܴ�����
% dp �׹ܴ��׿׾�
% Din ���ܹܾ�
% lp1 ���ײ��ֳ���
% k ����
% M1 ���ڵ������
% R0 ϵ��Ĭ��0.0055
% lc �׹ܱں�
    [a1,a2,a3,a4,a5,a6,a7,a8] = calcCoeffA(n1,dp,Din,Dv,lp1,k,M1,M2,R0,lc);
    [r1,r2,r3,r4] = calcCoeffR(a1,a2,a3,a4,a5,a6,a7,a8);
    beita = calcCoeffBeita(r1,r2,r3,r4);
    Fai = calcCoeffFai(beita,a1,a2,a3,a4);

    %����T
    Din1=Din;%
    Din2=Din;%�������������˿׹ܹܾ�����ȣ�����Ⱦ���������
    areaRatio1 = (Dv./Din1)^2;
    areaRatio2 = (Dv./Din2)^2;

    AperB = calcCoeffAperB(k,areaRatio1,areaRatio2,M1,la1);
    CperD = calcCoeffCperD(k,areaRatio1,areaRatio2,M1,la1);
    F0 = calcCoeffFi(k,la2,lp1,beita,Fai,AperB,CperD);
    [C31,C32,C41,C42] = calcCoeffC(k,la2,lp1,AperB,CperD,Fai,F0,beita);

    M0 = M2;
    T01 = 1./beita(1) + C31./beita(3) + C41./beita(4);
    T02 = 1./beita(2) + C32./beita(3) + C42./beita(4);
    T03 = exp(beita(1).*lp1)./beita(1) + C31.*exp(beita(3).*lp1)./beita(3) + C41.*exp(beita(4).*lp1)./beita(4);
    T04 = exp(beita(2).*lp1)./beita(2) + C32.*exp(beita(3).*lp1)./beita(3) + C42.*exp(beita(4).*lp1)./beita(4);
    T05 = Fai(2,1)./beita(1) + Fai(2,3).*C31./beita(3) + Fai(2,4).*C41./beita(4);
    T06 = Fai(2,2)./beita(2) + Fai(2,3).*C32./beita(3) + Fai(2,4).*C42./beita(4);
    T07 = -(1./(1i.*k+M0.*beita(1)) + C31./(1i.*k+M0.*beita(3)) + C41./(1i.*k+M0.*beita(4)));
    T08 = -(1./(1i.*k+M0.*beita(2)) + C32./(1i.*k+M0.*beita(3)) + C42./(1i.*k+M0.*beita(4)));
    T09 = -(Fai(2,1) + Fai(2,3).*C31 + Fai(2,4).*C41)./(1i.*k);
    T10 = -(Fai(2,2) + Fai(2,3).*C32 + Fai(2,4).*C42)./(1i.*k);
    T11 = -(exp(beita(1).*lp1)./(1i.*k+M0.*beita(1)) + C31.*exp(beita(3).*lp1)./(1i.*k+M0.*beita(3)) + C41.*exp(beita(4).*lp1)./(1i.*k+M0.*beita(4)));
    T12 = -(exp(beita(2).*lp1)./(1i.*k+M0.*beita(2)) + C32.*exp(beita(3).*lp1)./(1i.*k+M0.*beita(3)) + C42.*exp(beita(4).*lp1)./(1i.*k+M0.*beita(4)));

    G3 = T03*T12-T04*T11;
    Ta8 = (T05*T12-T06*T11)./G3;
    Tb8 = (T03*T06-T04*T05)./G3;
    Tc8 = (T09*T12-T10*T11)./G3;
    Td8 = (T03*T10-T04*T09)./G3;

end




function [a1,a2,a3,a4,a5,a6,a7,a8] = calcCoeffA(n1,dp,Din,Dv,lp1,k,M1,M2,R0,lc)
% n2 �׹ܴ�����
% dp �׹ܴ��׿׾�
% Din ���ܹܾ�
% lp2 ���ײ��ֳ���
% k ����
% M1 ���ڵ������
% R0 ϵ��Ĭ��0.0055
% lc �׹ܱں�

    bp1 = n1.*dp^2./(4.*Din.*lp1);%������
    rp = dp/2;
    kr = k.*rp;
%     if kr <= M1 %M1Ϊ���������    
%         Cg = 12^(k.*rp./(M1-1));
%     else
%         Cg = 1;
%     end  
    sig0 = calcSigma0(dp);
    if M1 == 0
         kp = (R0+1i.*k.*(lc+sig0.*dp))./bp1;%kpΪ�������迹��
    elseif M1>0
        kp = (R0 + 2.48.*(1-bp1).*(M1.^(1.04+40.*dp)) + 1i.*k.*(lc+(1-(1+398.34.*dp).*((1-bp1).^1.44).*(M1.^0.72)).*sig0.*dp))./bp1;%ͨ����
        %kp = (R0+0.48.*abs(k.*rp-M1)+1i.*k.*(lc+Cg.*sig0.*dp))./bp2;%�ӹ���
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
end

function [r1,r2,r3,r4] = calcCoeffR(a1,a2,a3,a4,a5,a6,a7,a8)
    r1 = ((a1+a7)+sqrt((a1-a7)^2+4*a3*a5))./2;
    r3 = ((a1+a7)-sqrt((a1-a7)^2+4*a3*a5))./2;
    r2 = ((a2+a8)-sqrt((a2-a8)^2+4*a4*a6))./2;
    r4 = ((a2+a8)+sqrt((a2-a8)^2+4*a4*a6))./2;
end

function beita = calcCoeffBeita(r1,r2,r3,r4)
    beita(1) = -(r1+sqrt(r1^2-4*r2))./2;
    beita(2) = -(r1-sqrt(r1^2-4*r2))./2;
    beita(3) = -(r3-sqrt(r3^2-4*r4))./2;
    beita(4) = -(r3+sqrt(r3^2-4*r4))./2;
end

function Fai = calcCoeffFai(beita,a1,a2,a3,a4)
    m = 1:4;
    Fai(1,m) = 1;
    Fai(2,m) = -(beita(m).^2 + a1*beita(m) + a2)./(a3*beita(m) + a4);
    Fai(3,m) = 1./beita(m);
    Fai(4,m) = Fai(2,m)./beita(m);
end

function AperB = calcCoeffAperB(k,areaRatio1,areaRatio2,M2,la1)
    AperB = -k.*((1-exp(-1i.*k.*la1.*(areaRatio2./areaRatio1).*M2)) + cos(k.*la1).*(cos(k.*la1) + 1i.*(2-1./areaRatio2)...
           .*(areaRatio2./areaRatio1).*M2.*sin(k.*la1)))./...
           (-2*1i.*(areaRatio2./areaRatio1).*M2 + cos(k.*la1).*(sin(k.*la1) - 1i.*(1-1./areaRatio2).*(areaRatio2./areaRatio1)...
           .*M2.*cos(k.*la1)));
end

function CperD = calcCoeffCperD(k,areaRatio1,areaRatio2,M2,la1)
    CperD = k.*(2.*(1-exp(1i.*k.*la1.*(areaRatio2./areaRatio1).*M2)) - cos(k.*la1).*(cos(k.*la1) + 1i.*(1-1./areaRatio2)...
        .*(areaRatio2./areaRatio1).*M2.*sin(k.*la1)))./...
        (-2.*1i.*(areaRatio2./areaRatio1).*M2 + cos(k.*la1).*(sin(k.*la1)...
        -1i.*(1-1./areaRatio2).*(areaRatio2./areaRatio1).*M2.*cos(k.*la1)));
end

function F0 = calcCoeffFi(k,la2,lp1,beita,Fai,AperB,CperD)
    F0 = ((Fai(2,3)-k.*tan(k.*la2).*Fai(4,3)).*(1+AperB.*Fai(3,4)-Fai(2,4)-CperD.*Fai(4,4)).*exp(beita(3).*lp1)...
      -(Fai(2,4)-k.*tan(k.*la2).*Fai(4,4)).*(1+AperB.*Fai(3,3)-Fai(2,3)-CperD.*Fai(4,3)).*exp(beita(4).*lp1));
end

function [C31,C32,C41,C42] = calcCoeffC(k,la2,lp1,AperB,CperD,Fai,F0,beita)
    C31 = ((Fai(2,4)-k.*tan(k.*la2).*Fai(4,4)).*(1+AperB.*Fai(3,1)-Fai(2,1)-CperD.*Fai(4,1)).*exp(beita(4).*lp1)...
           -(Fai(2,1)-k.*tan(k.*la2).*Fai(4,1)).*(1+AperB.*Fai(3,4)-Fai(2,4)-CperD.*Fai(4,4)).*exp(beita(1).*lp1))./F0;
    C32 = ((Fai(2,4)-k.*tan(k.*la2).*Fai(4,4)).*(1+AperB.*Fai(3,2)-Fai(2,2)-CperD.*Fai(4,2)).*exp(beita(4).*lp1)...
           -(Fai(2,2)-k.*tan(k.*la2).*Fai(4,2)).*(1+AperB.*Fai(3,4)-Fai(2,4)-CperD.*Fai(4,4)).*exp(beita(2).*lp1))./F0;
    C41 = ((Fai(2,1)-k.*tan(k.*la2).*Fai(4,1)).*(1+AperB.*Fai(3,3)-Fai(2,3)-CperD.*Fai(4,3)).*exp(beita(1).*lp1)...
           -(Fai(2,3)-k.*tan(k.*la2).*Fai(4,3)).*(1+AperB.*Fai(3,1)-Fai(2,1)-CperD.*Fai(4,1)).*exp(beita(3).*lp1))./F0;
    C42 = ((Fai(2,2)-k.*tan(k.*la2).*Fai(4,2)).*(1+AperB.*Fai(3,3)-Fai(2,3)-CperD.*Fai(4,3)).*exp(beita(2).*lp1)...
           -(Fai(2,3)-k.*tan(k.*la2).*Fai(4,3)).*(1+AperB.*Fai(3,2)-Fai(2,2)-CperD.*Fai(4,2)).*exp(beita(3).*lp1))./F0;
end


function sig0 = calcSigma0(bp)
    sig0 = 0.8216*(1-1.5443*bp^0.5+0.3508*bp+0.1935*bp^1.5);%���׹ܵĶ˲�����ϵ����������С��40%��
if bp >= 0.4
	error('�����ʲ��ܴ���40%');
end
end