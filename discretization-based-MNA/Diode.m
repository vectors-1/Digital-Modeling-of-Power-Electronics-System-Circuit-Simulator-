% PowerSwitch.m
classdef Diode < Component 
    properties
        R_on  % Resistance when "on" (Ohms)
        %R_off % Resistance when "off" (Ohms)
        diodeOn % 'on'(1) or 'off'(0)
    end
    methods
        function obj = Diode(n1, n2, R_on, diodeOn)
            obj.node1 = n1;
            obj.node2 = n2;
            obj.R_on = R_on;
            %obj.R_off = R_off;
            if nargin < 4
                obj.diodeOn = 0;
            else
                obj.diodeOn = diodeOn;
            end
        end
        

        
        function [A, b] = stampDC(obj, A, b, numNodes)
            if obj.diodeOn == 1
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
            if obj.diodeOn == 1
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
        
    end
end
