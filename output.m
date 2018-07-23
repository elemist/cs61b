function [Y,J] = output(U,u_km1,x_k,Sx,Su1,Su,Nc)

U_minus = [u_km1; U(1:Nc)];
U_minus(end) = [];


deltaU = U(1:Nc)-U_minus;%need modify
Y = Sx*x_k+Su1*u_km1+Su*deltaU;


J = zeros(2,1);


J(1) = sum(abs(deltaU));
% J(1) = 0;
J(2) = sum(abs(Y(1,:)));
% J(3) = sum(abs(Y(2,:)));