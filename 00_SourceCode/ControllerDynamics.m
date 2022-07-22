% This class stores the properties used to control the Newton-Raphson
% loading of an origami

classdef ControllerDynamics  < handle
    properties
        % storing the support information
        supp
        
        % NonRigidSupport
        % 0 means the non rigid support is not activated.
        % 1 means the non rigid support is activated.
        nonRigidSupport=0        
        
        % first column stores node number
        % second column stores direction
        % third column stores stiffness
        suppElastic
        % a sample input here
        % suppElastic=[1,3,10000;4,3,10000];
        
        % the applied load in time history
        Fext
        
        % self folding spring time history
        rotTargetAngle
        
        % time increment of each step
        dt
        
        % show the figure of a final deformed shape
        plotOpen=0
        
        % plot animation
        videoOpen=1
        
        % crop frames for video
        videoCropRate=100
        
        % plot details
        detailFigOpen=0
        
        %% Output properties
        % the history of displacement field
        Uhis
        
        % the history of strain energy
        strainEnergyHis        
        
        % The history of nodal forces
        FnodalHis
        
        % The history of bar strain
        barExHis
        
        % The history of bar stress
        barSxHis
        
        % The history of the rotational spring moment
        sprMHis
        
        % The history of the rotational spring rotation
        sprRotHis
        
    end
end