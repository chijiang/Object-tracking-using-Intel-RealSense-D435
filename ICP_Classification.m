function [errValue, ObjectID ] = ICP_Classification(ptCloud,Referenzdatenbank,Constants)
    FieldNames = fieldnames(Referenzdatenbank);
    errValueArray = zeros(numel(FieldNames),1);

    for idx = 1 :numel(FieldNames)
        Center = Referenzdatenbank.(FieldNames{idx}).Center;
        ReferencePtCloud = Referenzdatenbank.(FieldNames{idx}).ptCloud;

        rotx = [1, 0, 0, 0; 0, cos(pi), -sin(pi), 0; 0, sin(pi), cos(pi), 0; 0, 0, 0, 1];
        rotz = [cos(-pi/2), -sin(-pi/2), 0, 0; sin(-pi/2), cos(-pi/2), 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
        rotation = (rotx*rotz)';
        T_trans = affine3d(rotation);
        ptCloud_resize = pctransform(ptCloud,T_trans); 
        
        Xsize = (ptCloud_resize.XLimits(1,2) - ptCloud_resize.XLimits(1,1)) / ...
            (ReferencePtCloud.XLimits(1,2) - ReferencePtCloud.XLimits(1,1));
        Ysize = (ptCloud_resize.YLimits(1,2) - ptCloud_resize.YLimits(1,1)) / ...
            (ReferencePtCloud.YLimits(1,2) - ReferencePtCloud.YLimits(1,1));
        Zsize = (ptCloud_resize.ZLimits(1,2) - ptCloud_resize.ZLimits(1,1)) / ...
            (ReferencePtCloud.ZLimits(1,2) - ReferencePtCloud.ZLimits(1,1));
        
        trans = [1/Xsize,0,0,0;0,1/Ysize,0,0;0,0,1/Zsize,0;0,0,0,1];
        T_trans = affine3d(trans);
        ptCloud_resize = pctransform(ptCloud_resize,T_trans); 

        Xdiff = ((ptCloud_resize.XLimits(1,2)-ptCloud_resize.XLimits(1,1))/2)+...
                ptCloud_resize.XLimits(1,1)-Center(1,1);
        Ydiff = ((ptCloud_resize.YLimits(1,2)-ptCloud_resize.YLimits(1,1))/2)+...
                ptCloud_resize.YLimits(1,1)-Center(1,2);
        Zdiff = ((ptCloud_resize.ZLimits(1,2)-ptCloud_resize.ZLimits(1,1))/2)+...
                ptCloud_resize.ZLimits(1,1)-Center(1,3);
        T_trans = affine3d([1,0,0,0;0,1,0,0;0,0,1,0;Xdiff,Ydiff,Zdiff,1]);
        ReferencePtCloud = pctransform(ReferencePtCloud,T_trans); 

        [~,PC_ICP,rmse] = pcregistericp(ReferencePtCloud,ptCloud_resize,'MaxIterations',Constants.ICP_Parameters.ICP_Classi_iter,...
            'metric','pointToPlane');
        errValueArray(idx) = rmse;
%         figure();
%         pcshow(ReferencePtCloud); hold on; pcshow(ptCloud_resize);hold off;
    end 
    [errValue,ObjectID] = min(errValueArray);
end