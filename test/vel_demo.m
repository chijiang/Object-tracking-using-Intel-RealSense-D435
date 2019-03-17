load('cimg_run_2.mat')
cd ..
load('Constants_1.mat')
videoplayer = vision.VideoPlayer();

i = 1;
while i < 20
    color_img = pics.(genvarname(sprintf('cimg_%d', i)));
    try
        centerBright = findBinMarkers(color_img);
        [alpha,center_loc] = global_position(centerBright,color_img,Constants);
        circles = centerBright; 
        circles(:,3) = 8;
        RGB = insertShape(color_img,'circle', circles, 'LineWidth', 5, 'Color', 'g');
        RGB = insertText(RGB,[10 10],...
            sprintf('Center Location: %s', num2str(center_loc)),...
                'FontSize', 18);
    catch
        RGB = insertText(color_img,[10 10],'Binary code not detected',...
            'FontSize', 18);
    end
    videoplayer(RGB)
    pause(0.1)
    i = i+1;
    if i == 20
        i =1;
    end
%     videoplayer(RGB)
end