function centerBright = findBinMarkers(color_img)
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
    %------------- BEGIN CODE --------------
    
    % Crop the ROI out of the RGB image.
    shift = 480; %500, 100
    roi = imcrop(color_img, [shift, 1, 80, 720]);

    % Convert the ROI image into a binary image.
    roi_bin = imbinarize(rgb2gray(roi));
    % Finding edge using sobel filter.
    enhanced_roi = edge(roi_bin,'sobel');
    % Dilate the image.
    se = strel('disk',1);
    bw = imdilate(enhanced_roi, se);
    % Finding the circles in image fits the radius of the markers.
    [centers,rad,~] = imfindcircles(bw,[6,10],...
        'ObjectPolarity','bright','Method','TwoStage', 'Sensitivity', 0.66);
    % Calculating the position of the marker center point in the whole
    % RGB image.
    centers(:,1) = centers(:,1) + shift;
    centers(:,2) = centers(:,2);
    centerBright = centers;
    
    shift = 790; % 810
    roi = imcrop(color_img, [shift, 1, 80, 720]);
    % Convert the ROI image into a binary image.
    roi_bin = imbinarize(rgb2gray(roi), 0.4);
    % Finding edge using sobel filter.
    enhanced_roi = edge(roi_bin,'sobel');
    % Dilate the image.
    se = strel('disk',1);
    bw = imdilate(enhanced_roi, se);
    % Finding the circles in image fits the radius of the markers.
    [centers,rad,~] = imfindcircles(bw,[6,10],...
        'ObjectPolarity','bright','Method','TwoStage', 'Sensitivity', 0.6);
    % Calculating the position of the marker center point in the whole
    % RGB image.
    centers(:,1) = centers(:,1) + shift;
    centers(:,2) = centers(:,2);
    centerBright = [centerBright;centers];
    
	%------------- END OF CODE --------------
end