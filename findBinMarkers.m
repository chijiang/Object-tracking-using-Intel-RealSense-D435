function centersBright = findBinMarkers(bbox, color_img)
    % findBinMarkers - Finding the circle binary markers on the workpiece.
    %
    % Syntax:  
	%	centersBright = findBinMarkers(bbox, color_img)
	%
	% Inputs:
    %	 bbox - Boundary box of the ROI on the RGB image.
	%	 color_img - The RGB image captured by the camera.
	%
    % Outputs:
    %    centersBright - The centers of three binary markers.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
    
    % Crop the ROI out of the RGB image.
    roi = imcrop(color_img, bbox);
    % Convert the ROI image into a binary image.
    roi_bin = imbinarize(rgb2gray(roi));
    % Finding edge using sobel filter.
    enhanced_roi = edge(roi_bin,'sobel');
    % Dilate the image.
    se = strel('disk',1);
    bw = imdilate(enhanced_roi, se);
    % Finding the circles in image fits the radius of the markers.
    [centers,rad,~] = imfindcircles(bw,[8,9],...
        'ObjectPolarity','bright','Method','TwoStage', 'Sensitivity', 0.86);
    % Calculating the position of the marker center point in the whole
    % RGB image.
    centers(:,1) = centers(:,1) + double(bbox(1,1));
    centers(:,2) = centers(:,2) + double(bbox(1,2));
    centersBright = centers;
    
	%------------- END OF CODE --------------
end