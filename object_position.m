function weldingPos = object_position(ptCloud,Referenzdatenbank,ObjectID,Constants)
    % object_position - Calculate the object position of the welding point.
    %
    % Syntax:  
	%	 weldingPos = object_position(ptCloud,Referenzdatenbank,ObjectID,Constants)
	%
	% Inputs:
    %    ptCloud - The taken point cloud of the workpiece.
    %    Referenzdatenbank - The reference data bank, which contains the
    %           point cloud of the standard models.
	%	 ObjectID - Integer, the recognized ID of the workpiece.
	%	 Constants - Constants with the glaobal constants for program.
	%
    % Outputs:
    %    weldingPos - The calculated welding position.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
    
    % Assign the standard point cloud to the reference point cloud.
    workpieces = fieldnames(Referenzdatenbank);
    reference_ptCloud = Referenzdatenbank.(workpieces{ObjectID}).ptCloud;
    
    % The rotation matrix along the x axis.
    rotx = [1, 0, 0, 0;...
            0, cos(pi), -sin(pi), 0;...
            0, sin(pi), cos(pi), 0;...
            0, 0, 0, 1];
    % The rotation matrix along the z axis.
    rotz = [cos(-pi/2), -sin(-pi/2), 0, 0;...
            sin(-pi/2), cos(-pi/2), 0, 0;...
            0, 0, 1, 0;...
            0, 0, 0, 1];
    % The rotation matrix for the total rotation.
    rotation = (rotx*rotz)';
    % Perform the rotation to the refernce point cloud.
    t_rot = affine3d(rotation);
    reference_ptCloud = pctransform(reference_ptCloud,t_rot); 
    
    % Scale transformation of x coordinates.
    x_scale = (ptCloud.XLimits(1,2) - ptCloud.XLimits(1,1)) \ ...
        (reference_ptCloud.XLimits(1,2) - reference_ptCloud.XLimits(1,1));
    % Scale transformation of y coordinates.
    y_scale = (ptCloud.YLimits(1,2) - ptCloud.YLimits(1,1)) \ ...
        (reference_ptCloud.YLimits(1,2) - reference_ptCloud.YLimits(1,1));
    % Scale transformation of z coordinates.
    z_scale = (ptCloud.ZLimits(1,2) - ptCloud.ZLimits(1,1)) \ ...
        (reference_ptCloud.ZLimits(1,2) - reference_ptCloud.ZLimits(1,1));
    % Scale transformation matrix.
    trans = [1/x_scale,0,0,0;0,1/y_scale,0,0;0,0,1/z_scale,0;0,0,0,1];
    % Perform the scale transformation to the refernce point cloud.
    t_resize = affine3d(trans);
    reference_ptCloud = pctransform(reference_ptCloud,t_resize); 
    
    % The center offset in x axis.
    x_diff = ((ptCloud.XLimits(1,2)-ptCloud.XLimits(1,1))/2)+ptCloud.XLimits(1,1)-...
        (((reference_ptCloud.XLimits(1,2)-reference_ptCloud.XLimits(1,1))/2)+reference_ptCloud.XLimits(1,1));
    % The center offset in y axis.
    y_diff = ((ptCloud.YLimits(1,2)-ptCloud.YLimits(1,1))/2)+ptCloud.YLimits(1,1)-...
        (((reference_ptCloud.YLimits(1,2)-reference_ptCloud.YLimits(1,1))/2)+reference_ptCloud.YLimits(1,1));
    % The center offset in z axis.
    z_diff = ((ptCloud.ZLimits(1,2)-ptCloud.ZLimits(1,1))/2)+ptCloud.ZLimits(1,1)-...
        (((reference_ptCloud.ZLimits(1,2)-reference_ptCloud.ZLimits(1,1))/2)+reference_ptCloud.ZLimits(1,1));
    % Perform the translation to the reference point cloud.
    t_trans = affine3d([1,0,0,0;0,1,0,0;0,0,1,0;x_diff,y_diff,z_diff,1]);
    reference_ptCloud = pctransform(reference_ptCloud,t_trans); 

    % Perform the icp algorithms to calculate the transformation from the
    % reference point cloud to the workpiece point cloud.
    [t_ICP,~,~] = pcregistericp(reference_ptCloud,ptCloud,'MaxIterations',...
        Constants.ICP_Parameters.ICP_Pos_iter,'metric','pointToPlane');

    % Convert the welding position into a pointcloud.
    welding_position = Referenzdatenbank.(workpieces{ObjectID}).WeldingPoints;
    welding_position = pointCloud(welding_position); 
    % perform rotation, scale transformation, translation, icp
    % transformation on the welding position.
    welding_position = pctransform(welding_position,t_rot);
    welding_position = pctransform(welding_position,t_resize); 
    welding_position = pctransform(welding_position,t_trans);
    welding_position = pctransform(welding_position,t_ICP);
    
    % Covert the point cloud to position array.
    weldingPos(:,1) = welding_position.Location(:,2);
    weldingPos(:,2) = welding_position.Location(:,1);
    weldingPos(:,3) = welding_position.Location(:,3);
    
    %------------- END OF CODE --------------
end