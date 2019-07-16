function [errValue, objectID] = icp_Classification(ptCloud,Rfdata,Constants)
    % icp_Classification - Classification function
	% 	using the point cloud of workpiece and standard
	%	model with ICP algorithms.
    %
    % Syntax:  
	%	[errValue, objectID] = icp_Classification(ptCloud,...
    %                                        Referenzdatenbank,Constants)
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
	workpieces = fieldnames(Rfdata);
    
    % Initialize the error array.
    errValueArray = zeros(numel(workpieces),1);
    
    % For each standard models in data bank, its point cloud will be
    % rotated, resized, transtalted to match the camera taken point cloud
    % of the workpiece. Afterwards, the icp algorithms would be performed
    % to find the root mean squared error for each model.
    for idx = 1 :numel(workpieces)
        % Read the center position of the standard model.
        center = Rfdata.(workpieces{idx}).Center;
        % Assign the reference point cloud.
        reference_ptCloud = Rfdata.(workpieces{idx}).ptCloud;
        
        % The rotation matrix along the z axis.
        rotz = [cos(-pi), -sin(-pi), 0, 0;...
                sin(-pi), cos(-pi), 0, 0;...
                0, 0, 1, 0;...
                0, 0, 0, 1];
        % Perform the rotation to the refernce point cloud.
        t_rot = affine3d(rotz);
        reference_ptCloud = pctransform(reference_ptCloud,t_rot); 

        % Scale transformation of x coordinates.
        reference_ptCloud = pcresize(reference_ptCloud, 0.001); 

        % The center offset in x axis.
        x_diff = ((ptCloud.XLimits(1,2)-ptCloud.XLimits(1,1))/2)+...
            ptCloud.XLimits(1,1)-(((reference_ptCloud.XLimits(1,2)-...
            reference_ptCloud.XLimits(1,1))/2)...
            +reference_ptCloud.XLimits(1,1));
        % The center offset in y axis.
        y_diff = ((ptCloud.YLimits(1,2)-ptCloud.YLimits(1,1))/2)+...
            ptCloud.YLimits(1,1)-(((reference_ptCloud.YLimits(1,2)-...
            reference_ptCloud.YLimits(1,1))/2)...
            +reference_ptCloud.YLimits(1,1));
        % The center offset in z axis.
        z_diff = ((ptCloud.ZLimits(1,2)-ptCloud.ZLimits(1,1))/2)+...
            ptCloud.ZLimits(1,1)-(((reference_ptCloud.ZLimits(1,2)-...
            reference_ptCloud.ZLimits(1,1))/2)...
            +reference_ptCloud.ZLimits(1,1));
        % Perform the translation to the reference point cloud.
        t_trans = affine3d([1,0,0,0;0,1,0,0;0,0,1,0;x_diff,y_diff,z_diff,1]);
        reference_ptCloud = pctransform(reference_ptCloud,t_trans);
        
        % Perform the icp algorithms to find the root mean squared error.
        try
            [~,npc,rmse] = pcregistericp(reference_ptCloud,ptCloud,...
                'MaxIterations',Constants.ICP_Parameters.ICP_Pos_iter,...
                'metric','pointToPlane');
        catch
            rmse = 1000;
        end
        errValueArray(idx) = rmse;
    end
    
    % Find the minimum value of the RMSEs and its corresponding ID.
    [errValue,objectID] = min(errValueArray);
	
	%------------- END OF CODE --------------
end