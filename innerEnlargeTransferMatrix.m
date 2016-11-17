function M = innerEnlargeTransferMatrix(Dr1,Dr2,Le,varargin)
%�������ܴ��ݾ���
%                            
%______Le_(Lc)____  
%        |
%       /
%      / 
% Dv Dr1   Dr2 
%      \ 
%       \
%________|________   
%                    
pp = varargin;
k = nan;
a = nan;%����
sigma = 0;%����ϵ��
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
        case 'sigma'
            sigma = val;%����ϵ��
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

r1 = Dr1./2;
S1 = pi.*Dr1.^2./4;
r2 = Dr2./2;
S2 = pi.*Dr2.^2./4;
Lc = (r1./(r1-r2)).*Le;
x1 = Lc.*r1./(r2-r1);
A = (r2./r1).*cos(k.*Lc) - (1./(k.*x1)).*sin(k.*Lc);
B = 1i.*(a./S1).*(r1./r2).*sin(k.*Lc);
C = 1i.*(S1./a).*((r2./r1+1./(k.^2.*x1.^2)).*sin(k.*Lc) ...
    - (Lc./(k.*x1.^2)).*cos(k.*Lc));
D = (r1./r2).*(cos(k.*Lc) + (1./(k.*x1)).*sin(k.*Lc));

M = [D./(A.*D-B.*C),-B./(A.*D-B.*C);
    C./(B.*C-D.*A),-A./(B.*C-D.*A)];
end

