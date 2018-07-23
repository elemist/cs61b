%07/22/2016
%revised 08/03
% 1 input collective pitch
% 2 outputs,  gen speed, tower vel.
% Gen DOF and Tower fore-aft DOF
%**Perfromance is not good at lineaized one, but good at nonlinear one
clear;
Ts = 0.0125;
% load('D:\Wind Turbine\Individual\Reduced6to5_3DOF_18.mat');
load('D:\Wind Turbine\MPC\Reduced4to3_2DOF_18.mat');
A = A_c;
B = [B_c,Bd_c];
C = C_c;
D = [D_c, Dd_c];% 

rnk = rank(ctrb(A,B), 0); % rank with tol = 0
if rnk == size(A,1)
disp(' (A, B) controllable');
else
disp([' (A, B) uncontrollable, rank = ', num2str(rnk), ' < ',num2str(size(A_c,1))]);
error(' Cannot continue!');
end

rnk = rank(obsv(A,C), 0); % rank with tol = 0
if rnk == size(A,1)
disp(' (A, C) observable');
else
disp([' (A, C) unobservable, rank = ', num2str(rnk), ' < ',num2str(size(Abar,1))]);
error(' Cannot continue!');
end


[Am,Bm,Cm,Dm] = c2dm(A,B,C,D,Ts,'zoh');

plant = ss(Am,Bm,Cm,Dm,Ts);
%define signals
plant = setmpcsignals(plant,'MV',1,'UD',2);
p = 50;%%important when tuning
m = 20;%important
mpcobj = mpc(plant,Ts,p,m);
% mpcobj.MV = struct('Min',0,'Max',pi/2,'RateMin',-0.1396263,'RateMax',0.1396263);
% tune the weights to regulate the performance
% mpcobj.Weights = struct('MV',10^-4,'MVRate',1.2*10^5,'OV',[0.8*10^1 0.8*10^-3 10^1]);%importamt  tuning
p = 0.9;
% mpcobj.Weights = struct('MV',0,'MVRate',0,'OV',[0.5*p 0.1*(1-p)]);%importamt  tuning
mpcobj.Weights = struct('MV',1e-4,'MVRate',1.2e5,'OV',[8e0 1e-5]);%importamt  tuning

%define disturbance model used for disturbance estimation
% mpcobj.Model.Disturbance = tf(1,[1 0]);
mpcobj.Model.Disturbance = tf(sqrt(1000),[1 0]);% another disturbance
% model estimator redesign
[L,M,A1,Cm1]= getEstimator(mpcobj);% A1,Cm1 is system matrix
e =eig(A1-A1*M*Cm1);
% 
rnk = rank(ctrb(A1',Cm1'), 0); % rank with tol = 0
if rnk == size(A1',1)
disp(' (A, B) controllable');
else
disp([' (A, B) uncontrollable, rank = ', num2str(rnk), ' < ',num2str(size(A_c,1))]);
error(' Cannot continue!');
end

%set new poles
poles = [0.12 0.229 0.296 0.398 0.214];%original estimator pole is 0.0053 0.99. Disctrete pole is less than 1
L = place(A1',Cm1',poles)';
M = A1\L;
setEstimator(mpcobj,L,M);


slx = 'MPCmodual2O';
open_system(slx);
sim(slx);
%}