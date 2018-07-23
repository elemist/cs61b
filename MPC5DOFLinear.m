%06/28/2016
%sucessfully implemnted collective pitch control by MPC
%Assume the disturbance can not be measured
%sensitive when disturbance is negative; overshoot is 20, better than DOB. 
%=====!!!!NEED to READ the MPC TUNING PAPER!!!!!!!!!==========
clear;
Ts = 0.0125;
load('D:\Wind Turbine\MBC3\Source\Reduced10to5_18.mat');
A = A_c;
B = [B_c,Bd_c];
C = C_c;
D = [D_c Dd_c];
[Am,Bm,Cm,Dm] = c2dm(A,B,C,D,Ts,'zoh');
plant = ss(Am,Bm,Cm,Dm,Ts);
%define signals
plant = setmpcsignals(plant,'MV',1,'UD',2);
p = 50;%%important when tuning
m = 20;%important
mpcobj = mpc(plant,Ts,p,m);
mpcobj.MV = struct('Min',0,'Max',pi/2,'RateMin',-0.1396263,'RateMax',0.1396263);
mpcobj.Weights = struct('MV',0,'MVRate',10^-2,'OV',10^-3);
%define disturbance model used for disturbance estimation
% mpcobj.Model.Disturbance = tf(1,[1 0]);
% mpcobj.Model.Disturbance = tf(sqrt(1000),[1 0]);% another disturbance
% model estimator redesign
[L,M,A1,Cm1]= getEstimator(mpcobj);% A1,Cm1 is system matrix
e =eig(A1-A1*M*Cm1);
%set new poles
poles = [0.12 0.429 0.296 0.598 0.214 0.321];%original estimator pole is 0.0053 0.99. Disctrete pole is less than 1
L = place(A1',Cm1',poles)';
M = A1\L;
setEstimator(mpcobj,L,M);
slx = 'MPCmodual';
open_system(slx);
sim(slx);
