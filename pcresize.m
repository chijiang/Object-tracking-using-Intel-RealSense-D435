function resized_ptCloud = pcresize(ptCloud, factor)
    points = ptCloud.Location;
    resize_mtrx = [factor, 0, 0; 0, factor, 0; 0, 0, factor];
    points = (resize_mtrx * points')';
    resized_ptCloud = pointCloud(points);
end