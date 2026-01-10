data = cgScaleVector(Findgen(101), 30, 1200)
   ticks = LogLevels([10,2000])
   nticks = N_Elements(ticks)
   cgPlot, data, /YLOG, YRANGE=[2000,10], YTICKS=nticks-1, $
      YTICKV=Reverse(ticks)
end
