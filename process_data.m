% load experiments/Experiment1_20191203_MDP_N10000_dt5mins % MDP dataset for storm with uniform transition
% load experiments/Experiment1_20191203_AStar_N10000_dt5mins % AStar dataset for storm with uniform transition
% load experiments/Experiment2_20191203_MDP_N10000_dt5mins % MDP dataset for storm headed in random direction
% load experiments/Experiment2_20191203_AStar_N10000_dt5mins % AStar dataset for storm headed in random direction
% load experiments/Experiment3_20191203_MDP_N10000_dt5mins % MDP dataset for double storm cost
% load experiments/Experiment3_20191203_AStar_N10000_dt5mins % AStar dataset for double storm cost
% titleString = 'MDP Delay Statistics with Uniform Storm Transition Probabilities';
% titleString = 'A* Delay Statistics with Uniform Storm Transition Probabilities';
% titleString = 'MDP Delay Statistics with a Storm Moving in a Single Random Direction';
% titleString = 'A* Delay Statistics with a Storm Moving in a Single Random Direction';
titleString = 'MDP Delay Statistics with Doubling Storm Cost';
% titleString = 'A* Delay Statistics with Doubling Storm Cost';
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
histogram(significantDelay, 'Normalization', 'probability', 'BinWidth', 5)
avg = mean(significantDelay);
hold on
% line([avg, avg], [0, 1],'Color','red','LineStyle','--','LineWidth',2)
avglabel = sprintf('Average = %.2f', avg);
legend(line([avg, avg], [0, 1],'Color','red','LineStyle','--','LineWidth',2),...
    [avglabel,'\%'],'interpreter','latex')
title(titleString);
xlabel('Percent Increase in Flight Time')
ylabel('Fraction of Delayed Flights')
xlim([5, 70]);
ylim([0, 0.5]);
fprintf('N_D / N = %.2f%%\n', 100*(count-1)/numExp(1));