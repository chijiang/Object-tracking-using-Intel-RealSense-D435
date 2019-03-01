function [Pcx,Pcy] = camCoor2RGB(WeldingPos,Constants)
Fdx = Constants.CameraParameters.Fdx; %367.286994
Fdy = Constants.CameraParameters.Fdy; %367.286855
Cdx = Constants.CameraParameters.Cdx; %255.16569
Cdy = Constants.CameraParameters.Cdy; %211.82460

Pdy = ((WeldingPos(1,2)*Fdy)/WeldingPos(1,3))+Cdy;
Pdx = ((WeldingPos(1,1)*Fdx)/WeldingPos(1,3))+Cdx;

Pcx = round(Pdx*2.9111); 
Pcy = round(Pdy*2.9316);
end 