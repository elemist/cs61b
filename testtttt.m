Ts = 0.0125;
load('D:\Wind Turbine\Individual\Reduced4to3_2DOF_18.mat');

[Am, Bm, Bdm, Cm, Dm, Ddm] = con2dis(A_c, B_c, Bd_c, C_c, D_c, Dd_c);
%***************************
% %define disturbance
% %zd(k+1) = F*zd(k);
% %ud(k)= theta*zd(k);
% F = 0; B1 = 0; theta = 1; D1 = 0;
% [Fm,B1m,thetam,D1m] = c2dm(F,B1,theta,D1,Ts,'zoh');
% state [x(k); zd(k)]
% A = [Am Bdm*thetam; zeros(1,size(Am,2)) Fm];%%!!!!!!!!!!!!modify a
% little!!!
%******************************
%d(k+1)=d(k)+w(k) w(k) white noise random walk
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

Qn = 10;
Rn = [1 0; 0 0.1];
Nn = [0, 0]; 
[KEST,L,P,M,Z] = kalman(sys,Qn,Rn,Nn);



%intial x(1|0)=0;u(0)=14.92*pi/180;d(0)=0
% at interval k
%y actual output, u actual input
%x1p:x(k|k-1), x1:x(k|k), x2=x(k+1|k)

Nrun=10/Ts;%%need to modify
%Kalman filter
x1p =[0.01;0.01;0.01;0.01];
y1 = randi([0 1],1, Nrun); 
% linspace(1,20,Nrun);
y2 = randi([0,1],1,Nrun);
% linspace(1, 10,Nrun);
 yi = [y1;y2];
for k = 1:Nrun
    y = yi(:,k);
%every sampling interval, calculate the state estimate
e1 = y-C*x1p;
x1 = x1p+M*e1;
%update 
%  x2 = A*x1p+B*u+L*e1;%current u(k) here
%   x1p = x2;

x1p = x1;%
%save
x1s(:,k) = x1;


end
%}