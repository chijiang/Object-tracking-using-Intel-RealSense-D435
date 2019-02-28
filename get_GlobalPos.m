function [Alpha,CenterLoc] = get_GlobalPos (centersBright,crop_color,depth,Constants)
crop_color = rgb2gray(crop_color);
for idx = 1 : 3 
    ID1 = imbinarize(crop_color(round(centersBright(idx,2)-19),round(centersBright(idx,1)),:));
    ID2 = imbinarize(crop_color(round(centersBright(idx,2)+14),round((centersBright(idx,1)+14)),:));
    ID3 = imbinarize(crop_color(round(centersBright(idx,2)+14),round((centersBright(idx,1)-14)),:));
    
    if ID1 == 1 && ID2 == 1 && ID3 == 1 
        P2 = zeros(1,2); 
        P2(1) = centersBright(idx,1); 
        P2(2) = centersBright(idx,2); 
    elseif ID1 == 0 && ID2 == 0 && ID3 == 0 
        P3 = zeros(1,2);
        P3(1) = centersBright(idx,1); 
        P3(2) = centersBright(idx,2); 
    else
        P1 = zeros(1,2); 
        P1(1) = centersBright(idx,1); 
        P1(2) = centersBright(idx,2);
    end 
end

  XYZP1 = RGBToCameraCoor(depth,P1(2),P1(1));
  XYZP2 = RGBToCameraCoor(depth,P2(2),P2(1));
  XYZP3 = RGBToCameraCoor(depth,P3(2),P3(1));
  
  VP3P2 = XYZP3 - XYZP2;
  VP1P2 = XYZP1 - XYZP2;
  
  CenterLoc = [XYZP2 + (VP3P2/2) + (VP1P2/2)];
%   CenterLoc = [(XYZP3(1,1)-XYZP1(1,1))/2+XYZP1(1,1);(XYZP3(1,2)-XYZP1(1,2))/2+XYZP1(1,2);(XYZP3(1,3)-XYZP1(1,3))/2+XYZP1(1,3)];
  Alpha = atan2d(norm(cross(VP3P2,Constants.LinearAxisDirection)),dot(VP3P2,Constants.LinearAxisDirection));
end