function [pixel_x,pixel_y] = camCoor2RGB(welding_pos)
    % camCoor2RGB - Conversion from the camera frame to the RGB image
    %       frame. 
    %
    % Syntax:  
	%		[pixel_x,pixel_y] = camCoor2RGB(welding_pos)
    %
	% Inputs:
    %    welding_pos - Array with 3 elements, x, y, z coordinate of a
    %       single welding position.
	%
    % Outputs:
    %    pixel_x - The horizontal pixel count of the welding position.
    %    pixel_y - The vertical pixel count of the welding position.
    %------------- BEGIN CODE --------------
    global viewangle_x viewangle_y
    % Extract the coordinates of the welding postion.
    x = welding_pos(1);
    y = welding_pos(2);
    z = welding_pos(3);
    
    % Calculate the pixel count in horizontal and vertical direction in RGB
    % image of the welding position.
    pixel_x = x * (1280/(2 * tan(viewangle_x/180*pi/2))) / z + 640;
    pixel_y = y * (720/(2 * tan(viewangle_y/180*pi/2))) / z + 360;
    
    %------------- END OF CODE --------------
end 