function ptCloud = get_PointCloud(depth, centroid, bbox, pointcloud)   
    if size(centroid, 1) == 1
        points = pointcloud.calculate(depth);
        vertices = points.get_vertices();
        ptCloud = pointCloud(vertices);
        bbox = double(bbox);
        scale1 = depth.get_distance(bbox(1), bbox(2));
        scale2 = depth.get_distance(bbox(1)+bbox(3), bbox(2) + bbox(4));
        u_l_corner = [(bbox(1) - 640) * scale1/(1280/(2 * tan(65/180*pi/2))), -(720 - bbox(2) - bbox(4) - 360) * scale1/(720/(2 * tan(38/180*pi/2)))];
        d_r_corner = [(bbox(1) + bbox(3) - 640) * scale2/(1280/(2 * tan(73.8/180*pi/2))), -(720 - bbox(2) - 360) * scale2/(1280/(2 * tan(57.5/180*pi/2)))];
%         xlim = ptCloud.XLimits;
%         ylim = ptCloud.YLimits;
%         picsize = size(crop_depth);
%         Xscale = (xlim(2) - xlim(1)) / picsize(2);
%         Yscale = (ylim(2) - ylim(1)) / picsize(1);
%         ROIcoor = [[bbox(1), bbox(1)+bbox(3)]*Xscale + xlim(1);...
%             [ylim(2)/Yscale - bbox(2) - bbox(4), ylim(2)/Yscale - bbox(2)]*Yscale ; -Inf, Inf];
% %         obj_dist = depth.get_distance(round(centroid(1)), round(centroid(2)));
% %         ROIcoor = [-Inf, Inf; -Inf, Inf; 0.95*obj_dist, 1.05*obj_dist];
        ROIcoor = [u_l_corner(1), d_r_corner(1); d_r_corner(2), u_l_corner(2); 0.8*scale1, 1.2*scale1];
        sampleIndices = findPointsInROI(ptCloud, ROIcoor);
        ptCloud = select(ptCloud,sampleIndices); 
        ptCloud = pcdenoise(ptCloud, 'Threshold',0.05);
    end
%     xyzpoints = double(cat(3,X_coor,Y_coor,Z_coor));
%     ptCloud = pointCloud(xyzpoints);
%     sampleIndices = findPointsInROI(ptCloud,Constants.ROI_XYZ); 
%     ptCloud = select(ptCloud,sampleIndices); 
    % ptCloud = pcdenoise(ptCloud,'NumNeighbors',30,'Threshold',0.25); 
    % T = affine3d([1,0,0,0;0,cos(pi),sin(pi),0;0,-sin(pi),cos(pi),0;0,0,ptCloud.ZLimits(1,1),1]);
    % ptCloud = pctransform(ptCloud,T);
   
end
