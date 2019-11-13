% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% main_offline - solves the optimal policy given the plane and storm's
% current position

%% Initialize Gridworld
g.N = 10;
num_states = 4;
num_actions = 2;
total_states = g.N^num_states;
total_actions = g.N^num_actions;
state_dim = [g.N, g.N, g.N, g.N];
action_dim = [g.N, g.N];
sigma = 1;
ax = 5;
ay = 5;
R = zeros(total_states,total_actions);
%T = ones(total_states, total_states, total_actions);
for s = 1:total_states
    for a = 1:total_actions
        [px, py, sx, sy] = ind2sub(state_dim,s);
        [wx, wy] = ind2sub(action_dim,a);
        R(s,a) = dummy_cost(px,py,sx,sy,wx,wy,sigma,ax,ay);
    end
end
        