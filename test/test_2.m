function [depth_ims, color_ims, time_vector, ptClouds, bboxes, ims_w_obj] = test_2()
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
    time_vector = zeros(TAKEN_IMG_NUM,1);
    pos_vector = zeros(TAKEN_IMG_NUM,3);
    welding_pos_last = [];  % Vector of welding position
    counter = 1;
    for i = 1:5
       [~,~,~] = next_frame(pipe,...
            colorizer, alignedFs); 
    end
    
    tic;
    for i = 1:TAKEN_IMG_NUM
        [depth, depth_img, color_img] = next_frame(pipe,...
            colorizer, alignedFs);
        videoplayer(color_img)
        t = toc;
        time_vector(counter) = t;
        [img_w_obj,~,~, bbox] = foregrndDetection(depth_img,background,blobAnalysis,color_img);
        points = pointcloud.calculate(depth);
        vertices = points.get_vertices();
        ptCloud = pointCloud(vertices);
%         if size(bbox, 1) == 1
%             bbox = double(bbox);
%             scale1 = depth.get_distance(bbox(1), bbox(2));
%             if scale1 == 0
%                scale1 = depth.get_distance(bbox(1)+bbox(3), bbox(2)); 
%             end
%             scale2 = depth.get_distance(bbox(1)+bbox(3),...
%                 bbox(2) + bbox(4));
%             if scale2 ==0
%                scale2 = depth.get_distance(bbox(1), bbox(2)+bbox(4)); 
%             end
%             if scale1 == 0
%                 scale1 = scale2;
%             end
%             if scale2 == 0
%                 scale2 = scale1;
%             end
%         else
%             scale1 = 0;
%             scale2 = 0;
%         end
        bboxes.(genvarname(sprintf('bbox_%d', counter))) = bbox;
%         scales.(genvarname(sprintf('scale1_%d', counter))) = scale1;
%         scales.(genvarname(sprintf('scale2_%d', counter))) = scale2;
        ptClouds.(genvarname(sprintf('ptCloud_%d', counter))) = ptCloud;
        color_ims.(genvarname(sprintf('color_img_%d', counter))) = color_img;
        ims_w_obj.(genvarname(sprintf('img_w_obj_%d', counter))) = img_w_obj;
        depth_ims.(genvarname(sprintf('depth_img_%d', counter))) = depth_img;
        counter = counter+1;
    end
    for i = 1:TAKEN_IMG_NUM
        bbox = double(bboxes.(genvarname(sprintf('bbox_%d', i))));
        if size(bbox,1) ~= 1
            break
        end
        ptCloud = ptClouds.(genvarname(sprintf('ptCloud_%d', i)));
        scale = 0.88;
        % Position of the upper left corner.
        u_l_corner = [(bbox(1) - 640) * scale/(1280/...
            (2 * tan(68/180*pi/2))), -(720 - bbox(2)...
                - bbox(4) - 360) * scale/(720/...
                    (2 * tan(39.5/180*pi/2)))];
        % Position of the lower right corner.
        l_r_corner = [(bbox(1) + bbox(3) - 640) * ...
            scale/(1280/(2 * tan(68/180*pi/2))),...
                -(720 - bbox(2) - 360) * scale/(1280/...
                    (2 * tan(51.5/180*pi/2)))];

        % The ROI in 3D.
        ROIcoor = [u_l_corner(1), l_r_corner(1); ...
        l_r_corner(2), u_l_corner(2); ...
        0.8, 0.86];
        % Crop the ROI point cloud out of the entire 
        % point cloud. 
        sampleIndices = findPointsInROI(ptCloud, ROIcoor);
        ptCloud = select(ptCloud,sampleIndices); 
        % Remove unnecessary points.
        ptCloud = pcdenoise(ptCloud, 'Threshold',0.01);
        figure()
%         pcshow(ptCloud)
        objectID = 9;
        weldingPos = object_position(ptCloud,Referenzdatenbank,objectID,Constants);
        imFrame = create_VideoFrame(ims_w_obj.(genvarname(sprintf('img_w_obj_%d', i))), weldingPos);
        imshow(imFrame)
        if i > 1
            velocity = (weldingPos - weldingPos_old)/(time_vector(i) - time_vector(i-1));
            disp(velocity);
            weldingPos_old = weldingPos;
        else
            weldingPos_old = weldingPos;
        end
    end
    pipe.stop()
    cd test
end