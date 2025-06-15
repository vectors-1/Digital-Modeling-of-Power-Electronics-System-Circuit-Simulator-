%% Resistor.m
classdef Resistor < Component
    properties
        R   % Resistance (Ohms)
    end
    methods
        function obj = Resistor(n1, n2, R)
            obj.node1 = n1;
            obj.node2 = n2;
            obj.R = R;
        end
        
        function [A, b] = stampDC(obj, A, b, numNodes)
            g = 1/obj.R;
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
        
        function [A, b] = stampTransient(obj, A, b, dt, numNodes, ~)
            % For resistors, the stamp is identical to DC.
            [A, b] = obj.stampDC(A, b, numNodes);
        end
    end
end
