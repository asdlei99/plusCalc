function M = innerEnlargeCavityTransferMatrix(Dv,Dr1,Le,varargin)
%�������ܴ��ݾ���
%   Dv ������ھ�
%   Dr1 �����������С��
%   Dr2 �������ܳ��ڴ�
%   Le  �������ܳ���  
%______Le_________  
%        |
%       /
%      / 
% Dv Dr1   Dr2 
%      \ 
%       \
%________|________
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

S = pi.*Dv.^2./4;
Senlarge = pi.*Dr1.^2./4;
Sa = S - Senlarge;
lp = Le + sigma;
M = [1,0;
    -1i.*(Sa./a).*tan(k.*lp),1];
end

