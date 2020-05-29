%%%%%%%%%%%%%%%%%%%%%%  Origami Contact Simulator  %%%%%%%%%%%%%%%%%%%%%%%%
% Authors: Yi Zhu, and Evegueni T. Filipov
%
% Acknowledgement: We would like to acknowledge the prior works from
% Ke Liu and Glaucio H. Paulino for establishing shared versions of
% nonrigid origami simulators. Their works paved the way for the new
% contact model presented in this simulation code. 
%
% Code Features: 
% (1) Simulate Contact in Origami patterns
% (2) Simulate Compliant Creases in Origami Patterns
% (3) Automated Meshing for Compliant Creases
% (4) Solver for both folding and loading available
% (5) Nonrigid support available
%
% Reference:
% [1] Y. Zhu, E. T. Filipov (2019). 'An Efficient Numerical Approach for 
%     Simulating Contact in Origami Assemblages.' PRSA. (submitted)       
% [2] Y. Zhu, E. T. Filipov (2019). 'Simulating compliant crease origami 
%     with a bar and hinge model.' IDETC/CIE 2019. 97119. 
% [3] K. Liu, G. H. Paulino (2017). 'Nonlinear mechanics of non-rigid   
%     origami - An efficient computational approach.' PRSA.  
% [4] K. Liu, G. H. Paulino (2018). 'Highly efficient nonlinear        
%     structural analysis of origami assemblages using the MERLIN2      
%     software.' Origami^7. 
% [5] K. Liu, G. H. Paulino (2016). 'MERLIN: A MATLAB implementation to   
%     capture highly nonlinear behavior of non-rigid origami.'           
%     Proceedings of IASS Annual Symposium 2016. 
%
%%%%%%%%%%%%%%%%%%%%%%  Origami Contact Simulator  %%%%%%%%%%%%%%%%%%%%%%%%

clear;clc;close all;
%% Input data for Defining the Geometry
% This section of code is used to generate the geometry of structure
% Input files are still origami pattern with concentrated hinges.The code
% will automatically generate compliant creases.

W=0.8;
L=1;
L1=1;
L2=1;
tc=0.001;
tp1=0.01;
tp2=0.01;

Node=[0 0 0;
      L1+W/2 0 0;
      L2+L1+W 0 0;
      0 L 0;
      L1+W/2 L 0;
      L2+L1+W L 0;];
  
Panel{1}=[1 2 5 4];
Panel{2}=[2 3 6 5];

%% Setting up the plots for display
ViewControl=zeros(10,1);
ViewControl(1)=45; % View1: View angle 1
ViewControl(2)=45; % View2: View angle 2
ViewControl(3)=3; % Vsize: displayed axis range 
ViewControl(4)=0.2; % Vratio: ratio of displayed negative axis range versus the positive axis range

%% Assign Zero strain position for creases
[CreaseNum,Crease,CreaseType]=IdentifyCrease(Node,Panel);
% Here we identify the creases and show the drawing of the creases. With
% this information, users can assign mountain and valley folds and their
% zero strain position manually if needed.
plotOriginalMeshing(Node,Panel,CreaseNum,Crease,ViewControl)

RotationZeroStrain=pi*ones(CreaseNum,1);
% 0-2pi, This matrix can be used to manually set the target zero energy 
% angle of the crease hinge
FoldingSequence=ones(CreaseNum,1);
% Folding Sequence indicate which crease will be folded first
ratio=0;
RotationZeroStrain(3)=pi+ratio*pi;

TotalFoldingNum=max(FoldingSequence);
% Maximum number of loop needed for sequantial folding

%% Generate the Improved Meshing
% input parameters for generating the improved meshing
% Bar Areas, zero strain stretching will also be generated.
% Crease zero strain rotational position will be calculated.
% Crease rotational stiffness will be calculated (linear model used)

ModelConstant{1}=W; % CreaseW: Width of compliant creases
ModelConstant{2}=2*10^9; % PanelE: Young's modulus of panel
ModelConstant{3}=2*10^9; % CreaseE: Young's modulus of creases

