function VelocityVector = get_movement(PosArray,TimeArray,Constants)
     PosDiffArray = zeros(Constants.PositionCount-1,3); 
     TimeDiffArray = zeros(Constants.PositionCount-1,1); 
     VelocityArray = zeros(Constants.PositionCount-1,3); 
     VelocityVector = zeros(1,3); 
     for idx = 1 : Constants.PositionCount-1 
         PosDiffArray(idx,:) = PosArray(idx+1,:)-PosArray(idx,:);
         TimeDiffArray(idx) = TimeArray(idx+1)-TimeArray(idx); 
         VelocityArray(idx,:) = PosDiffArray(idx,:)/TimeDiffArray(idx);
     end
     VelocityVector(1,1) = sum(VelocityArray(:,1))/(Constants.PositionCount-1);
     VelocityVector(1,2) = sum(VelocityArray(:,2))/(Constants.PositionCount-1);
     VelocityVector(1,3) = sum(VelocityArray(:,3))/(Constants.PositionCount-1);
end