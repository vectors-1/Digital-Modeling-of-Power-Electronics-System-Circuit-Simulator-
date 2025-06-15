%% MOSFETSwitch.m
classdef MOSFETSwitch < Switch
    properties
        gate  % Logical gate signal: 0 (off) or 1 (on)
    end
    methods
        function obj = MOSFETSwitch(n1, n2, R_on, R_off, initialGate)
            % Call parent constructor
            obj@Switch(n1, n2, R_on, R_off, 'off');
            if nargin < 5
                obj.gate = 0;
            else
                obj.gate = initialGate;
            end
            % Set state based on the initial gate signal.
            if obj.gate == 1
                obj.state = 'on';
            else
                obj.state = 'off';
            end
        end
        
        function setGate(obj, gateSignal)
            % Update the gate signal (0 or 1) from an external controller.
            obj.gate = gateSignal;
            if obj.gate == 1
                obj.state = 'on';
            else
                obj.state = 'off';
            end
        end
        
        function [A, b] = stampDC(obj, A, b, numNodes)
            % Use the gate to choose conduction resistance.
            if obj.gate == 1
                R = obj.R_on;
            else
                R = obj.R_off;
            end
            g = 1/R;
            if obj.node1 > 0
                A(obj.node1, obj.node1) = A(obj.node1, obj.node1) + g;
            end
            if obj.node2 > 0
                A(obj.node2, obj.node2) = A(obj.node2, obj.node2) + g;
            end
            if obj.node1 > 0 && obj.node2 > 0
                A(obj.node1, obj.node2) = A(obj.node1, obj.node2) - g;
                A(obj.node2, obj.node1) = A(obj.node2, obj.node1) - g;
            end
        end
        
        function [A, b] = stampTransient(obj, A, b, dt, prevState, numNodes, branchCurrents)
            % In transient analysis, choose R based on the current gate signal.
            if obj.gate == 1
                R = obj.R_on;
            else
                R = obj.R_off;
            end
            g = 1/R;
            if obj.node1 > 0
                A(obj.node1, obj.node1) = A(obj.node1, obj.node1) + g;
            end
            if obj.node2 > 0
                A(obj.node2, obj.node2) = A(obj.node2, obj.node2) + g;
            end
            if obj.node1 > 0 && obj.node2 > 0
                A(obj.node1, obj.node2) = A(obj.node1, obj.node2) - g;
                A(obj.node2, obj.node1) = A(obj.node2, obj.node1) - g;
            end
        end
    end
end
