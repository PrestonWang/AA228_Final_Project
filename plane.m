classdef plane < handle
    %2D kinematic plane model
    %   8 states: (x,y,theta,m xdot, ydot, thetadot, mdot), where m is
    %   equal to fuel remaining
    %   2 controls: u(yaw rate) and v(velocity
    %   Properties: v_max, v_cruise, v_stall, max_yaw, fuel_rate, initcon,
    %   gains
    
    properties
        v = 1; % miles/min
        initcon;
        fuel_rate = 5000/60 % lbs/min
        state;
        state_past;
    end
    
    methods
        function obj = plane(initcon)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.initcon = initcon;
            obj.state = initcon;
            obj.state_past = initcon;
        end
        
        function theta = calcHeading(obj,target)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            theta = atan2(target(2)-obj.state(2), target(1)-obj.state(1));
        end
        function [new_state] = calcState(obj,t,target)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            theta = atan2(target(2)-obj.state(2), target(1)-obj.state(1));
            new_state = [obj.state(1)+cos(theta)*obj.v*t; obj.state(2)+sin(theta)*obj.v*t; theta; obj.state(4) - obj.fuel_rate*t];
            obj.state = new_state;
            obj.state_past = [obj.state_past, new_state];
        end
    end
end

