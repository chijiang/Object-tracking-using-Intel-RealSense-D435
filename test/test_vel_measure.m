% Load data.
load('cimg_run_2.mat')
cd ..

% Necessary variables.
load('Constants_1.mat')

% Video player initialize.
videoplayer = vision.VideoPlayer();
% Last recorded center location.
last_loc = [];
% Recorded velocity.
vel_vec = [];

% Number of recorded velocities.
counter = 1;

% Start recording loop
i = 1;
tic;
while i < 20
    % Load image. Use next_frame() instead.
    color_img = pics.(genvarname(sprintf('cimg_%d', i)));
    % Time of frame capture.
    t = toc;
    try
        % Calculating center location.
        centerBright = findBinMarkers(color_img);
        [alpha,center_loc] = global_position(centerBright,color_img,Constants);
        
        % Drawing the binary markers.
        circles = centerBright; 
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
        end
    catch
        % Tell the failure of finding biary code.
        RGB = insertText(color_img,[10 10],'Binary code not detected',...
            'FontSize', 18);
    end
    videoplayer(RGB)
    i = i+1;
end