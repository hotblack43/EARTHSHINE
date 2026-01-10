PRO colorbar_pt,zz,x,y
zzz=bytscl(zz)
;
loadct,33
ncolorlevels=55
ncontourlevels=55
levels=findgen(ncontourlevels)/float(ncontourlevels)*255
!P.MULTI=[0,1,2]
contour,zzz,x,y,/cell_fill,$
levels=levels,xstyle=1,ystyle=1,$
position=[0.1,0.1,0.9,0.8]
ncontourlevels=12
clabidx=findgen(ncontourlevels)*0+1
clabidx(where(fix(findgen(ncontourlevels)/2) eq findgen(ncontourlevels)/2))=0
levels=findgen(ncontourlevels)/float(ncontourlevels)*255
contour,smooth(zzz,11,/edge_truncate),x,y,$
levels=levels,/overplot
; color bar
range=max(zzz)-min(zzz)
minval=min(zzz)
bar=findgen(ncolorlevels)/float(ncolorlevels)*range+minval
bar=[[bar],[bar]]
range_2=max(zz)-min(zz)
minval_2=min(zz)
xrange=findgen(ncolorlevels)/float(ncolorlevels)*range_2+minval_2
contour,bar,xrange,[0,1],/cell_fill,$
levels=levels,xstyle=1,ystyle=1,$
position=[0.1,0.9,0.9,0.95]
return
end


image=readfits('crisium.fit')
l=size(image,/dimensions)
x=findgen(l(0))
y=findgen(l(1))
colorbar_pt,image/12.3,x,y
end
