function M = HelmholtzResonatorTransferMatrix_nInSeries(V,lv,lc,dp,varargin)
%����ڹܵ�ĳһ���洦����������n����ķ���ȹ��������䴫�ݾ���Ϊ
% lv ��������
% lc ���������ӹܳ�
%                         
%       __________                
%      |          |                   
%      |    V     | lv
%      |___    ___|     
%          |  | lc        
% _________|dp|__________                  
% _______________________                   
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
        	sigma = val;
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

Sv = V./lv;
Sc = pi.*dp.^2./4;
% sigma = 0.8.*dp;
lcp = lc + sigma;
X = -1i.*(Sc./a).*((tan(k.*lcp)+(Sv./Sc).*tan(k.*lv))./(1-(Sv./Sc).*tan(k.*lcp).*tan(k.*lv)));
M = [1,0;
    X,1];
end

