function depth_uint8 = depth_image_binarize(crop_depth, Limit)
    depth_uint8 = rgb2gray(crop_depth);
    depth_uint8 = depth_uint8 > Limit;
end 