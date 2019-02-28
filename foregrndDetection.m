function [Ishape,centroid,depth_uint8, bbox] = foregrndDetection(depth_img,background,BlobAnalysis,color_img)
      Ishape = [];
      % konvertierung des Tiefenbildes in einem Binärbild mit Datentyp uint8
      depth_uint8 = TiefenbildBinarisierung(depth_img, 220); 
      %Kleine Objekte entfernen, (Alle Objekte unter 200 Pixel)
      depth_uint8 = bwareaopen(depth_uint8,200);
      % Vordergrund extrahieren
      foreground = depth_uint8 > background;
      foreground = bwareaopen(foreground,10);
      se = strel('disk',10);
      foreground = imclose(foreground, se);
      % BlobAnalyse auf Vordergrund anwenden  
      [~,centroid,bbox] = step(BlobAnalysis,foreground);
      % Gefundene Objekte Markieren 
%       scale2 = size(crop_color,1)/size(depth_uint8,1); 
%       scale1 = size(crop_color,2)/size(depth_uint8,2); 
      if isempty(bbox) == 0
%           bbox_color = [round(bbox(1)*scale1),round(bbox(2)*scale2),round(bbox(3)*scale1),round(bbox(4)*scale2)];
          Ishape = insertShape(color_img,'rectangle',bbox,'Color',...
            'green','Linewidth',6); 
      end
end 