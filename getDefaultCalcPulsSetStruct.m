function dcpss = getDefaultCalcPulsSetStruct()
	dcpss.dim = 2;%����ά�� 1����pressureÿһ�д���һ������
	dcpss.sigma = 2.8;%sigmaȥ���sigma�ı�����3�������Ŷ�97%�����Ϊnan��������sigma�˲�
	dcpss.calcSection = [0,1];%��������0����ǰ�δӵ�һ���㿪ʼ�㣬1�����㵽���һ���㣬�����һ��Ϊ0.1��������10%��ʼ����
	dcpss.isHp = 0;%�Ƿ���и�ͨ�˲�
	dcpss.f_pass = 4;%ͨ��Ƶ��5Hz
	dcpss.f_stop = 2;%��ֹƵ��3Hz
	dcpss.rp = 0.1;%�ߴ���˥��DB������
	dcpss.rs = 30;%��ֹ��˥��DB������
	dcpss.fs = nan;
end