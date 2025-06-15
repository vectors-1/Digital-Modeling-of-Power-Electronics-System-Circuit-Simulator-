function [tf,yf,tedf,yedf] = model_on4(Vgg,Lg,Ls,Lp,Ld,Rg,Rpac,Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_Cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m,Vin,tend)
% y1=Id y2=Vds y3=Ig y4=Vgs y5=Ia y6=Vak 
% 

opts1 = odeset('RelTol',1e-5,'AbsTol',1e-5,'events',@(t,y)onEvent(t,y,IL/n));
[t1,y1] = ode15s(@(t,y)fun(t,y,Vgg,Lg,Ls,Lp+Ld,Rg,Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_Cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m),[0 tend],Vin,opts1);
            

ted1=t1(end);
yed1=y1(end,:);



 tend2=tend-ted1;

if (tend2 > 0) 

opts2 = odeset('RelTol',1e-6,'AbsTol',1e-6);

[t2,y2] = ode15s(@(t,y)fun(t,y,Vgg,Lg,Ls,Lp+Ld,Rg,Rpac+Rpdc,Rb,Cgs,f_Cgd,f_Cds,f_Cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m),[0 tend2],yed1,opts2);
     

 tp2=t2(2:end,:);
 yp2=y2(2:end,:);
  
 tf=[t1;tp2+ted1];
 yf=[y1;yp2];
 tedf=tp2(end);
 yedf=yp2(end,:);
else
    
 tf=t1;
 yf=y1;
 tedf=ted1;
 yedf=yed1;
    
end



VLds= diff(yf(:,1).*(Ls+Ld))./ diff(tf);
Von=yf(:,1).*Rb;
Vdsext=yf(:,2)+[0;VLds]+Von;

yf(:,2)=Vdsext;

end
