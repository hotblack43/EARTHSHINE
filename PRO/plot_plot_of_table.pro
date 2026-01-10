labels=['B','V','VE1','VE2','IRCUT']
data=get_data('plot_of_table.dat')
singleEFM=reform(data(0,*))
stackEFM=reform(data(1,*))
singleBBSO=reform(data(2,*))
stackBBSO=reform(data(3,*))
!P.CHARSIZE=2
plot,/nodata,singleEFM,yrange=[0.01,0.025],xstyle=3,ystyle=3,xtitle='Filter',ytitle='DS [rel. units.]',xtickname=labels
oplot,singleEFM,psym=-4,color=fsc_color('red')
oplot,stackEFM,psym=-5,color=fsc_color('red')
oplot,singleBBSO,psym=-6
oplot,stackBBSO,psym=-7
end
