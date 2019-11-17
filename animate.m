figure(1)
clf
hold on
waypoints = zeros(total_actions,2);
for w = 1:total_actions
    [wx, wy] = ind2sub(action_dim,w);
    waypoints(w,:) = [X(wx) Y(wy)];
end
plot(waypoints(:,1),waypoints(:,2),'ks','MarkerSize',10)
plot(airportX, airportY, 'h','MarkerSize',20, 'MarkerFaceColor','green')
plot(plane1.state_past(:,1),plane1.state_past(:,2),'-rx')
plot(storm1.state_past(:,2),storm1.state_past(:,2),'-o')