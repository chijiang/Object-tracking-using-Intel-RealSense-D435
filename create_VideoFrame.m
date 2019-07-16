function img_w_obj = create_VideoFrame(img_w_obj,welding_pos)
    % create_VideoFrame - Create a video frame using RGB image with all
    %   information visualized.
    %
    % Syntax:  
	%	img_w_obj = create_VideoFrame(img_w_obj,welding_pos)
	%
	% Inputs:
    %	 img_w_obj - RGB image or RGB image with ROI highlighted.
	%	 welding_pos - The welding postions.
	%
    % Outputs:
    %    img_w_obj - Created frame.
    %------------- BEGIN CODE --------------
    % Draw all welding positions
    for idx = 1 : size(welding_pos,1)
        % Transform the welding positions to image coordinate.
        [pixel_x,pixel_y] = camCoor2RGB(welding_pos(idx,:));
        
        img_w_obj = insertShape(img_w_obj,'circle',[pixel_x, pixel_y, 6]...
            ,'LineWidth',3,'color','red');
    end
    %------------- END OF CODE --------------
end