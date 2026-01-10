PRO setupsupportforlunardisc2,c_image,mask
common circle,x0,y0,radius,radius_surface
l=size(c_image,/dimensions)
if (file_test('moon_circle_data.dat') ne 1) then begin
contour,c_image
cursor,x1,y1
wait,0.2
cursor,x2,y2
wait,0.2
cursor,x3,y3
wait,0.2
openw,45,'moon_circle_data.dat'
printf,45,x1,y1
printf,45,x2,y2
printf,45,x3,y3
close,45
endif else begin
openr,45,'moon_circle_data.dat'
readf,45,x1,y1
readf,45,x2,y2
readf,45,x3,y3
close,45
endelse
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
maxval=max(c_image)
get_circle,l,[x0,y0],circle,radius,maxval
get_mask,x0,y0,radius,mask
n=l(0)
 x=indgen(N) # replicate(1,N)
 y=replicate(1,N) # indgen(N)
 radius_surface=sqrt((x-x0)^2+(y-y0) ^2)
return
end

PRO report_error,diff,mask,inverse_mask,n_mask,n_invmask
common circle,x0,y0,radius,radius_surface
common errors,err_on_disc,err_off_disc
l=size(diff,/dimensions)
surface,diff ,charsize=2
print,'Multiplicative deconvolution:',sqrt(total(diff^2)),' RSE'
err_on_disc=sqrt(total((diff*mask)^2)/n_mask^2)
err_off_disc=sqrt(total((diff*inverse_mask)^2)/n_invmask^2)
print,'RSE per pixel on disc:',err_on_disc
print,'RSE per pixel off-disc:',err_off_disc
print,'ratio ON/OFF',err_on_disc/err_off_disc
; annuli
rstep=0.333
i=0
for r=radius,2*l(0),rstep do begin
idx=where(radius_surface gt r and radius_surface le r+rstep,count)
if (count gt 2) then begin
if (i eq 0) then begin
	x=r+rstep/2.
	y=mean(diff(idx))
	z=stddev(diff(idx))/sqrt(count-1)
endif else begin
	x=[x,r+rstep/2.]
	y=[y,mean(diff(idx))]
	z=[z,stddev(diff(idx))/sqrt(count-1)]
endelse
i=i+1
endif
endfor
res=linfit(x,y,measure_errors=z,/double,yfit=yhat,sigma=sigs)
plot,x,y,charsize=2,xtitle='Radial distance from disc centre',title='Z='+strmid(string((res(1)/sigs(1)*10.)/10.),0,10),ytitle='Residual'
oploterr,x,y,z

oplot,x,yhat,thick=2
print,'Slope:',res(1),' Z: ',res(1)/sigs(1)
return
end


;========================
common circle,x0,y0,radius,radius_surface
common errors,err_on_disc,err_off_disc
; get an image to fold
getimage,c_image
setupsupportforlunardisc2,c_image,mask
n_mask=n_elements(where(mask eq 1))
inverse_mask=abs(mask-1)
n_invmask=n_elements(where(inverse_mask eq 1))
l=size(c_image,/dimensions)
if (l(0) ne l(1)) then stop
n=l(0)
; start settings for the PSF
a=1.1
b=1.3
c=0.3
a0=3.14
build_psf,a0,a,b,c,n,psf
surface,psf
; get an image
folded=double(fft(fft(c_image,-1,/double)*fft(psf,-1,/double),1,/double))
tvscl,folded
; make an estimate of the actual PSF and form a new folded image
reformed=double(fft(fft(folded,-1,/double)/fft(psf,-1,/double),1,/double)       )
tvscl,reformed
diff=c_image-reformed

report_error,diff,mask,inverse_mask,n_mask,n_invmask

end