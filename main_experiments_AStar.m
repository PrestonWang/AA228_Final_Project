% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% main_experiments - runs several iterations of the MDP and computes
% average flight delay (percent) while storing each output gridWorld
% object.
% Created: 11/27/2019, NW
% Updated: 11/28/2019, NW
%% Parameters
% Experiment parameters
numIter = 10000; % number of experiments to run
timeStep = 5; % time between updates (min)
runDebug = 0; % 1: plot individual results; 0: don't
saveFile = 1; % 1: save experiment file with the following name; 0: don't
saveName = 'Experiment3_20191203_AStar'; % first part of filename
% Storm Parameters
stormS  = 10; % storm standard deviation (mi)
stormU  = 0.75; % storm speed (mi/min) - supercell around 20 m/s at 6 km (20,000 ft)
nStormPts = 8;
stormT  = ones(1,nStormPts)/nStormPts; % transition probabilities (on circle)
% Plane Parameters
fuel_rate = 5000/60;
planeM = 100000;
planeV = 3;
planeTheta = 0;
% Gridworld Parameters
N = 11;
X = 0:10:100;
Y = 0:10:100;
airportX = 50;
airportY = 50;
wayptX = 50;
wayptY = 50;
costWeights = [1 4*exp(0.5)];
%endState Threshold
% threshold = 10;


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
    %stormT = zeros(1,nStormPts);
    %idx = randi(nStormPts);
    %stormT(idx) = 1;
    storm1 = storm(stormX, stormY, stormS, stormU, stormT);
    world = gridWorld(N, X, Y, wayptX, wayptY, airportX, airportY, plane1, storm1, costWeights);
    
    % MDP parameters
    num_states = 4;
    num_actions = 2;
    total_states = world.N^num_states; % total number of states
    total_actions = world.N^num_actions; % total number of actions
    state_dim = [world.N, world.N, world.N, world.N];
    action_dim = [world.N, world.N];
    
    %% Run Simulation iteration
    reward = 0;
    isHome = 0;
    steps = 0;
    totalDist = 0;
    while ~isHome
        Optimal_path = AStar_calc(world);
        next_action = Optimal_path(1,:);
        prev_pos = world.plane.state(1:2);
        world.updatePos(timeStep, next_action');
        penalty = world.cost(prev_pos(1),prev_pos(2),world.storm.state(1),...
            world.storm.state(2),world.storm.sigma,world.plane.state(1),...
            world.plane.state(2),world.plane.state(1),world.plane.state(2));
        reward = reward + penalty;
        steps = steps + 1;
        totalDist = totalDist + distance(prev_pos(1),prev_pos(2),world.plane.state(1),...
            world.plane.state(2));
        if distance(world.plane.state(1),world.plane.state(2),world.airport(1),world.airport(2)) == 0
            isHome = 1;
        end
    end
    %% Save parameters
    % Save reward, total distance, starting positions of plane and storm,
    % percent time variance, gridWorld object in struct
    minDist = sqrt((planeX-airportX)^2 + (planeY-airportY)^2);
    percentDelay(ii) = (totalDist-minDist)/minDist;
    data{ii} = struct('reward',reward,'totalDist',totalDist,'minDist',minDist,...
        'gridWorld',world,'nSteps',steps,'planeStart',[planeX,planeY],...
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

fprintf('Average delay: %.2f%%\n', mean(percentDelay)*100);

% Save file
if saveFile
    saveName = sprintf('%s_N%d_dt%dmins.mat', saveName, numIter, timeStep);
    save(fullfile('experiments', saveName), 'data', 'percentDelay');
    fprintf('File saved as %s\n', saveName);
end

% Bootstrapping analysis
sampleStdv = std(bootstrp(numIter*10, @mean, percentDelay));
fprintf('Standard deviation after %d iterations: +/- %.2f%%\n', ...
    numIter, sampleStdv*100);
fprintf('Standard deviation as percent of mean: %.2f%%\n', ...
    100*sampleStdv/mean(percentDelay));