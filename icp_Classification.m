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
	workpieces = fieldnames(Referenzdatenbank);
    errValueArray = zeros(numel(workpieces),1);

    for idx = 1 :numel(workpieces)
        center = Referenzdatenbank.(workpieces{idx}).Center;
        reference_PtCloud = Referenzdatenbank.(workpieces{idx}).ptCloud;

        rotx = [1, 0, 0, 0; 0, cos(pi), -sin(pi), 0; 0, sin(pi), cos(pi), 0; 0, 0, 0, 1];
        rotz = [cos(-pi/2), -sin(-pi/2), 0, 0; sin(-pi/2), cos(-pi/2), 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
        rotation = (rotx*rotz)';
        t_trans = affine3d(rotation);
        ptCloud_resize = pctransform(ptCloud,t_trans); 
        
        x_size = (ptCloud_resize.XLimits(1,2) - ptCloud_resize.XLimits(1,1)) / ...
            (reference_PtCloud.XLimits(1,2) - reference_PtCloud.XLimits(1,1));
        y_size = (ptCloud_resize.YLimits(1,2) - ptCloud_resize.YLimits(1,1)) / ...
            (reference_PtCloud.YLimits(1,2) - reference_PtCloud.YLimits(1,1));
        z_size = (ptCloud_resize.ZLimits(1,2) - ptCloud_resize.ZLimits(1,1)) / ...
            (reference_PtCloud.ZLimits(1,2) - reference_PtCloud.ZLimits(1,1));
        
        trans = [1/x_size,0,0,0;0,1/y_size,0,0;0,0,1/z_size,0;0,0,0,1];
        t_trans = affine3d(trans);
        ptCloud_resize = pctransform(ptCloud_resize,t_trans); 

        x_diff = ((ptCloud_resize.XLimits(1,2)-ptCloud_resize.XLimits(1,1))/2)+...
                ptCloud_resize.XLimits(1,1)-center(1,1);
        y_diff = ((ptCloud_resize.YLimits(1,2)-ptCloud_resize.YLimits(1,1))/2)+...
                ptCloud_resize.YLimits(1,1)-center(1,2);
        z_diff = ((ptCloud_resize.ZLimits(1,2)-ptCloud_resize.ZLimits(1,1))/2)+...
                ptCloud_resize.ZLimits(1,1)-center(1,3);
        t_trans = affine3d([1,0,0,0;0,1,0,0;0,0,1,0;x_diff,y_diff,z_diff,1]);
        reference_PtCloud = pctransform(reference_PtCloud,t_trans); 

        [~,pc_ICP,rmse] = pcregistericp(reference_PtCloud,ptCloud_resize,'MaxIterations',Constants.ICP_Parameters.ICP_Classi_iter,...
            'metric','pointToPlane');
        errValueArray(idx) = rmse;
%         figure();
%         pcshow(reference_PtCloud); hold on; pcshow(ptCloud_resize);hold off;
    end 
    [errValue,objectID] = min(errValueArray);
	
	%------------- END OF CODE --------------
end