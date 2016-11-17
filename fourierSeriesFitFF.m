function [A0,An,Ph ] = fourierSeriesFitFF( X,Y,N,Fre )
%����Ҷ�������
%   ���ݸ�����x��y���趨��Ƶ��Fre����N�׸���Ҷ�����������
%  �����ϳ� A0 + ��An cos(n Fre t + Ph)
if size(X,1) == 1
    error('X��Ҫ������');
end
hFun = fsFuncHandleMaker(N,Fre);
ft = fittype(hFun);
fitResult = fit(X,Y,ft);
A0 = fitResult.A0;
for ii=1:N
    An(ii) = eval(sprintf('fitResult.An%d',ii));
    Ph(ii) = eval(sprintf('fitResult.Ph%d',ii));
end
end

% function fp = fsFuncHandleMaker(N,Fre)
%     
% %     str = sprintf(...
% %     ['@(A0,An,Ph,X) '...
% %         ,'(Y = A0 .* ones(length(X),1);\n'...
% %         ,'for ii = 1:%d\n'...
% %         ,'   Y = Y + (An(ii) .* cos( ii*%g .* X + Ph(ii).*ones(length(X),1)));\n'...
% %         ,'end)'...
% %     ],N,Fre);
% 
%     strHead = '@(A0,An,Ph,x)';
%     str = '(A0 .* ones(length(x),1)';
%     for ii = 1:N
%         str = [str,'+',...
%             sprintf('(An(%d) .* cos( (%d*%g) .* x + Ph(%d).*ones(length(x),1)))',ii,ii,Fre,ii)];
%     end
%     str = [strHead,str,')'];
%     disp(str);
%     fp = str2func(str);
% end

function fp = fsFuncHandleMaker(N,Fre)   
    strHead = '@(A0'
    for ii = 1:N
        strHead = [strHead,','];
        strHead = [strHead,sprintf('An%d',ii)];
    end
    for ii = 1:N
        strHead = [strHead,','];
        strHead = [strHead,sprintf('Ph%d',ii)];
    end
    strHead = [strHead,',x)'];
    str = '(A0 .* ones(length(x),1)';
    for ii = 1:N
        str = [str,'+',...
            sprintf('(An%d .* cos( (%d*%g) .* x + Ph%d.*ones(length(x),1)))',ii,ii,Fre,ii)];
    end
    str = [strHead,str,')'];
    fp = str2func(str);
end
