function depth_uint8 = depth_image_binarize(depth_img, threshold)
    % depth_image_binarize - Convert a depth image into
	% 	a binary image with data type uint8.
    %
    % Syntax:  
	%		depth_uint8 = depth_image_binarize(depth_img, threshold)
	%
	% Inputs:
    %    depth_img - Depth image, 3-channel (RGB).
    %    threshold - Integer between 0 - 255.
	%
    % Outputs:
    %    depth_uint8 - Binarized depth image in data type uint8.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
	depth_uint8 = rgb2gray(crop_depth);
    depth_uint8 = depth_uint8 > threshold;
	depth_uint8 = cast(depth_img, 'uint8')
	%------------- END OF CODE --------------
end 