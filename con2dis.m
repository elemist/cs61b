function [Am, Bm, Bdm, Cm, Dm, Ddm] = con2dis(A_c, B_c, Bd_c, C_c, D_c, Dd_c)
% clear;
Ts = 0.0125;

[Am, Bm, Cm, Dm] = c2dm(A_c, B_c, C_c, D_c, Ts, 'zoh');
[Adm, Bdm, Cdm, Ddm] = c2dm(A_c, Bd_c, C_c, Dd_c, Ts,'zoh');
end