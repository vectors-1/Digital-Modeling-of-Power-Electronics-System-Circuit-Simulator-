function Ich = f_Ich(Kp,Vth,Vgs,Vds)

if (Vgs >= Vth) && (Vgs >= Vds + Vth)

    Ich=Kp*(2*Vds*(Vgs-Vth)-Vds^2);
    
elseif (Vgs >= Vth) && (Vgs < Vds + Vth)
    
    Ich=Kp*(Vgs-Vth)^2;
else 
    
    Ich=0;
end
    
end 

