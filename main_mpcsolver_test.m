%MPC solved by another method
%model one input two outputs. 
%cost function = minimize (y-r)(y=genSpeed and tower def)+(delta u= pitch
%activity)

Ts =0.0125;
load('D:\Wind Turbine\Individual\Reduced4to3_2DOF_18.mat');

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


Qn = 10;
Rn = [1 0; 0 1];
Nn = [0, 0]; 
[KEST,L,P,M,Z] = kalman(sys,Qn,Rn,Nn);


%intial x(1|0)=0;u(0)=14.92*pi/180;d(0)=0
% at interval k
%y actual output, u actual input
%x1p:x(k|k-1), x1:x(k|k), x2=x(k+1|k)

Nrun=600/Ts;%%need to modify
%Kalman filter
x1p =[0.01;0.01;0.01;0.01];
y1 = randi([0 1],1, Nrun); %gen speed
y2 = randi([0,1],1,Nrun);%tower del
yi = [y1;y2];
for k = 1:Nrun
%every sampling interval, calculate the state estimate
y = yi(:,k);
e1 = y-C*x1p;
x1 = x1p+M*e1;
%update 

x = x1;%current k state estimate
%use the current state estimate to predict further output
%output variable prediction, in prediction model
%xp(k+1,k):x(k+1|k, xp(k)= x(k|k)= x(k,k) ,u(k|k)= u(k,k)

Np = 5;
Nc = 3;
[Sx,Su1,Su] = PredictOutput(Np,Nc,A,B,C);%call function
 %deltaU = [deltau(0) deltau(1)... delta u(Np-1)]
 %deltau(0)= u(0)-u(-1)

 u = 14.92*pi/18;%u(k-1)=14.92*pi/180 rad;
 
 %*****************************************Modify********************************
 %07/28
 deltaU = [deltau0 deltau1 deltau3 deltau4];%need modify
 Y = Sx*x+Su1*u+Su*deltaU;
 %%
 %Optimizer to calculate deltaU
 DeltaU = %%%%%%%\
 deltau = DeltaU(1,1);
 u = u+deltau;
 
 %%
 %update estimator
  
  x2 = A*x1p+B*u+L*e1;%current u(k) here
  x1p = x2;
  
  
  %store values for plotting
  u1(k) = u;
  x1s(:,k) = x1;%current k state estimation
end

%}
