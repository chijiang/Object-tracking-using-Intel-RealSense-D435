function [errValue, objectID] = icp_Classification(ptCloud,Referenzdatenbank,Constants)
    % icp_Classification - Classification function
	% 	using the point cloud of workpiece and standard
	%	model with ICP algorithms.
    %
    % Syntax:  
	%	[errValue, objectID] = icp_Classification(ptCloud,Referenzdatenbank,Constants)
	%
	% Inputs:
    %	 ptCloud - Point cloud of the workpiece.
	%	 Referenzdatenbank - Data bank contains the 
	%			point clouds of the standard models.
	%	 Constants - Structure contains all variables
	%			for the program.
	%
    % Outputs:
    %    errValue - Root mean squared error, error of 
	%			the classification.
	%	 objectID - Classified ID of the workpiece.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
    
    % Get all IDs of workpieces from data bank.
	workpieces = fieldnames(Referenzdatenbank);
    
    % Initialize the error array.
    errValueArray = zeros(numel(workpieces),1);
    
    % For each standard models in data bank, its point cloud will be
    % rotated, resized, transtalted to match the camera taken point cloud
    % of the workpiece. Afterwards, the icp algorithms would be performed
    % to find the root mean squared error for each model.
    for idx = 1 :numel(workpieces)
        % Read the center position of the standard model.
        center = Referenzdatenbank.(workpieces{idx}).Center;
        % Assign the reference point cloud.
        reference_ptCloud = Referenzdatenbank.(workpieces{idx}).ptCloud;
        
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
        
        % Perform the icp algorithms to find the root mean squared error.
        [~,~,rmse] = pcregistericp(reference_ptCloud,ptCloud,'MaxIterations',...
        Constants.ICP_Parameters.ICP_Pos_iter,'metric','pointToPlane');
        errValueArray(idx) = rmse;
    end
    
    % Find the minimum value of the RMSEs and its corresponding ID.
    [errValue,objectID] = min(errValueArray);
	
	%------------- END OF CODE --------------
end