%% Plot the deformed configuration of the simulation
%
% This code plots the deformed confirguration of an origami system and the
% reference configuration of the origami before loading). 
%
% Input:
%       viewControl: general plotting setup;
%       newNode: reference nodal coordinates;
%       deformNode: deformed nodal coordinates;
%       newPanel: panel information;
%

function Plot_DeformedShape(obj,undeformedNode,deformNode)

View1=obj.viewAngle1;
View2=obj.viewAngle2;
Vsize=obj.displayRange;
Vratio=obj.displayRangeRatio;

% Plot Dots
figure
view(View1,View2); 
set(gca,'DataAspectRatio',[1 1 1])
set(gcf, 'color', 'white');
set(gcf,'position',[obj.x0,obj.y0,obj.width,obj.height])

A=size(Vsize);
if A(1)==1    
    axis([-Vratio*Vsize Vsize -Vratio*Vsize Vsize -Vratio*Vsize Vsize])
else
    axis([Vsize(1) Vsize(2) Vsize(3) Vsize(4) Vsize(5) Vsize(6)])
end

B=size(obj.newPanel);
FaceNum=B(2);

barNum=size(obj.barConnect);
barNum=barNum(1);

for i=1:FaceNum
    tempPanel=cell2mat(obj.newPanel(i));
    patch('Vertices',deformNode,'Faces',tempPanel,...
        'FaceColor',obj.faceColorAnimation, ...
        'FaceAlpha',obj.faceAlphaAnimation);
end

if obj.plotBars==1
    for j=1:barNum
        node1=deformNode(obj.barConnect(j,1),:);
        node2=deformNode(obj.barConnect(j,2),:);
        line([node1(1),node2(1)],...
             [node1(2),node2(2)],...
             [node1(3),node2(3)],'Color','k');
    end
end

if obj. plotUndeformedShape==1
    for i=1:FaceNum
        tempPanel=cell2mat(obj.newPanel(i));
        patch('Vertices',undeformedNode,'Faces',tempPanel,...
            'EdgeColor',[0.5 0.5 0.5],'FaceAlpha',0,'EdgeAlpha',obj.deformEdgeShow);
    end
end

if obj. plotUndeformedShape==1
    if obj.plotBars==1
        for j=1:barNum
            node1=undeformedNode(obj.barConnect(j,1),:);
            node2=undeformedNode(obj.barConnect(j,2),:);
            line([node1(1),node2(1)],...
                 [node1(2),node2(2)],...
                 [node1(3),node2(3)],'Color',[0.5 0.5 0.5]);
        end
    end
end