; give the telescope focallength
;
f=600.0 ; in mm
x=[0]
y=[0]
for f=600.,2000.,10. do begin
;
; Give image angular size
;
theta=0.5   ; in degrees
theta=theta*!dtor   ; in radians
;
; Give telescope aperture in inches
D=3 ; in inches
; Give the CCD properties
height=1020 ; in pixels
pixel_size=6.9  ; in microns
;--------------------------
; get the imag size
image_size=f*theta  ; in units of f
;
; get the resolving power
;
resolution=4.56/D   ; in arc seconds
;
; the size of the resolving element for this telescope will be
;
resolution_size=resolution/206265.*!pi*f    ; in units of f
; and in pixels it will be
resolution_in_microns=resolution_size/1000./1e-6
;
CCD_scale=height*pixel_size ; in microns
CCD_scale=CCD_scale*1000.*1e-6  ; in mm
print,'CCD is ',CCD_scale,' mm wide.'
print,'Image size will be:',image_size,' mm.'
print,'Resolving power is:',resolution,' arc seconds. This is ',resolution_in_microns,' microns, for this telescope, in prime focus.'
print,'Or, one resolving elemnt is ',resolution_in_microns/pixel_size,' pixels.
Print,'Image will be spanned by ',image_size/CCD_scale*height,' pixels.'
ratio=  (image_size/CCD_scale*height)/(resolution_in_microns/pixel_size)
print,'Image spanned by',ratio,' resolving elements.'
x=[x,f]
y=[y,image_size]
endfor
plot,x,y,xtitle='Focal length (mm)',ytitle='Image size (mm)',charsize=2
end
