function PredictionVidFrame = get_PredictVidFrame...
    (croped_color,VelocityVector,WeldingAverageArray,LastTime,LastCenterLoc,T,Constants)
    Tdiff = T-LastTime;
    NewPos = (WeldingAverageArray+LastCenterLoc) + (VelocityVector*Tdiff);
    [Pcx,Pcy] = CameraCoorToRGB(NewPos,Constants);
    
    PredictionVidFrame = insertShape(croped_color,'circle',[Pcx Pcy 10],'LineWidth',5,'color','red');
end