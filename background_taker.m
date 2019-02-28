function [background, crop_color] = background_taker()
    pipe = realsense.pipeline();
    config = realsense.config();
    config.enable_stream(realsense.stream.depth, 1280, 720, realsense.format.z16, 30)
    config.enable_stream(realsense.stream.color, 1280, 720, realsense.format.rgb8, 30)
    
    colorizer = realsense.colorizer(2);
    align_to = realsense.stream.color;
    alignedFs = realsense.align(align_to);
    profile = pipe.start(config);
    
    depth_sensor = profile.get_device().first('depth_sensor');
    depth_sensor.set_option(realsense.option.visual_preset, 0);
    
    videoplayer = vision.VideoPlayer();
    for i = 1:100
        [depth, crop_depth, crop_color, resize_color] = getFrame_Realsense(pipe, colorizer, alignedFs);
%         crop_depth(crop_depth == 0) = 255;
%         bi_depth = rgb2gray(crop_depth) > 180;
        bi_depth = TiefenbildBinarisierung(crop_depth, 220);
%         bi_depth = cast(bi_depth, 'uint8')*255;
%         bi_depth = bwareaopen(bi_depth,2000);
        videoplayer(bi_depth)
    end
    background = bi_depth;
end