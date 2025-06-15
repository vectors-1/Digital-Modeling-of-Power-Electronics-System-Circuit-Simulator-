function Ifd = f_If(Vd2,Vfto,Rd2)

Vak=-Vd2;

if (Vak>Vfto)
    Ifd=(Vak-Vfto)/Rd2;
else
    Ifd=0;
end
    
end

