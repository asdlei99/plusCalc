function fH = filterfrequency_vcv( a,Ac,Lc,Dc,V1,V2 )
%�����ֹƵ��
%  ���� L1         Lv1       Lc       Lv2         L3
%              __________         __________
%             |          |       |          |
%  -----------|          |-------|          |-------------
%             |__________|       |__________|  
%  ֱ�� Dpipe       Dv1      Dc       Dv2          Dpipe
%���                        Ac
%���                V1                 V2
% a ����
% Ac �м��ܵĽ����
Lc1 = Lc + 0.6*Dc;
fH = a./(2*pi)*((Ac./Lc1)*((1./V1)+(1./V2))).^0.5;
end

