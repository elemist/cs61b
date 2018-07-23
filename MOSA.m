function [U_archive,J_archive] = MOSA(u_km1 ,x_k, no_var,Nc,Sx,Su1,Su)
% clear
% clc
% u_km1 = 14.92*pi/180;
% x_k = zeros(4,1);
% [A,B,C,D,M,L] = SysPara;
% no_var = 10;
% Nc = 5;
% [Sx,Su1,Su] = PredictOutput(no_var,Nc,A,B,C);

MM = 2; %No. of objective functions

initial_population = 1;
xmin = -14.92*pi/180;%
xmax = (90-14.92)*pi/180;% 
steps = no_var; % how many steps do we want to predict

func_range = [1 1];
U_archive = zeros(initial_population,steps);
U_archive(:,1:Nc) = rand(initial_population,Nc).*(xmax-xmin);
U_archive(:,Nc+1:end) = repmat(U_archive(:,Nc),1,(no_var-Nc));
U_initial = U_archive(1,:);
U_initial = U_initial';
U_archive = U_archive';
[Y_initial, J_initial] = output(U_initial,u_km1,x_k,Sx,Su1,Su,Nc);

J = J_initial;
Y = Y_initial;
U = U_initial;

J_archive = J_initial;
Y_archive = Y_initial;
% U_archive = U_initial;

%Annealing
total_iter = 1000;
T0 = 100;
T = T0;
Tmin = 10^-4;
alpha = 0.9;
k = 0;
iter_per_temp = iter_temp(total_iter,alpha,T0,Tmin);
ploti = 1;
J_plot(ploti,:) = J';

while T>Tmin   
    for i = 1:iter_per_temp
        [~,row_num] = size(J_archive);
        if row_num ~= 1
            func_range = [max(J_archive(1,:))-min(J_archive(1,:)),max(J_archive(2,:))-min(J_archive(2,:))];
        end
        % Move Routing
            choose = randsample(1:Nc,1);
%             u_new = -1;
%             while_count = 0;
%             while (u_new<-14.92*pi/180 || u_new>(90-14.92)*pi/180)%%revise
                u_new = laprnd(0,0.06,U(choose)); %Laplacian Distribution
%                 while_count = while_count+1;
%                 if while_count == 8
%                     if u_new<-14.92*pi/180
%                         u_new = -14.92*pi/180;
%                     elseif u_new>((90-14.92)*pi/180)
%                         u_new = (90-14.92)*pi/180;
%                     end
%                     break
%                 end
%             end
            UN = U;
            
            if choose == Nc
                UN(Nc:end) = u_new*ones(no_var-Nc+1,1);
            else
                UN(choose) = u_new;
            end
            [YN,JN] = output(UN,u_km1,x_k,Sx,Su1,Su,Nc);
        
        YNew = YN;
        JNew = JN;
        UNew = UN;
        flag = 1;
        [dom_check, domnew] = domination_check(JNew,J,func_range,MM); % dom_check = 10 front dom later
%--------------------------------------------------------------------------
%MOSA/R
%--------------------------------------------------------------------------
        if dom_check == 1 %case 1 if current dominates new
            [dom_check_ar, dom,dommin_id, dommin,dom_id] = domination_check(JNew,J_archive,func_range,MM); 
            domavg = (length(dom_id)*dom+domnew)/(1+length(dom_id));
            if  ismember(J',J_archive','rows') %E belongs to archive
                if 1/(1+exp(domavg/T))>rand(1)
                    flag = 1;
                else
                    flag = 0;
                end
            else %E does not belong to archive
% repick scheme------------------------------------------------------------
                repick_scheme = 1;
                switch repick_scheme
                    case 1
                        if 1/(1+exp(-dommin(1))) > rand(1)
                            flag = 2;
                        else
                            if 1/(1+exp(domavg/T))>rand(1)
                                flag = 1;
                            else
                                flag = 0;
                            end
                        end
                    case 2
                end
% -------------------------------------------------------------------------
            end
        elseif dom_check == 10 
            [dom_check_ar, dom, dommin_id, dommin, dom_id] = domination_check(JNew,J_archive,func_range,MM); 
            if dom_check_ar == 1 %Case 3(a)  ??In numerical test, this part is commented except flag=1, the performance of them should be similar
%                 dom = prod((1+abs(EN_MAT(q,:)-E_archive(arc_d_new_index(q),:)))./...
%                     repmat((1+max(E_archive)-min(E_archive)),length(q),1),2);
%                 domavg = sum(dom)/arc_d_new;
%                 if 1/(1+exp(domavg/T))>rand(1)
                    flag = 1;
%                 else
%                     flag = 0;
%                 end
            elseif dom_check_ar == 10 %Case 3(c)
                flag = 1;
                J_archive(:,dom_id) = [];
                Y_archive(:,dom_id)=[];
                U_archive(:,dom_id)=[];
                J_archive = [J_archive,JNew];
                Y_archive = [Y_archive,YNew];
                U_archive = [U_archive,UNew];
            else %Case 3(b)
                flag = 1;
                J_archive = [J_archive,JNew];
                Y_archive = [Y_archive,YNew];
                U_archive = [U_archive,UNew];
            end                         
        else %Case 2
            [dom_check_ar, dom, dommin_id, dommin, dom_id] = domination_check(JNew,J_archive,func_range,MM); 
            if dom_check_ar == 1 %Case 2(a) new dominated by archive
                domavg = dom;
                if 1/(1+exp(domavg/T))>rand(1)
                    flag = 1;
                else
                    flag = 0;
                end
            elseif dom_check_ar == 10 %Case 2(c) new dominates archive
                flag = 1;
                J_archive(:,dom_id) = [];
                Y_archive(:,dom_id)=[];
                U_archive(:,dom_id)=[];
                J_archive = [J_archive,JNew];
                Y_archive = [Y_archive,YNew];
                U_archive = [U_archive,UNew];
            else %Case 2(b)
                flag = 1;
                J_archive = [J_archive,JNew];
                Y_archive = [Y_archive,YNew];
                U_archive = [U_archive,UNew];
            end                                                
        end

        if flag == 1
            J = JN;
            Y = YN;
            U = UN;
        elseif flag == 2
            J = J_archive(:,dommin_id);
            Y = Y_archive(:,dommin_id);
            U = U_archive(:,dommin_id);
        end
%         ploti = ploti+1;
%         J_plot(ploti,:) = J';
    end
    k = k+1;
    T = (alpha^k)*T0;
end

% figure;plot(1:ploti,J_plot(1:ploti,1));
% 
% figure;
% plot(1:ploti,J_plot(1:ploti,2));