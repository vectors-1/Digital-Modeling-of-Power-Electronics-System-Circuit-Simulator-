%% Inductor.m
classdef Inductor < Component
    properties
        L           % Inductance (Henries)
        branchIndex % Index for the extra unknown
    end
    methods
        function obj = Inductor(n1, n2, L, branchIndex)
            obj.node1 = n1;
            obj.node2 = n2;
            obj.L = L;
            obj.branchIndex = branchIndex;
        end
        
        function [A, b] = stampDC(obj, A, b, numNodes)
            % In DC, an ideal inductor acts as a short circuit.
            if obj.node1 > 0
                A(obj.node1, numNodes + obj.branchIndex) = A(obj.node1, numNodes + obj.branchIndex) + 1;
                A(numNodes + obj.branchIndex, obj.node1) = A(numNodes + obj.branchIndex, obj.node1) + 1;
            end
            if obj.node2 > 0
                A(obj.node2, numNodes + obj.branchIndex) = A(obj.node2, numNodes + obj.branchIndex) - 1;
                A(numNodes + obj.branchIndex, obj.node2) = A(numNodes + obj.branchIndex, obj.node2) - 1;
            end
            % The branch equation is V(node1)-V(node2)=0.
        end
        
        function [A, b] = stampTransient(obj, A, b, dt, numNodes, prevState)
            % Backward Euler companion model:
            % Req = L/dt, and V_eq = Req * I_prev (I_prev from previous branch current).
            Req = obj.L / dt;
            Iprev = prevState(numNodes+obj.branchIndex);
            Veq = Req * Iprev;
            if obj.node1 > 0
                A(obj.node1, numNodes + obj.branchIndex) = A(obj.node1, numNodes + obj.branchIndex) + 1;
                A(numNodes + obj.branchIndex, obj.node1) = A(numNodes + obj.branchIndex, obj.node1) + 1;
            end
            if obj.node2 > 0
                A(obj.node2, numNodes + obj.branchIndex) = A(obj.node2, numNodes + obj.branchIndex) - 1;
                A(numNodes + obj.branchIndex, obj.node2) = A(numNodes + obj.branchIndex, obj.node2) - 1;
            end
            % Stamp the branch equation: V(node1)-V(node2)= Req*I - Veq.
            A(numNodes + obj.branchIndex, numNodes + obj.branchIndex) = A(numNodes + obj.branchIndex, numNodes + obj.branchIndex) - Req;
            b(numNodes + obj.branchIndex) = b(numNodes + obj.branchIndex) - Veq;
        end
    end
end
