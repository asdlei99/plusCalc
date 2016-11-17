function [out_index,meadUpStd,meadDownStd,meanValue,stdValue] = fun_sigma_outlier_detection( series , stdTimes )
%����������ֵ��⣬������stdTimes���������
% series Ϊ���������
% stdTimesΪ��׼�����stdTimesΪ3ʱ�����Ŷȴﵽ99%
% out_index �������sigma��Χ����������
% meadUpStd ��meanValue+stdTimes*stdValue
% meadDownStd ��meanValue-stdTimes*stdValue;
% meanValue : ��ֵ
% stdValue ��׼��

stdValue = std(series);
meanValue = mean(series);
meadUpStd = meanValue+stdTimes*stdValue;
meadDownStd = meanValue-stdTimes*stdValue;
out_index = find((series > (meadUpStd)) | (series < (meadDownStd)) );

end