ModelConstant{4}=[tp1;tp2]; % PanelThick: thickness of panel;
% This is a vector storeing the thicknes of panels. We allow panels to have
% different thicknesses

ModelConstant{5}=tc; % CreaseThick: thickness of creases;
ModelConstant{6}=0.3; % PanelPoisson: Poisson ratio of panel
ModelConstant{7}=0.3; % CreasePoisson: Poisson ratio of crease

ModelConstant{8}=3; % Flag2D3D: 
% Flag2D3D is used to determine how the additional crease structuer is
% generated,2D means center bars are genertaed through using an averaged 
% vector, 3D means the center bars are located at the original positoin.
% 3 3D, 2 2D

ModelConstant{9}=4; % DiagonalRate:
% Diagonal Rate is the factor that determine how much diagonal springs are
% stiffer than horizontal ones.

ModelConstant{17}=1; % CompliantCreaseOpen
% 1 means include compliant crease model
% 0 means using concentrated hinge model

ModelConstant{10}=1; % LockingOpen:
% 1: calculating the locking forces and formulate stiffness matrix
% 0: Close the calculation for locking induced by having panel interaction

ModelConstant{11}=0.00002; % ke: used to scale the magnitude of potentil
ModelConstant{12}=10*(10^(-6)); % d0edge: d0 for points at the edge
ModelConstant{13}=10*(10^(-6)); % d0center: d0 for points at the center

[newNode,newPanel,BarType,BarConnect,BarArea,BarLength,...
    SprIJKL,SprTargetZeroStrain,SprK,Type1BarNum,oldCrease,...
    PanelInerBarStart,CenterNodeStart,NewFoldingSequence,...
    OldNode,PanelNum,oldPanel] ...
    =ImprovedMeshingN5B8(Node,Panel,RotationZeroStrain,...
    FoldingSequence,ModelConstant);
% Generate Improved meshing

plotImprovedMeshing(ViewControl,newNode,newPanel,BarArea,BarConnect);
% Plot improved meshing for inspection
[newNumbering,inverseNumbering]=NewSequence(newNode);
% Generate newNumbering and inverseNumbering code for sparse matrix
[CreaseRef]= NumberingForCreaseLocking(oldCrease,CreaseNum,BarType);

ModelConstant{14}=TotalFoldingNum; % TotalFoldingNum
ModelConstant{15}=PanelInerBarStart; % TotalFoldingNum
ModelConstant{16}=CenterNodeStart; % TotalFoldingNum


%% Input information of support for Assemble
Supp=[1,0,0,1;
      2,0,0,1;
      3,0,1,1;
      4,1,1,1;
      9,1,1,1;
      10,1,1,1;
      11,1,1,1;
      12,1,1,1;];
  
ModelConstant{18}=0; % NonRigidSupport
% 0 means the non rigid support is not activated.
% 1 means the non rigid support is activated.
SuppElastic=[1,3,10000;
             4,3,10000];
% first column stores node number
% second column stores direction
% third column stores stiffness

%% Support and loading information for loading process
% This is used to include the effects of gravity

LoadConstant=zeros(4,1);
LoadConstant(1)=1; % IncreStep
LoadConstant(2)=10^-6; % Tor
LoadConstant(3)=50; % iterMax
LoadConstant(4)=0.01; % LambdaBar

LoadMag=0/LoadConstant(1);
% Here we divide the magnitude by the step number so that after the newton
% method we get the desired gravity we want.
Load=[1,0,0,-LoadMag;];

U=zeros(size(newNode));

% solve the geometry under gravity
[U,UhisLoading,Loadhis,StrainEnergyLoading,NodeForce,LoadForce,lockForce]...
    =NonlinearSolverLoadingNR(Panel,newNode,BarArea,BarConnect,BarLength, ...
    BarType,SprIJKL,SprK,SprTargetZeroStrain,...
    Supp,Load,U,CreaseRef,CreaseNum,OldNode,...
    LoadConstant,ModelConstant,SuppElastic);

gravityShape=newNode+U;
plotDeformedShape(ViewControl,newNode,gravityShape,newPanel,PanelNum);

