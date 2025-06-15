% ttt = logsout{1}.Values.time;
% yyy = logsout{1}.Values.data;
 ttt = t;
 yyy = (nodeHist(5,:)-nodeHist(8,:))/31.7;

%plot(t, ia);%, 'LineWidth', 2);
plot(ttt,yyy);
xlim([0.35,0.45]);
xlabel('Time (s)');
ylabel('phase current (A)');
title('Transient Analysis');
grid on;

% hold on;
% 
% tmna = t;
% ymna = (nodeHist(5,:)-nodeHist(8,:))/31.7;
% plot(tmna,ymna);
