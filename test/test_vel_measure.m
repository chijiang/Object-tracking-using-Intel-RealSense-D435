% Load data.
% load('cimg_run_2.mat')
load('rs.mat')
cd ..

% Necessary variables.
load('Constants_1.mat')
load('Referenzdatenbank9_2.mat')
%% Set the camera parameters.
pipe = realsense.pipeline();
config = realsense.config();
config.enable_stream(realsense.stream.depth,...
    1280, 720, realsense.format.z16, 30)
config.enable_stream(realsense.stream.color,...
    1280, 720, realsense.format.rgb8, 30)
colorizer = realsense.colorizer(2);
align_to = realsense.stream.color;
alignedFs = realsense.align(align_to);
pointcloud = realsense.pointcloud();

blobAnalysis = vision.BlobAnalysis('MinimumBlobArea',30000,...
    'MaximumBlobArea',1000000);

profile = pipe.start(config);
depth_sensor = profile.get_device().first('depth_sensor');
depth_sensor.set_option(realsense.option.visual_preset, 1); 

%%

% % Recognition of object.

while 1
    [depth, depth_img, color_img] = next_frame(pipe, colorizer, alignedFs);
    points = pointcloud.calculate(depth);
    vertices = points.get_vertices();
    ptCloud = pointCloud(vertices);
    [img_w_obj,~,~, bbox] = foregrndDetection(depth_img,background,blobAnalysis,color_img);

    % ptCloud = ptClouds.ptCloud_2;
    % bbox = bboxes.bbox_2;
    % color_img = pics.cimg_2;
    ptCloud = crop_ptCloud(ptCloud, bbox);
    [errValue, objectID] = icp_Classification(ptCloud,Referenzdatenbank,Constants);
    weldingPos = object_position(ptCloud,Referenzdatenbank,objectID);
    centerBright = findBinMarkers(color_img);
    if size(centerBright,1) == 3
        [alpha,center_loc] = global_position(centerBright,color_img,Constants);
    else
        continue
    end
    p3_loc = find_p3(color_img);
    welding_vector = weldingPos - center_loc;
    p3_center = center_loc - p3_loc;
    break
end
safty_height = ptCloud.ZLimits(2) - ptCloud.ZLimits(1);
sim('write_data')
%%
% Video player initialize.
videoplayer = vision.VideoPlayer();
% Last recorded center location.
last_loc = [];
% Recorded velocity.
vel_vec = [];
% Time vector.
% time_vec = zeros(1,20);
% Number of recorded velocities.
counter = 1;
errImg = 0;
% Start recording loop
i = 1;
% vwriter = VideoWriter('measurement.avi');
% open(vwriter)
tic;
for i = 1:40
%     % Load image. Use next_frame() instead.
%     [~, ~, color_img] = next_frame(pipe, colorizer, alignedFs);
%     % Time of frame capture.
%     t = toc;
%     pics.(genvarname(sprintf('cimg_%d', i))) = color_img;
%     time_vec(i) = t;
    color_img = pics.(genvarname(sprintf('cimg_%d', i)));
    t = time(i);
    try
        % Calculating center location.
        p3_loc = find_p3(color_img);
        center_loc = p3_loc + p3_center;
        p3_circle = draw_p3(color_img);
        
        % Drawing the binary markers.
        circles = p3_circle; 
        circles(:,3) = 8;
        RGB = insertShape(color_img,'circle', circles, 'LineWidth', 5, 'Color', 'g');
        
        % Insert center location text.
        RGB = insertText(RGB,[10 10],...
            sprintf('Center Location: \n%s', num2str(center_loc)),...
                'FontSize', 18);
        % Calculating the velocity.
        if ~isempty(last_loc)
            % Calculate the velocity if not the first location recorded.
            velocity = (center_loc - last_loc) / (t - t_last);
            % Assign current loction to the last.
            last_loc = center_loc;
            % Assign current time to the last
            t_last = t;
            % Insert the velocity text.
            RGB = insertText(RGB,[10 70],...
                sprintf('Velocity: \n%s', num2str(velocity)),...
                    'FontSize', 18);
            % Add calculated velocity to the list.
            vel_vec(counter, :) = velocity;
            counter = counter + 1;
        else
            % Assign the very first location and time point.
            last_loc = center_loc;
            t_last = t;
            start_loc = center_loc;
        end
        errImg = 0;
    catch
        % Tell the failure of finding biary code.
        RGB = insertText(color_img,[10 10],'Binary code not detected',...
            'FontSize', 18);
        errImg = errImg + 1;
        if errImg > 2
            break
        end
    end
    videoplayer(RGB)
%     writeVideo(vwriter,RGB);
    i = i+1;
%     if i == 20
%         i = 1;
%     end
end
tic;
vel_norm = [];
for i = 1:size(vel_vec, 1)
    vel_norm(i) = norm(vel_vec(i,:));
end
[v_m, idx] = max(vel_norm);

run_length = 0.624 - norm(last_loc - start_loc);
pause(run_length/v_m - toc)

sim('start_process')
cd test