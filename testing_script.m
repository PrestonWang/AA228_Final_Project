clear all
plane1 = plane([100;100;0;90000]);
for i = 1:5
    target = randi([-50,50],2,1);
    plane1.calcState(5,target);
end
past = plane1.state_past;
plot(past(1,:),past(2,:),'-x')