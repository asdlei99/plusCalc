function P2_NEW
tic
clc;clear;close all;
[v,c_max]=jisuan;
for i=1:2
    figure(i+16)
    plot(v,c_max(i,:))
     xlabel('�����ݻ�/������')
    ylabel('����ѹ����ֵ/��')
end
toc
end

function [v,c]=jisuan

alpha=1.25;%�����϶�ݻ�
yimixilou=150/97;%ѹ���ȣ�����ѹ��/����ѹ����
k=1.4;%����ָ��
%m=1.28;
%theita=asind(1-2.*alpha.*(yimixilou.^(1/m)-1));
beita=asind(1-2.*(1+alpha).*(yimixilou.^(-(1/k)))+2.*alpha);%�ǶȲ��ǻ���
%alphaa=90-theita;%�ǲ���������Ŀ�����
alphac=270+beita;%�ǲ���������Ŀ�����
%alphaax=270-theita;%�����������Ŀ�����
alphacx=90+beita;%�����������Ŀ�����

%˫�������������ٶ����ߣ��ǲ��������
D=813/1000;%�׾�m
Ap=(pi.*(D.^2))/4;%����ͨ�����
d=358/1000;%���ھ�m
ap=(pi.*(d.^2))/4;%�ܵ�ͨ�����
b=Ap/ap;
n=300;%ת��r/min
r=140/1000;%������
lameda=140/800;%������/���˳�
oumiga=(pi.*n)/30;%�����Ľ��ٶ�rad/s
alpha0=0:0.5:360;
v10=zeros(size(alpha0));
for i=1:length(alpha0)%�ǲ൥����
    alpha=alpha0(i);
    if (alpha<alphacx&&alpha>=0)
        v11=0;
    elseif (alpha<=180&&alpha>=alphacx)
        v11=b.*r.*oumiga.*abs((sind(alpha)+(lameda/2).*sind(2.*alpha)));
    elseif (alpha<=alphac&&alpha>180)
        v11=0;
    elseif (alpha<=360&&alpha>=alphac)  
        v11=b.*r.*oumiga.*abs((sind(alpha)+(lameda/2).*sind(2.*alpha)));
    end
    v10(i)=v11;
end
figure(1)
plot(alpha0,v10)

%����Ҷ����չ��
am=zeros(1,2);
bm=zeros(1,2);
for i=1:2
    am(i)=trapz(alpha0/360*2*pi,v10.*cosd(i*alpha0))/pi;%?????????????
    bm(i)=trapz(alpha0/360*2*pi,v10.*sind(i*alpha0))/pi;
end
figure(2)
subplot(211)
stem(am)
subplot(212)
stem(bm)


%��������m/s
um=zeros(2,length(alpha0));
%a0=trapz(alpha0/360*2*pi,abs(v10).*cosd(0*alpha0))/pi
for i=1:2
    um(i,:)=am(i)*cosd(i*alpha0)+bm(i)*sind(i*alpha0);
    figure(i+2)
    plot(alpha0,um(i,:))%%��֤�ܵ���ȥ����Ҷ��
end
figure(5)
plot(alpha0,sum(um))

%����ѹ����������ѹ��
%p1=zeros(2,length(alpha0));
%p0=1.116;
%a=358;
%for i=1:2
%p1(i,:)=1j*(a0/2+am(i)*cosd(i*alpha0)+bm(i)*sind(i*alpha0))*p0*a+3900j;
%figure(i+5)
% plot(alpha0,imag(p1(i,:)))
%end
 

%���ô��ݾ���������ѹ��
p0=1.116;
%R=287.1;
a=358;
%A=(pi*(D^2))/4;
n=300;
oumiga=2*(pi*n)/30;
k=oumiga/a;
l1=0.3;
%S3=0.64;
S2=0.1;
S3=0.1;
l2=0.3;
%l2=10;
%D0=1;%m
%H=4;%m
%V0=1.81;

syms v1 p1 V P1
K=vpa(p0*a,3)
p1=1j*v1*p0*a;
eq1=((p1*cos(k*l1)-1j*p0*a*v1*sin(k*l1))*cos(k*l2)-1j*p0*a*((S2/S3)*((-1j)*(p1/...
    (p0*a))*sin(k*l1)+v1*cos(k*l1))+(-1j)*((V/(p0*(a^2)...
    *S3))*oumiga)*(p1*cos(k*l1)-1j*p0*a*v1*sin(k*l1)))*sin(k*l2))-P1;

    
P11=solve(eq1,P1);
PP1=zeros(size(um));

v=0.5:0.25:3;%ֱ����0.5��1.8��
c=zeros(2,length(v));
for k=1:length(v)
    for i=1:2
        for j=1:length(alpha0)
            P2=subs(P11,{v1,V},{um(i,j),v(k)});
            PP1(i,j)=P2;
        end
       %figure(i+8)
      % plot(alpha0,imag(PP1(i,:)))
    end
    c(:,k)=max(abs(imag(PP1)),[],2);
end
end