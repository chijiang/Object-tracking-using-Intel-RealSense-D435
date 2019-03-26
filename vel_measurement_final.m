clc, clear, close all;

% AdsAssembly = NET.addAssembly('C:\TwinCAT\AdsApi\.NET\v2.0.50727\TwinCAT.Ads.dll');
% import TwinCAT.Ads.*
% 
% %% Create TcAdsClient instance
% tcClient = TcAdsClient;
% 
% %% Connect to ADS port 851 on the local machine
% tcClient.Connect(350);

% Necessary variables.
load('Constants_1.mat')
load('test/rs.mat')
% load('test/cimg_run_3.mat')
% load('test/cimg_run_5.mat')

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

blobAnalysis = vision.BlobAnalysis('MinimumBlobArea',30000,...
    'MaximumBlobArea',1000000);

profile = pipe.start(config);
depth_sensor = profile.get_device().first('depth_sensor');
depth_sensor.set_option(realsense.option.visual_preset, 1); 

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
% i = 1;
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
            velocity = (center_loc - last_loc) / (t - t_last);
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
            if (norm(acceleration) < 0.12) && (norm(velocity) > 0.1)
                no_acc = no_acc + 1;
                if no_acc > 2
                    break
                end
            else
                no_acc = 0;
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
%     i = i+1;
%     if i == 40
%         break
%     end
end
tic;
vel_norm = [];
for i = 1:size(vel_vec, 1)
    vel_norm(i) = norm(vel_vec(i,:));
end
v_m = mean(vel_norm(end-3:end));
trigger = false;
sim('start_process')
run_length = 0.624 - norm(last_loc - start_loc);

pause(run_length/v_m - toc)

trigger = true;
sim('start_process')

% tcClient.Dispose();