%% main.m
clear; clc;

Ron=1e-3;
Roff=1e9;
%% Create a netlist table.
% Variable names: Type, Node1, Node2, Value, Value2, Node3, Node4, State, Gate
netlistTable = table;
netlistTable.Type = {'VoltageSource'; 'Switch'; 'Diode'; 'Inductor'; 'Resistor';  'Capacitor'};
netlistTable.Node1 = [1; 1; 2; 2; 3; 3];
netlistTable.Node2 = [0; 2; 0; 3; 0; 0];
netlistTable.Value = [100; Ron; NaN; 1e-3; 1e3; 1e-4];   % Voltage for VoltageSource, resistance for Resistor, R_on for Switch, capacitance for Capacitor
netlistTable.Value2 = [NaN; Roff; NaN; NaN; NaN; NaN];      % For Switch: R_off
%netlistTable.Node3 = {NaN; NaN; NaN; NaN};        
%netlistTable.Node4 = {NaN; NaN; NaN; NaN};
%netlistTable.State = {NaN; NaN; 'off'; NaN};
%netlistTable.Gate = [NaN; NaN; 0; NaN];  % Initial gate value for Switch

%% Specify the number of non-ground nodes.
% In this example, nodes 1, 2, and 3 are used.
numNodes = 3;

%% Build the circuit from the netlist table.
myCircuit = Circuit(netlistTable, numNodes);

%% Create a Controller.
% For demonstration, assume:
%   setpoint = 5 (e.g., desired voltage at node 2),
%   Kp = 0.1, Ki = 0.05,
%   Control sample period T_control = 0.001 sec,
%   Initial duty cycle = 0.5.
%controller = Controller(5, 0.1, 0.05, 0.001, 0.5);

% Also define the PWM period (e.g., 0.001 sec).
T_pwm = 0.001;

%% Perform DC Analysis.
% disp('=== DC Analysis ===');
% dcSolution = myCircuit.analyzeDC();

%% Perform Transient Analysis.
t_end = 1;   % Total simulation time (sec)
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
