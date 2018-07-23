function iter_per_temp = iter_temp(total_iter,alpha,T0,Tmin)

T = T0;
k = 0;
while T>Tmin
    k = k+1;
    T = (alpha^k)*T0; 
end

iter_per_temp = ceil(total_iter/k);


end