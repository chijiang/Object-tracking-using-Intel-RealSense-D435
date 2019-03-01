function [depth, depth_img, color_img] = getFrame_Realsense(pipe, colorizer, alignedFs)
    % getFrame_Realsense - the main function to capture one frame from 
	% 	the Intel® RealSense™ D435 camera. 
    %
    % Syntax:  
	%		[depth, depth_img, color_img] = getFrame_Realsense(pipe, colorizer, alignedFs)
    %
	% Inputs:
    %    pipe - realsense.pipeline object, needs to be initialized 
	%				and started.
    %    colorizer - realsense.colorizer object.
	%	 alignedFs - realsense.align object.
	%
    % Outputs:
    %    depth - realsense.depth_frame object, which can be used to 
	%				calculate point cloud
    %    depth_img - depth image, three-channel (RGB).
	%    color_img - RGB image captured by camera, three-channel (RGB).
    %
    % Subfunctions: none
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
	
	% Getting the next frames from camera.
	fs = pipe.wait_for_frames();
	
	% Align the images to the set alignment option.
    fs = alignedFs.process(fs);
	
	% Getting the depth frame and colorizing for visualization.
    depth = fs.get_depth_frame();
    depth_c = colorizer.colorize(depth);
	
	% Getting the RGB frame.
    color = fs.get_color_frame();
	
	% Getting the images from both frames.
    data = depth_c.get_data();
    depth_img = permute(reshape(data',[3,depth_c.get_width(),depth_c.get_height()]),[3 2 1]);
    data = color.get_data();
    color_img = permute(reshape(data',[3,color.get_width(),color.get_height()]),[3 2 1]);
	
	%------------- END OF CODE --------------
end