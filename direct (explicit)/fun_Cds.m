function Cds = fun_Cds(f_Cds,Vds,Vdsmax)

if (Vds >= 0) && (Vds <= Vdsmax)
    Cds=f_Cds(Vds).*1e-12;
elseif (Vds < 0) 
    Cds=f_Cds(0).*1e-12;
else 
    Cds=f_Cds(Vdsmax).*1e-12;
end
end

