function p3_circle = draw_p3(color_img)
    % draw_p3 - Draw p3 mark on the RGB image.
    %
    % Syntax:  
	%	p3_circle = draw_p3(color_img)
	%
	% Inputs:
    %	 color_img - RGB image.
	%
    % Outputs:
    %    p3_circle - RGB image with p3 highlighted.
    %------------- BEGIN CODE --------------
    p3_circle = [];
    roi = imcrop(color_img, [480, 1, 80, 720]);
    % Convert the ROI image into a binary image.
    roi_bin = imbinarize(rgb2gray(roi));
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
    if size(centers,1) > 0
        centers(:,1) = centers(:,1) + 480;
        centers(:,2) = centers(:,2);
        p3_circle = centers;
    end
    
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
        'ObjectPolarity','bright','Method','TwoStage', 'Sensitivity', 0.7);
    % Calculating the position of the marker center point in the whole
    % RGB image.
    centers(:,1) = centers(:,1) + shift;
    centers(:,2) = centers(:,2);
    p3_circle = [p3_circle;centers];
    %------------- END OF CODE --------------
end