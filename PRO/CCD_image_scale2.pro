nCCDs=3 ; number of CCDs to compare
npixels=[1024,512,1024]    ; number of pixels
pixel_size=[13,16,24]    ; in microns
CCD_name=['iXion','512B','1001E']
ccd_width=npixels*pixel_size*1e-6*1000 ; in mm

theta=0.5   ; in degrees
theta=theta*!dtor   ; in radians




x=0
y=transpose([0,0,0])
for f=500,3000,10 do begin  ; in mm
    image_size=f*theta
      fraction=image_size/ccd_width
      x=[x,f]
       y=[y,transpose(fraction)]

endfor
plot,x,y(*,0),title='CCD matched to prime focus',xrange=[500,3000],yrange=[0.1,1.5],ytitle='Moon diameter in units of CCD width',xtitle='focal length (mm)',linestyle=0,thick=4,charsize=1.5
oplot,x,y(*,1),linestyle=2
oplot,x,y(*,2),linestyle=3
plots,[!X.CRANGE],[0.95,0.95],linestyle=1
;
plots,[900,900],[0.0,0.95],linestyle=1
xyouts,870,0.05,'900 mm',orientation=90
;
plots,[2650,2650],[0.0,0.95],linestyle=1
xyouts,2640,0.05,'2650 mm',orientation=90
;
plots,[1450,1450],[0.0,0.95],linestyle=1
xyouts,1440,0.05,'1450 mm',orientation=90
;
xyouts,1750,1.0,CCD_name(0),orientation=40
xyouts,700,1.0,CCD_name(1),orientation=45
xyouts,2500,1.0,CCD_name(2),orientation=45
end