% Get the load vector with the original magnitude for latter use
LoadMag=(40*10^(-9));
Load=[1,0,0,-LoadMag;];
  
  
%% Generate Thermal Conductivity Matrix and perform analysis

ModelConstant{20} = [0.3;0.3]; % Thermal Conductivity of panel 
% This is a vector storing the thermal conductivity of panels. We allow 
% different panels to have different materials. This helps to simulate the
% boundary conditions better.

ModelConstant{29} = 0.3; %Thermal Conductivity of crease
ModelConstant{21} = 0.026; % Thermal Conductivity of submerged environment

ModelConstant{22} = [1;1]*1.5; % Thickness of the 
% submerged environment at RT for panels
% This value is allowed to be different to consider the anchorage.
ModelConstant{30} = 1.5; % Thickness of the 
% submerged environment at RT for panels
ModelConstant{31} = 10; % Number of Air layers used
ModelConstant{32} = 20/180*3.14; % Thermal dissipation angle

ModelConstant{23} = 0; % Temperature of the submerged environment
ModelConstant{24} = 0; % differential thermal expansion coefficients
ModelConstant{25} = 1*10^9; % Young's modulus of bimorph material 1
ModelConstant{26} = 1*10^9; % Young's modulus of bimorph material 2
ModelConstant{27} = 1*10^-6; % thickness of bimorph material 1
ModelConstant{28} = 1*10^-6; % thickness of bimorph material 2


ThermalBCpanels=[0];
% Define the BC for thermal conduction, to confine the maximum air
% thickness. The vector stores the number of panels that serves as the BC
% for heat transfer (ie. those that are Si wafers).
% if no BC panels are present, use [0].

RTnode=[];
% This vector stores extra nodes that should be at RT to adjust the BC.

% Assemble the thermal conductivity matrix
[ThermalMat,ThermalNode]=ThermalConductAssembleMat...
    (newNode,newPanel,BarConnect,BarLength,BarType,...
    ModelConstant,oldPanel,U,ThermalBCpanels);

% define input vector of energy
qtotal=10*W*L*tc; % total input energy with unit W
qin=zeros((ModelConstant{31}+1)*ThermalNode,1);
qin(2)=1/6*1/2*qtotal;
qin(3)=1/6*1/2*qtotal;
qin(5)=1/6*1/2*qtotal;
qin(8)=1/6*1/2*qtotal;
qin(9)=2/3*1/6*qtotal;
qin(10)=2/3*1/6*qtotal;
qin(11)=2/3*2/3*qtotal;

% Define the analyses parameter for electro-thermal induced mehcnaical
% behavior of the origami
AssembleConstant=zeros(3,1);
AssembleConstant(1)=1; % Mechanical IncreStep in thermal step
AssembleConstant(2)=5*10^-7; % Tor
AssembleConstant(3)=25; % iterMax

ThermalStep=1; % number of steps for solving the thermal conductivity
% set up storage matrix
TemperatureHistory=zeros(ThermalNode,ThermalStep);
UhisThermal=zeros(ThermalStep,ThermalNode,3);
EnergyHisThermal=zeros(ThermalStep,4);

tempNode=gravityShape;
qhis=zeros(ThermalStep,1);
foldHis=zeros(ThermalStep,1);
tempHis=zeros(ThermalStep,1);

