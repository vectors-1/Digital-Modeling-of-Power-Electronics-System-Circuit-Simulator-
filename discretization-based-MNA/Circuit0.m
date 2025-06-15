%% Circuit.m
classdef Circuit0
    properties
        components  % Cell array of Component objects
        numNodes    % Number of non‑ground nodes
        numBranches % Count of extra branch variables
    end
    methods
        function obj = Circuit0(netlistTable, numNodes)
            obj.numNodes = numNodes;
            obj.components = {};
            obj.numBranches = 0;
            
            for i = 1:height(netlistTable)
                compType = lower(netlistTable.Type{i});
                switch compType
                    case 'resistor'
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        R = netlistTable.Value(i);
                        comp = Resistor(n1, n2, R);
                    case 'capacitor'
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        C = netlistTable.Value(i);
                        comp = Capacitor(n1, n2, C);
                    case 'inductor'
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        L = netlistTable.Value(i);
                        obj.numBranches = obj.numBranches + 1;
                        comp = Inductor(n1, n2, L, obj.numBranches);
                    case 'voltagesource'
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        V = netlistTable.Value(i);
                        obj.numBranches = obj.numBranches + 1;
                        comp = VoltageSource(n1, n2, V, obj.numBranches);
                    case 'transformer'
                        % For transformer, primary: Node1 & Node2; secondary: Node3 & Node4; Value is gain.
                        np1 = netlistTable.Node1(i);
                        np2 = netlistTable.Node2(i);
                        ns1 = netlistTable.Node3{i};
                        ns2 = netlistTable.Node4{i};
                        gain = netlistTable.Value(i);
                        obj.numBranches = obj.numBranches + 1;
                        comp = Transformer(np1, np2, ns1, ns2, gain, obj.numBranches);
            %% below        %% not working properly
                    case {'switch','MOSFET'}
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        R_on = netlistTable.Value(i);
                        R_off = netlistTable.Value2(i);
                        if ismember('Gate', netlistTable.Properties.VariableNames)
                            initialGate = netlistTable.Gate(i);
                        else
                            initialGate = 0;
                        end
                        comp = MOSFETSwitch(n1, n2, R_on, R_off);
                        %comp = MOSFETSwitch(n1, n2, R_on, R_off, initialGate);
                    case 'mosfetd'
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        R_on = netlistTable.Value(i);
                        R_off = netlistTable.Value2(i);
                        if ismember('Gate', netlistTable.Properties.VariableNames)
                            initialGate = netlistTable.Gate(i);
                        else
                            initialGate = 0;
                        end
                        diodeThreshold = 0.7; %netlistTable.DiodeThreshold(i);
                        diodeResistance = 1e-3; %netlistTable.DiodeResistance(i);
                        comp = MOSFETWithDiode(n1, n2, R_on, R_off, initialGate, diodeThreshold, diodeResistance);
             %% above        %% not working properly
                    otherwise
                        error(['Unknown component type: ' compType]);
                end
                obj.components{end+1} = comp;
            end
        end
        
        %% function analyzeDC
        function sol = analyzeDC(obj)
            totalVars = obj.numNodes + obj.numBranches;
            A = zeros(totalVars, totalVars);
            b = zeros(totalVars, 1);
            
            % Stamp each component into A and b.
            for i = 1:length(obj.components)
                comp = obj.components{i};
                [A, b] = comp.stampDC(A, b, obj.numNodes);
            end
            
            sol = A\b;
            disp('DC Analysis Node Voltages:');
            disp(sol(1:obj.numNodes));
        end
        
        %% function analyzeTransient
        function [t, nodeHistory, branchHistory] = analyzeTransient(obj, t_end, dt, initialNodeVoltages, initialBranchCurrents, controller, T_pwm)
        % -not applicable to this case-    % controller: an instance of Controller (or [] if none)
         % -controller is deleted-   % T_pwm: PWM period for gate signal generation.

            totalVars = obj.numNodes + obj.numBranches;
            numSteps = ceil(t_end/dt);
            nodeHistory = zeros(obj.numNodes, numSteps);
            branchHistory = zeros(obj.numBranches, numSteps);

            % Initialize state vector: first numNodes are node voltages; remaining are branch currents.
            currentState = zeros(totalVars, 1);
            if ~isempty(initialNodeVoltages)
                currentState(1:obj.numNodes) = initialNodeVoltages;
            end
            if ~isempty(initialBranchCurrents)
                currentState(obj.numNodes+1:end) = initialBranchCurrents;
            end
            nodeHistory(:,1) = currentState(1:obj.numNodes);
            branchHistory(:,1) = currentState(obj.numNodes+1:end);
            
            t = linspace(0, t_end, numSteps);
            
            for k = 2:numSteps
                
                A = zeros(totalVars, totalVars);
                b = zeros(totalVars, 1);
                % Extract branch currents from current state.
                branchCurrents = currentState(obj.numNodes+1:end);
                for i = 1:length(obj.components)
                    comp = obj.components{i};
                    [A, b] = comp.stampTransient(A, b, dt, currentState(1:obj.numNodes), obj.numNodes, branchCurrents);
                end
                newState = A\b;
                currentState = newState;
                nodeHistory(:, k) = currentState(1:obj.numNodes);
                branchHistory(:, k) = currentState(obj.numNodes+1:end);
            end
        end
    end
end
