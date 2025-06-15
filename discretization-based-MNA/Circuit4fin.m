%% Circuit2.m
classdef Circuit4fin < handle
    properties
        components  % Cell array of Component objects
        numNodes    % Number of non‑ground nodes
        numBranches % Count of extra branch variables
        currentState
    end
    methods
        function obj = Circuit4fin(netlistStr, numNodes)
            % netlistTable: a MATLAB table containing the netlist
            obj.numNodes = numNodes;
            obj.components = {};
            obj.numBranches = 0;
            
            lines = split(netlistStr, ';');
            for i = 1:length(lines)
                line = strtrim(lines{i});
                if isempty(line)
                    continue;
                end
                tokens = split(line, ',');
                tokens = strtrim(tokens);
                compType = lower(tokens{1});
                switch compType
                    case 'resistor'
                        n1 = str2double(tokens{2});
                        n2 = str2double(tokens{3});
                        R = str2double(tokens{4});
                        comp = Resistor(n1, n2, R);
                        obj.components{end+1} = comp;

                    case 'capacitor'
                        n1 = str2double(tokens{2});
                        n2 = str2double(tokens{3});
                        C = str2double(tokens{4});
                        comp = Capacitor(n1, n2, C);
                        obj.components{end+1} = comp;

                    case 'inductor'
                        n1 = str2double(tokens{2});
                        n2 = str2double(tokens{3});
                        L = str2double(tokens{4});
                        obj.numBranches = obj.numBranches + 1;
                        comp = Inductor(n1, n2, L, obj.numBranches);
                        obj.components{end+1} = comp;

                    case 'voltagesource'
                        n1 = str2double(tokens{2});
                        n2 = str2double(tokens{3});
                        V = str2double(tokens{4});
                        obj.numBranches = obj.numBranches + 1;
                        comp = VoltageSource(n1, n2, V, obj.numBranches);
                        obj.components{end+1} = comp;
                    case 'transformer'
                        % For transformer, expect: Transformer, np1, np2, ns1, ns2, gain
                        np1 = str2double(tokens{2});
                        np2 = str2double(tokens{3});
                        ns1 = str2double(tokens{4});
                        ns2 = str2double(tokens{5});
                        gain = str2double(tokens{6});
                        obj.numBranches = obj.numBranches + 1;
                        comp = Transformer(np1, np2, ns1, ns2, gain, obj.numBranches);
                        obj.components{end+1} = comp;
                    case 'switch'
                        % For a switch, expect: Switch, n1, n2, R_on, R_off
                        n1 = str2double(tokens{2});
                        n2 = str2double(tokens{3});
                        R_on = str2double(tokens{4});
                        comp = Switch(n1, n2, R_on, 0);
                        obj.components{end+1} = comp;
                        
                    case 'diode'
                        n1 = str2double(tokens{2});
                        n2 = str2double(tokens{3});
                        R_on = str2double(tokens{4});
                        comp = Diode(n1, n2, R_on);
                        obj.components{end+1} = comp;
                    case 'mosfetd'
                        n1 = str2double(tokens{2});
                        n2 = str2double(tokens{3});
                        R_on = str2double(tokens{4});
                        obj.components{end+1} = Switch(n1, n2, R_on); 
                        obj.components{end+1} = Diode(n2, n1, R_on);
                    otherwise
                        error(['Unknown component type: ' tokens{1}]);
                end

            end
            totalVars = obj.numNodes + obj.numBranches;
            obj.currentState = zeros(totalVars, 1);
            obj.components
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


            obj.components{2}.state = 1;
            obj.components{4}.state = 0;
            obj.components{6}.state = 0;
            obj.components{8}.state = 1;

            obj.components{12}.state = 0;
            obj.components{14}.state = 1;
            obj.components{16}.state = 1;
            obj.components{18}.state = 0;

            lastUpdateTime = 0;
            flagc = 1;
            for k = 2:numSteps
                % --- Control loop update ---
                %% control, switches every 1e-3 s
dbg_show = 0;
                %call_controller(t(1,k), obj.currentState(controller.probe1));

                dtc = t(1,k) - lastUpdateTime;
                if dtc >= 1e-4
%dbg_show = 1;
%debug_t = t(1,k)
                    obj.components{2}.state = ~obj.components{2}.state;
                    obj.components{4}.state = ~obj.components{4}.state;
                    obj.components{6}.state = ~obj.components{6}.state;
                    obj.components{8}.state = ~obj.components{8}.state;
                   
%debug_sw = obj.components{3}.state
                    lastUpdateTime = t(1,k);
                    flagc = 1;

                end
                if flagc && ( t(1,k) - lastUpdateTime >= 1e-4 )
                    obj.components{12}.state = ~obj.components{12}.state;
                    obj.components{14}.state = ~obj.components{14}.state;
                    obj.components{16}.state = ~obj.components{16}.state;
                    obj.components{18}.state = ~obj.components{18}.state;
                    flagc = 0;
                end
%%
                
                % Extract branch currents from current state.
                %branchCurrents = currentState(obj.numNodes+1:end);

                
if dbg_show==1
debug_diniVn2 = dv2
debug_dinigus = dd.diodeOn
end
                
                %check=updatecheck();
                % Check()
                converged = false;
                iter = 0;
                while ~converged

                    A = zeros(totalVars, totalVars);
                    b = zeros(totalVars, 1);
                    for i = 1:length(obj.components)
                        comp = obj.components{i};
                        [A, b] = comp.stampTransient(A, b, dt, obj.numNodes, obj.currentState);
                    end
                    newState = A\b;

                    %check
                    numFailed = 0;
                    for i = 1:length(obj.components)
                        comp = obj.components{i};
                        if isa(comp, 'Diode')
                            dv1=0; dv2=0;
                            if comp.node1>0, dv1=newState(comp.node1); end
                            if comp.node2>0, dv2=newState(comp.node2); end 
                            if xor( (dv1-dv2>0), comp.diodeOn)
                                obj.components{i}.diodeOn = ~comp.diodeOn;
                                numFailed = numFailed + 1;
                            end
                        end
                    end
                    if numFailed > 0
                        iter = iter + 1;
                    else
                        converged = true;
                    end
                    if iter > 16
                        warning('unconverged at time %.6f', t(1,k));
                        break
                    end

                end


              
if dbg_show==1
debug_ckdVn2 = dv2
end
if dbg_show==1
debug_flagon=9
end
if dbg_show==1
debug_dalter=dd.diodeOn
debug_dorign=obj.components{7}.diodeOn
end
                    %stampinverse_actiondepending_onifdiodeOn %qujueyu Rbig/rsmall   事实上大电阻可以不stamp当断路

if dbg_show==1
debug_daltVn2=newState(dd.node2)
end
         
              %end
if dbg_show==1
debug_end = 1234567
end
                % stats(k)=-1;
                % stats(k)=obj.components{3}.state;
                
                obj.currentState = newState;
                nodeHistory(:, k) = obj.currentState(1:obj.numNodes);
                branchHistory(:, k) = obj.currentState(obj.numNodes+1:end);
            end
        end
    end
end
