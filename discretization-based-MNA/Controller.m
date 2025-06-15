%% Controller.m
classdef Controller < handle
    properties
        probe1
        T_control
        lastUpdateTime
        %gateassign = {}

        setpoint        % Desired (reference) measurement
        %feedback        % Mearsured Feedback
        Kp              % Proportional gain
        Ki              % Integral gain
        integralError   % Accumulated integral error
        phaseShift       % Current duty cycle (0 to 1)
        % T_control       % Control sample period (sec)
        % lastUpdateTime  % Last time the controller updated duty cycle
    end
    methods
        function obj = Controller(probe1, T_control)
            obj.probe1 = probe1;
            obj.T_control = T_control;
            obj.lastUpdateTime = 0;
            %obj.gateassign = []
        end
        % function obj = Controller(setpoint, Kp, Ki, T_control, initPS)
        %     if nargin < 5
        %         initPS = 0;
        %     end
        %     obj.setpoint = setpoint;
        %     obj.Kp = Kp;
        %     obj.Ki = Ki;
        %     obj.integralError = 0;
        %     obj.phaseShift = initPS;
        %     obj.T_control = T_control;
        %     obj.lastUpdateTime = 0;
        % end
        
        function call_controller(obj, circuit, tk, yk)
            dt = tk - obj.lastUpdateTime;
            if dt >= obj.T_control
                % for i = 1:length(obj.gateassign)
                %     obj.gateassign(i);
                %     if isa(comp, 'switch')
                
                obj.lastUpdateTime = tk;
            end

        end
        
        % function update(obj, t, measuredValue)
        %     % Update the PI controller if at least T_control seconds have elapsed.
        %     dt = t - obj.lastUpdateTime;
        %     if dt >= obj.T_control
        %         errorVal = obj.setpoint - measuredValue;
        %         obj.integralError = obj.integralError + errorVal * dt;
        %         % Update duty cycle using PI law (additive update)
        %         newPhase = obj.phaseShift + obj.Kp * errorVal + obj.Ki * obj.integralError;
        %         % Clamp duty cycle between 0 and 1.
        %         obj.phaseShift = min(max(newPhase, 0.01), 0.5);
        %         obj.lastUpdateTime = t;
        %     end
        % end
        
        % function gate = generateGateSignal(obj, t, T_pwm)
        %     % Generate a triangular carrier wave with period T_pwm normalized to [0,1]
        %     carrier = 1 - abs(mod(t, T_pwm)/(T_pwm/2) - 1);
        %     % Compare the duty cycle (updated by the PI controller) to the carrier.
        %     if carrier < obj.phaseShift
        %         gate = 1;
        %     else
        %         gate = 0;
        %     end
        % end
%%%     % watch for the two functions
        % function gate = generatePWM(obj, t, T_pwm)
        %     % Generate a triangular carrier wave with period T_pwm and normalized to [0,1].
        %     % For the secondary bridge, the carrier is shifted by the current phase shift.
        %     carrier = 1 - abs(mod(t - obj.phaseShift, T_pwm)/(T_pwm/2) - 1);
        %     % For simplicity we use a fixed threshold (e.g. 0.5). If carrier < 0.5, the switch is ON.
        %     if carrier < 0.5
        %         gate = 1;
        %     else
        %         gate = 0;
        %     end
        % end
    end
end
