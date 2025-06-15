%% Component.m
classdef (Abstract) Component
    properties
        node1   % First node (0 means ground)
        node2   % Second node
    end
    methods (Abstract)
        % Stamp for DC analysis.
        % [A, b] = stampDC(obj, A, b, numNodes)
        [A, b] = stampDC(obj, A, b, numNodes);
        
        % Stamp for transient analysis.
        % dt: time step; prevState: vector of previous node voltages;
        % branchCurrents: vector of branch currents from previous step.
        % [A, b] = stampTransient(obj, A, b, dt, prevState, numNodes, branchCurrents)
        [A, b] = stampTransient(obj, A, b, dt, prevState, numNodes, branchCurrents);
    end
end
