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
	%	 weldingAverageArray - The average vector shows the direction
	%	 	of the welding position change.
	%	 finish_time - The end coordinate of the welding position
	%		recorded.
	%
    % Outputs:
    %    errValue - Root mean squared error, error of 
	%			the classification.
	%	 objectID - Classified ID of the workpiece.
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
    t_diff = t-finish_time;
    next_pos = (weldingAverageArray+center_location_finish) + (velocity_vector*t_diff);
    [pixel_x,pixel_y] = camCoor2RGB(next_pos);
    
    prediction_VidFrame = insertShape(color_img,'circle',[Pcx Pcy 10],'LineWidth',5,'color','red');
end