function ptCloud = crop_ptCloud(ptCloud, bbox)   
    % calculate_ptCloud - Calculate the pointCloud of target
	% 	object by using the depth information.
    %
    % Syntax:  
	%		ptCloud = calculate_ptCloud(depth, centroid, bbox, pointcloud)
	%
	% Inputs:
    %    depth - The realsense.depth_frame object, carrying 
	%				depth information.
    %    centroid - The center location of the ROI in pixel 
	%				scale. 
	%	 bbox - Boundary of the ROI in pixel scale.
	%	 pointcloud - The realsense.pointcloud object, which
	%				contains method to calculate the point 
	%				cloud with realsense.depth_frame object.
	%
    % Outputs:
    %    ptCloud - realsense.pointCloud object, inheritance
	%	 			class of matlab pointCloud class.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
	%------------- BEGIN CODE --------------
    
    % Calculation of Conversion the ROI boundary in 
    % pixel scale to the real world scale (meter).
    % The parameters are calibrated.
    bbox = double(bbox);
    % Position of the upper left corner.
    u_l_corner = [(bbox(1) - 640) * 0.89/(1280/...
    (2 * tan(80/180*pi/2))), -(720 - bbox(2)...
    - bbox(4) - 360) * 0.89/(720/...
        (2 * tan(70/180*pi/2)))];
    % Position of the lower right corner.
    l_r_corner = [(bbox(1) + bbox(3) - 640) * ...
    0.89/(1280/(2 * tan(70/180*pi/2))),...
    -(720 - bbox(2) - 360) * 0.89/(1280/...
        (2 * tan(70/180*pi/2)))];

    % The ROI in 3D.
    ROIcoor = [u_l_corner(1), l_r_corner(1); ...
    l_r_corner(2), u_l_corner(2); ...
    0.7, 0.89];

    % Crop the ROI point cloud out of the entire 
    % point cloud. 
    sampleIndices = findPointsInROI(ptCloud, ROIcoor);
    ptCloud = select(ptCloud,sampleIndices); 
    % Remove unnecessary points.
    ptCloud = pcdenoise(ptCloud, 'Threshold',0.1);
	%------------- END OF CODE --------------
end