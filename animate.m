airport = imread('IMAGES/airport.png');
airport(airport == 0) = 255;
%% Static Plot
figure(1)
clf
hold on;
waypoints = zeros(total_actions,2);
for w = 1:total_actions
    [wx, wy] = ind2sub(action_dim,w);
    waypoints(w,:) = [X(wx) Y(wy)];
end
image('CData',airport,'XData',[g.airport(1)+5 g.airport(1)-5],'YData',[g.airport(2)+5 g.airport(2)-5])
plot(waypoints(:,1),waypoints(:,2),'ks','MarkerSize',10);
plot(plane1.state_past(1,1), plane1.state_past(2,1),'rp', 'MarkerSize',15, 'MarkerFaceColor','red')
plot(plane1.state_past(1,:),plane1.state_past(2,:),'-rx')
plot(storm1.state_past(1,1),storm1.state_past(2,1),'bp','MarkerSize',15, 'MarkerFaceColor','blue')
plot(storm1.state_past(1,:),storm1.state_past(2,:),'-bo')
xlabel('X (miles)');
ylabel('Y (miles)');
legend('Waypoints','Plane, $t=0$','Plane Path','Storm, $t=0$','Storm Path');
axis equal;
axis([-5 105 -5 105]);

%% Animation
figure(2)
clf
hold on
image('CData',airport,'XData',[g.airport(1)+5 g.airport(1)-5],'YData',[g.airport(2)+5 g.airport(2)-5])
plot(waypoints(:,1),waypoints(:,2),'ks','MarkerSize',10)
plot(plane1.state_past(1,1), plane1.state_past(2,1),'rp', 'MarkerSize',15, 'MarkerFaceColor','red')
plane2 = plot(plane1.state_past(1,1),plane1.state_past(2,1),'-rx');
plot(storm1.state_past(1,1),storm1.state_past(2,1),'bp','MarkerSize',15, 'MarkerFaceColor','blue')
storm2 = plot(storm1.state_past(1,1),storm1.state_past(2,1),'bo', 'MarkerSize', 45);
da = plane1.target_past(1:2,1) - plane1.state_past(1:2,1);
arrow2 = quiver(plane1.state_past(1,1),plane1.state_past(2,1), da(1), da(2),0,'m','LineWidth',1.5);
legend('Waypoints','Plane, $t=0$','Plane Path','Storm, $t=0$','Storm Path','Target Waypoint');
xlabel('X (miles)');
ylabel('Y (miles)');
axis equal;
axis([-5 105 -5 105]);
num_iter = size(plane1.state_past(1,:),2);
Frames(num_iter) = struct('cdata',[],'colormap',[]);
for i = 1:num_iter
    da = plane1.target_past(1:2,i) - plane1.state_past(1:2,i);
    plane2.XData = [plane2.XData, plane1.state_past(1,i)];
    plane2.YData = [plane2.YData, plane1.state_past(2,i)];
    storm2.XData = storm1.state_past(1,i);
    storm2.YData = storm1.state_past(2,i);
    arrow2.XData = plane1.state_past(1,i);
    arrow2.YData = plane1.state_past(2,i);
    arrow2.UData = da(1);
    arrow2.VData = da(2);
    drawnow
    Frames(i) = getframe(figure(2));
    pause()
end

