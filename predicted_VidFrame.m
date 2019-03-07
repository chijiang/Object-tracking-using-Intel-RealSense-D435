function prediction_VidFrame = predicted_VidFrame...
    (color_img,velocity_vector,weldingAverageArray,finish_time,center_location_finish,t)
	% predicted_VidFrame - Calculate the video frame that contains
	% 	the predicted welding positions marked.
    %
    % Syntax:  
	%	prediction_VidFrame = predicted_VidFrame...
    %		(color_img,velocity_vector,weldingAverageArray,finish_time,center_location_finish,t)
	%
	% Inputs:
    %	 color_img - The RGB image taken by the camera.
	%	 velocity_vector - The velocity vector by cakculation.
	%	 weldingAverageArray - The average vector from the center
	%	 	position to the welding points.
	%	 finish_time - The finish time of the welding position
	%		recorded.
	%	 center_location_finish - The center location of the workpiece
	%		at the finish time of recording.
	%
    % Outputs:
    %    predicted_VidFrame - A video frame, in which the predicted 
	%	 	position of the welding points are marked.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
	
	% Calculate the time difference.
    t_diff = t-finish_time;
	
	% Calculate the next welding positions.
    next_pos = (weldingAverageArray+center_location_finish) +...
			(velocity_vector*t_diff);
    
	% Converte the position to the camera coordinate.
	[pixel_x,pixel_y] = camCoor2RGB(next_pos);
    
	% Insert the welding position to the RGB image.
    prediction_VidFrame = insertShape(color_img,'circle',...
			[Pcx Pcy 10],'LineWidth',5,'color','red');
end