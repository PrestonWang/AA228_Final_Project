% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% main_simulate - scores a given policy by simulating the MDP.
% Initializes a gridWorld with a plane, storm, and airport location,
% then calculates the reward one timestep at a time while simulating the
% MDP.
% Created: 11/14/2019, CS
% Updated: 11/14/2019, CS

clear
%% Parameters
% Storm Parameters
stormX  = 25; % storm position (x)
stormY  = 25; % storm position (y)
stormS  = 10; % storm standard deviation (mi)
stormU  = 1; % storm speed (mi/min)
stormT  = [0.25 .25 .25 .25]; % transition probabilities (on circle)
% Plane Parameters
fuel_rate = 5000/60;
planeX = 100;
planeY = 100;
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
costWeights = [1 1];
%endState Threshold
threshold = 10e-2;
%% Initialization
plane1 = plane([planeX,planeY,0,100000],1,5000/60, [wayptX, wayptY]);
storm1 = storm(stormX, stormY, stormS, stormU, stormT);
g = gridWorld(N, X, Y, wayptX, wayptY, airportX, airportY, plane1, storm1, costWeights);
load policies/policy2.mat;

%% Simulate
num_states = 4;
num_actions = 2;
total_states = g.N^num_states; % total number of states 
total_actions = g.N^num_actions; % total number of actions
state_dim = [g.N, g.N, g.N, g.N];
action_dim = [g.N, g.N];
reward = 0;
while sqrt((g.plane.state(1)-g.airport(1))^2 + (g.plane.state(2)-g.airport(2))^2) > threshold
    % get closest neighbor
    [px, py] = closestNeighbor(g.plane.state(1), g.plane.state(2), 10);
    [sx, sy] = closestNeighbor(g.storm.state(1), g.storm.state(2), 10);
    % execute the policy of the closest grid point to the plane and storm
    % location
    action = policy(px+1, py+1, sx+1, sy+1);
    [waypt_ix, waypt_iy] = ind2sub(action_dim,action);
    wayptX = g.X(waypt_ix);
    wayptY = g.X(waypt_iy);
    target = [wayptX, wayptY];
    g.updatePos(1, target);
    % Use the line integral to compute the cost accumulated during a single
    % time step
    penalty = g.cost();
    reward = reward - penalty;
    printVec = ['waypoint: ', num2str(wayptX), ', ', num2str(wayptY), ...
        ' plane Location: ', num2str(g.plane.state(1)), ', ', num2str(g.plane.state(2)), ...
        ' storm Location: ', num2str(g.storm.state(1)), ', ', num2str(g.storm.state(2)), ...
        ' total reward: ', num2str(reward)];
    disp(printVec)
end
reward = reward + endStateReward;
printVec = ['waypoint: ', num2str(wayptX), ', ', num2str(wayptY), ...
        ' plane Location: ', num2str(g.plane.state(1)), ', ', num2str(g.plane.state(2)), ...
        ' storm Location: ', num2str(g.storm.state(1)), ', ', num2str(g.storm.state(2)), ...
        ' total reward: ', num2str(reward)];
    disp(printVec)
figure(1)
hold on
plot(plane1.state_past(:,1),plane1.state_past(:,2),'-rx')
plot(storm1.state_past(:,2),storm1.state_past(:,2),'-o')

% Helper function to get closest grid point
function [px, py] = closestNeighbor(x, y, stepSize)
x1 = fix(x/stepSize);
x2 = x1 + 1;
y1 = fix(y/stepSize);
y2 = y1 + 1;
neighborList = [x1, x1, x2, x2; y1, y2, y1, y2];
dist = zeros(4,1);
for i = 1:4
    dist(i) = sqrt((x-neighborList(1,i)*stepSize)^2 + (y-neighborList(2,i)*stepSize)^2);
end
[minDist, index] = min(dist);
px = neighborList(1,index);
py = neighborList(2,index);
end
