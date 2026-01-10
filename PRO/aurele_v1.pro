file='aureole.jpg'
nam=['R','G','B']
colnam=['red','green','blue']
levels=[160,170,180,190,200,250]
read_jpeg,file,im
!P.MULTI=[0,1,1]

for ic=0,2,1 do begin
	imrgb=reform(im(ic,*,*))
	if (ic eq 0) then contour,imrgb,levels=levels,/isotropic, $
		title=nam(ic),color=fsc_color(colnam(ic))
    if (ic gt 0) then contour,imrgb,levels=levels,/isotropic, $
		title=nam(ic),color=fsc_color(colnam(ic)),/overplot
endfor ; end of ic loop
r=float(reform(im(0,*,*)))
g=float(reform(im(1,*,*)))
b=float(reform(im(2,*,*)))
!P.MULTI=[0,2,3]
mask=r*0.0+1.0
mask(where(r lt 50)) =0.0
contour,mask*r/g,/cell_fill,nlevels=100,title='R/G',xstyle=1,ystyle=1,/isotropic
surface,congrid(r/g,20,20)
mask(where(r lt 60)) =0.0
contour,mask*r/b,/cell_fill,nlevels=100,title='R/B',xstyle=1,ystyle=1,/isotropic
surface,congrid(r/b,20,20)
contour,g/b,/cell_fill,nlevels=100,title='G/B',xstyle=1,ystyle=1,/isotropic
surface,maskcongrid(g/b,20,20)
end
