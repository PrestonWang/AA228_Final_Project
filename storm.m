% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% Weather class: represents storm in 2D grid-world and allows it to move
% Created: 11/01/2019, NW
% Updated: 11/12/2019, NW

classdef storm
    % Storm model
    %   States: x and y position, standard deviation (sigma)
    %   Transition probabilities for an array of angles
    % Initialize method
    % Move method
    % Cost function goes in gridWorld.m
    %   Given three points (x0,y0,x1,y1,x2,y2), airplane velocity, and
    %   storm location, compute line integral cost
    
    % Experiments:
    % - Start storm at different starting positions
    % - Storms moving at same speed with different transition probs.
    % - Storms moving at random speeds with same transition probs.
    %   = This should show that our model isn't dependent on storm speed
    
    properties
        X; % grid position of storm (x)
        Y; % grid position of storm (y) [storm can wander off grid]
        sigma; % standard deviation of Gaussian
        speed; % speed of storm, in miles per minute
        transProbs; % directional transition probabilities on the circle
        transAngles; % vector of angles corresponding to transProbs on [0, 2*pi)
    end
    
    methods
        % Constructor for an instance of the storm class
        function obj = storm(x, y, sigma, speed, transProbs)
            obj.X = x;
            obj.Y = y;
            obj.sigma = sigma;
            obj.speed = speed;
            obj.transProbs = transProbs;
            obj.transAngles = linspace(0, 2*pi, length(transProbs)+1);
            obj.transAngles = obj.transAngles(1:end-1); % not including 2*pi
        end
        
        % Move storm according to speed and transition probabilities
        function this = move(this, dt)
            % Move storm then update newX and newY and X and Y in storm obj
            theta = randsrc(1, 1, [this.transAngles; this.transProbs]);
            r = this.speed*dt; % dt in mins, speed in miles / min
            this.X = r*cos(theta);
            this.Y = r*sin(theta);
        end
        
    end
end

