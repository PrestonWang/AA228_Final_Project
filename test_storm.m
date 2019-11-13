% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% Test script for weather class
% Created: 11/12/2019, NW
% Updated: 11/12/2019, NW

% Set up parameters
stormX  = 0; % storm position (x)
stormY  = 0; % storm position (y)
stormS  = 10; % storm standard deviation (mi)
stormU  = 1; % storm speed (mi/min)
stormT  = [0.2 0.4 0.3 0.1]; % transition probabilities (on circle)
steps   = 100; % number of simulation steps
dt      = 1; % simulation time-step (min)

stormObj = storm(stormX, stormY, stormS, stormU, stormT); % create object
xHistory = zeros(steps, 1);
yHistory = zeros(steps, 1);

% Run simulation
for ii = 1 : steps
    % Get current storm location
    xHistory(ii) = stormObj.X;
    yHistory(ii) = stormObj.Y;
    % Move storm
    stormObj = move(stormObj, 1);
end

% Plot results
figure();
plot(xHistory, yHistory, 'b');
hold on;
plot(xHistory(1), yHistory(1), 'rp');
axis equal;
grid on;
xlabel('x');
ylabel('y');