function weldingPos = object_position(ptCloud,Rfdata,objectID)
    % object_position - Calculate the object position of the welding point.
    %
    % Syntax:  
	%	 weldingPos = object_position(ptCloud,Rfdata,objectID,Constants)
	%
	% Inputs:
    %    ptCloud - The taken point cloud of the workpiece.
    %    Referenzdatenbank - The reference data bank, which contains the
    %           point cloud of the standard models.
	%	 objectID - Integer, the recognized ID of the workpiece.
	%	 Constants - Constants with the glaobal constants for program.
	%
    % Outputs:
    %    weldingPos - The calculated welding position.
    %------------- BEGIN CODE --------------
    
    % Assign the standard point cloud to the reference point cloud.
    workpieces = fieldnames(Rfdata);
    reference_ptCloud = Rfdata.(workpieces{objectID}).ptCloud;

    % The rotation matrix along the z axis.
    rotz = [cos(-pi), -sin(-pi), 0, 0;...
            sin(-pi), cos(-pi), 0, 0;...
            0, 0, 1, 0;...
            0, 0, 0, 1];
    % Perform the rotation to the refernce point cloud.
    t_rot = affine3d(rotz);
    reference_ptCloud = pctransform(reference_ptCloud,t_rot); 

    % Scale transformation.
    reference_ptCloud = pcresize(reference_ptCloud, 0.001);

    % The center offset in x axis.
    x_diff = ((ptCloud.XLimits(1,2)-ptCloud.XLimits(1,1))/2)+...
        ptCloud.XLimits(1,1)-(((reference_ptCloud.XLimits(1,2)-...
        reference_ptCloud.XLimits(1,1))/2)+reference_ptCloud.XLimits(1,1));
    % The center offset in y axis.
    y_diff = ((ptCloud.YLimits(1,2)-ptCloud.YLimits(1,1))/2)+...
        ptCloud.YLimits(1,1)-(((reference_ptCloud.YLimits(1,2)-...
        reference_ptCloud.YLimits(1,1))/2)+reference_ptCloud.YLimits(1,1));
    % The center offset in z axis.
    z_diff = ((ptCloud.ZLimits(1,2)-ptCloud.ZLimits(1,1))/2)+...
        ptCloud.ZLimits(1,1)-(((reference_ptCloud.ZLimits(1,2)-...
        reference_ptCloud.ZLimits(1,1))/2)+reference_ptCloud.ZLimits(1,1));
    % Perform the translation to the reference point cloud.
	t_trans = affine3d([1,0,0,0;0,1,0,0;0,0,1,0;x_diff,y_diff,z_diff,1]);
    reference_ptCloud = pctransform(reference_ptCloud,t_trans);

    % Perform the icp algorithms to calculate the transformation from the
    % reference point cloud to the workpiece point cloud.
    [t_ICP,~,~] = pcregistericp(reference_ptCloud,pcdenoise(ptCloud,...
        'Threshold', 0.01),'MaxIterations',...
        100,'metric','pointToPlane');

    % Convert the welding position into a pointcloud.
    welding_position = Rfdata.(workpieces{objectID}).WeldingPoints;
    if isempty(welding_position)
        weldingPos = [];
    else
        welding_position = pointCloud(welding_position); 
        % perform rotation, scale transformation, translation, icp
        % transformation on the welding position.
        welding_position = pctransform(welding_position,t_rot);
        welding_position = pcresize(welding_position,0.001);
        welding_position = pctransform(welding_position,t_trans);
        welding_position = pctransform(welding_position,t_ICP);

        % Covert the point cloud to position array.
        weldingPos(:,1) = welding_position.Location(:,1);
        weldingPos(:,2) = welding_position.Location(:,2);
        weldingPos(:,3) = welding_position.Location(:,3);
    end
    %------------- END OF CODE --------------
end