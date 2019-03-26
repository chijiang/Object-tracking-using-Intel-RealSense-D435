function position_cam = rgb2camCoor(pixel_x,pixel_y)
    % rgb2camCoor - Conversion from the RGB image frame to the camera frame. 
    %
    % Syntax:  
	%		WorldCoord = rgb2camCoor(depth,Pcx,Pcy)
    %
	% Inputs:
    %    depth - realsense.depth_frame object.
    %    pixel_x - X position in image.
	%	 pixel_y - Y position in image.
	%
    % Outputs:
    %    position_cam - The coordinate along the camera frame.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
    
    % Calculate the distance from point to the camera.
    pixel_x = round(pixel_x);
    pixel_y = round(pixel_y);
    z = 0.9025;
    
    % Calculate the x and y according to the size of the picture, the
    % height z and the view angle of the camera.
    x = (pixel_x - 640) * z/(1280/(2 * tan(69.4/180*pi/2)));
    y = -(360 - pixel_y) * z/(720/(2 * tan(42.5/180*pi/2)));
    % Position in camera frame.
    position_cam = [x, y, z];
    
    %------------- END OF CODE --------------
end