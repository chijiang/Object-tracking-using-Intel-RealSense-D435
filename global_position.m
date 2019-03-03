function [alpha,center_loc] = global_position(centersBright,color_img,depth,Constants)
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
    %    alpha - The angle between the image frame and the global frame.
    %    center_loc - The center location of the workpiece.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
    
    color_img = rgb2gray(color_img);
    for idx = 1 : 3 
        upper = imbinarize(color_img(round(centersBright(idx,2)-19),round(centersBright(idx,1)),:));
        lower_right = imbinarize(color_img(round(centersBright(idx,2)+14),round((centersBright(idx,1)+14)),:));
        lower_left = imbinarize(color_img(round(centersBright(idx,2)+14),round((centersBright(idx,1)-14)),:));

        if upper == 1 && lower_right == 1 && lower_left == 1 
            p2 = zeros(1,2); 
            p2(1) = centersBright(idx,1); 
            p2(2) = centersBright(idx,2); 
        elseif upper == 0 && lower_right == 0 && lower_left == 0 
            p3 = zeros(1,2);
            p3(1) = centersBright(idx,1); 
            p3(2) = centersBright(idx,2); 
        else
            p1 = zeros(1,2); 
            p1(1) = centersBright(idx,1); 
            p1(2) = centersBright(idx,2);
        end 
    end

    coor_p1 = rgb2camCoor(depth,p1(2),p1(1));
    coor_p2 = rgb2camCoor(depth,p2(2),p2(1));
    coor_p3 = rgb2camCoor(depth,p3(2),p3(1));

    p2p3 = coor_p3 - coor_p2;
    p2p1 = coor_p1 - coor_p2;

    center_loc = [coor_p2 + (p2p3/2) + (p2p1/2)];
    alpha = atan2d(norm(cross(p2p3,Constants.LinearAxisDirection)),dot(p2p3,Constants.LinearAxisDirection));
end