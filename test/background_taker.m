function [background, color_img] = background_taker()
    cd C:\Users\chijiang\Desktop\Camera
    pipe = realsense.pipeline();
    config = realsense.config();
    config.enable_stream(realsense.stream.depth, 1280, 720, realsense.format.z16, 30)
    config.enable_stream(realsense.stream.color, 1280, 720, realsense.format.rgb8, 30)
    
    colorizer = realsense.colorizer(2);
    align_to = realsense.stream.color;
    alignedFs = realsense.align(align_to);
    profile = pipe.start(config);
    
    depth_sensor = profile.get_device().first('depth_sensor');
    depth_sensor.set_option(realsense.option.visual_preset, 1);
    
    videoplayer = vision.VideoPlayer();
    videoplayer2 = vision.VideoPlayer();
    for i = 1:50
        [depth, depth_img, color_img] = next_frame(pipe,...
            colorizer, alignedFs);
%         crop_depth(crop_depth == 0) = 255;
%         bi_depth = rgb2gray(crop_depth) > 180;
        bi_depth = depth_image_binarize(depth_img, 200);
%         bi_depth = cast(bi_depth, 'uint8')*255;
%         bi_depth = bwareaopen(bi_depth,2000);
        videoplayer(depth_img)
        videoplayer2(color_img)
    end
    background = bi_depth;
    cd 'test'
end