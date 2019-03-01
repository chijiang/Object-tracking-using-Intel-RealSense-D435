function centersBright = findBinMarkers(bbox_color, color_img)
    BinaryMatrix = [];
    centersBright = []; 
    radiiBright = [];
    
    FOI_width = bbox_color(1,3);
    FOI_height = bbox_color(1,4);
%     FOI(:,:,1) = crop_color(bbox_color(2):(bbox_color(2)+FOI_Size),bbox_color(1):(bbox_color(1)+FOI_Size));
%     FOI(:,:,2) = crop_color(bbox_color(2):(bbox_color(2)+FOI_Size),bbox_color(1)+bbox_color(3)-FOI_Size:(bbox_color(1)+bbox_color(3)));
%     FOI(:,:,3) = crop_color(bbox_color(2)+bbox_color(4)-FOI_Size:(bbox_color(2)+bbox_color(4)),bbox_color(1)+bbox_color(3)-FOI_Size:(bbox_color(1)+bbox_color(3)));
    FOI = imcrop(color_img, bbox_color);
    FOI_bin = imbinarize(rgb2gray(FOI),0.6);
    enhanced_FOI = edge(FOI_bin,'sobel');
    SE = strel('disk',1);
    bw = imdilate(enhanced_FOI, SE);
    [centers,radiis,~] = imfindcircles(bw,[8,10],...
        'ObjectPolarity','bright','Method','TwoStage', 'Sensitivity', 0.8);
    centers(:,1) = centers(:,1) + double(bbox_color(1,1));
    centers(:,2) = centers(:,2) + double(bbox_color(1,2));

%     for idx = 1 : 3
% %         FOI_bin = imbinarize(FOI(:,:,idx),0.6);
% %         enhanced_FOI = edge(FOI_bin,'sobel');
% %         SE = strel('disk',1);
% %         bw = imdilate(enhanced_FOI, SE);
% 
% %         [centers,radiis,~] = imfindcircles(bw,[Constants.DetectCircles.rmin,Constants.DetectCircles.rmax],...
% %             'ObjectPolarity','bright','Method','TwoStage');
% %         [centers,radiis,~] = imfindcircles(bw,[8,10],...
% %             'ObjectPolarity','bright','Method','TwoStage', 'Sensitivity', 0.8);
%         
% %         center = centers(1:1,:); 
% %         radii = radiis(1:1);
% 
%         if ~isempty(center)
%             if idx == 1
%                centersBright(1,1) = center(1,1) + double(bbox_color(1));
%                centersBright(1,2) = center(1,2) + double(bbox_color(2));
%                radiiBright(1) = radii;
%             elseif idx == 2
%                 centersBright(2,1) = center(1,1) + double(bbox_color(1)+bbox_color(3))-FOI_width;
%                 centersBright(2,2) = center(1,2) + double(bbox_color(2)); 
%                 radiiBright(2) = radii;
%             elseif idx == 3
%                 centersBright(3,1) = center(1,1) + double(bbox_color(1)+bbox_color(3))-FOI_width; 
%                 centersBright(3,2) = center(1,2) + double(bbox_color(2)+bbox_color(4))-FOI_height;
%                 radiiBright(3) = radii;
%             end
%         end
%     end
    centersBright = centers;
    % imshow(crop_color); 
    % viscircles(centersBright, radiis,'EdgeColor','b');
%     viscircles(centers, radiis)
end