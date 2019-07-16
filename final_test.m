clc; clear; close all;
% Load background.
load('test/rs.mat')

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

global viewangle_x viewangle_y
viewangle_x = 66.5;
viewangle_y = 45;

%% Recognition of object.

while 1
    [depth, depth_img, color_img] = next_frame(pipe, colorizer, alignedFs);
    points = pointcloud.calculate(depth);
    vertices = points.get_vertices();
    ptCloud = pointCloud(vertices);
    try
        [img_w_obj,~,~, bbox] = foregrndDetection(depth_img,background,blobAnalysis,color_img);
        if size(bbox, 1) ~= 1
            disp('Foreground detection error!!')
            continue
        end

        % ptCloud = ptClouds.ptCloud_4;
        % bbox = bboxes.bbox_4;
        % color_img = color_ims.color_img_4;
        ptCloud = crop_ptCloud(ptCloud, bbox);
        [errValue, objectID] = icp_Classification(ptCloud,Referenzdatenbank,Constants); % Change for camera rotation
        weldingPos = object_position(ptCloud,Referenzdatenbank,objectID); % Change for camera rotation
        if isempty(weldingPos)
            disp('Recognition error!!')
            continue
        end
        centerBright = findBinMarkers(color_img); % If camera rotated:  centerBright = findBinMarkers_r(color_img); // Need adjustment!
        if size(centerBright,1) == 3
            [alpha,center_loc] = global_position(centerBright,color_img,Constants);
        else
            disp('Binary markers detection error!!')
            continue
        end
        welding_vector = weldingPos - center_loc;
        break
    catch
        disp('More than 3 Binary markers detected!!')
        continue
    end
end
safty_height = (ptCloud.ZLimits(2) - ptCloud.ZLimits(1)) * 1000;
% welding_pos_sys = ([0, 1, 0; 1, 0, 0; 0, 0, -1] * welding_vector')' * 1000 + [-284, 196.5, 0];
welding_pos_sys = [-447.31, 106.52, 37, -291.67, 95.2, 36.5, -189.38, 85.31, 37];
for i = [1,4,7]
    welding_pos_sys(i) = welding_pos_sys(i) + 17;
end
array_length = numel(welding_pos_sys);
welding_pos_sys = reshape(welding_pos_sys', [1,array_length]);
transfer_array = zeros(1,30);
transfer_array(1:array_length) = welding_pos_sys;
transfer_array(array_length+1) = 11111;
sim('write_data_2018a')
imshow(create_VideoFrame(img_w_obj,weldingPos))
viscircles(centerBright, [7 7 7])

%% Velocity measurement

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
no_acc = 0;
% vwriter = VideoWriter('measurement.avi');
% open(vwriter)
tic;
while true
    % Load image. Use next_frame() instead.
    [~, ~, color_img] = next_frame(pipe, colorizer, alignedFs);
    % Time of frame capture.
    t = toc;
% %     pics.(genvarname(sprintf('cimg_%d', i))) = color_img;
% %     time_vec(i) = t;
%     color_img = pics.(genvarname(sprintf('cimg_%d', i)));
%     t = time_vec(i);
    try
        % Calculating center location.
        p3_loc = find_p3(color_img);
        center_loc = p3_loc + [0.1623, 0.2471, 0];
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
            velocity = norm(center_loc - last_loc) / (t - t_last);
            acceleration = (velocity - last_velocity) / (t - t_last);
            % Assign current loction to the last.
            last_loc = center_loc;
            last_velocity = velocity;
            % Assign current time to the last
            t_last = t;
            % Insert the velocity text.
            RGB = insertText(RGB,[10 70],...
                sprintf('Velocity: \n%s', num2str(velocity)),...
                    'FontSize', 18);
            % Add calculated velocity to the list.
            vel_vec(counter, :) = velocity;
            acc_vec(counter, :) = acceleration;
            counter = counter + 1;
            if (acceleration < 0.12) && (norm(velocity) > 0.05)
                no_acc = no_acc + 1;
                if no_acc > 4
                    break
                end
%             else
%                 no_acc = 0;
            end
        else
            % Assign the very first location and time point.
            last_loc = center_loc;
            t_last = t;
            start_loc = center_loc;
            last_velocity = 0;
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
end
tic;
vel_norm = [];
for i = 1:size(vel_vec, 1)
    vel_norm(i) = norm(vel_vec(i,:));
end
v_m = 0.5*median(vel_norm(end-4:end)) + 0.5*mean(vel_norm(end-4:end));
velo = v_m * 1000;
trigger = false;
sim('start_process_2018a')
run_length = 0.5135 - norm(last_loc - start_loc);

robot_acc = 4.6; % 10
% pause(run_length/v_m - toc - v_m/2/robot_acc - 0.001) % 0.001 Simulation time
pause(run_length/v_m - toc - v_m/2/robot_acc - 0.001)

trigger = true;
sim('start_process_2018a')

%% Draw the diagrams
figure
plot(vel_norm)
line([0, ceil(i/10)*10], [v_m, v_m], 'Color', 'red')
title('Velocity for each frame')
xlabel('frame number')
ylabel('velocity [m/s]')
grid minor
grid on
legend('velocity')

acc_norm = [];
for i = 1:size(vel_vec, 1)
    acc_norm(i) = norm(acc_vec(i,:));
end
figure
plot(acc_norm, 'r')
title('Acceleration for each frame')
xlabel('frame number')
ylabel('acceleration [m/s^2]')
grid minor
grid on
legend('Acceleration')
%% Stop camera
pipe.stop()