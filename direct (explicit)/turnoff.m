 clear all;
 clc
load('f_cd.mat');
load('Cap.mat')

Vggon=15;
Vggoff=0;
IL=40;
Rg=30;

Ld=8e-9;

Ls=6e-9;
% Ls=1e-9 to 3e-9 for 4pin



Lp=50e-9;
Lg=20e-9;
Vdc=300;

Rpdc=0.1;
Rpac=0.5;

Rd2=0.06;
Vfto=0.89;


Rb=0.17;
Cgs=9900e-12;
Vth=4;
Kp= 35.16;

m=1;

n=1;


Vdsmax=500;
Vdmax=500;

tend=1200e-9;

% y1=Id y2=Vds y3=Ig y4=Vgs y5=Ia y6=Vak 



Vds0=-(Kp*Vth - Kp*Vggon + (-Kp*(IL/n - Kp*Vggon^2 - Kp*Vth^2 + 2*Kp*Vggon*Vth))^(1/2))/Kp;

% phase 1
Vin1=[IL/n;Vds0;0;Vggon;0;Vdc-Vds0-Rb*IL/n-Rpdc*IL];


[t,y,ted,yed] =  model_off4(Vggoff,Lg,Ls,Lp,Ld,Rg,Rpac,Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m,Vin1,tend);






T0=t.*1e6;
ST1=0; 
ST2=5;


Vds=y(:,2);

Id=y(:,1)*n;

Vgs=y(:,4);


% figure
ax1=subplot(3,1,1);
plot(T0-T0(1)- ST1,Vds,'k','Linewidth',0.8);
ylim([-100 800])
grid on
set(gca,'xticklabel',[])
ax2=subplot(3,1,2);
plot(T0-T0(1)- ST1,Id,'r','Linewidth',0.8);
ylim([-10 120])
grid on
set(gca,'xticklabel',[])
ax3=subplot(3,1,3);
plot(T0-T0(1)- ST1,Vgs,'b','Linewidth',0.8);
ylim([0 20])
grid on
xlabel('Time ({\mu}s)') 

ylabel(ax1,'V_{DS} (V)') 
ylabel(ax2,'I_{D} (A)') 
ylabel(ax3,'V_{GS} (V)') 




set(gcf,'windowstyle','normal');
set(gcf,'unit','centimeters','position',[2 2 12 17])
% set(gca,'Position',[.1 .1 .8 .8]);


