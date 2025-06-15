%% circuit simulation
clc;
clear;

simulation_time_lenth = 0.5;
time_step = 1e-6;
total_steps = round(simulation_time_lenth / time_step);
%nodal_voltage = zeros(8,total_steps);

% Vin = 100;
% R = 10;
% L = 0.1;

Vin = 100;
R = 31.7;
L = 0.003;

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




    % if abs(ic(ii)-icc) > 0.001
    %     warning("error at:", ii)
    % end

    % forward be like
    % ia(ii) = (Va(ii-1) - VA(ii-1)) * time_step / L + ia(ii-1)
    % ib(ii) = (Vb(ii-1) - VB(ii-1)) * time_step / L + ib(ii-1)
    % ic(ii) = (Vc(ii-1) - VC(ii-1)) * time_step / L + ic(ii-1)
end

figure;
plot(t, ia, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Branch Current (A)');
title('Transient Analysis: Current');
grid on;

U_p1 = VA-VN;