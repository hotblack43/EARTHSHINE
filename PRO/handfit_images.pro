@get_ims.pro	; read in this subroutine
;============================================================
str='HAPKE'
 modelimagename=strcompress('OUTPUT/'+str+'_ROLO_May_23_1999.fit',/remove_all)
 observedimagename='/home/pth/SCIENCEPROJECTS/EARTHSHINE/TOMSTONE/2321_ROLO.fit'
 ;
 get_ims,inputim,observed,modelimagename,observedimagename
;=============
window,0,title='Observed image'
contour,observed,/cell_fill,nlevels=101,/isotropic,xstyle=1,ystyle=1
window,2,title='Model image'
;
factor=mean(inputim)/mean(observed)
;
angle=-90
Mag=1.0
Yshift=0
Xshift=-150
if_reverse=1
im=inputim
if (if_reverse eq 1) then im=reverse(im,2)
im=ROT(shift(im,Xshift,Yshift), Angle, Mag)
contour,im,/cell_fill,nlevels=101,/isotropic,xstyle=1,ystyle=1
print,'Xshift:',xshift
print,'Yshift:',yshift
print,'Angle:',angle
print,'Mag:',mag
print,'Reverse:',if_reverse
print,'Factor (mod/obs):',factor
openw,44,'imagefiddlepars.dat'
printf,44,xshift,yshift,angle,mag,if_reverse,factor
close,44
end
