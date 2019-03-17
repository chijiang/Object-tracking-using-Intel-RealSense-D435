function p3_circle = draw_p3(color_img)
    % roi = imcrop(color_img, [500, 1, 420, 720]);
    roi = imcrop(color_img, [500, 1, 100, 720]);
    % Convert the ROI image into a binary image.
    roi_bin = imbinarize(rgb2gray(roi));
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
    centers(:,1) = centers(:,1) + 500;
    centers(:,2) = centers(:,2);
    p3_circle = centers;
end