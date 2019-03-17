function [pics, time_vector] = test_3()
    TAKEN_IMG_NUM = 20;
    
    load('rs.mat')
    cd 'C:\Users\chijiang\Desktop\Camera'
    pipe = realsense.pipeline();
    config = realsense.config();
    config.enable_stream(realsense.stream.depth,...
		1280, 720, realsense.format.z16, 30)
    config.enable_stream(realsense.stream.color,...
		1280, 720, realsense.format.rgb8, 30)
    
    blobAnalysis = vision.BlobAnalysis('MinimumBlobArea',30000,...
        'MaximumBlobArea',1000000);
    load('Constants_1.mat')
    load('Referenzdatenbank9_2.mat')
    colorizer = realsense.colorizer(2);
    align_to = realsense.stream.color;
    alignedFs = realsense.align(align_to);
    pointcloud = realsense.pointcloud();
    videoplayer = vision.VideoPlayer();
    
    profile = pipe.start(config);
    
    depth_sensor = profile.get_device().first('depth_sensor');
    depth_sensor.set_option(realsense.option.visual_preset, 1); 
    % 0 and 1 no much difference.
    % 2 doesn't work at all.
    % 3 works fine, but pc not preety.
    % 4 is for long focus length.
    % 5 not very accurate.
    
%     videoplayer = vision.VideoPlayer();
    
    load('Constants_1.mat')
    load('Referenzdatenbank9_2.mat')
    counter = 1;
    objectID = [];
    
    % Vectors
    center_loc = zeros(TAKEN_IMG_NUM,3);
    time_vector = zeros(TAKEN_IMG_NUM,1);
    pos_vector = zeros(TAKEN_IMG_NUM,3);
    welding_pos_last = [];  % Vector of welding position
    counter = 1;
    tic;
    for i = 1:TAKEN_IMG_NUM
       [~,~,color_img] = next_frame(pipe,...
            colorizer, alignedFs); 
        time_vector(counter) = toc;
        videoplayer(color_img)
        pics.(genvarname(sprintf('cimg_%d', i))) = color_img;
%         try
%             centerBright = findBinMarkers(color_img);
%         catch
%             continue
%         end
%         if size(centerBright, 1) == 3
%             try
%                 [~, plat_center] = global_position(centerBright, color_img, Constants);
%             catch
%                 continue
%             end
%         end
%         center_loc(counter, :) = plat_center;
        counter = counter+1;
%         if counter > TAKEN_IMG_NUM
%             break
%         end
        pause(0.2)
    end
    
    pipe.stop()
    cd test
end