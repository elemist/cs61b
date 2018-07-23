function[Alin, Blin, Bdlin, Clin, Dlin, Ddlin] = SymmAsymm(A,B,Bd,C,D,Dd)
Tm = [1/3 1/3 1/3 0 0 0 0;
    2/3 -4/3 2/3 0 0 0 0;
    0 0 0 1 0 0 0;
    0 0 0 0 1/3 1/3 1/3;
    0 0 0 0 2/3 -4/3 2/3];
Tb = [1/3 1/3 1/3;
    2/3 -4/3 2/3];
Tv = [2/3 -4/3 2/3;
    1/3 1/3 1/3];
Ty = [1 0 0 0;
    0 2/3 -4/3 2/3];

Alin = Tm*A*pinv(Tm);
Blin = Tm*B*pinv(Tb);
Bdlin = Tm*Bd*pinv(Tv);
Clin = Ty*C*pinv(Tm);
Dlin = Ty*D*pinv(Tb);
Ddlin = Ty*Dd*pinv(Tv);