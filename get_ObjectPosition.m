function [WeldingPos] = get_ObjectPosition(ptCloud,Referenzdatenbank,ObjectID,Constants)
    FieldNames = fieldnames(Referenzdatenbank);
    Center = Referenzdatenbank.(FieldNames{ObjectID}).Center;
    ReferencePtCloud = Referenzdatenbank.(FieldNames{ObjectID}).ptCloud;

%     Xdiff = ((ptCloud.XLimits(1,2)-ptCloud.XLimits(1,1))/2)+...
%             ptCloud.XLimits(1,1)-Center(1,1);
%     Ydiff = ((ptCloud.YLimits(1,2)-ptCloud.YLimits(1,1))/2)+...
%             ptCloud.YLimits(1,1)-Center(1,2);
%     Zdiff = ((ptCloud.ZLimits(1,2)-ptCloud.ZLimits(1,1))/2)+...
%             ptCloud.ZLimits(1,1)-Center(1,3);
    rotx = [1, 0, 0, 0; 0, cos(pi), -sin(pi), 0; 0, sin(pi), cos(pi), 0; 0, 0, 0, 1];
    rotz = [cos(-pi/2), -sin(-pi/2), 0, 0; sin(-pi/2), cos(-pi/2), 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
    rotation = (rotx*rotz)';
    T_rot = affine3d(rotation);
    ReferencePtCloud = pctransform(ReferencePtCloud,T_rot); 
    
    Xsize = (ptCloud.XLimits(1,2) - ptCloud.XLimits(1,1)) \ ...
        (ReferencePtCloud.XLimits(1,2) - ReferencePtCloud.XLimits(1,1));
    Ysize = (ptCloud.YLimits(1,2) - ptCloud.YLimits(1,1)) \ ...
        (ReferencePtCloud.YLimits(1,2) - ReferencePtCloud.YLimits(1,1));
    Zsize = (ptCloud.ZLimits(1,2) - ptCloud.ZLimits(1,1)) \ ...
        (ReferencePtCloud.ZLimits(1,2) - ReferencePtCloud.ZLimits(1,1));

    trans = [1/Xsize,0,0,0;0,1/Ysize,0,0;0,0,1/Zsize,0;0,0,0,1];
    T_resize = affine3d(trans);
    ReferencePtCloud = pctransform(ReferencePtCloud,T_resize); 
    
    Xdiff = ((ptCloud.XLimits(1,2)-ptCloud.XLimits(1,1))/2)+ptCloud.XLimits(1,1)-...
        (((ReferencePtCloud.XLimits(1,2)-ReferencePtCloud.XLimits(1,1))/2)+ReferencePtCloud.XLimits(1,1));
    Ydiff = ((ptCloud.YLimits(1,2)-ptCloud.YLimits(1,1))/2)+ptCloud.YLimits(1,1)-...
        (((ReferencePtCloud.YLimits(1,2)-ReferencePtCloud.YLimits(1,1))/2)+ReferencePtCloud.YLimits(1,1));
    Zdiff = ((ptCloud.ZLimits(1,2)-ptCloud.ZLimits(1,1))/2)+ptCloud.ZLimits(1,1)-...
        (((ReferencePtCloud.ZLimits(1,2)-ReferencePtCloud.ZLimits(1,1))/2)+ReferencePtCloud.ZLimits(1,1));
    
    T_trans = affine3d([1,0,0,0;0,1,0,0;0,0,1,0;Xdiff,Ydiff,Zdiff,1]);
    ReferencePtCloud = pctransform(ReferencePtCloud,T_trans); 

    RefDirection = Referenzdatenbank.(FieldNames{ObjectID}).DirectionVector;
    LinearAxisDirection = Constants.LinearAxisDirection;

    %  alpha = atan2d(RefDirection(1,1)*LinearAxisDirection(1,2)-LinearAxisDirection(1,1)*RefDirection(1,2),...
    %      RefDirection(1,1)*RefDirection(1,2)+LinearAxisDirection(1,1)*LinearAxisDirection(1,2));
    %  
    %  T_rot = affine3d([cos(alpha),sin(alpha),0,0;-sin(alpha),cos(alpha),0,0;0,0,1,0;0,0,0,1]);
    %  ReferencePtCloud = pctransform(ReferencePtCloud,T_rot);

     [T_ICP,ReferencePtCloud] = pcregistericp(ReferencePtCloud,ptCloud,'MaxIterations',...
         Constants.ICP_Parameters.ICP_Pos_iter,'metric','pointToPlane');


    WeldingPosition = Referenzdatenbank.(FieldNames{ObjectID}).WeldingPoints;
    WeldingPosition = pointCloud(WeldingPosition); 
    WeldingPosition = pctransform(WeldingPosition,T_rot);
    WeldingPosition = pctransform(WeldingPosition,T_resize); 
    WeldingPosition = pctransform(WeldingPosition,T_trans);
    WeldingPosition = pctransform(WeldingPosition,T_ICP);
    WeldingPos(:,1) = WeldingPosition.Location(:,2);
    WeldingPos(:,2) = WeldingPosition.Location(:,1);
    WeldingPos(:,3) = WeldingPosition.Location(:,3);

end