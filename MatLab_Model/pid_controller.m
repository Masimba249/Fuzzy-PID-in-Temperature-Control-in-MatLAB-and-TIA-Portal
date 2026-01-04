%% Grain Storage - FULL PID Controller (0 to 15 °C)
% Y-axis up to 32 °C - perfect for aggressive tuning
clear; clc; close all;

%% 1. Realistic plant model (grain silo)
tau_hours = 206.16;
tau_sec   = tau_hours * 3600;
wn    = 1/(tau_sec/6);
zeta  = 0.15;
Gp = tf(1, [tau_sec 1]) + tf(0.25*[wn^2], [1 2*zeta*wn wn^2]);

%% 2. PID gains - you can make them much larger now
Kp = 15;          % Proportional
Ki = 0.0015;      % Integral
Kd = 150000;      % Derivative

% THIS LINE IS 100 % CLEAN - no hidden characters
C_PID = tf([Kd Kp Ki], [1 0]);   % Kd*s + Kp + Ki/s

%% 3. Closed-loop system
T_cl = feedback(C_PID * Gp, 1);

%% 4. Step response (setpoint step 0 to 15 °C)
T_setpoint = 15;
t_final_sec = 40*86400;
t = 0:60:t_final_sec;                 % 1-minute resolution
[y, t_step] = step(T_cl, t);

y_real = T_setpoint * y;
t_days = t_step / 86400;

%% 5. Performance metrics
idx10 = find(y_real >= 0.1*T_setpoint, 1, 'first');
idx90 = find(y_real >= 0.9*T_setpoint, 1, 'first');
rise_time_days = t_days(idx90) - t_days(idx10);

peak_temp = max(y_real);
overshoot_percent = 100*(peak_temp - T_setpoint)/T_setpoint;

% Settling time (±2 % of setpoint)
band = 0.02*T_setpoint;
idx_out = find(abs(y_real - T_setpoint) > band);

% --- FIXED SECTION START ---
if isempty(idx_out)
    settle_time_days = 0;
else
    settle_time_days = t_days(idx_out(end));
end
% --- FIXED SECTION END ---

ess = abs(y_real(end) - T_setpoint);

%% 6. Plot - Y-axis safely up to 32 °C
figure('Color','w','Position',[100 100 1150 700]);
plot(t_days, y_real, 'Color',[0.85 0.33 0.10], 'LineWidth', 3.5); hold on;
plot([0 40], [15 15], 'k--', 'LineWidth', 2.5);

% ±2 % band
fill([0 40 40 0], [15*0.98 15*0.98 15*1.02 15*1.02], ...
     [0.9 0.95 1], 'FaceAlpha',0.25, 'EdgeColor','none');

% Rise-time markers
if ~isempty(idx10) && ~isempty(idx90)
    plot([t_days(idx10) t_days(idx10)], [0 1.5],  'r--','LineWidth',2);
    plot([t_days(idx90) t_days(idx90)], [0 13.5], 'r--','LineWidth',2);
    plot(t_days(idx10), 1.5,  'ro','MarkerFaceColor','r','MarkerSize',10);
    plot(t_days(idx90), 13.5, 'ro','MarkerFaceColor','r','MarkerSize',10);
end

% Settling arrow
plot([settle_time_days settle_time_days], [0 15], 'g--','LineWidth',3);
plot(settle_time_days, 14, 'g>','MarkerFaceColor','g','MarkerSize',14);

xlabel('Time [days]','FontSize',14);
ylabel('Grain Temperature [°C]','FontSize',14);
title(sprintf('PID Controller | Kp = %.1f   Ki = %.4f   Kd = %g', Kp, Ki, Kd), ...
      'FontSize',16,'FontWeight','bold');
grid on; box on;

xlim([0 35]);
ylim([-1 32]);                     % Y-axis now goes to 32 °C
set(gca,'YTick',0:5:35,'FontSize',12);
legend({'Temperature response','Setpoint 15 °C'},'Location','southeast','FontSize',12);

text(16, 8, {sprintf('Rise time = %.2f days',rise_time_days), ...
             sprintf('Overshoot = %.2f %%',overshoot_percent), ...
             sprintf('Max temp = %.2f °C',peak_temp), ...
             sprintf('Settling time ≈ %.2f days',settle_time_days), ...
             sprintf('Steady-state error = %.1e °C',ess)}, ...
     'BackgroundColor','w','EdgeColor','k','FontSize',12,'FontWeight','bold');

%% 7. Summary
fprintf('\n=== PID Controller Performance ===\n');
fprintf('Kp = %.2f    Ki = %.6f    Kd = %g\n', Kp, Ki, Kd);
fprintf('Max temperature   = %.3f °C\n', peak_temp);
fprintf('Overshoot         = %.2f %%\n', overshoot_percent);
fprintf('Rise time (10-90) = %.2f days\n', rise_time_days);
fprintf('Settling time     = %.2f days\n', settle_time_days);
fprintf('Steady-state error = %.1e °C\n', ess);
fprintf('Y-axis scaled to 32 °C - feel free to push gains higher!\n\n');