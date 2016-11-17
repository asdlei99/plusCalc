function M = innerReduceCavityTransferMatrix(Dv,Dr2,Lr,varargin)
%�ڲ��������ܴ��ݾ���
%   Dv ������ھ�
%   Dr1 ����������ڴ�
%   Dr2 �������ܳ���С��
%   Lr  �������ܳ���
% ___Lr___   
%    |
%     \
%      \
% Dr1    Dr2  Dv
%      / 
%     /
% ___|____
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
Sreduce = pi.*Dr2.^2./4;
Sa = S - Sreduce;
lp = Lr + sigma;
M = [1,0;
    -1i.*(Sa./a).*tan(k.*lp),1];
end
