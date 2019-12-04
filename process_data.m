%load experiments/Experiment1_20191203_MDP_N10000_dt5mins % MDP dataset for storm with uniform transition
%load experiments/Experiment1_20191203_AStar_N10000_dt5mins % AStar dataset for storm with uniform transition
%load experiments/Experiment2_20191203_MDP_N10000_dt5mins % MDP dataset for storm headed in random direction
%load experiments/Experiment2_20191203_AStar_N10000_dt5mins % AStar dataset for storm headed in random direction
%load experiments/Experiment3_20191203_MDP_N10000_dt5mins % MDP dataset for double storm cost
load experiments/Experiment3_20191203_AStar_N10000_dt5mins % AStar dataset for double storm cost
numExp = size(percentDelay);
stats = {};
significantDelay = [];
count = 1;
for i = 1:numExp
    if percentDelay(i) >= 0.05
        stats(count) = data(i);
        significantDelay(count) = 100*percentDelay(i);
        count = count + 1;
    end
end
hist(significantDelay,24)
avg = mean(significantDelay);
hold on
line([avg, avg], [0, 700],'Color','red','LineStyle','--','LineWidth',2)
avglabel = sprintf('average = %.2f%%', avg);
legend(line([avg, avg], [0, 1200],'Color','red','LineStyle','--','LineWidth',2),avglabel)
%title('MDP Delay Statistics with Uniform Storm Transition Probabilities')
%title('A* Delay Statistics with Uniform Storm Transition Probabilities')
%title('MDP Delay Statistics with a Storm Moving in a Single Random Direction')
%title('A* Delay Statistics with a Storm Moving in a Single Random Direction')
%title('MDP Delay Statistics with Doubling Storm Cost')
title('A* Delay Statistics with Doubling Storm Cost')
xlabel('Percent Increase in Flight Path Length')
ylabel('Frequency')