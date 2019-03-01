function WorldCoord = rgb2camCoor(depth,Pcx,Pcy)
    % Pdx = round(Pcx/2.9111); 
    % Pdy = round(Pcy/2.9316);

    Z = depth.get_distance(round(Pcx),round(Pcx));
    % Y = ((Pcx-Constants.CameraParameters.Cdx)*Z)/Constants.CameraParameters.Fdx;
    % X = ((Pcy-Constants.CameraParameters.Cdy)*Z)/Constants.CameraParameters.Fdy;
    Y = (Pcx - 640) * Z/(1280/(2 * tan(69.4/180*pi/2)));
    X = (Pcy - 360) * Z/(720/(2 * tan(42.5/180*pi/2)));
    WorldCoord = cat(2,X,Y,Z);
end