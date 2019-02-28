function [depth, depth_img, color_img] = getFrame_Realsense(pipe, colorizer, alignedFs)
    fs = pipe.wait_for_frames();
    fs = alignedFs.process(fs);
%     depth_o = fs.get_depth_frame();
%     depth = colorizer.colorize(depth_o);
%     color = fs.get_color_frame();
%     
%     data = depth.get_data();
%     depth_img = permute(reshape(data',[3,depth.get_width(),depth.get_height()]),[3 2 1]);
%     crop_depth = imcrop(depth_img, [160, 115, 902, 488]);
%     
%     data = color.get_data();
%     crop_color = permute(reshape(data',[3,color.get_width(),color.get_height()]),[3 2 1]);
%     
%     resize_color = imresize(crop_color,[489,561]); 
    depth = fs.get_depth_frame();
    depth_c = colorizer.colorize(depth);
    color = fs.get_color_frame();
    data = depth_c.get_data();
    depth_img = permute(reshape(data',[3,depth_c.get_width(),depth_c.get_height()]),[3 2 1]);
    data = color.get_data();
    color_img = permute(reshape(data',[3,color.get_width(),color.get_height()]),[3 2 1]);
end