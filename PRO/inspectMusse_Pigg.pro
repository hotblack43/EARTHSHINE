FUNCTION moonmodel,lon,lat,lontab,lattab,A,o,i
; lon,lat are the IMAGES of lon and lat
; lontab,latttab are the printed TABLES of lon and lat
; o is the image of the angle to Earth wrt local normal
; i is the image of the angle to the Sun wrt normal
; all angles are input in radians
; A is the  image of the clementine map projekted onto a sphere and hidden points missing

image=lon*0.0d0
n=n_elements(lontab)
for k=0,n-1,1 do begin
idx=where(abs(lon - lontab(k)) eq min(abs(lon - lontab(k))))
;ilat=where(abs(lon - lontab(k)) eq min(abs(lon - lontab(k))))
image(idx)=abs(832.559134337261 + 18030.9155306762*cos(i(k)) -987.466963082486/(0.0161257498393064 + 0.209588048503454*(A(k)*cos(o(k))*cos(i(k))/(cos(o(k)) + cos(i(k))))^2 + cos(o(k))) + 283601.692918511*A(k)*cos(o(k))*cos(i(k))/(0.0161257498393064*cos(o(k)) + 0.0161257498393064*cos(i(k)) + cos(o(k))^2 + cos(o(k))*cos(i(k)) + 0.209588048503454*(A(k)*cos(o(k))*cos(i(k))/(cos(o(k)) + cos(i(k))))^2*cos(o(k)) + 0.209588048503454*(A(k)*cos(o(k))*cos(i(k))/(cos(o(k)) + cos(i(k))))^2*cos(i(k))))
endfor
return,image
end

PRO getclemalbedfromlonlat,lon,lat,albedo_i
common stuff,iflag,lonClem,latClem,Clem
if (iflag ne 314) then begin
data=get_data('Clem.txt')
Clem=reform(data(0,*))
lonClem=reform(data(1,*))
idx=where(lonClem gt 180)
lonClem(idx)=-(360-lonClem(idx))
lonClem=-lonClem
latClem=reform(data(2,*))
print,'Done reading Clem.txt'
iflag=314
endif
;print,lon,lat
dlon=abs(lon-lonClem)
dlat=abs(lat-latClem)
idx=where(dlon eq min(dlon))
jdx=where(dlat(idx) eq min(dlat(idx)))
;print,lonClem(idx(jdx))
;print,latClem(idx(jdx))
albedo_i=Clem(idx(jdx))
return
end
 PRO gofindphaseangle,header,phase
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
 idx=strpos(header,'PHSAN_E')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'PHSAN_E not in header. Stoppinmg'
	stop
     endif else begin
     phase=float(strmid(header(jdx),15,9))
     endelse
return
end

 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),11,19))
     endelse
 x0=x0(0)
 y0=y0(0)
 radius=radius(0)
 return
 end
;......................................................
;
common stuff,iflag,lonClem,latClem,Clem
iflag=0
JD='2456104.8770674'
JD='2456045.7861532'
openr,2,'JDs'
while not eof(2) do begin
JD=''
readf,2,JD
want='HGL/observed_image_JD'+JD+'.fits'
print,want
obs=readfits(want,header)
gofindradiusandcenter_fromheader,header,x0,y0,radius
obs=shift(obs,256-x0,256-y0)
modl=readfits('HGL/synth_folded_scaled_shifted_JD'+JD+'.fits')
modl=shift(modl,256-x0,256-y0)
lonlat=readfits('HGL/lonlatSELimage_JD'+JD+'.fits',header2)
gofindphaseangle,header2,phase
phase=phase*!dtor
lon=reform(lonlat(*,*,0))
lon=reverse(lon,2)
lat=reform(lonlat(*,*,1))
lat=reverse(lat,2)

angles=readfits('HGL/Angles_JD'+JD+'.fits')
iSun=reform(angles(*,*,0))
iSun=reverse(iSun,2)
iEarth=reform(angles(*,*,1))
iEarth=reverse(iEarth,2)

!P.MULTI=[0,2,3]
contour,/isotropic,obs,xstyle=3,ystyle=3
contour,/isotropic,modl,xstyle=3,ystyle=3
contour,/isotropic,lon,xstyle=3,ystyle=3
contour,/isotropic,lat,xstyle=3,ystyle=3
contour,/isotropic,iEARTH,xstyle=3,ystyle=3
contour,/isotropic,iSUN,xstyle=3,ystyle=3
; select BS
idx=where(obs gt max(obs)/100.)
n=n_elements(idx)
openw,33,'moontable_JD'+JD+'.dat'
for i=0,n-1,1 do begin
if (lon(idx(i)) gt -200) then begin
print,lon(idx(i)),lat(idx(i))
getclemalbedfromlonlat,lon(idx(i)),lat(idx(i)),albedo_i
printf,33,format='(7(1x,f11.4))',albedo_i,iEARTH(idx(i)),iSUN(idx(i)),lon(idx(i)),lat(idx(i)),phase,obs(idx(i))
endif
endfor
close,33
spawn," awk 'NF == 7 ''' "+"moontable_JD"+JD+".dat"+" > aha"
data=get_data('aha')
A=reform(data(0,*))
o=reform(data(1,*))
i=reform(data(2,*))
lontab=reform(data(3,*))
lattab=reform(data(4,*))
g=reform(data(5,*))
; now build the better model moon image
moonmod=moonmodel(lon,lat,lontab,lattab,A,o,i)
writefits,'moonmodel_JD'+JD+'.fits',shift(moonmod,x0-256,y0-256)
endwhile
close,2
end

