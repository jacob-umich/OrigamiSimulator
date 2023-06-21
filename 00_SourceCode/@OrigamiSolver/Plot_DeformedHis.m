%% plot the deformation history of the simulated results.
%
% This funciton plots the deformation history of the simlation results,
% with an assemble (self-folding) process and another loading process. The
% function also generates a GIF animation for inspection.
%
% Input: 
%       viewControl: general plotting set up;
%       newNode: the nodal coordinates;
%       newPanel: the nodes of each panel;
%       UhisLoading: the deformation history for loading;
%       UhisAssemble: the deformation history for self-assemble.
%

function Plot_DeformedHis(obj,undeformedNode,UhisLoading)

View1=obj.viewAngle1;
View2=obj.viewAngle2;
Vsize=obj.displayRange;
Vratio=obj.displayRangeRatio;

pauseTime=obj.holdTime;
filename='OriAnimation.gif';

h=figure;
% view(View1,View2); 
% set(gca,'DataAspectRatio',[1 1 1])
% axis([-0.2*Vsize Vsize -0.2*Vsize Vsize -0.2*Vsize Vsize])
% axis([-Vsize Vsize -Vsize Vsize -Vsize Vsize])

B=size(obj.newPanel);
FaceNum=B(2);


B=size(UhisLoading);
Incre=B(1);
n1=B(2);
n2=B(3);

set(gcf, 'color', 'white');
set(gcf,'position',[obj.x0,obj.y0,obj.width,obj.height])
    

for i=1:Incre
    clf
    view(View1,View2); 
    set(gca,'DataAspectRatio',[1 1 1])
    
    A=size(Vsize);
    if A(1)==1    
        axis([-Vratio*Vsize Vsize -Vratio*Vsize Vsize -Vratio*Vsize Vsize])
    else
        axis([Vsize(1) Vsize(2) Vsize(3) Vsize(4) Vsize(5) Vsize(6)])
    end
    
    tempU=zeros(n1,n2);
    for j=1:n1
        for k=1:n2
           tempU(j,k)=UhisLoading(i,j,k);
        end
    end
    deformNode=undeformedNode+tempU;
    for j=1:FaceNum
        tempPanel=cell2mat(obj.newPanel(j));
        patch('Vertices',deformNode,'Faces',tempPanel,...
            'FaceColor',obj.faceColorAnimation, ...
            'FaceAlpha', obj.faceAlphaAnimation);     
    end
    
    if obj.plotBars==1
        barNum=size(obj.barConnect);
        barNum=barNum(1);
        for j=1:barNum
            node1=deformNode(obj.barConnect(j,1),:);
            node2=deformNode(obj.barConnect(j,2),:);
            line([node1(1),node2(1)],...
                 [node1(2),node2(2)],...
                 [node1(3),node2(3)],'Color','k');
        end
    end
    
    pause(pauseTime);  
    
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if i == 1 
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime', pauseTime); 
    end 
end
