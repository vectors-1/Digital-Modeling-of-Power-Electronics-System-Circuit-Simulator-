%% MOSFETSwitchWithDiode.m
classdef MOSFETWithDiode < MOSFETSwitch
    properties
        diodeThreshold  % Forward voltage threshold for the diode (e.g., 0.7 V)
        diodeResistance % Effective resistance when the diode is forward-biased (Ohms)
        diodeOn         % Logical flag indicating if the diode is conducting (true/false)
    end
    methods
        function obj = MOSFETWithDiode(n1, n2, R_on, R_off, initialGate, diodeThreshold, diodeResistance)
            % Call the parent constructor to initialize the MOSFET switch part.
            obj@MOSFETSwitch(n1, n2, R_on, R_off, initialGate);
            obj.diodeThreshold = diodeThreshold;
            obj.diodeResistance = diodeResistance;
            % Initialize diodeOn flag (for example, assume off initially)
            obj.diodeOn = false;
        end
        
        function [A, b] = stampDC(obj, A, b, numNodes)
            % In DC analysis the diode is typically not active if the voltage is
            % below its threshold. Here we simply stamp the MOSFET branch as usual.
            [A, b] = stampDC@MOSFETSwitch(obj, A, b, numNodes);
            % Optionally, you might want to include a diode branch if you already know
            % that the diode would be forward-biased in your DC operating point.
            if obj.diodeOn %&& obj.node1 > 0 && obj.node2 > 0
                g_d = 1 / obj.diodeResistance;
                if obj.node1 > 0
                    A(obj.node1, obj.node1) = A(obj.node1, obj.node1) + g_d;
                end
                if obj.node2 > 0
                    A(obj.node2, obj.node2) = A(obj.node2, obj.node2) + g_d;
                end
                if obj.node1 > 0 && obj.node2 > 0
                    A(obj.node1, obj.node2) = A(obj.node1, obj.node2) - g_d;
                    A(obj.node2, obj.node1) = A(obj.node2, obj.node1) - g_d;
                end
                % The diode is anti-parallel: it conducts from node2 (anode) to node1 (cathode).
                % A(obj.node2, obj.node2) = A(obj.node2, obj.node2) + g_d;
                % A(obj.node1, obj.node1) = A(obj.node1, obj.node1) + g_d;
                % A(obj.node2, obj.node1) = A(obj.node2, obj.node1) - g_d;
                % A(obj.node1, obj.node2) = A(obj.node1, obj.node2) - g_d;
            end
        end
        
        function [A, b] = stampTransient(obj, A, b, dt, prevState, numNodes, branchCurrents)
            % --- Update Diode Conduction State ---
            % For example, we check the voltage difference from node2 to node1 (i.e., from drain to source).
            % A positive voltage (above diodeThreshold) indicates the diode is forward-biased.
            if obj.node1 > 0 && obj.node2 > 0
                V_diode = prevState(obj.node2) - prevState(obj.node1);
                if V_diode > obj.diodeThreshold
                    obj.diodeOn = true;
                else
                    obj.diodeOn = false;
                end
            end
            
            % --- Stamp MOSFET Branch ---
            [A, b] = stampTransient@MOSFETSwitch(obj, A, b, dt, prevState, numNodes, branchCurrents);
            
            % --- Stamp Anti-Parallel Diode (if active) ---
            if obj.diodeOn %&& obj.node1 > 0 && obj.node2 > 0
                g_d = 1 / obj.diodeResistance;
                if obj.node1 > 0
                    A(obj.node1, obj.node1) = A(obj.node1, obj.node1) + g_d;
                end
                if obj.node2 > 0
                    A(obj.node2, obj.node2) = A(obj.node2, obj.node2) + g_d;
                end
                if obj.node1 > 0 && obj.node2 > 0
                    A(obj.node1, obj.node2) = A(obj.node1, obj.node2) - g_d;
                    A(obj.node2, obj.node1) = A(obj.node2, obj.node1) - g_d;
                end
                % Stamp the diode as a resistor connected from node2 to node1.
                % A(obj.node2, obj.node2) = A(obj.node2, obj.node2) + g_d;
                % A(obj.node1, obj.node1) = A(obj.node1, obj.node1) + g_d;
                % A(obj.node2, obj.node1) = A(obj.node2, obj.node1) - g_d;
                % A(obj.node1, obj.node2) = A(obj.node1, obj.node2) - g_d;
            end
        end
    end
end
