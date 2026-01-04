%% Grain Storage - Step Response Analysis (0 → 15 °C over 40 days)
% Rise time, Settling time, Steady-state error clearly shown
clear; clc; close all;

%% 1. System Parameters (your real grain storage model)
tau_hours = 206.16;              % hours
tau_sec   = tau_hours * 3600;     % seconds
Gp = tf(1, [tau_sec 1]);          % Gp(s) = 1 / (τs + 1)

%% 2. Step Response Settings
T_initial  = 0;                   % °C
T_setpoint = 15;                  % °C
Delta_T    = T_setpoint - T_initial;

% Simulate up to 40 days
t_final_days = 40;
t_final_sec  = t_final_days * 86400;
t = 0:60:t_final_sec;             % fine resolution (1 minute steps)

[y_norm, t_step] = step(Gp, t);        % normalized step response
y_real = T_initial + Delta_T * y_norm; % actual temperature in °C
t_days = t_step / 86400;

%% 3. Performance Metrics Calculation
final_value = T_setpoint;

% --- Rise time (10% to 90%) ---
T10 = 0.10 * final_value;
T90 = 0.90 * final_value;
idx10 = find(y_real >= T10, 1, 'first');
idx90 = find(y_real >= T90, 1, 'first');
t_rise_days = t_days(idx90) - t_days(idx10);

% --- Settling time (enter and stay within ±2% band) ---
band = 0.02 * final_value;
lower_band = final_value * (1 - 0.02);
upper_band = final_value * (1 + 0.02);

% Find the last time it exits the band
idx_out = find(y_real < lower_band | y_real > upper_band);
if isempty(idx_out)
    t_settle_days = 0;
else
    t_settle_days = t_days(idx_out(end));
end

% For first-order system: theoretical settling time ≈ 4τ
tau_days = tau_sec / 86400;
t_settle_theory = 4 * tau_days;

% --- Steady-state error ---
y_ss = y_real(end);
ess = abs(final_value - y_ss);  % Should be numerically ~0

%% 4. Beautiful Plot
figure('Color','w','Position',[100 100 1100 650]);

plot(t_days, y_real, 'Color', [0, 0.35, 0.8], 'LineWidth', 3); 
hold on;

% Setpoint line
plot([0 40], [T_setpoint T_setpoint], 'k--', 'LineWidth', 1.5, 'HandleVisibility','off');

% ±2% settling band
fill([0 40 40 0], [lower_band lower_band upper_band upper_band], ...
     [0.9 0.95 1], 'FaceAlpha', 0.3, 'EdgeColor','none', 'HandleVisibility','off');
plot([0 40], [lower_band lower_band], 'b:', 'LineWidth', 1.2, 'HandleVisibility','off');
plot([0 40], [upper_band upper_band], 'b:', 'LineWidth', 1.2, 'HandleVisibility','off');

% Rise time marking
plot([t_days(idx10) t_days(idx10)], [0 T10], 'r--', 'LineWidth', 1.8);
plot([t_days(idx90) t_days(idx90)], [0 T90], 'r--', 'LineWidth', 1.8);
plot([t_days(idx10) t_days(idx90)], [T10 T10], 'r--', 'LineWidth', 1.8);
plot(t_days(idx10), T10, 'ro', 'MarkerFaceColor','r', 'MarkerSize',9);
plot(t_days(idx90), T90, 'ro', 'MarkerFaceColor','r', 'MarkerSize',9);

% Settling time arrow
plot([t_settle_days t_settle_days], [0 final_value], 'g--', 'LineWidth', 2);
plot(t_settle_days, final_value*0.95, 'g>', 'MarkerFaceColor','g', 'MarkerSize',12);

xlabel('Time [days]', 'FontSize', 14);
ylabel('Grain Temperature [°C]', 'FontSize', 14);
title('Step Response: 0 °C → 15 °C  |  Grain Storage Silo (\tau = 206.16 hours)', ...
      'FontSize', 16, 'FontWeight','bold');

grid on; box on;

% Legend & annotations
legend({'Temperature Response', ...
        sprintf('Rise time t_r = %.2f days', t_rise_days), ...
        sprintf('Settling time t_s ≈ %.2f days (±2%%)', t_settle_days)}, ...
       'Location','southeast', 'FontSize', 12);

text(15, 8, {sprintf('Rise time (10%%–90%%): %.2f days', t_rise_days), ...
             sprintf('Settling time (±2%%): %.2f days', t_settle_days), ...
             sprintf('Steady-state error: %.2e °C', ess), ...
             sprintf('Time constant τ = %.2f days', tau_days)}, ...
     'BackgroundColor','w', 'EdgeColor','k', 'FontSize', 12, 'FontWeight','bold');

xlim([0 40]);
ylim([-0.5 16]);
set(gca, 'FontSize', 12, 'LineWidth', 1.2);

%% Command Window Summary
fprintf('\n=== Grain Storage Step Response Summary ===\n');
fprintf('Setpoint change: %.1f °C → %.1f °C\n', T_initial, T_setpoint);
fprintf('Time constant τ        = %.3f days\n', tau_days);
fprintf('Rise time (10%%–90%%)   = %.3f days\n', t_rise_days);
fprintf('Settling time (±2%%)    = %.3f days  (actual)\n', t_settle_days);
fprintf('Theoretical t_s (4τ)   = %.3f days\n', 4*tau_days);
fprintf('Steady-state error     = %.2e °C\n', ess);
fprintf('Simulation: 0 to 40 days\n');
fprintf('==========================================\n\n');