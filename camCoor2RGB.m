function [pixel_x,pixel_y] = camCoor2RGB(welding_pos,Constants)
x = welding_pos(1);
y = welding_pos(2);
z = welding_pos(3);

pixel_x = (x * 1280) / (2*tan(69.4/180*pi/2)) / z + 640;
pixel_y = - ((x * 720) / (2*tan(42.5/180*pi/2)) / z - 360);
end 