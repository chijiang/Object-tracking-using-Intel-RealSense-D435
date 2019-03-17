function [alpha,center_loc] = global_position(centerBright,color_img,Constants)
    % global_position - Calculating the global position of the center point
    %       of the target workpiece.
    %
    % Syntax:  
	%	[Alpha,CenterLoc] = global_position(centersBright,crop_color,depth,Constants)
	%
	% Inputs:
    %	 centersBright - The center point positions of the markers in
    %       image.
	%	 color_img - The RGB image captured by the camera.
    %    depth - The realsense.depth_frame object.
    %    Constants - The structure contains all global variables for the
    %       program.
	%
    % Outputs:
    %    alpha - The angle between the workpiece frame and the camera frame.
    %    center_loc - The center location of the workpiece.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
    
    % Convert color image to gray scale.
    img = imbinarize(rgb2gray(color_img));
    for idx = 1 : 3 
        % Find the color of the upper, lower right, lower left corner of
        % the marker.
        upper = img(round(centerBright(idx,2)-25),round(centerBright(idx,1)));
        lower_right = img(round(centerBright(idx,2)+18),round((centerBright(idx,1)+18)),:);
        lower_left = img(round(centerBright(idx,2)+18),round((centerBright(idx,1)-18)),:);
        % Determin the correct position of marker.
        if upper == 1 && lower_right == 1 && lower_left == 1 
            p2 = zeros(1,2); 
            p2(1) = round(centerBright(idx,1)); 
            p2(2) = round(centerBright(idx,2)); 
        elseif upper == 0 && lower_right == 0 && lower_left == 0 
            p3 = zeros(1,2);
            p3(1) = round(centerBright(idx,1)); 
            p3(2) = round(centerBright(idx,2)); 
        else
            p1 = zeros(1,2); 
            p1(1) = round(centerBright(idx,1)); 
            p1(2) = round(centerBright(idx,2));
        end 
    end
    
    % Calculate the coordiante of the markers according to the camera
    % frame.
    coor_p1 = rgb2camCoor(p1(1),p1(2));
    coor_p2 = rgb2camCoor(p2(1),p2(2));
    coor_p3 = rgb2camCoor(p3(1),p3(2));
    
    % Calculate the coordinate of the center position of the workpiece
    % according to the camera frame.
    p2p3 = coor_p3 - coor_p2;
    p2p1 = coor_p1 - coor_p2;
    center_loc = coor_p2 + (p2p3 + p2p1)/2;
    
    % Calculate the angle between the workpiece frame and the camera frame.
    alpha = atan2d(norm(cross(p2p3,Constants.LinearAxisDirection)),...
        dot(p2p3,Constants.LinearAxisDirection));
end