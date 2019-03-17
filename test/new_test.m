function [depth_ims, color_ims, time_vector, ptClouds, scales, bboxes, ims_w_obj] = new_test(background)
    cd 'C:\Users\chijiang\Desktop\Camera'
    pipe = realsense.pipeline();
    config = realsense.config();
    config.enable_stream(realsense.stream.depth,...
		1280, 720, realsense.format.z16, 30)
    config.enable_stream(realsense.stream.color,...
		1280, 720, realsense.format.rgb8, 30)
    
    blobAnalysis = vision.BlobAnalysis('MinimumBlobArea',30000,...
        'MaximumBlobArea',1000000);
    
    colorizer = realsense.colorizer(2);
    align_to = realsense.stream.color;
    alignedFs = realsense.align(align_to);
    pointcloud = realsense.pointcloud();
    
    profile = pipe.start(config);
    
    depth_sensor = profile.get_device().first('depth_sensor');
    depth_sensor.set_option(realsense.option.visual_preset, 5);
    
%     videoplayer = vision.VideoPlayer();
    
    load('Constants_1.mat')
    load('Referenzdatenbank9_2.mat')
    counter = 1;
    objectID = [];
    videoplayer = vision.VideoPlayer();
    
    % Vectors
    time_vector = zeros(Constants.PositionCount,1);
    pos_vector = zeros(Constants.PositionCount,3);
    welding_pos_last = [];  % Vector of welding position
    counter = 1;
    for i = 1:50000
       [~,color_img,~] = next_frame(pipe,...
            colorizer, alignedFs); 
       videoplayer(color_img)
    end
    pipe.stop()
    cd test
end