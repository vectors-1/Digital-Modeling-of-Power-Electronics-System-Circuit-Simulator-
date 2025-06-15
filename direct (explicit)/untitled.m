clc;
clear all;

%% load MOSFET model
load('f_cd.mat');
load('Cap.mat')


Vggon=15;
Vggoff=0;

Rg=20;

Ld=8e-9;
Ls=6e-9;
% Ls=1e-9 to 3e-9 for 4pin

Lp=50e-9;

Lg=20e-9;


Vdc=100;
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


% % y1=Id y2=Vds y3=Ig y4=Vgs y5=Ia y6=Vak 
% 
% Vin1=[0;Vdc+Vfto+Rd2*IL/m;0;Vggoff;IL;-(Vfto+Rd2*IL/m)];
% tend=500e-9;
% [t,y,ted,yed] = model_on4(Vggon,Lg,Ls,Lp,Ld,Rg,Rpac ,Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m,Vin1,tend);

tt=[];
yy=[];

%% circuit simulation
% clc;
% clear;

simulation_time_lenth = 0.1;
time_step = 1e-6;
total_steps = round(simulation_time_lenth / time_step);
%nodal_voltage = zeros(8,total_steps);

Vin = 100;
R = 10;
L = 0.1;

% Va = Vin * S1;
% Vb = Vin * S3;
% Vc = Vin * S5;
pwmPeriod = 1e-3;

S1 = zeros(1,total_steps);
S3 = zeros(1,total_steps);
S5 = zeros(1,total_steps);
Va = zeros(1,total_steps);
Vb = zeros(1,total_steps);
Vc = zeros(1,total_steps);
VA = zeros(1,total_steps);
VB = zeros(1,total_steps);
VC = zeros(1,total_steps);
VN = zeros(1,total_steps);
ia = zeros(1,total_steps);
ib = zeros(1,total_steps);
ic = zeros(1,total_steps);
t = zeros(1,total_steps);

