%% demo_with_a_switch.m
%% uses "Circuit2.m"
%% switching every 1e-3 s (implemented in "Circuit2.m")
clear; clc;
dt = 1e-6;

%% Create a netlist table.
% Variable names: Type, Node1, Node2, Value, Value2, Node3, Node4, State, Gate
% netlistTable = table;
% netlistTable.Type = {'VoltageSource'; 'Resistor'; 'Switch'; 'Capacitor'; 'Resistor'; 'Inductor'; "Diode"};
% netlistTable.Node1 = [1; 1; 2; 4; 4; 3; 0];
% netlistTable.Node2 = [0; 2; 3; 0; 0; 4; 3];
% netlistTable.Value = [100; 0.1; 1e-3; 1e-3; 100; 1e-2; 1e-3];   % Voltage for VoltageSource, resistance for Resistor, R_on for Switch, capacitance for Capacitor
netlistStr = [...
    'VoltageSource, 1,  0,  100;'   newline ...
    'MOSFETd,       1,  2,  1e-3;'  newline ...
    'MOSFETd,       2,  0,  1e-3;'  newline ...
    'MOSFETd,       1,  3,  1e-3;'  newline ...
    'MOSFETd,       3,  0,  1e-3;'  newline ...
    'MOSFETd,       1,  4,  1e-3;'  newline ...
    'MOSFETd,       4,  0,  1e-3;'  newline ...
    'Inductor,      2,  5,  0.003;'     newline ...
    'Inductor,      3,  6,  0.003;'     newline ...
    'Inductor,      4,  7,  0.003;'     newline ...
    'Resistor,      5,  8,  31.7;'     newline ...
    'Resistor,      6,  8,  31.7;'     newline ...
    'Resistor,      7,  8,  31.7;'     ];

%% Specify the number of non-ground nodes.
% In this example, nodes 1, 2, and 3 are used.
numNodes = 8;

%% Build the circuit from the netlist table.
myCircuit = Circuit5invctl(netlistStr, numNodes);

%% Create a Controller.
% For demonstration, assume:
%   setpoint = 5 (e.g., desired voltage at node 2),
%   Kp = 0.1, Ki = 0.05,
%   Control sample period T_control = 0.001 sec,
%   Initial duty cycle = 0.5.
%controller = 0;

% Also define the PWM period (e.g., 0.001 sec).
T_pwm = 0.001;
T_control = 1e-3; % control_update_cycle
%controller = Controller(3, T_control); % Controller(probe1, T_control)

%% Perform DC Analysis.
% disp('=== DC Analysis ===');
% dcSolution = myCircuit.analyzeDC();

%% Perform Transient Analysis.
t_end = 0.2;   % Total simulation time (sec)
    % Time step (sec)
initialNodeVoltages = zeros(numNodes,1);
initialBranchCurrents = zeros(myCircuit.numBranches, 1);

disp('=== Transient Analysis ===');
[t, nodeHist, branchHist,stats] = myCircuit.analyzeTransient(t_end, dt, initialNodeVoltages, initialBranchCurrents);

%% Plot the node voltages.
figure;
plot(t, nodeHist(5,:)-nodeHist(8,:), 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Node Voltage (V)');
title('Transient Analysis: Node Voltages');
grid on;
