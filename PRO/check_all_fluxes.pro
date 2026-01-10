 PRO     get_mediansquares,im,sqAmed,sqBmed,sqCmed,sqDmed
 sqAmed=median(im(0:24,0:24),/double)
 sqBmed=median(im(0:24,511-24:511),/double)
 sqCmed=median(im(511-24:511,0:24),/double)
 sqDmed=median(im(511-24:511,511-24:511),/double)
 return
 end

PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 im=sobel(im)
 ;im=laplacian(im,/CENTER)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 ; remove specks
 im=median(im,3)
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 openw,49,'trash.dat'
 for i=0,ntries-1,1 do begin 
     irnd=randomu(seed)*nels
     x1=reform(coords(0,irnd))
     y1=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x2=reform(coords(0,irnd))
     y2=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x3=reform(coords(0,irnd))
     y3=reform(coords(1,irnd))
     ;oplot,[x1,x1],[y1,y1],psym=7
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,49,x0,y0,radius
     endfor
 close,49
 data=get_data('trash.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 return
 end

PRO gofindDSBS,im,x0,y0,radius,cg_x,cg_y,w,BS,DS
; determine if BS is to the right or the left of the center
if (cg_x gt x0) then begin
; BS is to the right
BS=median(im(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*2./3.-w:x0-radius*2./3.+w,y0-w:y0+w))
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(im(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*2./3.-w:x0+radius*2./3.+w,y0-w:y0+w))
endif
return
end

PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
return
end

PRO gettheDSBSratio,im,DSBS,x0,y0,radius
; extract the DSBS ratio
     cgfinder,im,cg_x,cg_y
     w=11
	iflag=1
     gofindDSBS,im,x0,y0,radius,cg_x,cg_y,w,BS,DS
	DSBS=DS/BS
return
end

FUNCTION youngairmass,z
; z is the zenith distance in degrees
numerator=(1.002432*cos(z*!dtor)*cos(z*!dtor)+0.148386*cos(z*!dtor)+0.0096467)
denominator=(cos(z*!dtor)*cos(z*!dtor)*cos(z*!dtor)+0.149864*cos(z*!dtor)*cos(z*!dtor)+0.0102963*cos(z*!dtor)+0.000303978)
am=numerator/denominator
return,am
end

 PRO get_time,header,JD
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 JD=julday(mm,dd,yy,hh,mi,se)
 return
 end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
 return
 end

 PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 return
 end

files=file_search('/data/pth/DATA/ANDOR/BIASSUBTRACTEDALIGNEDSUM/','*MOON*',count=n)
print,'Found ',n,' fits files.'
openw,66,'DUDs.dat'
openw,33,'observed_fluxes.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),header)
; get rid of the sky level
get_mediansquares,im,sqAmed,sqBmed,sqCmed,sqDmed
im=im-mean([sqAmed,sqBmed,sqCmed,sqDmed])
gofindradiusandcenter,im,x0,y0,radius
flag=314
lolim_x=170
lolim_y=170
hilim_x=512-171
hilim_y=512-171
if (x0 gt lolim_x and y0 gt lolim_y and x0 lt hilim_x and y0 lt hilim_y) then flag=1
if (flag eq 314 or radius lt 120 or radius gt 160) then printf,66,'DUD: ',files(i)
if (flag ne 314) then begin
	get_filtername,header,name
	get_EXPOSURE,header,exptime
	get_time,header,JD
	moonphase_pth,jd,phase_angle,alt_moon,alt_sun,'mlo'
	nname=strcompress('_'+name+'_',/remove_all)
	gettheDSBSratio,im,DSBS,x0,y0,radius
	printf,33,format='(1x,f16.7,7(1x,g15.7),2(1x,a))',JD,total(im)/exptime,exptime,phase_angle,alt_moon,alt_sun,DSBS,max(smooth(im,11,/edge_truncate)),nname,files(i)
	print,format='(1x,f16.7,7(1x,g15.7),2(1x,a))',JD,total(im)/exptime,exptime,phase_angle,alt_moon,alt_sun,DSBS,max(smooth(im,11,/edge_truncate)),nname,files(i)
endif
endfor
close,33
close,66
end
