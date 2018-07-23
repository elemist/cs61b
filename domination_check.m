function [dom_check, dom_amount,dommin_id,dommin, dom_id] = domination_check(E1,E2,func_range,MM)
% E1 is Enew, E2 is current E or E_archive
E1 = E1';
E2 = E2';
row_num = size(E2,1);
E1_origin = E1;
E1 = repmat(E1,row_num,1);
dommin_id = [];
dommin = [];
dom_id = [];


com1 = (E1 < E2);
com1 = sum(com1,2);
com1_id1 = find(com1>0); % Index for the rows that E1 has at least one element better 
com1_id2 = find(com1==0); % Index for the rows that is no worse than E1

com2 = E1 > E2;
com2 = sum(com2,2);
com2_id1 = find(com2>0 ); % Index for the rows that E2 has at least one element better 
com2_id2 = find(com2==0);% Index for the rows that is no worse than E2

E1_d_E2_id = intersect(com1_id1,com2_id2);
E2_d_E1_id = intersect(com1_id2,com2_id1);


if isempty(E1_d_E2_id) ~= 1
    dom_check = 10;
    dom_amount = 0;
    dom_id = E1_d_E2_id;
elseif isempty(E2_d_E1_id) ~= 1
    dom_check = 01;
    dom_id = E2_d_E1_id;
    E2 = E2(E2_d_E1_id,:);
    row_num = size(E2,1);
    E1 = repmat(E1_origin,row_num,1);
    E_diff = E1-E2;
    for i = 1:MM
        E_diff(:,i) = E_diff(:,i)/(func_range(i)) ;
    end
    [p,q] = find(E_diff==0);
    lp = length(p);
    for j=1:lp
        E_diff(p(j),q(j)) = 1;
    end
    E_diff = prod(E_diff,2);
    dom_amount = mean(E_diff);
    [~,dommin_id] = min(E_diff);
    dommin = E_diff(dommin_id);
    dommin_id = E2_d_E1_id(dommin_id);
else
    dom_check = 11;
    dom_amount = 0;
end
end