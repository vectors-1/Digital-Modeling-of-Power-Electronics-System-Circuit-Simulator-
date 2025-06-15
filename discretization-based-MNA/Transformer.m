% Transformer.m
classdef Transformer < Component
    properties
        % Primary side: node1 and node2 (inherited)
        % Secondary side:
        node3
        node4
        gain        % Transformer's gain (ratio)
        branchIndex % Extra branch variable index
    end
    methods
        function obj = Transformer(np1, np2, ns1, ns2, gain, branchIndex)
            obj.node1 = np1;
            obj.node2 = np2;
            obj.node3 = ns1;
            obj.node4 = ns2;
            obj.gain = gain;
            obj.branchIndex = branchIndex;
        end
        
        function [A, b] = stampDC(obj, A, b, numNodes)
            % Primary side stamping:
            if obj.node1 > 0
                A(obj.node1, numNodes + obj.branchIndex) = A(obj.node1, numNodes + obj.branchIndex) + 1;
                A(numNodes + obj.branchIndex, obj.node1) = A(numNodes + obj.branchIndex, obj.node1) + 1;
            end
            if obj.node2 > 0
                A(obj.node2, numNodes + obj.branchIndex) = A(obj.node2, numNodes + obj.branchIndex) - 1;
                A(numNodes + obj.branchIndex, obj.node2) = A(numNodes + obj.branchIndex, obj.node2) - 1;
            end
            % Secondary side stamping:
            if obj.node3 > 0
                A(obj.node3, numNodes + obj.branchIndex) = A(obj.node3, numNodes + obj.branchIndex) - obj.gain;
                A(numNodes + obj.branchIndex, obj.node3) = A(numNodes + obj.branchIndex, obj.node3) - obj.gain;
            end
            if obj.node4 > 0
                A(obj.node4, numNodes + obj.branchIndex) = A(obj.node4, numNodes + obj.branchIndex) + obj.gain;
                A(numNodes + obj.branchIndex, obj.node4) = A(numNodes + obj.branchIndex, obj.node4) + obj.gain;
            end
            b(numNodes + obj.branchIndex) = 0;
        end
        
        function [A, b] = stampTransient(obj, A, b, dt, numNodes, ~)
            % Assume transformer behavior is time invariant.
            [A, b] = obj.stampDC(A, b, numNodes);
        end
    end
end
