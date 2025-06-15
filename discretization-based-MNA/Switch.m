% PowerSwitch.m
classdef Switch < Component
    properties
        R_on  % Resistance when "on" (Ohms)
        %R_off % Resistance when "off" (Ohms)
        state % 'on'(1) or 'off'(0)
    end
    methods
        function obj = Switch(n1, n2, R_on, state)
            obj.node1 = n1;
            obj.node2 = n2;
            obj.R_on = R_on;
            %obj.R_off = R_off;
            if nargin < 4
                obj.state = 0;
            else
                obj.state = state;
            end
        end
        
        function setState(obj, newState)
            obj.state = newState;
        end
        
        function [A, b] = stampDC(obj, A, b, numNodes)
            if obj.state == 1
                g = 1/obj.R_on;
            else
                g = 1e-9;
            end
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
            [A, b] = obj.stampDC(A, b, numNodes);
        end
    end
end
