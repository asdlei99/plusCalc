function [ fre,mag,ph ] = fft_byColumn( rawData,Fs )
%����Ƶ�׷���
for i=1:size(rawData,2)  
    [fre(:,i),mag(:,i),ph(:,i)]...
            = fun_fft(detrend(rawData(:,i)),Fs);    
end
end

