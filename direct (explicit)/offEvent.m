function [value,isterminal,direction] = offEvent(t,y,Rb,Vdc)

% y1=Id y2=Vds y3=Ig y4=Vgs y5=Ia y6=Vak 
value = y(2)+y(1)*Rb-Vdc;
isterminal= 1;
direction = 0;