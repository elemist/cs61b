%main file: run the simulation
clear;
% Ts = 0.0125;
 Ts = 0.01;%revise .fst
YY_Read_FAST_Input; 
slx = 'MOSA_mpc';
open_system(slx);
sim(slx);