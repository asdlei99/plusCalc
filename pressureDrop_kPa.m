function d = pressureDrop_kPa(u,p,K)
%% ����ѹ����
% u ǰ�ܵ����� m/s
% p �ܶ� kg/m3
% ����ϵ��
    d = K .* u.^2.*p./2000;
end