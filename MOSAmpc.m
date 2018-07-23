function MOSAmpc(block)

setup(block);

%endfunction

%% Function: setup ===================================================

function setup(block)

% Register number of ports
block.NumInputPorts  = 2;% y1 y2
block.NumOutputPorts = 1;% u

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = false;

block.InputPort(2).Dimensions        = 1;
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).DirectFeedthrough = false;

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
%===============================================================
% block.SampleTimes = [0.0125 0];%%% discrete , need ti change
block.SampleTimes = [0.01 0];%%% discrete , need ti change
%=============================================================
% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
% block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
% block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

function DoPostPropSetup(block)
block.NumDworks = 2;
  
  block.Dwork(1).Name            = 'x1p';
  block.Dwork(1).Dimensions      = 4;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
  
  block.Dwork(2).Name            = 'u';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = true;

%end InitializeConditions

function Start(block)

block.Dwork(1).Data = [0;0;0;0];
block.Dwork(2).Data = 0;
% 14.92*pi/180;
%end Start

function Outputs(block)
y1 = block.InputPort(1).Data;
y2 = block.InputPort(2).Data;
y = [y1;y2];
x1p = block.Dwork(1).Data;
u = block.Dwork(2).Data;

[A,B,C,D,M,L] = SysPara;
 

    x1 = x1p+M*(y-C*x1p);%%%define
    x = x1;%current k state estimate
    Np = 5;
    Nc = 2;
    [Sx,Su1,Su] = PredictOutput(Np,Nc,A,B,C);
    [U_archive,J_archive] = MOSA(u,x,Np,Nc,Sx,Su1,Su);
    
%     [~,rown] = size(J_archive);
%     Temp = randperm(rown);
%     repick_id = Temp(1);
%     Uopt = U_archive(1,repick_id);
     
    [~,min_id] = min(J_archive(2,:));
     %choose a critia to find a optimal value, one element
     Uopt = U_archive(1,min_id);
     %update
     u = Uopt;
   
  block.OutputPort(1).Data = u;

%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)
[A,B,C,D,M,L] = SysPara;

y1 = block.InputPort(1).Data;
y2 = block.InputPort(2).Data;
y = [y1;y2];
block.Dwork(2).Data = block.OutputPort(1).Data;

e1 = y-C*block.Dwork(1).Data;
x2 = A*block.Dwork(1).Data+B*block.Dwork(2).Data+L*e1;%current u(k) here

block.Dwork(1).Data = x2;


%end Update

%%
%% Derivatives:
%%   Functionality    : Called to update derivatives of
%%                      continuous states during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlDerivatives
%%


%end Derivatives

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

