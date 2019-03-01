function [Ishape,centroid,depth_uint8, bbox] = foregrndDetection(depth_img,background,blobAnalysis,color_img)
	% foregrndDetection - detecte the foreground of captured frame
	% 	using the depth image.
    %
    % Syntax:  
	%		[Ishape,centroid,depth_uint8, bbox] = foregrndDetection(depth_img,background,blobAnalysis,color_img)
	%
	% Inputs:
    %    depth_img - Depth image, 3-channel (RGB).
    %    background - Depth image of the background, converted to
	%					binary image (data type: bool). 
	%	 blobAnalysis - vision.BlobAnalysis object.
	%	 color_img - RGB image, 3-channel.
	%
    % Outputs:
    %    Ishape - RGB image, in which foreground is marked.
    %    centroid - The center pixel location of the ROI or foreground.
	%    depth_uint8 - The depth image, which is converted to binary 
	%					image.
	%	 bbox - The boundary of the ROI, in pixel scale. 
	% 				[x_upperleft, y_upperleft, width, height]
    %
    % Subfunctions: TiefenbildBinarisierung
    %
    % Author: Chijiang Duan
    % email: chijiang.duan@tu-braunschweig.de
    % Mar 2019; Version 1.0.0
    %------------- BEGIN CODE --------------
	Ishape = [];
	% konvertierung des Tiefenbildes in einem Binärbild mit Datentyp uint8
	depth_uint8 = depth_image_binarize(depth_img, 220); 
	%Kleine Objekte entfernen, (Alle Objekte unter 200 Pixel)
	depth_uint8 = bwareaopen(depth_uint8,200);
	% Vordergrund extrahieren
	foreground = depth_uint8 > background;
	foreground = bwareaopen(foreground,10);
	se = strel('disk',10);
	foreground = imclose(foreground, se);
	% blobAnalyse auf Vordergrund anwenden  
	[~,centroid,bbox] = step(blobAnalysis,foreground);
	% Gefundene Objekte Markieren 
	%       scale2 = size(crop_color,1)/size(depth_uint8,1); 
	%       scale1 = size(crop_color,2)/size(depth_uint8,2); 
	if isempty(bbox) == 0
	%           bbox_color = [round(bbox(1)*scale1),round(bbox(2)*scale2),round(bbox(3)*scale1),round(bbox(4)*scale2)];
		Ishape = insertShape(color_img,'rectangle',bbox,'Color',...
			'green','Linewidth',6); 
	end
	%------------- END OF CODE --------------
end 