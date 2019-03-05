function PredictionVidFrame = get_PredictVidFrame...
    (croped_color,velocity_vector,weldingAverageArray,LastTime,LastCenterLoc,T,Constants)
    Tdiff = T-LastTime;
    NewPos = (weldingAverageArray+LastCenterLoc) + (velocity_vector*Tdiff);
    [Pcx,Pcy] = CameraCoorToRGB(NewPos,Constants);
    
    PredictionVidFrame = insertShape(croped_color,'circle',[Pcx Pcy 10],'LineWidth',5,'color','red');
end