for i=1:ThermalStep
    
    % linearly increment of input energy
    qtemp=i/ThermalStep*qin;
    qhis(i)=i/ThermalStep*qtotal;    
    A=size(RTnode);
    Nrt=A(1);
        
    % Solve for the temperature profile
    [T,indexArray]=ThermalConductSolveT(qtemp,ThermalMat,ThermalNode,ModelConstant,RTnode);
    TemperatureHistory(indexArray,i)=T(1:(ThermalNode-Nrt));
    TemperatureHistory(RTnode,i)=ModelConstant{23}*ones(Nrt,1);
    T=TemperatureHistory(:,i);
    % Update the "SprTargetZeroStrain" with Timoshenko Model
    Tave=2/3*1/3*(T(9)+T(10)+T(11))+...
        1/3*1/4*(T(2)+T(3)+T(5)+T(8));
    rot=ThermalConductTimoshenko(Tave,ModelConstant);
    tempHis(i)=Tave;
    
    % Initialize the vectors again
    RotationZeroStrain=pi*ones(CreaseNum,1);
    % 0-2pi, This matrix can be used to manually set the target zero energy 
    % angle of the crease hinge
    FoldingSequence=ones(CreaseNum,1);
    % Folding Sequence indicate which crease will be folded first
    TotalFoldingNum=max(FoldingSequence);
    % Maximum number of loop needed for sequantial folding
    
    RotationZeroStrain(3)=pi+rot;

    [newNode,newPanel,BarType,BarConnect,BarArea,BarLength,...
        SprIJKL,SprTargetZeroStrain,SprK,Type1BarNum,oldCrease,...
        PanelInerBarStart,CenterNodeStart,NewFoldingSequence,...
        OldNode,PanelNum,oldPanel] ...
        =ImprovedMeshingN5B8(Node,Panel,RotationZeroStrain,...
        FoldingSequence,ModelConstant);
    
    [U,UhisAssemble,StrainEnergyAssemble]=NonlinearSolverAssemble(...
        Panel,tempNode,BarArea,BarConnect,BarLength,...
        BarType,SprIJKL,SprK,SprTargetZeroStrain, ...
        Supp,CreaseRef,CreaseNum,NewFoldingSequence,OldNode,...
        AssembleConstant,ModelConstant,SuppElastic,Load);
    
    % Record the diformation field
    if i==1
        UhisThermal(i,:,:)=U;
    else
        UhisThermal(i,:,:)=U+squeeze(UhisThermal(i-1,:,:));
    end
    EnergyHisThermal(i,:)=squeeze(...
        StrainEnergyAssemble(AssembleConstant(1),:));    
    tempNode=tempNode+U; 

    % Solve the fold angle for plotting
    node1=squeeze(gravityShape(1,:))'+squeeze(UhisThermal(i,1,:));
    node2=squeeze(gravityShape(2,:))'+squeeze(UhisThermal(i,2,:));
    node3=squeeze(gravityShape(5,:))'+squeeze(UhisThermal(i,5,:));
    node4=squeeze(gravityShape(6,:))'+squeeze(UhisThermal(i,6,:));
    vec1=node2-node1;
    vec2=node4-node3;
    rotation=dot(vec1,vec2)/norm(vec1)/norm(vec2);
    rotation=sign(node4(3)-node1(3))*acos(rotation);
    foldHis(i)=rotation;
    
    % update the thermal matrix for next step
    [ThermalMat,ThermalNode]=ThermalConductAssembleMat...
        (gravityShape,newPanel,BarConnect,BarLength,BarType,...
        ModelConstant,oldPanel,...
        squeeze(UhisThermal(i,:,:)),ThermalBCpanels);
end

1/3*(T(9)+T(10)+T(11))
T(11)

AssembleNode=tempNode;
plotDeformedShapeTemp(ViewControl,newNode,AssembleNode,newPanel...
    ,PanelNum,squeeze(TemperatureHistory(:,ThermalStep)));
% plotDeformedHisTemp(ViewControl,gravityShape,...
%     UhisThermal,newPanel,PanelNum,TemperatureHistory);
% figure; plot(qhis,foldHis);
% figure; plot(foldHis,tempHis);

%% Summary of ModelConstant
% CreaseW=ModelConstant{1};
% PanelE=ModelConstant{2};
% CreaseE=ModelConstant{3};
% PanelThick=ModelConstant{4};
% CreaseThick=ModelConstant{5};
% PanelPoisson=ModelConstant{6};
% CreasePoisson=ModelConstant{7};
% Flag2D3D=ModelConstant{8};
% DiagonalRate=ModelConstant{9};
% LockingOpen=ModelConstant{10};
% ke=ModelConstant{11};
% d0edge=ModelConstant{12};
% d0center=ModelConstant{13};
% TotalFoldingNum=ModelConstant{14};
% PanelInerBarStart=ModelConstant{15};
% CenterNodeStart=ModelConstant{16};
% CompliantCreaseOpen=ModelConstant{17};
