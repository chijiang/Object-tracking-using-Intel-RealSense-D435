function [img_w_obj,centroid,depth_uint8, bbox] = foregrndDetection(depth_img,background,blobAnalysis,color_img)
	% foregrndDetection - detecte the foreground of captured frame
	% 	using the depth image.
    %
    % Syntax:  
	%		[img_w_obj,centroid,depth_uint8, bbox] = foregrndDetection(depth_img,background,blobAnalysis,color_img)
	%
	% Inputs:
    %    depth_img - Depth image, 3-channel (RGB).
    %    background - Depth image of the background, converted to
	%					binary image (data type: bool). 
	%	 blobAnalysis - vision.BlobAnalysis object.
	%	 color_img - RGB image, 3-channel.
	%
    % Outputs:
    %    img_w_obj - RGB image, in which foreground is marked.
    %    centroid - The center pixel location of the ROI or foreground.
	%    depth_uint8 - The depth image, which is converted to binary 
	%					image.
	%	 bbox - The boundary of the ROI, in pixel scale. 
	% 				[x_upperleft, y_upperleft, width, height]
    %
    % Subfunctions: TiefenbildBinarisierung
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
	
	% Image with target object marked out.
	img_w_obj = [];
	% Convert depth image into binary image with data type uint8.
	depth_uint8 = depth_image_binarize(depth_img, 220); 
	% Morphological opening, get rid of small size noices.
	depth_uint8 = bwareaopen(depth_uint8,200);
	
	% Extract foreground.
	foreground = depth_uint8 > background;
	% Get rid of "post-processed" noices.
	foreground = bwareaopen(foreground,10);
	% Close segments into one piece.
	se = strel('disk',10);
	foreground = imclose(foreground, se);
	
	% Apply blobAnalyse to foreground.
	[~,centroid,bbox] = step(blobAnalysis,foreground);
	
	% If the foreground has been detected, mark the region
	% out on the RGB image.
	if ~isempty(bbox)
		img_w_obj = insertShape(color_img,'rectangle',bbox,'Color',...
			'green','Linewidth',6); 
	end
	%------------- END OF CODE --------------
end 