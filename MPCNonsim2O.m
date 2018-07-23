%08/04 
%test nonlinear model @ all DOFs
%linearized model has two outputs,  gen speed, tower def. 2DOF Gen DOF,
%tower DOF
% Reduced4to3_DOF_18.mat is the data
% Assume the disturbance is unknown and can be observed
%c ollective pitch

%***********Performance show Genspeed and Tower fore-aft def. can be %stable*********
clear;
Ts = 0.0125;

load('D:\Wind Turbine\MPC\Reduced4to3_2DOF_18.mat');
A = A_c;
B = [B_c,Bd_c];
C = C_c;
D = [D_c, Dd_c];% 
[Am,Bm,Cm,Dm] = c2dm(A,B,C,D,Ts,'zoh');
plant = ss(Am,Bm,Cm,Dm,Ts);
%define signals
plant = setmpcsignals(plant,'MV',1,'UD',2);
p = 50;%%important when tuning
m = 20;%important
% rou = .99;
mpcobj = mpc(plant,Ts,p,m);
mpcobj.MV = struct('Min',0,'Max',pi/2,'RateMin',-0.1396263,'RateMax',0.1396263);
% tune the weights to regulate the performance
% mpcobj.Weights = struct('MV',1e-4,'MVRate',1.2e5,'OV',[8e0 1e-5]);%importamt  tuning
% mpcobj.Weights = struct('MV',rou*1e-4,'MVRate',1.2e5,'OV',[(1-rou)*8e0 (1-rou)*1e-5]);%importamt  tuning
mpcobj.Weights = struct('MV',1e-4,'MVRate',1.2e5,'OV',[8*1e0 1*1e0]);%importamt  tuning

%define disturbance model used for disturbance estimation
mpcobj.Model.Disturbance = tf(1,[1 0]);
% mpcobj.Model.Disturbance = tf(sqrt(1000),[1 0]);% another disturbance
% model estimator redesign
[L,M,A1,Cm1]= getEstimator(mpcobj);% A1,Cm1 is system matrix
e = eig(A1-A1*M*Cm1);
%set new poles
poles = [0.12 0.229 0.296 0.398 0.214];%original estimator pole is 0.0053 0.99. Disctrete pole is less than 1
L = place(A1',Cm1',poles)';
M = A1\L;
setEstimator(mpcobj,L,M);

YY_Read_FAST_Input; 
slx = 'MPCNonModual2O';
open_system(slx);
sim(slx);

    cd('D:\Wind Turbine\MPC\Output');
    save('OutData_MPC_Turb18_Op18.mat','OutData_MPC_Turb18_Op18');%adjust mat file
    save('Time.mat','Time');
    copyfile('D:\Wind Turbine\MPC\OnshoreGen_MPC_18mps_SFunc.out','D:\Wind Turbine\MPC\MPC_Turb18_Op18.out');
    movefile('D:\Wind Turbine\MPC\MPC_Turb18_Op18.out','D:\Wind Turbine\MLife\CertTest\SPIE2017');

    
if 1
    clear;
    cd('D:\Wind Turbine\MPC');
    YY_Read_FAST_Input; 
    sim('GSPI.slx');
    cd('D:\Wind Turbine\MPC\Output');
    save('OutData_GSPI_Turb18_Op18.mat','OutData_GSPI_Turb18_Op18');
    copyfile('D:\Wind Turbine\MPC\OnshoreGen_MPC_18mps_SFunc.out','D:\Wind Turbine\MPC\GSPI_Turb18_Op18.out');
    movefile('D:\Wind Turbine\MPC\GSPI_Turb18_Op18.out','D:\Wind Turbine\MLife\CertTest\SPIE2017');
end
%}
load('D:\Wind Turbine\MPC\Output\Time.mat');
load('D:\Wind Turbine\MPC\Output\OutData_MPC_Turb18_Op18.mat');
load('D:\Wind Turbine\MPC\Output\OutData_GSPI_Turb18_Op18.mat');

plot(Time,OutData_GSPI_Turb18_Op18(:,11),'g--','LineWidth',1.5);hold on;
plot(Time,OutData_MPC_Turb18_Op18(:,11),'b:','LineWidth',1.5);hold on;
xlabel('Time (s)');
ylabel('Generator speed (rpm)');
legend('GSPI','MPC');
% legend boxoff
set(gca,'FontSize',12);
axis([100 600 1100 1280]);
%}
%average power&MAx pitch rate
n1=size(OutData_MPC_Turb18_Op18(:,11),1);
for i=8000:n1%8000 100s
     a1(i,:)=OutData_GSPI_Turb18_Op18(i,11)-1173.7;
     b1(i,:)=a1(i,:).^2;
  
     a2(i,:)=OutData_MPC_Turb18_Op18(i,11)-1173.7;
     b2(i,:)=a2(i,:).^2;
     
     a7(i,:)=OutData_GSPI_Turb18_Op18(i,20);%RMS pitch Rate
     b7(i,:)=a7(i,:).^2;
     a9(i,:)=OutData_MPC_Turb18_Op18(i,20);
     b9(i,:)=a9(i,:).^2;
  
end
Out.GenErPI = sqrt(sum(b1))/n1;%GSPI
Out.GenErMPC =sqrt(sum(b2))/n1;%MPC
Out.AvgPwrPI = mean(OutData_GSPI_Turb18_Op18(:,4)) %average power& 
Out.AvgPwrMPC = mean(OutData_MPC_Turb18_Op18(:,4))
Out.PwrRatio = Out.AvgPwrMPC/Out.AvgPwrPI;
Out.MaxptrtPI = max(OutData_GSPI_Turb18_Op18(:,20))%MAx pitch rate
Out.MaxptrtMPC = max(OutData_MPC_Turb18_Op18(:,20))
Out.rmsptrtPI = sqrt(sum(b7))/n1%RMS pitch rate
Out.rmsptrtMPC = sqrt(sum(b9))/n1

cd('D:\Wind Turbine\MLife\CertTest');
C=regexp(fileread('GSPI_Turb_Op18.mlif'),'\n','split');
C{8}=['"MPC_Turb18_Op18"      	  RootName          Root name for output files'];
C{88}=['"MPC_Turb18_Op18.out"']; %%      when add output 87 should be changed to 88 
outputfile=['MPC_Turb18_Op18.mlif'];
fid=fopen(outputfile,'w');
fprintf(fid,'%s\n',C{:});
fclose(fid);

D=regexp(fileread('GSPI_Turb_Op18.mlif'),'\n','split');
D{8}=['"GSPI_Turb18_Op18"']; 
D{88}=['"GSPI_Turb18_Op18.out"']; 
outputfile=['GSPI_Turb18_Op18.mlif'];
fid=fopen(outputfile,'w');
fprintf(fid,'%s\n',D{:});
fclose(fid);

%calculate fatigueDEL
% clear;
cd('D:\Wind Turbine\MLife\CertTest');
mlife('GSPI_Turb18_Op18.mlif', '.\SPIE2017\', '.\SPIE2017\GSPI_Turb18_Op18\');
mlife('MPC_Turb18_Op18.mlif', '.\SPIE2017\', '.\SPIE2017\MPC_Turb18_Op18\');
%}
