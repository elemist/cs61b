% Np = 5;
% Nc = 3;
function [Sx, Su1, Su] = PredictOutput(Np,Nc,A,B,C)
Sx = C*A;
Su1= C*B;

for ii =2:Np
    Sx = [Sx;Sx(2*(ii-1)-1:2*(ii-1),:)*A];
    Su1 = [Su1; Su1(2*(ii-1)-1:2*(ii-1),:)+C*A^(ii-1)*B];
end

v = Su1;
Su  = Su1;

for jj = 2:Nc
 
    Su_temp = [zeros(2*(jj-1),1);v(1:2*(Np-jj+1),1)];
    Su = [Su, Su_temp];
    
end

