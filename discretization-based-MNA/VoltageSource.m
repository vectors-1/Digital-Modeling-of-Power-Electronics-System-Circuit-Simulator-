% VoltageSource.m
classdef VoltageSource < Component
    properties
        V           % Voltage value (Volts)
        branchIndex % Index for the extra unknown
    end
    methods
        function obj = VoltageSource(n1, n2, V, branchIndex)
            obj.node1 = n1;
            obj.node2 = n2;
            obj.V = V;
            obj.branchIndex = branchIndex;
        end
        
        function [A, b] = stampDC(obj, A, b, numNodes)
            if obj.node1 > 0
                A(obj.node1, numNodes + obj.branchIndex) = A(obj.node1, numNodes + obj.branchIndex) + 1;
                A(numNodes + obj.branchIndex, obj.node1) = A(numNodes + obj.branchIndex, obj.node1) + 1;
            end
            if obj.node2 > 0
                A(obj.node2, numNodes + obj.branchIndex) = A(obj.node2, numNodes + obj.branchIndex) - 1;
                A(numNodes + obj.branchIndex, obj.node2) = A(numNodes + obj.branchIndex, obj.node2) - 1;
            end
            b(numNodes + obj.branchIndex) = obj.V;
        end
        
        function [A, b] = stampTransient(obj, A, b, dt, numNodes, ~)
            % Assume constant voltage source in transient analysis.
            [A, b] = obj.stampDC(A, b, numNodes);
        end
    end
end
