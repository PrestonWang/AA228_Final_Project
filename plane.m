% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% Plane class: represents plane in 2D grid-world and allows it to move in
% heading based on waypoint. 

classdef plane < handle
    %2D kinematic plane model
    %   4 states: (x,y,theta,m) where m is equal to fuel remaining
    %   Properties: fuel_rate, initcon,
    
    properties
        v = 1; % miles/min
        initcon; % initial conditions [x0; y0; theta0; m0]
        fuel_rate = 5000/60 % lbs/min
        state; % [x;y;theta;m]
        state_past; % matrix of previous states
    end
    
    methods
        function obj = plane(initcon)
            %Construct a plane object with initial conditions
            obj.initcon = initcon;
            obj.state = initcon;
            obj.state_past = initcon;
        end
        
        function theta = calcHeading(obj,target)
            %calcHeading calculates the new theta based on the target
            %waypoint location
            theta = atan2(target(2)-obj.state(2), target(1)-obj.state(1));
        end
        function [new_state] = calcState(obj,t,target)
            %calcState returns the new states based on the new target
            %location and a timestep of t. 
            theta = obj.calcHeading(target);
            new_state = [obj.state(1)+cos(theta)*obj.v*t; obj.state(2)+sin(theta)*obj.v*t; theta; obj.state(4) - obj.fuel_rate*t];
            obj.state = new_state;
            obj.state_past = [obj.state_past, new_state];
        end
    end
end

