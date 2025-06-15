% 假设 signal, Fs 已定义
%signal = U_output(:,2);
%signal = U_p2;
%signal = (nodeHist(5,:)-nodeHist(8,:))/31.7;
%signal = logsout{1}.Values.data;
%signal = ia;
signal = voltage;
Fs = 1e7;
N    = length(signal);
%w    = hann(N)';                   % 窗口（可选）
%Y    = fft(signal .* w);
Y    = fft(signal);
P2   = abs(Y) / N;
P1   = P2(1:floor(N/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f    = Fs * (0:floor(N/2)) / N;

% 基频与谐波设置
f0    = 50;    % 基频 (Hz)
nharm = 20;     % 计算到第 5 次谐波

% 基频幅值
[~, idx0] = min(abs(f - f0));
A0 = P1(idx0);

% 谐波幅值平方累加
Ah_sq = 0;
for k = 2:nharm
    fk = k * f0;
    [~, idxk] = min(abs(f - fk));
    Ah_sq = Ah_sq + P1(idxk)^2;
end

% 计算 THD
THD = sqrt(Ah_sq) / A0;
fprintf('基频幅值 A0 = %.4f\n', A0);
fprintf('THD = %.4f (%.2f%%)\n', THD, THD*100);

figure;
plot(f, P1);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Single-Sided Amplitude Spectrum');
grid on;