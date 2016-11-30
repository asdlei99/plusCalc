function Matrix = sudEnlargeTransferMatrix( S_in,S_out,a,varargin)
%���ٱ侶���ݾ���
%   S1���ڽ����
%   S2���ڽ����
%   S1BigThanS2 s1��s2��˵��������������Ϊ����
%   a����
if(S_in > S_out)
    error('S_in ��ҪС�� S_out');
end

mach = 10/345;
coeffDamping = 0.03;
pp = varargin;
notMach = 1;
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'coeffdamping' %����ϵ��
            coeffDamping = val;
        case 'damping' %����ϵ��
            coeffDamping = val;
        case 'mach' %��������������������ʹ�ô�������Ĺ�ʽ����
            mach = val;
        case 'm'
            mach = val;
        case 'notmach'
            notMach = val;
        otherwise
       		error('��������%s',prop);
    end
end

M=0;
Tin_out = S_in/S_out;
if notMach
    mach = 0;
end
M=(1-Tin_out)*(2*coeffDamping*mach*a)/S_out;
if isnan(M)
    M = 0;
end

Matrix = [1,M;...
          0,1];

end

