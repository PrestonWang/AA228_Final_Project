% Colin Shi, Preston Wang, and Nathan Wei
% AA 228 Final Project, Fall 2019
% Simulates the air traffic control problem with the plane following the A*
% planning path to avoid the storm. Also evaluates the performance with the
% cost function.
% Created: 12/1/2019, CS
% Updated: 12/1/2019, CS

airport = imread('IMAGES/airport.png');
airport(airport == 0) = 255;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timeStep = 5; % time between updates (min)
% Storm Parameters
stormX  = 80; % storm position (x)
stormY  = 50; % storm position (y)
stormS  = 10; % storm standard deviation (mi)
stormU  = 0.75; % storm speed (mi/min)
nStormPts = 360;
stormT  = ones(1,nStormPts)/nStormPts; % transition probabilities (on circle)
% stormT = [0.25 0.25 0.25 0.05 0.05 0.05 0.05 0.05];
% Plane Parameters
fuel_rate = 5000/60;
planeX = 100;
planeY = 50;
planeTheta = 0;
planeM = 100000;
planeV = 3;
% Gridworld Parameters
N = 11;
X = 0:10:100;
Y = 0:10:100;
airportX = 50;
airportY = 50;
wayptX = 50;
wayptY = 50;
costWeights = [1 2*exp(0.5)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plane1 = plane([planeX;planeY;planeTheta;planeM],planeV,fuel_rate, [wayptX; wayptY]);
storm1 = storm(stormX, stormY, stormS, stormU, stormT);
g = gridWorld(N, X, Y, wayptX, wayptY, airportX, airportY, plane1, storm1, costWeights);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reward = 0;
isHome = 0;

while ~isHome
    Optimal_path = AStar_calc(g);
    next_action = Optimal_path(1,:);
    prev_pos = g.plane.state(1:2);
    g.updatePos(timeStep, next_action');
    penalty = g.cost(prev_pos(1),prev_pos(2),g.storm.state(1),...
            g.storm.state(2),g.storm.sigma,g.plane.state(1),...
            g.plane.state(2),g.plane.state(1),g.plane.state(2));
    reward = reward + penalty;
    printVec = ['waypoint: ',num2str(next_action(1)),', ', num2str(next_action(2)),...
        ' plane Location: ', num2str(g.plane.state(1)), ', ', num2str(g.plane.state(2)), ...
        ' storm Location: ', num2str(g.storm.state(1)), ', ', num2str(g.storm.state(2)), ...
        ' total reward: ', num2str(reward)];
    disp(printVec)
    
%     clf
%     image('CData',airport,'XData',[world.airport(1)+5 world.airport(1)-5],'YData',[world.airport(2)+5 world.airport(2)-5])
%     hold on
%     plot(waypoints(:,1),waypoints(:,2),'ks','MarkerSize',10)
%     p=plot(world.plane.state(1),world.plane.state(2),'r^','MarkerSize',10,'MarkerFaceColor','r');
%     total_path = [world.plane.state(1), world.plane.state(2); Optimal_path(:,1), Optimal_path(:,2)];
%     plot(world.storm.state(1),world.storm.state(2), 'bo', 'MarkerSize', 45);
%         plot(total_path(:,1),total_path(:,2),'LineWidth',2);
%     waypoints = zeros(121,2);
%     for w = 1:121
%         [wx, wy] = ind2sub([11,11],w);
%         waypoints(w,:) = [X(wx) Y(wy)];
%     end
%     axis equal;
%     legend('Waypoints','Plane','Storm','Plane Path')
%     xlabel('X(m)');
%     ylabel('Y(m)');
%     axis([-5 105 -5 105]);
%     pause()
    if distance(g.plane.state(1),g.plane.state(2),g.airport(1),g.airport(2)) == 0
        isHome = 1;
    end
end
Optimal_path = AStar_calc(g);
num_states = 4;
num_actions = 2;
total_states = g.N^num_states; % total number of states
total_actions = g.N^num_actions; % total number of actions
state_dim = [g.N, g.N, g.N, g.N];
action_dim = [g.N, g.N];
%Plot the Optimal Path!
% image('CData',airport,'XData',[world.airport(1)+5 world.airport(1)-5],'YData',[world.airport(2)+5 world.airport(2)-5])
% hold on
% p=plot(world.plane.state(1),world.plane.state(2),'rx');
% total_path = [world.plane.state(1), world.plane.state(2); Optimal_path(:,1), Optimal_path(:,2)];
% plot(total_path(:,1),total_path(:,2),'LineWidth',2);
% plot(world.storm.state(1),world.storm.state(2), '-bo', 'MarkerSize', 45);
% waypoints = zeros(121,2);
% for w = 1:121
%     [wx, wy] = ind2sub([11,11],w);
%     waypoints(w,:) = [X(wx) Y(wy)];
% end
% axis equal;
% axis([-5 105 -5 105]);
% plot(waypoints(:,1),waypoints(:,2),'ks','MarkerSize',10)
animate