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
        reference_PtCloud = Referenzdatenbank.(workpieces{idx}).ptCloud;
        
        % Rotation matrix along x axis.
        rotx = [1, 0, 0, 0;...
                0, cos(pi), -sin(pi), 0; ...
                0, sin(pi), cos(pi), 0; ...
                0, 0, 0, 1];
        % Rotation matrix along z axis.
        rotz = [cos(-pi/2), -sin(-pi/2), 0, 0; ...
                sin(-pi/2), cos(-pi/2), 0, 0; ...
                0, 0, 1, 0; ...
                0, 0, 0, 1];
        % Total rotation.
        rotation = (rotx*rotz)';
        % Perform the rotation to the point cloud.
        t_trans = affine3d(rotation);
        ptCloud_resize = pctransform(ptCloud,t_trans); 
        
        % Scale transformation of x coordinates.
        x_size = (ptCloud_resize.XLimits(1,2) - ptCloud_resize.XLimits(1,1)) / ...
            (reference_PtCloud.XLimits(1,2) - reference_PtCloud.XLimits(1,1));
        % Scale transformation of y coordinates.
        y_size = (ptCloud_resize.YLimits(1,2) - ptCloud_resize.YLimits(1,1)) / ...
            (reference_PtCloud.YLimits(1,2) - reference_PtCloud.YLimits(1,1));
        % Scale transformation of z coordinates.
        z_size = (ptCloud_resize.ZLimits(1,2) - ptCloud_resize.ZLimits(1,1)) / ...
            (reference_PtCloud.ZLimits(1,2) - reference_PtCloud.ZLimits(1,1));
        % The scale transformation matrix.
        trans = [1/x_size,0,0,0;0,1/y_size,0,0;0,0,1/z_size,0;0,0,0,1];
        % Perform the scale transformation to the point cloud.
        t_trans = affine3d(trans);
        ptCloud_resize = pctransform(ptCloud_resize,t_trans); 
        
        % Find the offset of two centers in x axis.
        x_diff = ((ptCloud_resize.XLimits(1,2)-ptCloud_resize.XLimits(1,1))/2)+...
                ptCloud_resize.XLimits(1,1)-center(1,1);
        % Find the offset of two centers in y axis.
        y_diff = ((ptCloud_resize.YLimits(1,2)-ptCloud_resize.YLimits(1,1))/2)+...
                ptCloud_resize.YLimits(1,1)-center(1,2);
        % Find the offset of two centers in z axis.
        z_diff = ((ptCloud_resize.ZLimits(1,2)-ptCloud_resize.ZLimits(1,1))/2)+...
                ptCloud_resize.ZLimits(1,1)-center(1,3);
        % Perform the translation to the reference point cloud.
        t_trans = affine3d([1,0,0,0;0,1,0,0;0,0,1,0;x_diff,y_diff,z_diff,1]);
        reference_PtCloud = pctransform(reference_PtCloud,t_trans); 
        
        % Perform the icp algorithms to find the root mean squared error.
        [~,~,rmse] = pcregistericp(reference_PtCloud,ptCloud_resize,...
            'MaxIterations',Constants.ICP_Parameters.ICP_Classi_iter,...
            'metric','pointToPlane');
        errValueArray(idx) = rmse;
    end
    
    % Find the minimum value of the RMSEs and its corresponding ID.
    [errValue,objectID] = min(errValueArray);
	
	%------------- END OF CODE --------------
end