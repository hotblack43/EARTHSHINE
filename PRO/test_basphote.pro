@stuff17.pro
;==================================================================
; BASPHOTE  used onn images in DARKCURRENTREDUCED/
;==================================================================
common radius,r
r=fltarr(512,512)
bias=readfits('superbias.fits')
print,'Found bias.'
bias=bias*0.0; since the images are darkreduced already
filter='IRCUT'
lookfor=strcompress('DARKCURRENTREDUCED/*ALTAIR'+'*_'+filter+'_*'+'*.fits',/remove_all)
print,lookfor
files=file_search(lookfor,count=n)
name='Altair'
gain=1.0
gain_real=3.78
pscale=6.67
im=readfits(files(0))-bias
;contour,/cell_fill,histomatch(im,fltarr(256)*0+1),/isotropic
openw,72,'basphote_output.dat'
for ifile=0,n-1,1 do begin
im=readfits(files(ifile),h)-bias
kdx=where(im eq max(im))
coords=array_indices(im,kdx)
xloc=coords(0)
yloc=coords(1)
im=im*gain_real
get_info_from_header,h,'DMI_ACT_EXP',exptime
get_time,h,jd
radius=9
sky1=9
sky2=12
logfile='test.log'
Basphote,gain,im,exptime,xloc,yloc,radius,sky1,sky2,logfile,xcen=xc,ycen=yc,/ALTLOG,fname=files(ifile),filter=filter,jd=jd(0),name=name,pscale=pscale,flux=flux,flerr=flerr,skymean=skymean,skyerr=skyerr,mag=mag
printf,72,format='(f15.7,2(1x,f20.7),2(1x,f10.4))',jd,flux,flerr,mag,exptime
;
tvscl,im
oplot,[xc,xc],[!Y.crange]
oplot,[!X.crange],[yc,yc]
endfor
close,72
end

