function Ishape = create_VideoFrame(Ishape,WeldingPos,Constants)
    for idx = 1 : size(WeldingPos,1)
        [Pcx,Pcy] = camCoor2RGB(WeldingPos(idx,:),Constants);
        Ishape = insertShape(Ishape,'circle',[Pcx Pcy 10],'LineWidth',5,'color','green');
    end
end