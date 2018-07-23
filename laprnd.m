function x_new = laprnd(mu,b,x_base)
    u = rand(1,1)-.5;
    if u==0
        u = rand(1,1)-.5;
    end
    x = mu - b*sign(u).*log(1-2*abs(u));
    x_new = x+x_base;
%     i_count = 1;
%     while x_new<0 || x_new>1
%         if i_count == 20;
%             break
%         end        
%         u = rand(1,1)-.5;
%         if u==0
%             u = rand(1,1)-.5;
%         end
%         x = mu - b*sign(u).*log(1-2*abs(u));
%         x_new = x+x_base;
%         i_count = i_count+1;
%     end
%     if x_new < 0
%         x_new = 0;
%     elseif x_new>1
%         x_new = 1;
%     end 
end