%% Capacitor.m
classdef Capacitor < Component
    properties
        C   % Capacitance (Farads)
    end
    methods
        function obj = Capacitor(n1, n2, C)
            obj.node1 = n1;
            obj.node2 = n2;
            obj.C = C;
        end
        
        function [A, b] = stampDC(obj, A, b, numNodes)
            % In DC, a capacitor is an open circuit.
            % (No stamp is added.)
        end
        
        function [A, b] = stampTransient(obj, A, b, dt, numNodes, prevState)
            % Backward Euler companion model:
            % G = C/dt and I_eq = G*(V_prev(node1)-V_prev(node2))
            G = obj.C / dt;
            Vprev1 = 0; Vprev2 = 0;
            if obj.node1 > 0, Vprev1 = prevState(obj.node1); end
            if obj.node2 > 0, Vprev2 = prevState(obj.node2); end
            Ieq = G * (Vprev1 - Vprev2);
            
            if obj.node1 > 0
                A(obj.node1, obj.node1) = A(obj.node1, obj.node1) + G;
                b(obj.node1) = b(obj.node1) + Ieq;
            end
            if obj.node2 > 0
                A(obj.node2, obj.node2) = A(obj.node2, obj.node2) + G;
                b(obj.node2) = b(obj.node2) - Ieq;
            end
            if obj.node1 > 0 && obj.node2 > 0
                A(obj.node1, obj.node2) = A(obj.node1, obj.node2) - G;
                A(obj.node2, obj.node1) = A(obj.node2, obj.node1) - G;
            end
        end
    end
end
