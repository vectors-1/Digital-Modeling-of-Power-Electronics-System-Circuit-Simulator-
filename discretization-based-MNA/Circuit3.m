%% Circuit2.m
classdef Circuit3 < handle
    properties
        components  % Cell array of Component objects
        numNodes    % Number of non‑ground nodes
        numBranches % Count of extra branch variables
        currentState
    end
    methods
        function obj = Circuit3(netlistTable, numNodes)
            % netlistTable: a MATLAB table containing the netlist
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
                    case 'switch'
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        R_on = netlistTable.Value(i);
                        %R_off = netlistTable.Value2(i);
                     
                        comp = Switch(n1, n2, R_on, 0);
                        %comp = MOSFETSwitch(n1, n2, R_on, R_off, initialGate);
                    case 'diode'
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        R_on = netlistTable.Value(i);
                        %R_off = netlistTable.Value2(i);
                     
                        comp = Diode(n1, n2, R_on);
                    case 'mosfetd'
                        n1 = netlistTable.Node1(i);
                        n2 = netlistTable.Node2(i);
                        R_on = netlistTable.Value(i);
                        %R_off = netlistTable.Value2(i);
                        if ismember('Gate', netlistTable.Properties.VariableNames)
                            initialGate = netlistTable.Gate(i);
                        else
                            initialGate = 0;
                        end
                        diodeThreshold = 0.7; %netlistTable.DiodeThreshold(i);
                        diodeResistance = 1e-3; %netlistTable.DiodeResistance(i);
                        comp = MOSFETWithDiode(n1, n2, R_on, initialGate, diodeThreshold, diodeResistance);
                    otherwise
                        error(['Unknown component type: ' compType]);
                end
                obj.components{end+1} = comp;
            end
            totalVars = obj.numNodes + obj.numBranches;
            obj.currentState = zeros(totalVars, 1);
        end
        
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
        
        function [t, nodeHistory, branchHistory,stats] = analyzeTransient(obj, t_end, dt, initialNodeVoltages, initialBranchCurrents)

            totalVars = obj.numNodes + obj.numBranches;
            numSteps = ceil(t_end/dt);
            nodeHistory = zeros(obj.numNodes, numSteps);
            branchHistory = zeros(obj.numBranches, numSteps);
            stats = zeros(1,numSteps);
        %%   
            

            % Initialize state vector: first numNodes are node voltages; remaining are branch currents.
            %currentState = zeros(totalVars, 1);
            %if ~isempty(initialNodeVoltages)
                obj.currentState(1:obj.numNodes) = initialNodeVoltages;
            %end
            %if ~isempty(initialBranchCurrents)
                obj.currentState(obj.numNodes+1:end) = initialBranchCurrents;
            %end
            nodeHistory(:,1) = obj.currentState(1:obj.numNodes);
            branchHistory(:,1) = obj.currentState(obj.numNodes+1:end);
            
            t = linspace(0, t_end, numSteps);
            lastUpdateTime = 0;
            for k = 2:numSteps
                % --- Control loop update ---
                %% control, switches every 1e-3 s
dbg_show = 0;
                dtc = t(1,k) - lastUpdateTime;
                if dtc >= 1e-3
%dbg_show = 1;
%debug_t = t(1,k)
                            if obj.components{3}.state==0
                                obj.components{3}.state=1;
                                %flag = 1
                            else
                                obj.components{3}.state=0;
                                %flag = 0
                            end
%debug_sw = obj.components{3}.state
               lastUpdateTime = t(1,k); 
               %obj.components{3}.state
            end
               

%%
                A = zeros(totalVars, totalVars);
                b = zeros(totalVars, 1);
                % Extract branch currents from current state.
                %branchCurrents = currentState(obj.numNodes+1:end);
                %check=0;
              %while(~check)
                dv1=0; dv2=0;
                dd=obj.components{7};
                if dd.node1>0, dv1=obj.currentState(dd.node1); end
                if dd.node2>0, dv2=obj.currentState(dd.node2); end
                if dv1-dv2>0
                    obj.components{7}.diodeOn=1;
                else
                    obj.components{7}.diodeOn=0;
                end
if dbg_show==1
debug_diniVn2 = dv2
debug_dinigus = dd.diodeOn
end
                for i = 1:length(obj.components)
                    comp = obj.components{i};
                    [A, b] = comp.stampTransient(A, b, dt, obj.numNodes, obj.currentState);
                end
                newState = A\b;
                %check=updatecheck();
                % Check()
                dv1=0; dv2=0;
                dd=obj.components{7};
                if dd.node1>0, dv1=newState(dd.node1); end
                if dd.node2>0, dv2=newState(dd.node2); end
if dbg_show==1
debug_ckdVn2 = dv2
end
                if xor( (dv1-dv2>0), dd.diodeOn)
if dbg_show==1
debug_flagon=9
end
                    obj.components{7}.diodeOn = ~dd.diodeOn;
if dbg_show==1
debug_dalter=dd.diodeOn
debug_dorign=obj.components{7}.diodeOn
end
                    %stampinverse_actiondepending_onifdiodeOn %qujueyu Rbig/rsmall   事实上大电阻可以不stamp当断路
                    A = zeros(totalVars, totalVars);
                    b = zeros(totalVars, 1);
                    for i = 1:length(obj.components)
                        comp = obj.components{i};
                        [A, b] = comp.stampTransient(A, b, dt, obj.numNodes, obj.currentState);
                    end
                    newState = A\b;
if dbg_show==1
debug_daltVn2=newState(dd.node2)
end
                end
              %end
if dbg_show==1
debug_end = 1234567
end
                stats(k)=-1;
                stats(k)=obj.components{3}.state;
                
                obj.currentState = newState;
                nodeHistory(:, k) = obj.currentState(1:obj.numNodes);
                branchHistory(:, k) = obj.currentState(obj.numNodes+1:end);
            end
        end
    end
end
