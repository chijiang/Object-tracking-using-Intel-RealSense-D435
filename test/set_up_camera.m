function set_up_camera(background)
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
    
    videoplayer = vision.VideoPlayer();
    
    load('Constants_1.mat')
    load('Referenzdatenbank9_2.mat')
    counter = 0;
    objectID = [];
    tic;
    for i = 1:6000
        [depth, depth_img, color_img] = next_frame(pipe,...
            colorizer, alignedFs);
        
        [img_w_obj,centroid,~, bbox] = foregrndDetection(depth_img,background,blobAnalysis,color_img);
        if size(bbox, 1) == 1
            % Creating the point cloud of the workpiece.
            ptCloud = calculate_ptCloud(depth, centroid, bbox, pointcloud);
            % The point cloud is for the workpiece recognization and 
            % classification. All data and standard point clouds of the
            % different types of the workpieces are stored in the reference
            % databank, which will be used for comparison with the ICP
            % algorithms.
            if isempty(objectID) && ~isempty(ptCloud)
                [errValue, objectID] = icp_Classification(...
                    ptCloud,Referenzdatenbank,Constants);
                % If the error is greater than a threshold, the
                % classification is not confident enough for the object
                % recognization.
                if errValue > Constants.ConfidenceInterval
                   objectID = [];
                   continue
                else
                    sprintf('Detect obj: %d', objectID)
                end
            else
                continue
            end

            % Record the time into the time vector.
%             time_vector(counter) = t;
            % Record the position into the position vector.
%             pos_vector(counter,:) = center_loc;

            % Calculate the coordinate of the welding point.
            try
                welding_pos = object_position(ptCloud,...
                    Referenzdatenbank,objectID,Constants);
            catch
                videoplayer(color_img)
                continue
            end

            % Visulizing the result.
            videoFrame = create_VideoFrame(img_w_obj,welding_pos);
            videoplayer(videoFrame);

%             % The vector from the center location of the workpiece
%             % pointing to the welding position.
%             weldingVector = welding_pos-center_loc;
% 
%             % Calculation of the average moving direction of the
%             % welding position.
%             if counter == 1
%                 weldingAverageArray = weldingVector;
%             elseif counter > 1
%                 weldingAverageArray = (weldingVector + weldingAverageArray) / 2;
%             end

            % If the detection succeeded, add one to the counter.
            counter = counter + 1;
            t = toc;

            % If enough correct positions recorded, break the for loop.
            if counter > Constants.PositionCount
                finish_time = t;
%                 center_location_finish = center_loc;
                break
            end
            continue
        else
            videoplayer(color_img)
        end
%         if size(bbox,1) == 1
%             videoplayer(img_w_obj)
%         else
%             videoplayer(color_img)
%         end
    end
    pipe.stop()
    cd 'test'
end