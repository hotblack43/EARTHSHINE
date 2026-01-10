x=THICKNESS_500_200(*,1+indgen(nlat-1),*)
Y=MEAN_TEMP_500_200(*,1+indgen(nlat-1),*)
;plot,x,y,psym=3,xtitle='200-500 HPa layer thickness (m)',ytitle='200-500 HPa layer weighted mean T (C)',charsize=2
res=linfit(x,y,yfit=yhat,/double)
min1=5600
max1=6800
bin1=5
min2=-70
max2=-20
bin2=0.25
xarray=indgen((max1-min1)/bin1+1)*bin1+min1
yarray=indgen((max2-min2)/bin2+1)*bin2+min2
hist=hist_2d(x,y,min1=min1,max1=max1,bin1=bin1,min2=min2,max2=max2,bin2=bin2)
contour,hist,xarray,yarray,xtitle='200-500 HPa layer thickness (m)',ytitle='200-500 HPa layer weighted mean T (C)',charsize=2,levels=[1,10,100,1e3,1e4,1e5,1e6]

oplot,x,yhat,thick=3
end
