function [policy, iter, cpu_time] = mdp_value_iteration(R, discount, epsilon, max_iter, V0)
% Arguments --------------------------------------------------------------
% Let S = number of states, A = number of actions
%   R(SxSxA) or (SxA) = reward matrix
%              R could be an array with 3 dimensions (SxSxA) or 
%              a cell array (1xA), each cell containing a sparse matrix (SxS) or
%              a 2D array(SxA) possibly sparse  
%   discount  = discount rate in ]0; 1]
%               beware to check conditions of convergence for discount = 1.
%   epsilon   = epsilon-optimal policy search, upper than 0,
%               optional (default : 0.01)
%   max_iter  = maximum number of iteration to be done, upper than 0, 
%               optional (default : computed)
%   V0(S)     = starting value function, optional (default : zeros(S,1))
% Evaluation -------------------------------------------------------------
%   policy(S) = epsilon-optimal policy
%   iter      = number of done iterations
%   cpu_time  = used CPU time
cpu_time = cputime;
% computation of threshold of variation for V for an epsilon-optimal policy
if discount ~= 1
    thresh = epsilon * (1-discount)/discount;
else 
    thresh = epsilon;
end
iter = 0;
V = V0;
is_done = false;
while ~is_done
    iter = iter + 1;
    Vprev = V;

    [V, policy] = mdp_bellman_operator(R,discount,V);

    variation = mdp_span(V - Vprev);
    if variation < thresh 
        is_done = true;
        disp('MDP Toolbox: iterations stopped, epsilon-optimal policy found')
    elseif iter == max_iter
        is_done = true; 
        disp('MDP Toolbox: iterations stopped by maximum number of iteration condition')
    end
end
cpu_time = cputime - cpu_time;
end

