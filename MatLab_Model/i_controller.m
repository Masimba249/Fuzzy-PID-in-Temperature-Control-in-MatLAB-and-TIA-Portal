%% Grain Storage - PURE INTEGRAL (I-only) Controller 
% Setpoint: 0 → 15 °C | Shows elimination of steady-state error + natural oscillation
clear; clc; close all;

%% 1. Plant Model (same realistic model as before)
tau_hours = 206.16;                  % hours
tau_sec   = tau_hours * 3600;

% Optional: slight resonance for more realistic fluctuation (comment out for pure 1st-order)
wn    = 1/(tau_sec/6);               
zeta  = 0.15;
Gp1   = tf(1, [tau_sec 1]);                                      % Dominant lag
Gp_res = tf(0.25*[wn^2], [1 2*zeta*wn wn^2]);                     % Small resonance
Gp    = Gp1 + Gp_res;       % ←← Comment this line and uncomment next for pure 1st-order
% Gp = tf(1, [tau_sec 1]);                                        % Pure 1st-order (no ringing)

%% 2. Pure Integral Controller
Ki = 0.0008;        % Integral gain — YOU WILL TUNE THIS!
% Small Ki → slow but stable, Large Ki → fast but heavy oscillation
C_I = tf(Ki, [1 0]);           % Pure integrator:  Ki / s

%% 3. Closed-Loop System (unity feedback)
T_cl = feedback(C_I * Gp, 1);

%% 4. Step Response (0 → 15 °C)
T_setpoint = 15;
t_final_days = 40;
t_final_sec  = t_final_days * 86400;
t = 0:60:t_final_sec;                 % 1-min steps
[y_norm, t_step] = step(T_cl, t);
y_real = T_setpoint * y_norm;         % Actual temperature
t_days = t_step / 86400;

%% 5. Performance Metrics
y_ss = y_real(end);
ess  = abs(T_setpoint - y_ss);        % Should be ~0 (numerically ≤ 1e-6)

% Oscillations detection
[peaks,   locs_peak]   = findpeaks(y_real);
[troughs, locs_trough] = findpeaks(-y_real);
troughs = -troughs;

% Approximate period of oscillation (if exists)
if numel(locs_peak) >= 2
    period_days = mean(diff(t_days(locs_peak)));
else
    period_days = NaN;
end

% Settling time (±2% of setpoint)
band = 0.02 * T_setpoint;
idx_out = find(abs(y_real - T_setpoint) > band);
if isempty(idx_out)
    t_settle_days = 0;
else
    t_settle_days = t_days(idx_out(end));
end

%% 6. Beautiful Plot
figure('Color','w','Position',[100 100 1200 700]);
plot(t_days, y_real, 'Color',[0.85 0.33 0.10], 'LineWidth', 3.2);
hold on;
plot([0 40], [T_setpoint T_setpoint], 'k--', 'LineWidth', 2);

% ±2% band
lower = T_setpoint*(1-0.02); upper = T_setpoint*(1+0.02);
fill([0 40 40 0], [lower lower upper upper], [0.9 1 0.9], ...
     'FaceAlpha',0.25, 'EdgeColor','none', 'HandleVisibility','off');

% Mark peaks and troughs
plot(t_days(locs_peak),   peaks,   'rv', 'MarkerFaceColor','r', 'MarkerSize',8);
plot(t_days(locs_trough), troughs, 'r^', 'MarkerFaceColor','m', 'MarkerSize',8);

xlabel('Time [days]', 'FontSize',14);
ylabel('Grain Temperature [°C]', 'FontSize',14);
title(sprintf('Pure Integral (I-only) Controller | K_i = %.6f', Ki), ...
      'FontSize',16,'FontWeight','bold');
grid on; box on;
xlim([0 35]);
ylim([0 20]);

legend({'Temperature Response', 'Setpoint 15 °C'}, 'Location','southeast','FontSize',12);

text(12, 5, sprintf('Steady-state error = %.2e °C\n', ess), ...
     'BackgroundColor','w','EdgeColor','k','FontSize',12,'FontWeight','bold');

text(2, 18, {sprintf('K_i = %.6f', Ki), ...
             sprintf('Settling time (\\pm2%%) ≈ %.1f days', t_settle_days), ...
             sprintf('Oscillation period ≈ %.1f days', period_days), ...
             'Zero steady-state error!'}, ...
     'BackgroundColor','w','EdgeColor','k','FontSize',12,'HorizontalAlignment','left');

%% 7. Command Window Summary
fprintf('\n=== Pure Integral Controller Summary ===\n');
fprintf('Integral gain Ki = %.8f\n', Ki);
fprintf('Final temperature = %.6f °C  →  Steady-state error = %.2e °C\n', y_ss, ess);
fprintf('Settling time (±2%%) ≈ %.2f days\n', t_settle_days);
if ~isnan(period_days)
    fprintf('Dominant oscillation period ≈ %.2f days\n', period_days);
end
fprintf('Note: Pure I control always eliminates steady-state error\n');
fprintf('      but introduces oscillation and slow response.\n');
fprintf('      Combine with Proportional → PI controller for best results!\n');
fprintf('========================================\n\n');

% Bonus: Try these Ki values and watch the behavior change
disp('Try these Ki values:');
disp('Ki = 0.0003 → very slow, almost no oscillation');
disp('Ki = 0.0008 → moderate oscillation (shown above)');
disp('Ki = 0.0020 → aggressive, heavy ringing');
disp('Ki = 0.0050 → unstable (diverges)');