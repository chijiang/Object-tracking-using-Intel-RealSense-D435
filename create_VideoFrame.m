function img_w_obj = create_VideoFrame(img_w_obj,welding_pos)
    for idx = 1 : size(welding_pos,1)
        [pixel_x,pixel_y] = camCoor2RGB(welding_pos(idx,:));
        img_w_obj = insertShape(img_w_obj,'circle',[pixel_x, pixel_y, 10]...
            ,'LineWidth',5,'color','green');
    end
end