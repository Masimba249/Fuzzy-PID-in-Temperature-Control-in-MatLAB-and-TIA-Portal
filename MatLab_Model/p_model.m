%% Grain Storage - P Controller Step Response (0 → 15 °C Setpoint over 40 days)
% Proportional (P) Controller: Adds gain to speed up response, with possible fluctuation & steady-state error
% Rise time, Settling time, Overshoot, Steady-state error shown
clear; clc; close all;

%% 1. System Parameters (Enhanced model with slight oscillation for realism)
tau_hours = 206.16;              % Dominant time constant (hours)
tau_sec   = tau_hours * 3600;     % in seconds

% Lightly damped second-order mode for realistic fluctuation/overshoot
wn = 1/(tau_sec/6);               % Natural frequency ~6x faster than main tau
zeta = 0.15;                      % Damping ratio → visible ringing

% Plant model: dominant 1st-order + weak resonant mode
Gp_dominant = tf(1, [tau_sec 1]);                             % Main thermal lag
Gp_resonant = tf(0.25*[wn^2], [1 2*zeta*wn wn^2]);             % Small resonant mode
Gp = Gp_dominant + Gp_resonant;                                % Combined plant

%% 2. P Controller Design
Kp = 10;                          % Proportional gain (tune higher for less error, but more oscillation)
C = tf(Kp, 1);                    % P controller: C(s) = Kp

%% 3. Closed-Loop System
closed_loop = feedback(C * Gp, 1);  % Unity feedback: T(s) = C*Gp / (1 + C*Gp)

%% 4. Step Response Settings (Setpoint change: 0 → 15 °C)
T_initial = 0;                    % Initial temperature °C
T_setpoint = 15;                  % Setpoint °C
Delta_T = T_setpoint - T_initial;

% Simulate up to 40 days
t_final_days = 40;
t_final_sec = t_final_days * 86400;
t = 0:60:t_final_sec;             % 1-minute resolution
[y_norm, t_step] = step(closed_loop, t);  % Normalized response (to unit step)
y_real = T_initial + Delta_T * y_norm;    % Scaled to actual setpoint
t_days = t_step / 86400;

%% 5. Performance Metrics Calculation
final_value = T_setpoint;

% --- Rise time (10% to 90% of setpoint) ---
T10 = T_initial + 0.10 * Delta_T;
T90 = T_initial + 0.90 * Delta_T;
idx10 = find(y_real >= T10, 1, 'first');
idx90 = find(y_real >= T90, 1, 'first');
t_rise_days = t_days(idx90) - t_days(idx10);

% --- Overshoot ---
peak_value = max(y_real);
overshoot_percent = 100 * (peak_value - T_setpoint) / T_setpoint;

% --- Settling time (enter and stay within ±2% band around setpoint) ---
band = 0.02 * T_setpoint;
lower_band = T_setpoint - band;
upper_band = T_setpoint + band;
idx_out = find(y_real < lower_band | y_real > upper_band);
if isempty(idx_out)
    t_settle_days = 0;
else
    t_settle_days = t_days(idx_out(end));
end

% --- Steady-state error ---
y_ss = y_real(end);
ess = abs(T_setpoint - y_ss);  % For P controller, ess = Delta_T / (1 + Kp * dcgain(Gp)) ≈ 15 / (1 + Kp)

%% 6. Beautiful Plot
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
plot([t_settle_days t_settle_days], [0 T_setpoint], 'g--', 'LineWidth', 2);
plot(t_settle_days, T_setpoint*0.95, 'g>', 'MarkerFaceColor','g', 'MarkerSize',12);

xlabel('Time [days]', 'FontSize', 14);
ylabel('Grain Temperature [°C]', 'FontSize', 14);
title(sprintf('P Controller Step Response: 0 → 15 °C | K_p = %.1f | Grain Storage Silo', Kp), ...
      'FontSize', 16, 'FontWeight','bold');
grid on; box on;

% Legend & annotations
legend({'Temperature Response', ...
        sprintf('Rise time t_r = %.2f days', t_rise_days), ...
        sprintf('Settling time t_s ≈ %.2f days (±2%%)', t_settle_days)}, ...
       'Location','southeast', 'FontSize', 12);

text(15, 8, {sprintf('Rise time (10%%–90%%): %.2f days', t_rise_days), ...
             sprintf('Overshoot: %.2f %%', overshoot_percent), ...
             sprintf('Settling time (±2%%): %.2f days', t_settle_days), ...
             sprintf('Steady-state error: %.2f °C', ess), ...
             sprintf('Time constant τ ≈ %.2f days', tau_hours/24)}, ...
     'BackgroundColor','w', 'EdgeColor','k', 'FontSize', 12, 'FontWeight','bold');

xlim([0 40]);
ylim([-0.5 18]);
set(gca, 'FontSize', 12, 'LineWidth', 1.2);

%% 7. Command Window Summary
fprintf('\n=== Grain Storage P Controller Step Response Summary ===\n');
fprintf('Setpoint change: %.1f °C → %.1f °C\n', T_initial, T_setpoint);
fprintf('Proportional gain K_p = %.1f\n', Kp);
fprintf('Time constant τ = %.3f days\n', tau_hours/24);
fprintf('Rise time (10%%–90%%) = %.3f days\n', t_rise_days);
fprintf('Overshoot = %.2f %%\n', overshoot_percent);
fprintf('Settling time (±2%%) = %.3f days\n', t_settle_days);
fprintf('Steady-state error = %.3f °C\n', ess);
fprintf('Simulation: 0 to 40 days\n');
fprintf('Note: P controller has inherent steady-state error; use PI for zero error.\n');
fprintf('==================================================\n\n');