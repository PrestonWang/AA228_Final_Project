% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% main_offline - solves the optimal policy given the plane and storm's
% current position

%% Initialize Gridworld
g = gridWorld();

num_states = 4;
num_actions = 2;
R = zeros(g.N^num_states,g.N^num_actions);
for s = 1:num_states
    for a = 1:num_actions
        
        