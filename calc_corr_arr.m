function corr_pos_arr = calc_corr_arr(trans_array, vel)
    % calc_corr_arr - Calculate the corrected array for the array of
    %   welding positions.
    %
    % Syntax:  
	%	corr_pos_arr = calc_corr_arr(trans_array, vel)
	%
	% Inputs:
    %	trans_array = The array of welding positions.
    %   vel = Velocity of the workpiece.
	%
    % Outputs:
    %    corr_pos_arr - Array of corrected positions.
    %------------- BEGIN CODE --------------
    % Load the trained neural network.
    load('nn_model.mat')
    
    corr_pos_arr = zeros(size(trans_array));
    for i = 1:10
        % Find meaningful elements in array to form up features to feed the
        % neural network.
        x = trans_array(3*i-2);
        y = trans_array(3*i-1);
        z = trans_array(3*i);
        if x == 11111
            corr_pos_arr(3*i-2) = 11111;
            break
        end
        features = [x, y, z, vel];
        % Make prediction.
        predicted_error = err_pred(model, features);
        % Compensate the errors to the positions.
        corr_x = x + predicted_error(1);
        corr_y = y + predicted_error(2);
        corr_pos_arr(3*i-2) = corr_x;
        corr_pos_arr(3*i-1) = corr_y;
        corr_pos_arr(3*i) = z;
    end
end
%%  Subfunction to calculate the prected error.
function predicted_error = err_pred(model, features)
    % Reshape the features to fit the ANN model.
    features = reshape(features, [1,1,numel(features)]);
    error = predict(model,features);
    predicted_error = reshape(error, [1, numel(error)]);
end
%------------- END OF CODE --------------