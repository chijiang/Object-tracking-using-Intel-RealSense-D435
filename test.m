function ptCloud = test(background)
    pipe = realsense.pipeline();
    config = realsense.config();
    config.enable_stream(realsense.stream.depth, 1280, 720, realsense.format.z16, 30)
    config.enable_stream(realsense.stream.color, 1280, 720, realsense.format.rgb8, 30)

    pointcloud = realsense.pointcloud();
    colorizer = realsense.colorizer(2);
    align_to = realsense.stream.color;
    alignedFs = realsense.align(align_to);

    profile = pipe.start(config);

    depth_sensor = profile.get_device().first('depth_sensor');
    depth_sensor.set_option(realsense.option.visual_preset, 0)

    BlobAnalysis = vision.BlobAnalysis('MinimumBlobArea',32000, 'MaximumBlobArea',100000);

    for frame = 1 : 10
        [depth, crop_depth,crop_color,~] = getFrame_Realsense(...
            pipe,colorizer, alignedFs);
    end
    [Ishape,centroid,~, bbox] = my_ObjectDetection(crop_depth,background,BlobAnalysis,crop_color);
    ptCloud = get_PointCloud(depth, crop_depth, centroid, bbox, pointcloud);
    pcshow(ptCloud)
    pipe.stop()
end