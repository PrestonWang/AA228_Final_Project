% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% main_simulate - scores a given policy by simulating the MDP.
% Initializes a gridWorld with a plane, storm, and airport location,
% then calculates the reward one timestep at a time while simulating the
% MDP.
% Created: 11/14/2019, CS
% Updated: 11/28/2019, NW

clear
load policies/policy-1-3.mat;
%% Parameters
% Experiment parameters
timeStep = 5; % time between updates (min)
% Storm Parameters
stormX  = 90; % storm position (x)
stormY  = 50; % storm position (y)
stormS  = 10; % storm standard deviation (mi)
stormU  = 0.75; % storm speed (mi/min)
nStormPts = 360;
stormT  = ones(1,nStormPts)/nStormPts; % transition probabilities (on circle)
%stormT = [0.25 0.25 0.25 0.05 0.05 0.05 0.05 0.05];
% Plane Parameters
fuel_rate = 5000/60;
planeX = 100;
planeY = 50;
planeTheta = 0;
planeM = 100000;
planeV = 1;
% Gridworld Parameters
N = 11;
X = 0:10:100;
Y = 0:10:100;
airportX = 50;
airportY = 50;
wayptX = 50;
wayptY = 50;
costWeights = [1 2*exp(0.5)];
%endState Threshold
% threshold = 1;

%% Initialization
plane1 = plane([planeX;planeY;planeTheta;planeM],planeV,fuel_rate, [wayptX; wayptY]);
storm1 = storm(stormX, stormY, stormS, stormU, stormT);
g = gridWorld(N, X, Y, wayptX, wayptY, airportX, airportY, plane1, storm1, costWeights);

%% Simulate
num_states = 4;
num_actions = 2;
total_states = g.N^num_states; % total number of states
total_actions = g.N^num_actions; % total number of actions
state_dim = [g.N, g.N, g.N, g.N];
action_dim = [g.N, g.N];
reward = 0;
isHome = 0;
totalDist = 0;
while ~isHome
    lastState = g.plane.state;
    % get closest neighbor
    [px, py] = closestNeighbor(g.plane.state(1), g.plane.state(2), ...
        mean(diff(X)), [min(X) max(X)], [min(Y) max(Y)]);
    [sx, sy] = closestNeighbor(g.storm.state(1), g.storm.state(2), ...
        mean(diff(Y)), [min(X) max(X)], [min(Y) max(Y)]);
    % execute the policy of the closest grid point to the plane and storm
    % location
    action = policy(px+1, py+1, sx+1, sy+1);
    [waypt_ix, waypt_iy] = ind2sub(action_dim,action);
    wayptX = g.X(waypt_ix);
    wayptY = g.X(waypt_iy);
    target = [wayptX; wayptY];
    g.updatePos(timeStep, target);
    % Use the line integral to compute the cost accumulated during a single
    % time step
    penalty = g.cost();
    reward = reward + penalty;
    printVec = ['waypoint: ', num2str(wayptX), ', ', num2str(wayptY), ...
        ' plane Location: ', num2str(g.plane.state(1)), ', ', num2str(g.plane.state(2)), ...
        ' storm Location: ', num2str(g.storm.state(1)), ', ', num2str(g.storm.state(2)), ...
        ' total reward: ', num2str(reward)];
    disp(printVec)
    % Check to see if airplane has arrived at the airport
    if sqrt((g.plane.state(1)-g.airport(1))^2 + (g.plane.state(2)-g.airport(2))^2) == 0
        isHome = 1;
    end
    % Compute added distance
    totalDist = totalDist + sqrt((g.plane.state(2)-lastState(2))^2 ...
        +(g.plane.state(1)-lastState(1))^2);
end
reward = reward;
printVec = ['waypoint: ', num2str(wayptX), ', ', num2str(wayptY), ...
    ' plane Location: ', num2str(g.plane.state(1)), ', ', num2str(g.plane.state(2)), ...
    ' storm Location: ', num2str(g.storm.state(1)), ', ', num2str(g.storm.state(2)), ...
    ' total reward: ', num2str(reward)];
disp(printVec)

%% Plotting plane position
animate