function [output1,output2] = main_program()
    % main_program - the main function to activate the Intel� RealSense�
    % D435 camera for the use of "Dynamisierte Fertigungsketten". This 
    % program needs to be used with Intel� RealSense� SDK 2.0 and its
    % MATLAB wrapper, which can be downloaded from:
    % https://github.com/IntelRealSense/librealsense
    % 
    % The original program was designed by Henrik Wilhelm Becker in his
    % bachelor thesis for a Microsoft Kinect v2 camera.
    %
    % Syntax:  [output1,output2] = main_program()
    %
    % Outputs:
    %    output1 - Description
    %    output2 - Description
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Feb 2019;
    %------------- BEGIN CODE --------------
    
    % Initialize the camera
    pipe = realsense.pipeline();
    config = realsense.config();
    config.enable_stream(realsense.stream.depth, 1280, 720, realsense.format.z16, 30)
    config.enable_stream(realsense.stream.color, 1280, 720, realsense.format.rgb8, 30)
    
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
    BlobAnalysis = vision.BlobAnalysis('MinimumBlobArea',32000,...
        'MaximumBlobArea',100000);
    
    % Loading the necessary data.
    load('Constants_1','-mat'); % Constants and parameters
    load('Referenzdatenbank9_2','-mat'); % Reference databank
    
    % Initialize a video player object for video streaming and
    % visualization.
    videoPlayer = vision.VideoPlayer();
    
    % Time vector, necessary for the calculation of the direction vector 
    TimeArray = zeros(Constants.PositionCount,1);
    
    % Position vector of the workpiece carrier at the times 
    % stored in the TimeArray
    PosArray = zeros(Constants.PositionCount,3);
    
    
    ObjectID = [];  % For object recognition
    WeldingAverageArray = [];  % Vector of welding position
    
    % Counter to count the number of successful pallet position detectors. 
    % When the counter reaches its limit, the direction vector is sent to 
    % the last position of the pallet on the robot controller
    Counter = 1;
    
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
        [depth, depth_img, color_img] = getFrame_Realsense(pipe,...
            colorizer, alignedFs);
        
        % When the frames were created is cached, if the frame is used to 
        % position the workpiece carrier, the time in "TimeArray" is 
        % overwritten.
        T = toc;
        
        % Foreground detector, which isolates the workpiece carrier from 
        % the background, outputs among other things the pixel area of the 
        % workpiece carrier.
        [Ishape,centroid,depth_uint8, bbox] = foregrndDetection(...
            depth_img,Constants.background,BlobAnalysis,color_img);
        
        % If the workpiece carrier can be isolated, the program sequence
        % will continue unless new frames are created and the program 
        % sequence starts from the beginning.
        if ~isempty(centroid)
            % Creating the point cloud of the workpiece.
            ptCloud = get_PointCloud(depth, centroid, bbox, pointcloud);
            % The point cloud is for the workpiece recognization and 
            % classification. All data and standard point clouds of the
            % different types of the workpieces are stored in the reference
            % databank, which will be used for comparison with the ICP
            % algorithms.
            if isempty(ObjectID)
                [errValue, ObjectID] = ICP_Classification(...
                    ptCloud,Referenzdatenbank,Constants);
                % If the error is greater than a threshold, the
                % classification is not confident enough for the object
                % recognization.
                if errValue > Constants.ConfidenceInterval
                   ObjectID = [];
                   continue
                end
            end
            
            
        end
    end
    
    
    % Release Devices
    pipe.stop();
    
    %------------- END OF CODE --------------
    % 
    %
    %
end