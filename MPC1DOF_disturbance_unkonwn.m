%06/28/2016
%sucessfully implemnted collective pitch control by MPC
%Assume the disturbance can not be measured
clear;
Ts = 0.0125;
%continous ss 
A_c = -0.5526; B_c = -1.1829; Bd_c = 0.0277; C_c = 926.3; D_c=0; Dd_c=0;
%discrete ss
A = A_c;
B = [B_c,Bd_c];
C = C_c;
D = [0 0];
[Am,Bm,Cm,Dm] = c2dm(A,B,C,D,Ts,'zoh');
plant = ss(Am,Bm,Cm,Dm,Ts);
%define signals
plant = setmpcsignals(plant,'MV',1,'UD',2);
p = 20;
m = 8;
mpcobj = mpc(plant,Ts,p,m);
%define disturbance model used for disturbance estimation
mpcobj.Model.Disturbance = tf(1,1);
% mpcobj.Model.Disturbance = tf(sqrt(1000),[1 0]);% another disturbance
% model estimator redesign
[L,M,A1,Cm1]= getEstimator(mpcobj);% A1,Cm1 is system matrix
e =eig(A1-A1*M*Cm1);
%set new poles
poles = [0.2 0.3];%original estimator pole is 0.0053 0.99. Disctrete pole is less than 1
L = place(A1',Cm1',poles)';
M = A1\L;
setEstimator(mpcobj,L,M);
mpcobj.MV = struct('Min',0,'Max',pi/2,'RateMin',-0.1396263,'RateMax',0.1396263);
mpcobj.Weights = struct('MV',10^-2,'MVRate',10^-2,'OV',10^-1);
slx = 'MPCmodual';
open_system(slx);
sim(slx);
