PRO ladder_plot,x,y,ymod,xtit,ytit,titstr
   Plot, x,y-ymod, XStyle=3, Position=[0.15, 0.15, 0.9, 0.30], $
      XTitle=xtit, YTitle='Residuals'
 oplot,[!X.crange],[0,0],linestyle=1
   Plot, x,y,  Position=[0.15, 0.3, 0.9, 0.90], ystyle=3, $
      /NoErase, XTickformat='(A1)', YTitle=ytit,title=titstr,xstyle=3
   oplot,x,ymod,color=fsc_color('red')
   Plots, [0.15, 0.15], [0.50, 0.52], /Normal ; Fix left axis.
   Plots, [0.90, 0.90], [0.50, 0.52], /Normal ; Fix right axis.
return
end
