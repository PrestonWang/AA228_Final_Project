% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% Initial gridWorld structure
% Dependencies: plane.m, storm.m
% Created: 11/08/2019, CS
% Updated: 11/13/2019, NW

classdef gridWorld
    properties
        gridState; % N x N matrix for grid state
        X; % vector of length N with physical values for grid x-dimension
        Y; % vector of length N with physical values for grid y-dimension
        waypt; % location of waypoint (x,y)
        airport; % location of airport (x,y)
        N; % dimension of (square) gridWorld
        plane; % plane object
        storm; % storm object
    end
    
    methods
        % Initialization function (constructs gridWorld object)
        function world = gridWorld(N, X, Y, wayptX, wayptY, ...
                airportX, airportY, plane, storm)
            if length(X) ~= N || length(Y) ~= N
                error('X and Y must be vectors of length N!');
            end
            world.gridState = zeros(N);
            world.N = N;
            world.X = X;
            world.Y = Y;
            world.waypt = [wayptX, wayptY];
            world.airport = [airportX, airportY];
            world.plane = plane;
            world.storm = storm;
        end
        
        % Cost function
        function cost(world, planeX, planeY, stormX, stormY, sigma, ...
                wayptX, wayptY, airportX, airportY)
            % Allow cost function to be called with or without state vars
            if nargin == 1
                planeX = world.plane.state(1);
                planeY = world.plane.state(2);
                stormX = world.storm.state(1);
                stormY = world.storm.state(2);
                sigma = world.storm.sigma;
                wayptX = world.waypt(1);
                wayptY = world.waypt(2);
                airportX = world.airport(1);
                airportY = world.airport(2);
            end
            % Compute cost
            % - Euclidean distance
            % - Line integral over path through storm
            % - Need weighting coefficients
        end
        
        % Interpolate the reward at a state given its current position
        function interpval = interpolateVal(x, y)
            x1 = fix(x/1);
            x2 = x1 + 1;
            y1 = fix(y/1);
            y2 = y1 + 1;
            xinterpy1 = (x2-x)/(x2-x1)*obj.gridState(x1, y1) + ...
                (x-x1)/(x2-x1)*obj.gridState(x2, y1);
            xinterpy2 = (x2-x)/(x2-x1)*obj.gridState(x1, y2) + ...
                (x-x1)/(x2-x1)*obj.gridState(x2, y2);
            interpval = (y2-y)/(y2-y1)*xinterpy1 + (y-y1)/...
                (y2-y1)*xinterpy2;  
        end
        
        %Check to see if plane is within bounds
        % REPLACE WITH VALIDATION FUNCTION FOR PLANE AND STORM COORDS
        function bool = boundCheck(obj)
            if (obj.X <= 100) && (obj.Y <= 100) && (obj.X >= 0)...
                    && (obj.Y >= 100)
                bool = 1;
            else
                bool = 0;
            end
        end
        
        % Update positions of plane and storm
        function updatePos(obj, plane, timestep, target)
            newState = plane.calcState(timestep, target);
            obj.X = newState(1);
            obj.Y = newState(2);
        end
    end
end
