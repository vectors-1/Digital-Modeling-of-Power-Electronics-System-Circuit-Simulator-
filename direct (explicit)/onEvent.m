function [value,isterminal,direction] = onEvent(t,y,IL)

% y1=Id y2=Vds y3=Ig y4=Vgs y5=Ia y6=Vak

value = y(1)-IL;
isterminal= 1;
direction = 0;