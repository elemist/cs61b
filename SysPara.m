function [A,B,C,D,M,L]= SysPara
clear
clc
% Ts =0.0125;
    Ts = 0.01;
load('D:\Wind Turbine\MPC\Reduced4to3_2DOF_18.mat');

[Am, Bm, Bdm, Cm, Dm, Ddm] = con2dis(A_c, B_c, Bd_c, C_c, D_c, Dd_c);
%***************************
% %define disturbance
% %zd(k+1)= F*zd(k)+B*nd(k); random walk
% %ud(k)= theta*zd(k);
% F = 1; B = 1; theta = 1; ;

% state [x(k); zd(k)]

%******************************

[NBm,MBm] = size(Bm);
A = [Am Bdm; zeros(1,size(Am,2)) 1];
B = [Bm; 0];
G = [zeros(NBm,MBm);1];
C = [Cm, [0;0]];
D = [0;0];
H = [0;0];
sys = ss(A,[B G],C,[D H],Ts);

rnk = rank(obsv(A,C), 0); % rank with tol = 0
if rnk == size(A,1)
disp(' (A, C) observable');
else
disp([' (A, C) unobservable, rank = ', num2str(rnk), ' < ',num2str(size(Abar,1))]);
error(' Cannot continue!');
end

%Kalman gain
Qn = [1e-6];
Rn = [1e-4 0; 0 1e-4];
Nn = [0, 0];
[KEST,L,P,M,Z] = kalman(sys,Qn,Rn,Nn);