for ii = 2:(total_steps+1)
                
                tk = (ii-1) * time_step;
                t(ii) = tk;
                modularwave_a = 0.5*sin(2*pi*50*tk);
                modularwave_b = 0.5*sin(2*pi*50*tk+2/3*pi);
                modularwave_c = 0.5*sin(2*pi*50*tk+4/3*pi);
                %call_controller(obj, t(1,k), obj.currentState(controller.probe1));
                % Generate a triangular carrier wave (normalized to 0–1)
                carrierwave = 0.5 - abs(mod(tk, pwmPeriod)/(pwmPeriod/2) - 1);
                % The gate signal is high if the carrier is less than the duty cycle.
                if carrierwave < modularwave_a
                    S1(ii) = 1;
                else
                    S1(ii) = 0;
                end
                if carrierwave < modularwave_b
                    S3(ii) = 1;
                else
                    S3(ii) = 0;
                end
                if carrierwave < modularwave_c
                    S5(ii) = 1;
                else
                    S5(ii) = 0;
                end

    Va(ii) = Vin * S1(ii);
    Vb(ii) = Vin * S3(ii);
    Vc(ii) = Vin * S5(ii);
    VN(ii) = (Va(ii) + Vb(ii) + Vc(ii)) / 3;

    % VA(ii) = (R * time_step * Va(ii) + L * VN(ii) + L * R * ia(ii-1)) / (L + R * time_step);
    % VB(ii) = (R * time_step * Vb(ii) + L * VN(ii) + L * R * ib(ii-1)) / (L + R * time_step);
    % VC(ii) = (R * time_step * Vc(ii) + L * VN(ii) + L * R * ic(ii-1)) / (L + R * time_step);
    % ia(ii) = (VA(ii) - VN(ii)) / R;
    % ib(ii) = (VB(ii) - VN(ii)) / R;
    % ic(ii) = -ia(ii) - ib(ii);
    % icc = (VC(ii) - VN(ii)) / R;

    ia(ii) = (Va(ii) - VN(ii) + L/time_step * ia(ii-1)) / (L/time_step + R);
    ib(ii) = (Vb(ii) - VN(ii) + L/time_step * ib(ii-1)) / (L/time_step + R);
    ic(ii) = -ia(ii) - ib(ii);
    icc = (Vc(ii) - VN(ii) + L/time_step * ic(ii-1)) / (L/time_step + R);

    VA(ii) = ia(ii) * R + VN(ii);
    VB(ii) = ib(ii) * R + VN(ii);
    VC(ii) = ic(ii) * R + VN(ii);


    %%
    % y1=Id y2=Vds y3=Ig y4=Vgs y5=Ia y6=Vak 
    if ii>8e4 && ii<10e4 && S1(ii-1)==0 && S1(ii)==1 
        IL = ia(ii-1);
        if IL>=0
        InVl=[0;Vin+Vfto+Rd2*IL/m;0;Vggoff;IL;-(Vfto+Rd2*IL/m)];
        tend=500e-9;
        [ttmp,ytmp,ted,yed] = model_on4(Vggon,Lg,Ls,Lp,Ld,Rg,Rpac ,Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m,InVl,tend);
        tt=[tt; ttmp+((ii-1)*(1e-6))];
        yy=[yy; ytmp];
        else
            tend=1200e-9;
        IL = -IL;
        Vds0=-(Kp*Vth - Kp*Vggon + (-Kp*(IL/n - Kp*Vggon^2 - Kp*Vth^2 + 2*Kp*Vggon*Vth))^(1/2))/Kp;
        % phase 1
        InVl=[IL/n;Vds0;0;Vggon;0;Vin-Vds0-Rb*IL/n-Rpdc*IL];
        [ttmp,ytmp,ted,yed] =  model_off4(Vggoff,Lg,Ls,Lp,Ld,Rg,Rpac,Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m,InVl,tend);
        tt=[tt; ttmp+((ii-1)*(1e-6))];
        tytmp=ytmp;
        tytmp(:,1) = -(IL-ytmp(:,1));
        tytmp(:,2) = Vin-ytmp(:,2);
        yy=[yy; tytmp];
        end
    end
    % 
    if ii>8e4 && ii<10e4 && S1(ii-1)==1 && S1(ii)==0
        IL = ia(ii-1);
        if IL>=0
        tend=1200e-9;
        
        Vds0=-(Kp*Vth - Kp*Vggon + (-Kp*(IL/n - Kp*Vggon^2 - Kp*Vth^2 + 2*Kp*Vggon*Vth))^(1/2))/Kp;
        % phase 1
        InVl=[IL/n;Vds0;0;Vggon;0;Vin-Vds0-Rb*IL/n-Rpdc*IL];
        [ttmp,ytmp,ted,yed] =  model_off4(Vggoff,Lg,Ls,Lp,Ld,Rg,Rpac,Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m,InVl,tend);
        tt=[tt; ttmp+((ii-1)*(1e-6))];
        yy=[yy; ytmp];
        else
            IL= -IL;
            InVl=[0;Vin+Vfto+Rd2*IL/m;0;Vggoff;IL;-(Vfto+Rd2*IL/m)];
        tend=500e-9;
        [ttmp,ytmp,ted,yed] = model_on4(Vggon,Lg,Ls,Lp,Ld,Rg,Rpac ,Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m,InVl,tend);
        tt=[tt; ttmp+((ii-1)*(1e-6))];
        tytmp=ytmp;
        tytmp(:,1) = -(IL-ytmp(:,1));
        tytmp(:,2) = Vin-ytmp(:,2);
        yy=[yy; tytmp];
        end
    end

    % if abs(ic(ii)-icc) > 0.001
    %     warning("error at:", ii)
    % end

    % forward be like
    % ia(ii) = (Va(ii-1) - VA(ii-1)) * time_step / L + ia(ii-1)
    % ib(ii) = (Vb(ii-1) - VB(ii-1)) * time_step / L + ib(ii-1)
    % ic(ii) = (Vc(ii-1) - VC(ii-1)) * time_step / L + ic(ii-1)
end

% figure;
% plot(t, ia, 'LineWidth', 2);
% xlabel('Time (s)');
% ylabel('Node Voltage (V)');
% title('Transient Analysis: Node Voltages');
% grid on;

figure;
scatter(tt,yy(:,2),1);
%plot(tt, yy(:,2), 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Vds(V)');
title('Drain-Source Voltage, S1');
grid on;

% yyy = yy(:,2);
% [F,TF] = fillmissing(yyy,'previous','SamplePoints',tt);
% figure;
% 
% plot(tt,yy(:,2),'.', tt(TF),F(TF),'.') ;
% xlabel('Time (s)');
% ylabel('Vds(V)');
% title('Drain-Source Voltage, S1');
% grid on;

% figure;
% scatter(tt,yy(:,1),1);
%plot(tt, yy(:,2), 'LineWidth', 2);
% xlabel('Time (s)');
% ylabel('Id(A)');
% title('Drain Current, S1');
% grid on;