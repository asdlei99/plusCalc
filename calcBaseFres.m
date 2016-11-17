function [ multFreMag,multFrePh ] = calcBaseFres( rawDatas,Fs,baseFrequency,multFreTimes,allowDeviation )
%����һ�������ݵĻ���Ƶ�ʵķ�ֵ
[rawFre,rawMag,rawPh] = fft_byColumn(rawDatas,Fs);%ԭʼ����Ƶ�׷���
multFreMag = [];
multFrePh = [];
for i=1:multFreTimes%���㱶Ƶ��ֵ����λ
    [m,p] = fun_findBaseFres(rawFre,rawMag,rawPh,baseFrequency*i,allowDeviation);
    multFreMag(i,:) = m;
    multFrePh(i,:) = p;
end

end

