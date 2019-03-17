function p3_loc = find_p3(color_img)
    roi = imcrop(color_img, [500, 1, 100, 720]);
    % Convert the ROI image into a binary image.
    roi_bin = imbinarize(rgb2gray(roi));
    % Finding edge using sobel filter.
    enhanced_roi = edge(roi_bin,'sobel');
    % Dilate the image.
    se = strel('disk',1);
    bw = imdilate(enhanced_roi, se);
    % Finding the circles in image fits the radius of the markers.
    [centers,~,~] = imfindcircles(bw,[6,10],...
        'ObjectPolarity','bright','Method','TwoStage', 'Sensitivity', 0.7);
    % Calculating the position of the marker center point in the whole
    % RGB image.
    centers(:,1) = centers(:,1) + 500;
    centers(:,2) = centers(:,2);
    centerBright = centers;
    
    p3 = [];
    img = imbinarize(rgb2gray(color_img));
    for idx = 1 : size(centerBright, 1)
        % Find the color of the upper, lower right, lower left corner of
        % the marker.
        upper = img(round(centerBright(idx,2)-25),round(centerBright(idx,1)));
        lower_right = img(round(centerBright(idx,2)+18),round((centerBright(idx,1)+18)),:);
        lower_left = img(round(centerBright(idx,2)+18),round((centerBright(idx,1)-18)),:);
        % Determin the correct position of marker.
        if upper == 0 && lower_right == 0 && lower_left == 0
            if ~isempty(p3)
               p3_loc = [];
               return
            end
            p3 = zeros(1,2);
            p3(1) = round(centerBright(idx,1)); 
            p3(2) = round(centerBright(idx,2)); 
        end
    end
    p3_loc = rgb2camCoor(p3(1),p3(2));
end