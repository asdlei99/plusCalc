function M = orificeTransferMatrix(D,d,Velocity )
%�װ崫�ݾ���
%   D �⾶
%   d �ھ�
%   Velocity ƽ���ٶ�
S = pi.*D.^2./4;
ks = (1+0.707./((1-(d.^2)./(D.^2)).^0.5)).^2 ...
.*...
((D./d).^2-1).^2;
A = -ks.*Velocity./S;
if isnan(A)
    A = 0;
end
M = [1,A;...
	0,1];
end

