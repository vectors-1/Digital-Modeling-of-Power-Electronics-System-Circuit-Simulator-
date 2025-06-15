function Cd2 = fun_Cd(f_Cd,Vd2,Vdmax)

if (Vd2 >= 0) && (Vd2 <= Vdmax)
    Cd2=f_Cd(Vd2).*1e-12;
elseif (Vd2 < 0)
    Cd2=f_Cd(0).*1e-12;
else
    Cd2=f_Cd(Vdmax).*1e-12;
end

end

