%% DAB1.m
clear; clc;

%% para
Vin = 200;
ron = 1e-3;
roff = 1e9;
Ls = 100e-6;
ratio = 2;

R = 30;
Cout = 680e-6;

Kp = 0.4;
Ki = 0.2;
%ev_accum = 0;
tstep = 1e-8;
%Rs1 = 100e-3;
%Rs2 = 100e-3;
Vref = 300;

%% Create a netlist table.
% Variable names: Type, Node1, Node2, Value, Value2, Node3, Node4, State, Gate
netlist = table;
netlist.Type = {'VoltageSource'; 'MOSFETd'; 'MOSFETd'; 'MOSFETd'; 'MOSFETd'; 'Inductor'; 'Transformer'; 'MOSFETd'; 'MOSFETd'; 'MOSFETd'; 'MOSFETd'; 'Capacitor'; 'Resistor'};
netlist.Node1 = [1; 1; 2; 1; 4; 2; 3; 7; 5; 7; 6; 7; 7];
netlist.Node2 = [0; 2; 0; 4; 0; 3; 4; 5; 8; 6; 8; 8; 8];
netlist.Value = [Vin; ron; ron; ron; ron; Ls; ratio; ron; ron; ron; ron; Cout; R];   % Voltage for VoltageSource, resistance for Resistor, R_on for Switch, capacitance for Capacitor
netlist.Value2 = [NaN; roff; roff; roff; roff; NaN; NaN; roff; roff; roff; roff; NaN; NaN];      % For Switch: R_off
netlist.Node3 = {NaN; NaN; NaN; NaN; NaN; NaN; 5; NaN; NaN; NaN; NaN; NaN; NaN};        
netlist.Node4 = {NaN; NaN; NaN; NaN; NaN; NaN; 6; NaN; NaN; NaN; NaN; NaN; NaN};
netlist.State = {NaN; 'off'; 'off'; 'off'; 'off'; NaN; NaN; 'off'; 'off'; 'off'; 'off'; NaN; NaN};
netlist.Gate = [NaN; 0; 0; 0; 0; NaN; NaN; 0; 0; 0; 0; NaN; NaN];  % Initial gate value for Switch

%% Specify the number of non-ground nodes.
% In this example, nodes 1, 2, and 3 are used.
numNodes = 8;

%% Build the circuit from the netlist table.
myCircuit = Circuit(netlist, numNodes);

%% Create a Controller.
% For demonstration, assume:
%   setpoint = 5 (e.g., desired voltage at node 2),
%   Kp = 0.1, Ki = 0.05,
%   Control sample period T_control = 0.001 sec,
%   Initial duty cycle = 0.5.
T_pwm = 1e-3;

controller = Controller(Vref, Kp, Ki, T_pwm, 0);

% Also define the PWM period (e.g., 0.001 sec).
%T_pwm = 1e-3;

%% Perform DC Analysis.
% disp('=== DC Analysis ===');
% dcSolution = myCircuit.analyzeDC();

%% Perform Transient Analysis.
t_end = 2;   % Total simulation time (sec)
dt = 1e-6;    % Time step (sec)
initialNodeVoltages = zeros(numNodes,1);
initialBranchCurrents = zeros(myCircuit.numBranches, 1);

disp('=== Transient Analysis ===');
[t, nodeHist, branchHist] = myCircuit.analyzeTransient(t_end, dt, initialNodeVoltages, initialBranchCurrents, controller, T_pwm);

%% Plot the node voltages.
figure;
plot(t, nodeHist, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Node Voltage (V)');
title('Transient Analysis: Node Voltages');
grid on;
