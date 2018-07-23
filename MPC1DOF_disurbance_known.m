% Assume the disturbance could be measured
% 1 DOF model and disturbance
Ts = 0.0125;
numP = [-13.649];
denP = [1 -0.9931];
numD = [0.31963];
denD = [ -13.649];%fix
P = tf(numP,denP,Ts);
D = tf(numD,denD,Ts);
Dd = P*D;
[numDd, denDd] = tfdata(Dd,'v') ;
plant = tf({numP numDd},{denP denDd}, Ts);
%define signals
plant = setmpcsignals(plant,'MV',1,'MD',2);
p = 9;
m = 3;
mpcobj = mpc(plant, Ts, p, m);
mpcobj.MV = struct('Min',0,'Max',pi/2,'RateMin',-0.1396263,'RateMax',0.1396263);
mpcobj.Weights = struct('MV',10,'MVRate',.1,'OV',100);
% mpcobj.Model.Disturbance = tf(numD,denD,Ts);
slx = 'MPC1DOF'; 
open_system(slx);
sim(slx);