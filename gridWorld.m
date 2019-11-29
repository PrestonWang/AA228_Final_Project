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
        meshX; % x-output of meshgrid(X, Y)
        meshY; % y-output of meshgrid(X, Y)
        waypt; % location of waypoint (x,y)
        airport; % location of airport (x,y)
        N; % dimension of (square) gridWorld
        plane; % plane object
        storm; % storm object
        costWeights; % 2-element vector of cost weights for distance and storm
        radius = .5; % radius from airport
        airport_reward = 1000; % reward for reaching the airport
        airport_reward_plus = 100; % additional reward for having the waypoint at the airport. 
        penalty = 100; % penalty for waypoint being at the same location as the plane
    end
    
    methods
        % Initialization function (constructs gridWorld object)
        function world = gridWorld(N, X, Y, wayptX, wayptY, ...
                airportX, airportY, plane, storm, costWeights)
            % Validate arguments
            if length(X) ~= N || length(Y) ~= N
                error('X and Y must be vectors of length N!');
            end
            if wayptX > max(X) || wayptX < min(X) ...
                    || wayptY > max(Y) || wayptY < min(Y) ...
                    || airportX > max(X) || airportX < min(X) ...
                    || airportY > max(Y) || airportY < min(Y) ...
                    || plane.state(1) > max(X) || plane.state(1) < min(X) ...
                    || plane.state(2) > max(Y) || plane.state(2) < min(Y) ...
                    || storm.state(1) > max(X) || storm.state(1) < min(X) ...
                    || storm.state(2) > max(Y) || storm.state(2) < min(Y)
                error('Coordinates are outside range of X and Y!');
            end
            % world.gridState = zeros(N);
            world.N = N;
            world.X = X;
            world.Y = Y;
            [world.meshX, world.meshY] = meshgrid(X, Y);
            world.waypt = [wayptX, wayptY];
            world.airport = [airportX, airportY];
            world.plane = plane;
            world.storm = storm;
            world.costWeights = costWeights;
        end
        
        % Cost function
        % Can be called using world.cost(world) [use stored parameters]
        % or world.cost(planeX, planeY, etc.) [use arguments as parameters]
        function totalCost = cost(world, planeX, planeY, stormX, stormY, ...
                sigma, wayptX, wayptY, airportX, airportY)
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
            % Compute Euclidean distance
            if norm([planeX-airportX, planeY-airportY]) <= world.radius
                totalCost =  world.airport_reward; % High reward for reaching the airport
                if wayptX==airportX && wayptY==airportY
                    totalCost = totalCost + world.airport_reward_plus;
                end
            else
                totalDist = sqrt((planeX-wayptX)^2 + (planeY-wayptY)^2) ...
                    + sqrt((wayptX-airportX)^2 + (wayptY-airportY)^2);
                if norm([wayptX-planeX, wayptY-planeY]) == 0
                    totalDist = totalDist + world.penalty;
                end
                % Compute storm cost: 2 line integrals
                if world.costWeights(2) == 0
                    totalCost = totalDist*world.costWeights(1);
                else
                stormCosts = exp(-((world.meshX-stormX).^2 ...
                    + (world.meshY-stormY).^2)./(2*sigma^2));
                % Source: https://www.mathworks.com/matlabcentral/answers/298011-line-integral-over-a-scalar-field
                t = linspace(0,1,world.N*4)'; % number of points = world.N * 4
                seg1 = (1-t)*[planeX, planeY] + t*[wayptX, wayptY];
                zseg1 = interp2(world.meshX, world.meshY, stormCosts, ...
                    seg1(:,1), seg1(:,2));
                stormCost1 = trapz(cumsum([0;sqrt(sum(diff(seg1).^2,2))]), zseg1);
                seg2 = (1-t)*[wayptX, wayptY] + t*[airportX, airportY];
                zseg2 = interp2(world.meshX, world.meshY, stormCosts, ...
                    seg2(:,1), seg2(:,2));
                stormCost2 = trapz(cumsum([0;sqrt(sum(diff(seg2).^2,2))]), zseg2);

                % Compute total cost
                totalCost = -world.costWeights(1)*totalDist ...
                    - world.costWeights(2)*(stormCost1+stormCost2);
                end
            end
        end
        
        %{
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
        %}
        
        % Update positions of plane and storm
        function updatePos(world, timestep, target)
            oldState = world.plane.state;
            % If target is on airport and airplane can reach it within the
            % timestep, then send the thing home!
            if sqrt((oldState(2)-world.airport(2))^2 ...
                +(oldState(1)-world.airport(1))^2) < timestep*world.plane.v ...
                && target(1) == world.airport(1) && target(2) == world.airport(2)
                newState = world.plane.goToState(timestep, target);
            else
                % Otherwise, compute new state
                newState = world.plane.calcState(timestep, target);
            end
            % Validation (should never happen if plane.v*timestep < dx)
            % if newState(1) > max(world.X) || newState(1) < min(world.X) ...
            %         || newState(2) > max(world.Y) || newState(2) < min(world.Y)
            %     error('Plane is out of range!');
            % end
            % Move storm and keep it within the bounds of the grid
            stormState = world.storm.move(timestep);
            %{
            attempts = 0;
            while stormState(1) > max(world.X) || stormState(1) < min(world.X) ...
                    || stormState(2) > max(world.Y) || stormState(2) < min(world.Y)
                stormState = world.storm.move(timestep);
                attempts = attempts + 1;
                if attempts > 100
                    error('Storm is stuck :(');
                end
            end
            %}
        end
    end
end
