function pressure = straightPipePulsationCalc( massFlowE,Frequency,time,L...
    ,sectionL,varargin)
%����ֱ����������
% massFlowE��������Ҷ�任�����������,������fft�������з�ֵ����
% Frequency ������Ӧ��Ƶ�ʣ��˳����Ƕ�ӦmassFlowE��һ��
% L �ܳ�
% sectionL �ܵ������ֶΣ����ֵ���ܳ���L
%  opt �������ã����������
if nargin == 1
    inputData = massFlowE;
    
    checkInput(inputData);

    massFlowE = inputData.massFlowE;
    k = inputData.k;
    a = inputData.a;
    S = inputData.S;
    Dpipe = inputData.Dpipe;
    isDamping = inputData.isDamping;
    coeffFriction = inputData.coeffFriction;
    meanFlowVelocity = inputData.meanFlowVelocity;
    mach = inputData.mach;
    notMach = inputData.notMach;
    Frequency = inputData.frequency;
    time = inputData.time;
    L = inputData.L;
    sectionL = inputData.sectionL;

else
    pp=varargin;
    k = nan;
    oumiga = nan;
    f = nan;
    a = nan;%����
    S = nan;
    Dpipe = nan;
    isDamping = 0;
    coeffFriction = nan;
    meanFlowVelocity = nan;
    mach = nan;
    notMach = 0;%ǿ�Ʋ�ʹ��mach
    isOpening = 1;
    while length(pp)>=2
        prop =pp{1};
        val=pp{2};
        pp=pp(3:end);
        switch lower(prop)
            case 's' %����
                S = val;
            case 'd' %�ܵ�ֱ��
                Dpipe = val;
                S = (pi.*Dpipe^2)./4;
            case 'a' %����
                a = val; 
            case 'acousticvelocity' %����
                a = val;
            case 'acoustic' %����
                a = val;
            case 'isdamping' %�Ƿ��������
                isDamping = val;   
            case 'friction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
                coeffFriction = val;
            case 'coefffriction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
                coeffFriction = val;
            case 'meanflowvelocity' %ƽ�����٣���������ϵ��ʱʹ��
                meanFlowVelocity = val;
            case 'flowvelocity' %ƽ�����٣���������ϵ��ʱʹ��
                meanFlowVelocity = val;
            case 'mach' %��������������������ʹ�ô�������Ĺ�ʽ����
                mach = val;
            case 'm'
                mach = val;
            case 'notmach' %ǿ��������������趨
                notMach = val;
            case 'isopening'%�ܵ�ĩ���Ƿ�Ϊ�޷����(����)�����Ϊ0������Ϊ�տڣ���������
                isOpening = val;
            otherwise
                error('��������%s',prop);
        end
    end
end




count = 1;
pressureE1 = [];
for i = 1:length(Frequency)
    f = Frequency(i);
    matrix_total = straightPipeTransferMatrix(L,'s',S,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
    A = matrix_total(1,1);
    B = matrix_total(1,2);
    C = matrix_total(2,1);
    D = matrix_total(2,2);
    if(isOpening)
        pressureE1(count) = ((-B/A)*massFlowE(count));
    else
        pressureE1(count) = ((-D/C)*massFlowE(count));
    end
    count = count + 1;
end
%% ���ݳ�ʼ������ѹ���������������ѹ��

count = 1;
for len = sectionL
    count2 = 1;
    pressureEi = [];
    for i = 1:length(Frequency)
        f = Frequency(i);
        matrixTOther = straightPipeTransferMatrix(len,'s',S,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
        pressureEi(count2) = matrixTOther(1,1)*pressureE1(count2) + matrixTOther(1,2)*massFlowE(count2);
        count2 = count2 + 1;
    end
    pressure(:,count) = changToWave(pressureEi,Frequency,time);
    count = count + 1;
end
end

function checkInput(inp)
    if isnan(inp.frequency)
        error('input.frequency not allow nan');
    end
    if isnan(inp.time)
        error('input.time not allow nan');
    end
    if isnan(inp.L)
        error('input.L not allow nan');
    end
    if isnan(inp.sectionL)
        error('input.sectionL not allow nan');
    end
    if isnan(inp.massFlowE)
        error('input.massFlowE not allow nan');
    end
end