function dydt = fun(t,y,Vgg,Lg,Ls,Lp,Rg,Rp,Rb,Cgs,f_Cgd,f_Cds,f_Cd,Kp,Vth,Vfto,Rd2,Vdc,IL,Vdsmax,Vdmax,n,m)
dydt = zeros(6,1);
% y1=Id y2=Vds y3=Ig y4=Vgs y5=Ia y6=Vd2
Cgd=fun_Cgd(f_Cgd,y(2),Vdsmax);
Cds=fun_Cds(f_Cds,y(2),Vdsmax);
Cd2=fun_Cd(f_Cd,y(6),Vdmax);


Ich=f_Ich(Kp,Vth,y(4),y(2));
If=f_If(y(6),Vfto,Rd2);





dydt(1)=-(Ls*Vgg - Ls*Vdc - Lg*Vdc + Lg*y(2) + Lg*y(6) + Ls*y(2) - Ls*y(4) + Ls*y(6) + Lg*Rb*y(1) + Ls*Rb*y(1) - Ls*Rg*y(3) + Lg*Rp*n*y(1) + Ls*Rp*n*y(1))/(Lg*Ls + Lg*Lp*n + Lp*Ls*n);
dydt(2)=(Cgd*y(1) + Cgd*y(3) + Cgs*y(1) - Cgd*Ich - Cgs*Ich)/(Cds*Cgd + Cds*Cgs + Cgd*Cgs);
dydt(3)=(Ls*Vgg - Ls*Vdc + Ls*y(2) - Ls*y(4) + Ls*y(6) + Lp*Vgg*n + Ls*Rb*y(1) - Ls*Rg*y(3) - Lp*n*y(4) - Lp*Rg*n*y(3) + Ls*Rp*n*y(1))/(Lg*Ls + Lg*Lp*n + Lp*Ls*n);
dydt(4)=(Cds*y(3) + Cgd*y(1) + Cgd*y(3) - Cgd*Ich)/(Cds*Cgd + Cds*Cgs + Cgd*Cgs);
dydt(5)=-dydt(1)*n;
dydt(6)=(If*m - IL + n*y(1))/(Cd2*m);

end