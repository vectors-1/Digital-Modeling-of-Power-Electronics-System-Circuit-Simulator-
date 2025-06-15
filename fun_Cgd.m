function Cgd = fun_Cgd(f_Cgd,Vds,Vdsmax)

if (Vds >= 0) && (Vds <= Vdsmax)
    Cgd=f_Cgd(Vds).*1e-12;
elseif (Vds < 0) 
    Cgd=f_Cgd(0).*1e-12;
else 
    Cgd=f_Cgd(Vdsmax).*1e-12;
end
end

