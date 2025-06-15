%% main.m
clear; clc;

%% Define the netlist as a MATLAB table.
% Columns:
%   Type: component type (e.g. 'VoltageSource', 'Resistor', etc.)
%   Node1, Node2: nodes for the element (0 = ground)
%   Value: For resistor, capacitor, inductor, voltage source (or transformer gain)
%   For transformer: Node3 and Node4 are secondary nodes.
%   For PowerSwitch: Value2 is R_off and State is the initial state.
netlist = table();
netlist.Type = {'VoltageSource';'Resistor';'Capacitor'};
netlist.Node1 = [1; 1; 2];  % Node1 - positive connection
netlist.Node2 = [0; 2; 0];  % Node2 - negative connection
%                           % 0 represents the ground (ref)
netlist.Value = [100; 1000; 1e-3];  
% For transformer, secondary side nodes:
%netlist.Node3 = {NaN; NaN; NaN; NaN};  
%netlist.Node4 = {NaN; NaN; NaN; NaN};  
% For PowerSwitch, R_off:
%netlist.Value2 = [NaN; NaN; NaN; 1e9];  
%netlist.Value2 = [NaN; NaN; NaN];  


%% Specify the number of nodes (excluding ground).
numNodes = 2;

%% Create the Circuit from the netlist table.
myCircuit = Circuit0(netlist, numNodes);

%% Perform DC Analysis.
% d

%% Perform Transient Analysis.
t_end = 2;   % total simulation time in seconds
dt = 0.00001;    % time step in seconds
initialNodeVoltages = zeros(numNodes,1);           % initial voltages (e.g., all 0V)
initialBranchCurrents = zeros(myCircuit.numBranches, 1);  % initialize branch currents

disp('Transient Analysis');
[t, nodeHist, branchHist] = myCircuit.analyzeTransient(t_end, dt, initialNodeVoltages, initialBranchCurrents);

%% Plot the Node Voltages.
figure;
plot(t, nodeHist, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Node Voltage (V)');
title('Transient Node Voltages');
grid on;
