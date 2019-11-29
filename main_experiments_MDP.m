% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% main_experiments - runs several iterations of the MDP and computes
% average flight delay (percent) while storing each output gridWorld
% object.
% Created: 11/27/2019, NW
% Updated: 11/28/2019, NW

clear
load policies/policy6.mat;

%% Parameters
% Experiment parameters
numIter = 100; % number of experiments to run
timeStep = 10; % time between updates (min)
runDebug = 0; % 1: plot individual results; 0: don't
saveName = 'Experiments_20191128_MDP_N100_dt10mins.mat';
% Storm Parameters
stormS  = 10; % storm standard deviation (mi)
stormU  = 0.75; % storm speed (mi/min) - supercell around 20 m/s at 6 km (20,000 ft)
nStormPts = 360;
stormT  = ones(1,nStormPts)/nStormPts; % transition probabilities (on circle)
% Plane Parameters
fuel_rate = 5000/60;
planeM = 100000;
planeV = 1;
planeTheta = 0;
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
threshold = 10;

%% Run experiments

% Grid markers for random point selection
boundPts = ones(length(X),length(Y));
boundPts(2:end-1,2:end-1) = 0;
innerPts = ~boundPts;

% Experiment data storage
data = {};
percentDelay = zeros(numIter,1);

for ii = 1 : numIter
    %% Initialize parameters
    % Find random start locations for plane and storm
    randMesh = rand(size(boundPts)); % random values at all points
    [~,pInd] = max(randMesh(:).*boundPts(:)); % largest value on boundary (plane)
    [~,sInd] = max(randMesh(:).*innerPts(:)); % largest value on interior (storm)
    [pX,pY] = ind2sub(size(randMesh), pInd); % corresponding storm indices
    [sX,sY] = ind2sub(size(randMesh), sInd); % corresponding plane indices
    stormX  = X(sX); % storm position (x)
    stormY  = Y(sY); % storm position (y)
    planeX = X(pX); % plane position (x)
    planeY = Y(pY); % plane position (y)
    plane1 = plane([planeX;planeY;planeTheta;planeM],planeV,fuel_rate, [wayptX; wayptY]);
    storm1 = storm(stormX, stormY, stormS, stormU, stormT);
    g = gridWorld(N, X, Y, wayptX, wayptY, airportX, airportY, plane1, storm1, costWeights);
    
    % MDP parameters
    num_states = 4;
    num_actions = 2;
    total_states = g.N^num_states; % total number of states
    total_actions = g.N^num_actions; % total number of actions
    state_dim = [g.N, g.N, g.N, g.N];
    action_dim = [g.N, g.N];
    
    %% Run simulation iteration
    reward = 0;
    steps = 0;
    totalDist = 0;
    isHome = 0;
    % Old condition: sqrt((g.plane.state(1)-g.airport(1))^2 + (g.plane.state(2)-g.airport(2))^2) > threshold
    while ~isHome
        steps = steps + 1;
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
        % Check to see if airplane has passed near enough to airport
        % Initial check based on external threshold (one grid spacing)
        if sqrt((g.plane.state(1)-g.airport(1))^2 + (g.plane.state(2)-g.airport(2))^2) == 0
            isHome = 1;
        end
        % Compute added distance
        totalDist = totalDist + sqrt((g.plane.state(2)-lastState(2))^2 ...
            +(g.plane.state(1)-lastState(1))^2);
    end
    % reward = reward;
    % printVec = ['waypoint: ', num2str(wayptX), ', ', num2str(wayptY), ...
    %         ' plane Location: ', num2str(g.plane.state(1)), ', ', num2str(g.plane.state(2)), ...
    %         ' storm Location: ', num2str(g.storm.state(1)), ', ', num2str(g.storm.state(2)), ...
    %         ' total reward: ', num2str(reward)];
    %     disp(printVec)
    
    %% Save parameters
    % Save reward, total distance, starting positions of plane and storm,
    % percent time variance, gridWorld object in struct
    minDist = sqrt((planeX-airportX)^2 + (planeY-airportY)^2);
    percentDelay(ii) = (totalDist-minDist)/minDist;
    data{ii} = struct('reward',reward,'totalDist',totalDist,'minDist',minDist,...
        'gridWorld',g,'nSteps',steps,'planeStart',[planeX,planeY],...
        'stormStart',[stormX,stormY],'percentDelay',percentDelay(ii));
    
    if runDebug
        figure(1)
        clf
        xlim([-5 105]);
        ylim([-5 105]);
        axis equal;
        hold on
        waypoints = zeros(total_actions,2);
        for w = 1:total_actions
            [wx, wy] = ind2sub(action_dim,w);
            waypoints(w,:) = [X(wx) Y(wy)];
        end
        plot(waypoints(:,1),waypoints(:,2),'ks','MarkerSize',10)
        plot(airportX, airportY, 'h','MarkerSize',20, 'MarkerFaceColor','green')
        plot(plane1.state_past(1,:),plane1.state_past(2,:),'-rx')
        plot(storm1.state_past(1,:),storm1.state_past(2,:),'-bo')
    end
    
end

%% Process results

% Save file
save(fullfile('experiments', saveName), 'data', 'percentDelay');

% Bootstrapping analysis
fprintf('Average delay: %.2f%%\n', mean(percentDelay)*100);

%% Helper function to get closest grid point
function [px, py] = closestNeighbor(x, y, stepSize, xLims, yLims)
x1 = fix(x/stepSize);
x2 = x1 + 1;
y1 = fix(y/stepSize);
y2 = y1 + 1;
% Validation to deal with storm running off the grid
if x >= xLims(2)
    x1 = fix(xLims(2)/stepSize);
    x2 = fix(xLims(2)/stepSize);
elseif x < xLims(1)
    x1 = fix(xLims(1)/stepSize);
    x2 = fix(xLims(1)/stepSize);
end
if y >= yLims(2)
    y1 = fix(yLims(2)/stepSize);
    y2 = fix(yLims(2)/stepSize);
elseif y < yLims(1)
    y1 = fix(yLims(1)/stepSize);
    y2 = fix(yLims(1)/stepSize);
end
neighborList = [x1, x1, x2, x2; y1, y2, y1, y2];
dist = zeros(4,1);
for i = 1:4
    dist(i) = sqrt((x-neighborList(1,i)*stepSize)^2 + (y-neighborList(2,i)*stepSize)^2);
end
[minDist, index] = min(dist);
px = neighborList(1,index);
py = neighborList(2,index);
end