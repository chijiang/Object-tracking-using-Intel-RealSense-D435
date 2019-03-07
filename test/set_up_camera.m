function set_up_camera()
	cd ..
    pipe = realsense.pipeline();
    config = realsense.config();
    config.enable_stream(realsense.stream.depth,...
		1280, 720, realsense.format.z16, 30)
    config.enable_stream(realsense.stream.color,...
		1280, 720, realsense.format.rgb8, 30)
    
    blobAnalysis = vision.BlobAnalysis('MinimumBlobArea',32000,...
        'MaximumBlobArea',1000000);
    
    colorizer = realsense.colorizer(2);
    align_to = realsense.stream.color;
    alignedFs = realsense.align(align_to);
    
    profile = pipe.start(config);
    
    depth_sensor = profile.get_device().first('depth_sensor');
    depth_sensor.set_option(realsense.option.visual_preset, 5);
    
    play_color = vision.VideoPlayer();
    play_depth = vision.VideoPlayer();
    play_foreground = vision.VideoPlayer();
    play_obj = vision.VideoPlayer();
    
    load('Constants_1.mat')
    
    for i = 1:6000
        [~, depth_img, color_img] = next_frame(pipe,...
            colorizer, alignedFs);
%         play_color(color_img)
%         play_depth(depth_img)
        play_foreground(depth_image_binarize(depth_img, 200))
%         [img_w_obj,centroid,depth_uint8, bbox] = foregrndDetection(...
%             depth_img,Constants.Background,blobAnalysis,color_img);
%         if ~isempty(img_w_obj)
%             play_obj(img_w_obj)
%         else
%             play_obj(color_img)
%         end
    end
    pipe.stop()
end