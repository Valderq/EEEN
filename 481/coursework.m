ht = 10; hu = 6; dx = 80; Gt = 20; Gr = 20;
f = 900e6; c = 3e8; lambda = c / f;
r = sqrt(dx^2 + (ht - hu)^2);
% Converts decibels to power
function pow = db2pow(db)
    pow = 10.^(db / 10);
end
Pt = db2pow([20:60]); % Convert dB to linear scale
gamma_th = 4; % in dB
PL = Gt * Gr * (lambda / (4 * pi * r))^2;
K = 8; % Rician factor in dB
sigma = 1;
mu = sqrt(db2pow(K) / (1 + db2pow(K)));
h = abs(mu + sigma * (randn(1e6, 1) + 1i * randn(1e6, 1)));
SNR = Pt * PL * h.^2 / N0;
h = abs(sigma * (randn(1e6, 1) + 1i * randn(1e6, 1)));
SNR = Pt * PL * h.^2 / N0;
% Ergodic Capacity
C = mean(log2(1 + SNR), 1);

% Outage Probability
P_out = mean(SNR <= db2pow(gamma_th), 1);
figure;
subplot(2, 1, 1);
plot(20:60, C);
title('Ergodic Capacity vs \gamma_t');
xlabel('\gamma_t (dB)'); ylabel('Capacity (bits/s/Hz)');

subplot(2, 1, 2);
plot(20:60, P_out);
title('Outage Probability vs \gamma_t');
xlabel('\gamma_t (dB)'); ylabel('Outage Probability');
