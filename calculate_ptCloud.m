function ptCloud = calculate_ptCloud(depth, centroid, bbox, pointcloud)   
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
	
	% Initialize the point cloud.
	ptCloud = [];
	
	% Verify if the only ROI has been detected.
    if size(centroid, 1) == 1
        % Calculating of the points of the point cloud.
        points = pointcloud.calculate(depth);
        vertices = points.get_vertices();
        % Create the pointCloud object out of the points.
        ptCloud = pointCloud(vertices);

        % Calculation of Conversion the ROI boundary in 
        % pixel scale to the real world scale (meter).
        % The parameters are calibrated.
        bbox = double(bbox);
        scale1 = depth.get_distance(bbox(1), bbox(2));
        scale2 = depth.get_distance(bbox(1)+bbox(3),...
            bbox(2) + bbox(4));
        if scale1 == 0 || scale2 ==0
            ptCloud = [];
            return
        end
        % Position of the upper left corner.
        u_l_corner = [(bbox(1) - 640) * scale1/(1280/...
        (2 * tan(68/180*pi/2))), -(720 - bbox(2)...
        - bbox(4) - 360) * scale1/(720/...
            (2 * tan(39.5/180*pi/2)))];
        % Position of the lower right corner.
        l_r_corner = [(bbox(1) + bbox(3) - 640) * ...
        scale2/(1280/(2 * tan(68/180*pi/2))),...
        -(720 - bbox(2) - 360) * scale2/(1280/...
            (2 * tan(51.5/180*pi/2)))];

        % The ROI in 3D.
        ROIcoor = [u_l_corner(1), l_r_corner(1); ...
        l_r_corner(2), u_l_corner(2); ...
        0.8*scale1, 0.958*scale1];

        % Crop the ROI point cloud out of the entire 
        % point cloud. 
        sampleIndices = findPointsInROI(ptCloud, ROIcoor);
        ptCloud = select(ptCloud,sampleIndices); 
        % Remove unnecessary points.
        ptCloud = pcdenoise(ptCloud, 'Threshold',0.01);
    end
	%------------- END OF CODE --------------
end
