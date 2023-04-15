LineWidth = 1.5;
MarkerSize = 6;
figure
plot(v, sumRate_maxSum, 'k-s', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize)
hold on
plot(v, sumRate_maxMin, 'b-o', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize)
hold on
plot(v, sumRate_maxSum2, 'k--s', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize)
hold on
plot(v, sumRate_maxMin2, 'b--o', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize)
grid on
legend('P_{max}^c = 23 dBm, Algorithm 1', 'P_{max}^c = 23 dBm, Algorithm 2',...
'P_{max}^c = 17 dBm, Algorithm 1', 'P_{max}^c = 17 dBm, Algorithm 2')
xlabel('$v$ (km/h)', 'interpreter','latex')
ylabel('$\sum\limits_m C_m$ (bps/Hz)', 'interpreter','latex')
% saveas(gcf, sprintf('sumRateVsSpeed')); % save current figure to file

figure
plot(v, minRate_maxSum, 'k-s', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize)
hold on
plot(v, minRate_maxMin, 'b-o', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize)
hold on
plot(v, minRate_maxSum2, 'k--s', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize)
hold on
plot(v, minRate_maxMin2, 'b--o', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize)
grid on
legend('P_{max}^c = 23 dBm, Algorithm 1', 'P_{max}^c = 23 dBm, Algorithm 2',...
'P_{max}^c = 17 dBm, Algorithm 1', 'P_{max}^c = 17 dBm, Algorithm 2')
xlabel('$v$ (km/h)', 'interpreter','latex')
ylabel('$\min C_m$ (bps/Hz)', 'interpreter','latex')
% saveas(gcf, 'minRateVsSpeed'); % save current figure to file

% save all data
save('main_rateSpeed_Jan29')

toc