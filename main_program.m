function [pos_vector,velocityVector] = main_program()
    % main_program - the main function to activate the Intel® RealSense™
    % 	D435 camera for the use of "Dynamisierte Fertigungsketten". This 
    % 	program needs to be used with Intel® RealSense™ SDK 2.0 and its
    % 	MATLAB wrapper, which can be downloaded from:
    % 	https://github.com/IntelRealSense/librealsense
    % 
    % The original program was designed by Henrik Wilhelm Becker in his
    % bachelor thesis for a Microsoft Kinect v2 camera. This version of 
	% the program is reprogrammed by Chijiang Duan for Intel® RealSense™
	% D435 and its SDK v2.0.
    %
    % Syntax:  [output1,output2] = main_program()
    %
    % Outputs:
    %    output1 - Description
    %    output2 - Description
    %
    % Other m-files required: 	rgb2camCoor.m
	%							create_VideoFrame.m
	%							findBinMarkers.m 
	%							foregrndDetection.m 
	%							global_position.m 
	%							object_position.m
	%							calculate_ptCloud.m 
	%							next_frame.m 
	%							icp_Classification.m 
    % Subfunctions: none
    % MAT-files required: Constants_1.mat  Referenzdatenbank9_2.mat
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Feb 2019; Version 1.0.1
    %------------- BEGIN CODE --------------
    
    % Initialize the camera
    pipe = realsense.pipeline();
    config = realsense.config();
    config.enable_stream(realsense.stream.depth,...
		1280, 720, realsense.format.z16, 30)
    config.enable_stream(realsense.stream.color,...
		1920, 1080, realsense.format.rgb8, 30)
    
    % Initialize a pointcloud object to calculate the point cloud of target
    % workpiece.
    pointcloud = realsense.pointcloud();
    
    % Initialize a colorizer object for visualization of the depth image.
    colorizer = realsense.colorizer(2); % 2 - white to black.
    
    % align all images to the RGB image.
    align_to = realsense.stream.color;
    alignedFs = realsense.align(align_to);
    
    % Start the configuration.
    profile = pipe.start(config);
    
    % Set the depth sensor to dynamic.
    depth_sensor = profile.get_device().first('depth_sensor');
    depth_sensor.set_option(realsense.option.visual_preset, 0);
    
    % Creating a BlobAnalysis object for foreground detecting.
    blobAnalysis = vision.BlobAnalysis('MinimumBlobArea',32000,...
        'MaximumBlobArea',1000000);
    
    % Loading the necessary data.
    load('Constants_1','-mat'); % Constants and parameters
    load('Referenzdatenbank9_2','-mat'); % Reference databank
    
    % Initialize a video player object for video streaming and
    % visualization.
    videoPlayer = vision.VideoPlayer();
    
    % Time vector, necessary for the calculation of the direction vector 
    time_vector = zeros(Constants.PositionCount,1);
    
    % Position vector of the workpiece carrier at the times 
    % stored in the time_vector
    pos_vector = zeros(Constants.PositionCount,3);
    
    
    objectID = [];  % For object recognition
    weldingAverageArray = [];  % Vector of welding position
    
    % Counter to count the number of successful pallet position detectors. 
    % When the counter reaches its limit, the direction vector is sent to 
    % the last position of the pallet on the robot controller
    counter = 1;
    
    % Preprocessing of the streaming. During this part of the program,
    % several frames of the video streaming will be taken. With help of the
    % depth image, the foreground of the images will be located, which is
    % the ROI containing the target workpiece. Afterwards, a point cloud
    % of the workpiece will be calculated for object recognition. Finally,
    % the prestored welding position of the object will be converted to the
    % real position on the workpiece.
    
    % Start des Timers
    tic;
    for frame = 1 : Constants.NumOfFrames
        % Getting one frame from the camera.
        [depth, depth_img, color_img] = next_frame(pipe,...
            colorizer, alignedFs);
        
        % When the frames were created is cached, if the frame is used to 
        % position the workpiece carrier, the time in time_vector is 
        % overwritten.
        t = toc;
        
        % Foreground detector, which isolates the workpiece carrier from 
        % the background, outputs among other things the pixel area of the 
        % workpiece carrier.
        [img_w_obj,centroid,depth_uint8, bbox] = foregrndDetection(...
            depth_img,Constants.Background,blobAnalysis,color_img);
        
        % If the workpiece carrier can be isolated, the program sequence
        % will continue unless new frames are created and the program 
        % sequence starts from the beginning.
        if ~isempty(centroid)
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
                end
            end
            % Detecting the Binary markers.
            centersBright = findBinMarkers(bbox, color_img);
            % Make sure all binary markers have been detected. If not, 
            % the program starts again from the beginning.
            if size(centersBright,1) ==3
                [alpha,center_loc] = global_position(...
                    centersBright,color_img,depth,Constants);
                % Record the time into the time vector.
                time_vector(counter) = t;
                % Record the position into the position vector.
                pos_vector(counter,:) = center_loc;

                % Calculate the coordinate of the welding point.
                welding_pos = object_position(ptCloud,...
                    Referenzdatenbank,objectID,Constants);

                % Visulizing the result.
                videoFrame = create_VideoFrame(img_w_obj,welding_pos,Constants);
                videoPlayer(videoFrame);

                % The vector from the center location of the workpiece
                % pointing to the welding position.
                weldingVector = welding_pos-center_loc;

                % Calculation of the average moving direction of the
                % welding position.
                if counter == 1
                    weldingAverageArray = weldingVector;
                elseif counter > 1
                    weldingAverageArray = (weldingVector + weldingAverageArray) / 2;
                end
                
                % If the detection succeeded, add one to the counter.
                counter = counter + 1;
                
                % If enough correct positions recorded, break the for loop.
                if counter > Constants.PositionCount
                    finish_time = t;
                    center_location_finish = center_loc;
                    break
                end
                continue
            end
        end
        continue
    end
    
    % Direction vector calculation.
    velocityVector = velocity_calculate(pos_vector,time_vector,Constants);
    
    % Streaming the prediction of welding position.
    for idx = 1 : 250
       [~, ~, color_img] = next_frame(pipe,...
            colorizer, alignedFs);
        t = toc;
        prediticted_frame = get_PredictVidFrame...
            (color_img, velocityVector, weldingAverageArray, finish_time,...
            center_location_finish, t, Constants);
        videoPlayer(prediticted_frame)
    end
    
    % Release Devices
    pipe.stop();
    
    %------------- END OF CODE --------------
    % 
    %
    %
end