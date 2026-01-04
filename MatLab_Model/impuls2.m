%% IEEE-Quality Impulse Response with Oscillations Reaching Settling Time
clear; clc; close all;

% -------------- Design a VERY lightly damped system --------------
wn   = 25;       % rad/day  → many cycles in a few days
zeta = 0.02;     % extremely low damping → oscillations persist for a long time

sys = tf(wn^2, [1  2*zeta*wn  wn^2]);

% -------------- Simulate long enough so oscillations reach settling time --------------
Tsim_days = 10;                                   % simulate 10 days
t = 0:0.0005:Tsim_days;                           % fine time vector
[y,t] = impulse(sys, t);                          % impulse response

% -------------- Performance metrics (2% criterion) --------------
S = stepinfo(sys,'SettlingTimeThreshold',0.02,'RiseTimeLimits',[0.1,0.9]);

rise_time_days     = S.RiseTime;
settling_time_days = S.SettlingTime;   % this is exactly when |y(t)| first stays < 2% of peak

fprintf('Rise time     = %.4f days\n', rise_time_days);
fprintf('Settling time = %.4f days\n', settling_time_days);

% Find actual peak (first peak)
[ypeak, idx_peak] = max(abs(y));
peak_time = t(idx_peak);

% 2% settling band
settling_band = 0.02 * ypeak;

% -------------- IEEE Publication-Quality Figure --------------
figure('Color','w','Position',[100 100 560 380]);

plot(t, y, 'Color', [0 0.2 0.6], 'LineWidth', 2.2); hold on; grid on;

% ±2% band (light gray background)
fill([t(1) t(end) t(end) t(1)], [settling_band settling_band -settling_band -settling_band], ...
     [0.93 0.93 0.93], 'EdgeColor','none','FaceAlpha',0.7);

plot([t(1) t(end)], [ settling_band  settling_band], 'k--', 'LineWidth',1.1);
plot([t(1) t(end)], [-settling_band -settling_band], 'k--', 'LineWidth',1.1);

% Rise time markers (10%–90% of first peak)
y10 = 0.10 * ypeak;
y90 = 0.90 * ypeak;
t10 = interp1(y(1:idx_peak), t(1:idx_peak), y10, 'linear');
t90 = interp1(y(1:idx_peak), t(1:idx_peak), y90, 'linear');

plot([t10 t10], ylim, 'Color',[0 0.6 0], 'LineStyle','--', 'LineWidth',2);
plot([t90 t90], ylim, 'Color',[0 0.6 0], 'LineStyle','--', 'LineWidth',2);

% Settling time vertical line (red, thick)
plot([settling_time_days settling_time_days], ylim, ...
     'Color',[0.8 0 0], 'LineWidth',2.8);

% Annotations with background for readability
text((t10+t90)/2, 0.85*ypeak, sprintf('Rise time\n%.3f days',rise_time_days), ...
     'HorizontalAlignment','center','FontSize',11,'FontWeight','bold',...
     'BackgroundColor','w','EdgeColor','k','Color',[0 0.5 0]);

text(settling_time_days, -0.9*ypeak, ...
     sprintf('Settling time\n%.3f days',settling_time_days), ...
     'HorizontalAlignment','center','FontSize',11,'FontWeight','bold',...
     'BackgroundColor','w','EdgeColor','k','Color',[0.7 0 0]);

xlabel('Time (days)','Interpreter','latex','FontSize',12);
ylabel('Amplitude','Interpreter','latex','FontSize',12);
title('Impulse Response of the Heating System',...
      'Interpreter','latex','FontSize',13);

set(gca,'FontName','Times','FontSize',11,'Box','on',...
    'TickLabelInterpreter','latex','LineWidth',1.2);

xlim([0 6]);   % zoom to show the important part clearly

% -------------- Export for IEEE papers --------------
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 8.7 6.2]);   % single-column IEEE width

print(gcf, 'Impulse_Response_Oscillations_To_Settling_IEEE','-dpdf','-r600');
print(gcf, 'Impulse_Response_Oscillations_To_Settling_IEEE','-dpng','-r600');

disp('Figure saved as Impulse_Response_Oscillations_To_Settling_IEEE.pdf (IEEE-ready)');