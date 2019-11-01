% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% Weather class: represents storm in 2D grid-world and allows it to move
% Created: 11/01/2019, NW
% Updated: 11/01/2019, NW

classdef storm
    % Storm model
    %   8 states: (x,y,theta,m xdot, ydot, thetadot, mdot), where m is
    %   equal to fuel remaining
    %   2 controls: u(yaw rate) and v(velocity
    %   Properties: v_max, v_cruise, v_stall, max_yaw, fuel_rate, initcon,
    %   gains
    
    properties
        v_max = 12; % miles/min
        v_cruise = 8; % miles/min
        v_stall = 2.4; % miles/min
        max_yaw = pi/min; % rad/min
        initcon = [100;100;0;90000];
        fuel_rate = 5000*60 % lbs/min
        gains = struct('ki',1,'kp',1,'kw',1,'kc',1,'kf', 0.01);
        state = initcon
    end
    
    methods
        function next_waypoint
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

