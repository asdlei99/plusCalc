function filterData = sigmaFilter(dataRaw,sigma)
%����������ֵ�˲�
% dataRawԭʼ���ݣ�sigma�ı���
if nargin<2
	sigma = 3;
end
	oi = fun_sigma_outlier_detection(dataRaw,sigma);
	dataRaw(oi) = [];
	filterData = dataRaw;
end