% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% Initial gridWorld structure
% Created: 11/08/2019, CS
% Updated: 11/08/2019, CS

classdef gridWorld
    properties
        gridState;
        X;
        Y;
        airportX;
        airportY;
    end
    
    methods
        %Initialization function
        function world = gridWorld(initX, initY, Xfinal, Yfinal)
            world.gridState = zeros(100, 100);
            world.X = initX;
            world.Y = initY;
            world.airportX = Xfinal;
            world.airportY = Yfinal;
        end
        
        function updateRewards(obj, storm)
            % Updates the value at each node given storm the current state
            % of the world and a storm object as a 2D Gaussian
        end
        
        % Interpolate the reward at a state given its current position
        function interpval = interpolateVal(obj)
            x1 = fix(obj.X/1);
            x2 = x1 + 1;
            y1 = fix(obj.Y/1);
            y2 = y1 + 1;
            xinterpy1 = (x2-obj.X)/(x2-x1)*obj.gridState(x1, y1) + ...
                (obj.X-x1)/(x2-x1)*obj.gridState(x2, y1);
            xinterpy2 = (x2-obj.X)/(x2-x1)*obj.gridState(x1, y2) + ...
                (obj.X-x1)/(x2-x1)*obj.gridState(x2, y2);
            interpval = (y2-obj.Y)/(y2-y1)*xinterpy1 + (obj.Y-y1)/...
                (y2-y1)*xinterpy2;  
        end
        
        %Check to see if plane is within bounds
        function bool = boundCheck(obj)
            if (obj.X <= 100) && (obj.Y <= 100) && (obj.X >= 0)...
                    && (obj.Y >= 100)
                bool = 1;
            else
                bool = 0;
            end
        end
        
        function updatePos(obj, plane, timestep, target)
            newState = plane.calcState(timestep, target);
            obj.X = newState(1);
            obj.Y = newState(2);
        end
    end
end
