function waveData = changToWave( EData,fre,t )
%�Ѹ�������ת��Ϊ����
ang=angle(EData);
Amp=abs(EData);

waveData = Amp(1)*cos(2*pi*fre(1).*t + ang(1));
for i=2:length(EData)
    waveData = waveData + Amp(i)*cos(2*pi*fre(i).*t + ang(i));
end
end

