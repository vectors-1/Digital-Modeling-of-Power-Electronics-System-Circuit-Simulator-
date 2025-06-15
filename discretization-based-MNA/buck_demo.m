%% demo_with_a_switch.m
%% uses "Circuit2.m"
%% switching every 1e-3 s (implemented in "Circuit2.m")
clear; clc;
dt = 1e-8;
Ron=1e-3;
Roff=1e9;
%% Create a netlist table.
% Variable names: Type, Node1, Node2, Value, Value2, Node3, Node4, State, Gate
netlistTable = table;
netlistTable.Type = {'VoltageSource'; 'Resistor'; 'Switch'; 'Capacitor'; 'Resistor'; 'Inductor'; "Diode"};
netlistTable.Node1 = [1; 1; 2; 4; 4; 3; 0];
netlistTable.Node2 = [0; 2; 3; 0; 0; 4; 3];
netlistTable.Value = [100; 0.1; 1e-3; 1e-3; 100; 1e-2; 1e-3];   % Voltage for VoltageSource, resistance for Resistor, R_on for Switch, capacitance for Capacitor
%netlistTable.Value2 = [NaN; NaN; 1e9; NaN; NaN; NaN; 1e9];      % For Switch: R_off
%netlistTable.Node3 = {NaN; NaN; NaN; NaN};        
%netlistTable.Node4 = {NaN; NaN; NaN; NaN};
%netlistTable.State = {NaN; NaN; 'off'; NaN};
%netlistTable.Gate = [NaN; NaN; 0; NaN];  % Initial gate value for Switch

%% Specify the number of non-ground nodes.
% In this example, nodes 1, 2, and 3 are used.
numNodes = 4;

%% Build the circuit from the netlist table.
ans=-1;
myCircuit = Circuit3(netlistTable, numNodes);

%% Create a Controller.
% For demonstration, assume:
%   setpoint = 5 (e.g., desired voltage at node 2),
%   Kp = 0.1, Ki = 0.05,
%   Control sample period T_control = 0.001 sec,
%   Initial duty cycle = 0.5.
%controller = 0;

% Also define the PWM period (e.g., 0.001 sec).
T_pwm = 0.001;

%% Perform DC Analysis.
% disp('=== DC Analysis ===');
% dcSolution = myCircuit.analyzeDC();

%% Perform Transient Analysis.
t_end = 1;   % Total simulation time (sec)
    % Time step (sec)
initialNodeVoltages = zeros(numNodes,1);
initialBranchCurrents = zeros(myCircuit.numBranches, 1);

disp('=== Transient Analysis ===');
[t, nodeHist, branchHist,stats] = myCircuit.analyzeTransient(t_end, dt, initialNodeVoltages, initialBranchCurrents);

%% Plot the node voltages.
figure;
plot(t, nodeHist(4,:), 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Node Voltage (V)');
title('Transient Analysis: Node Voltages');
grid on;
