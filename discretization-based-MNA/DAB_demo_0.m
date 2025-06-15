%% demo_with_a_switch.m
%% uses "Circuit2.m"
%% switching every 1e-3 s (implemented in "Circuit2.m")
clear; clc;
dt = 1e-5;

%% Create a netlist table.
% Variable names: Type, Node1, Node2, Value, Value2, Node3, Node4, State, Gate
% netlistTable = table;
% netlistTable.Type = {'VoltageSource'; 'Resistor'; 'Switch'; 'Capacitor'; 'Resistor'; 'Inductor'; "Diode"};
% netlistTable.Node1 = [1; 1; 2; 4; 4; 3; 0];
% netlistTable.Node2 = [0; 2; 3; 0; 0; 4; 3];
% netlistTable.Value = [100; 0.1; 1e-3; 1e-3; 100; 1e-2; 1e-3];   % Voltage for VoltageSource, resistance for Resistor, R_on for Switch, capacitance for Capacitor
netlistStr = [...
    'VoltageSource, 1,  0,  200;'   newline ...
    'MOSFETd,       1,  2,  1e-3;'  newline ...
    'MOSFETd,       2,  0,  1e-3;'  newline ...
    'MOSFETd,       1,  4,  1e-3;'  newline ...
    'MOSFETd,       4,  0,  1e-3;'  newline ...
    'Inductor,      2,  3,  100e-6;' newline ...
    'Transformer,   3,  4,  5, 6, 2;' newline ...
    'MOSFETd,       7,  5,  1e-3;'  newline ...
    'MOSFETd,       5,  8,  1e-3;'  newline ...
    'MOSFETd,       7,  6,  1e-3;'  newline ...
    'MOSFETd,       6,  8,  1e-3;'  newline ...
    'Capacitor,     7,  8,  680e-6;' newline ...
    'VoltageSource,      7,  8,  300;'    ];

%% Specify the number of non-ground nodes.
% In this example, nodes 1, 2, and 3 are used.
numNodes = 8;

%% Build the circuit from the netlist table.
myCircuit = Circuit4fin(netlistStr, numNodes);

%% Create a Controller.
% For demonstration, assume:
%   setpoint = 5 (e.g., desired voltage at node 2),
%   Kp = 0.1, Ki = 0.05,
%   Control sample period T_control = 0.001 sec,
%   Initial duty cycle = 0.5.
%controller = 0;

% Also define the PWM period (e.g., 0.001 sec).
T_pwm = 0.001;
%T_control = 1e-3; % control_update_cycle
%controller = Controller(4, T_control); % Controller(probe1, T_control)

%% Perform DC Analysis.
% disp('=== DC Analysis ===');
% dcSolution = myCircuit.analyzeDC();

%% Perform Transient Analysis.
t_end = 3e-4;   % Total simulation time (sec)
    % Time step (sec)
initialNodeVoltages = zeros(numNodes,1);
%initialNodeVoltages(1) = 200;
%initialNodeVoltages(8) = 400;
%initialNodeVoltages(7) = 0;

initialBranchCurrents = zeros(myCircuit.numBranches, 1);

disp('=== Transient Analysis ===');
[t, nodeHist, branchHist,stats] = myCircuit.analyzeTransient(t_end, dt, initialNodeVoltages, initialBranchCurrents);

%% Plot the node voltages.
figure;
plot(t, nodeHist, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Node Voltage (V)');
title('Transient Analysis: Node Voltages');
grid on;
