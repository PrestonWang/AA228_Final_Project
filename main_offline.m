% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% main_offline - solves the optimal policy for all plane and storm
% combinations. Assumes that plane and storms have to be on the grid.
% save policy and parameters as .mat file
%   saves policy, stormS, stormT, N, airportX, airportY, costWeights,
%   discount, epsilon
%% Parameters
% file name
filename = 'policy3.mat';

% Storm Parameters
stormX  = 0; % storm position (x)
stormY  = 0; % storm position (y)
stormS  = 10; % storm standard deviation (mi)
stormU  = 1; % storm speed (mi/min)
stormT  = [0.2 0.4 0.3 0.1]; % transition probabilities (on circle)
% Plane Parameters
fuel_rate = 5000/60;
planeX = 100;
planeY = 100;
planeTheta = 0;
planeM = 100000;
planeV = 1;
% Gridworld Parmaeters
N = 11;
X = 0:10:100;
Y = 0:10:100;
airportX = 50;
airportY = 50;
wayptX = 50;
wayptY = 50;
costWeights = [1 exp(0.5)];

% value iteration parameters
discount = 0.95;
epsilon = .01;
max_iter = 1000;
endStateReward = 1000; % Reward for reaching the airport

%% Initialize Gridworld
tic;
h = waitbar(0,'Initializing parameters...','Name','Running offline solver');
plane1 = plane([planeX,planeY,planeTheta,planeM],planeV,fuel_rate,[wayptX,wayptY]);
storm1 = storm(stormX, stormY, stormS, stormU, stormT);
g = gridWorld(N, X, Y, wayptX, wayptY, airportX, airportY, plane1, storm1, costWeights);

%% Value Iteration
% calculating reward function
num_states = 4;
num_actions = 2;
total_states = g.N^num_states; % total number of states
total_actions = g.N^num_actions; % total number of actions
state_dim = [g.N, g.N, g.N, g.N];
action_dim = [g.N, g.N];
R = zeros(total_states,total_actions, 'single');
for s = 1:total_states
    if mod(s,10) == 0
        waitbar(s/total_states,h,sprintf(...
            'Computing reward function...\n Remaining time: %ds',...
            fix(toc*(total_states-s)/s)));
    end
    for a = 1:total_actions
        [px, py, sx, sy] = ind2sub(state_dim,s);
        [wx, wy] = ind2sub(action_dim,a);
        R(s,a) = g.cost(X(px),Y(py),X(sx),Y(sy),X(wx),Y(wy),stormS,airportX,airportY); % costs are negative rewards
    end
end
% setting up MDP
V0 = zeros(size(R,1),1, 'single');

% solving MDP
waitbar(1,h,'Solving MDP...');
[policy_vec, iter, cpu_time] = mdp_value_iteration(R, discount, epsilon, max_iter, V0);

% converting policy to matrix form
policy = zeros(state_dim, 'int8');
for p = 1:total_states
    policy(ind2sub(state_dim,p)) = policy_vec(p);
end

% saving
save(filename,'policy','N','airportX', 'airportY','costWeights','discount','epsilon', 'stormS','stormT');
close(h);
fprintf('Offline solver completed in %.2f minutes!\n', toc/60);