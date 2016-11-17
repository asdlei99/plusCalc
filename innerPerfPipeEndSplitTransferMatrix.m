function M = innerPerfPipeEndSplitTransferMatrix(Din,Dv,lb2,varargin)
%�ڲ�׹ܳ��ڲ��֣��׹ܳ��ڴ����ţ������ȫ��,�������ơ�������ֻ���lb2���ֹ��ں�ǻ�ڷ�������ϣ��ο���76ҳ�ĸ���ʽ������
% n2 �׹ܴ�����
% dp �׹ܴ��׿׾�
% Din ���ܹܾ�
% lp2 ���ײ��ֳ���
% k ����
% M1 ���ڵ������
% R0 ϵ��Ĭ��0.0055
% lc �׹ܱں�
% xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
% xSection2 =[0,1,1,1,1,1,1,1,1,1]
%�������ݾ���ֻ��ʾ���ײ���
%      -----------------------------------|
%     |----- -- -- --dp----               |lc
%-----|   Din                             |------
%     |----- -- --n2-- ----               |
%      lb1_______lp2____lb2_______________|
%
% lp �׹ܳ��ȣ��ӵ�һ���������𣬵����һ�����׽���������79ҳͼ4.5.1��

pp = varargin;
k = nan;
oumiga = nan;
f = nan;
a = 345;%����
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
Sv_inner = Sv-Sp;%�ڲ�ܻ���ǻ��
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


kc1 = k./(1-M1^2);
kc2 = k./(1-M2^2);
coeffA = Sp./tan(kc1.*lb2);
coeffB = Sv_inner./tan(kc2.*lb2);
coeffC = Sp.*exp(1i.*M1.*kc1.*lb2)./sin(kc1.*lb2);
coeffD = Sv_inner.*exp(1i.*M2.*kc2.*lb2)./sin(kc2.*lb2);
coeffE = Sp.*exp(-1i.*M1.*kc1.*lb2)./sin(kc1.*lb2);
coeffF = Sv_inner.*exp(-1i.*M2.*kc2.*lb2)./sin(kc2.*lb2);
coeffT(1,1) = (coeffA + coeffB)./(coeffC + coeffD);
coeffT(1,2) = 1i.*a./(coeffC + coeffD);
coeffT(2,1) = 1i./a.*(coeffE + coeffF)-1i./a.*(coeffA + coeffB)^2./(coeffC + coeffD);
coeffT(2,2) = (coeffA + coeffB)./(coeffC + coeffD);


coeffFM = coeffT(2,2)*coeffT(1,1)-coeffT(1,2)*coeffT(2,1);

A = coeffT(2,2)./coeffFM;
B = (-a./Sp)*coeffT(1,2)./coeffFM;
C = (Sp./a*coeffT(2,1))./(-coeffFM);
D = -coeffT(1,1)./(-coeffFM);
M = [A,B;C,D];%[p2,m2]�׹ܳ��ڶˣ����ײ��֣����ڻ�����ڵ�ѹ��=M*[p1,m1]
end
 
