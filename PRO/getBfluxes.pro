@stuff66.pro
PRO cleanthisstack,im
l=size(im,/dimensions)
stack=im*0.0
if (n_elements(l) ne 3) then stop
ic=0
for i=0,l(2)-1,1 do begin
subim=reform(im(*,*,i))
if (max(subim) lt 56000.0 and max(subim) gt 20000.0 and total(subim) ne 0.0) then begin
stack(*,*,ic)=subim
ic=ic+1
endif
endfor
im=stack
return
end

PRO findafittedlinearsurface,im,mask,thesurface
l=size(im,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
;----------------------------------------
offset=mean(im(0:10,0:10))
thesurface=findgen(512,512)*0.0
mim=mask*im
get_lun,wxy
openw,wxy,'masked.dat'
for i=0,511,1 do begin
for j=0,511,1 do begin
if (mim(i,j) ne 0.0) then begin
printf,wxy,i,j,mim(i,j)
endif
endfor
endfor
close,wxy
free_lun,wxy
data=get_data('masked.dat')
res=sfit(data,/IRREGULAR,1,kx=coeffs)
print,coeffs
thesurface=coeffs(0,0)+coeffs(1,0)*y+coeffs(0,1)*x+coeffs(1,1)*x*y
;thesurface=thesurface+offset
return
end

PRO getridoffittedlinearsurface,im,iflag
l=size(im,/dimensions)
if (n_elements(l) eq 2 and max(im) gt 20000 and max(im) lt 56000L) then begin
iflag=1
mask=im*0.0
mask(0:20,0:20)=1.0
mask(0:20,511-20:511)=1.0
mask(511-20:511,0:20)=1.0
mask(511-20:511,511-20:511)=1.0
if (total(im) ne 0.0) then begin
findafittedlinearsurface,im,mask,thesurface
im=im-thesurface
endif
endif
if (n_elements(l) eq 3) then begin
iflag=1
for kl=0,l(2)-1,1 do begin
if (max(im(*,*,kl)) lt 20000 and max(im(*,*,kl)) lt 56000L) then iflag=314
endfor
for k=0,l(2)-1,1 do begin
im_in=reform(im(*,*,k))
iflag=1
mask=im_in*0.0
mask(0:20,0:20)=1.0
mask(0:20,511-20:511)=1.0
mask(511-20:511,0:20)=1.0
mask(511-20:511,511-20:511)=1.0
if (total(im_in) ne 0.0) then begin
findafittedlinearsurface,im_in,mask,thesurface
im(*,*,k)=im(*,*,k)-thesurface
endif
endfor
endif
print,'Minimum: ',min(im)
return
end

PRO get_sunmoonangle,jd,angle
; returns the angle between Sun and Moon as seen from Earth
angle=1
MOONPOS, jd, ra_moon, dec_moon, dis
obsname='MLO'
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
; Where is the Sun in the local sky?
        SUNPOS, jd, ra_sun, dec_sun
        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
; what is the angular distance between Moon and SUn?
u=0     ; radians
gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
angle=dis/!pi*180.
if (ra_moon*!dtor gt ra_sun*!dtor) then angle=-angle
return
end

;------------------------------------------------------------------------------
files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/','*MOON*_B_*.fi*',count=n)
openw,33,'Bfluxdata.dat'
for i=0,n-1,1 do begin
if (strpos(files(i),'averaged') eq -1 and strpos(files(i),'DITHER') eq -1) then begin
im=readfits(files(i),header,/silent)
l=size(im,/dimensions)
if (n_elements(l) eq 3) then cleanthisstack,im
getbasicinfo,files(i),jd,filtername,exptime,am
MOONPOS, jd, ra, dec, dis
; factor for Moon-Earth distance variations:
factor=(dis/384000.00)^2
; factor for Sun_Earth distance
caldat,jd,dd,mm,yy,hh
day=long(jd)-julday(1,1,yy)
time=hh
tt=((fix(day)+time/24.-1.) mod 365.25) +1.
rsun=1.-0.01673*cos(.9856*(tt-2.)*!dtor)      ; earth-sun distance in AU
geomfactor=factor*rsun^2
print,jd,geomfactor
l=size(im,/dimensions)
get_sunmoonangle,jd,angle
iflag=314
getridoffittedlinearsurface,im,iflag
fmt='(f17.3,3(1x,f9.4),1x,f9.2,1x,f9.6,1x,i2,1x,f17.6)'
if (iflag ne 314) then begin
if (n_elements(l) eq 2) then print,format=fmt,total(im,/double),exptime,am,angle,min(im),geomfactor,2,jd
if (n_elements(l) eq 3) then print,format=fmt,total(im,/double)/float(l(2)),exptime,am,angle,min(im),geomfactor,3,jd
if (n_elements(l) eq 2) then printf,33,format=fmt,total(im,/double),exptime,am,angle,min(im),geomfactor,2,jd
if (n_elements(l) eq 3) then printf,33,format=fmt,total(im,/double)/float(l(2)),exptime,am,angle,min(im),geomfactor,3,jd
endif
endif
endfor
close,33
end

