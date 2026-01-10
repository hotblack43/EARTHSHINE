FUNCTION go_unpad,imout
l=size(imout,/dimensions)
n=l(0)/3.
x1=n
x2=2*n-1
y1=x1
y2=x2
out=imout(n:2*n-1,n:2*n-1)
return, out
end

FUNCTION airy,a,wavelength,theta
; INPUT        a = radius - of aperture
;              wavelength of light - same units as radius
;              theta - angle from center in radians
k=2.0d0*!pi/wavelength
x=k*a*sin(theta)
value=(2.0d0*BESELJ(x,1,/double)/x)^2
return,value
end


PRO gofillthePSF,PSF_in,OD,fl,PSF_out,wavelength
l=size(PSF_in,/dim)
n=l[0]
scale=6.7*1d-4 ; cm per pixel
theta_max=1e-12
for i=0,n-1,1 do begin
for j=0,n-1,1 do begin
r=sqrt((i-n/2.)^2+(j-n/2.)^2)+1.0d-12
theta = atan(r*scale,fl) ; this is in radians
if (theta gt theta_max) then theta_max=theta
value=airy(OD/2.0d0,wavelength*1e-7,theta)
PSF_in(i,j)=value
endfor
endfor
print,'Volume of PSF before norm: ',total(PSF_in,/double)
; give it 'volume' 1
PSF_out=PSF_in/total(PSF_in,/double)
print,'Volume of PSF after norm: ',total(PSF_out,/double)
print,'Theta max : ',theta_max/!pi*180/sqrt(2),' deg.'
plate_scale=206265./(10*fl)
print,'Plate scale : ',plate_scale/3600.,' deg/mm'
print,'Image width : ',2.0*theta_max/!pi*180/sqrt(2)/(plate_scale/3600.),' mm.'
return
end

FUNCTION foldit,PSF,im_org
; PSF is already 3x3
; pad im_org
l=size(im_org,/dim)
n=l[0]
zeros=dblarr(n,n)*0.0d0
first_col=[zeros,zeros,zeros]
middle_col=[zeros,im_org,zeros]
last_col=[zeros,zeros,zeros]
im_padded=[[first_col],[middle_col],[last_col]]
;FFT the PSF
PSF_FFT=fft(PSF,-1,/double)
;FFT the padded image
im_FFT=fft(im_padded,-1,/double)
; multiply them
prod=im_FFT*PSF_FFT
; inverse FFT the product
inv=double(FFT(prod,1,/double))
; shift corner to middle
n=3*n
big_im_out=shift(inv,n/2.,n/2.)
; restore the factor n*n lost in the FFT
big_im_out=n*n*big_im_out
; and clip the padding away
im_out=go_unpad(big_im_out)
return,im_out
end

;PRO maincode
!P.CHARSIZE=1.4
!P.CHARTHICK=1.4
!P.thick=1.6
!P.MULTI=[0,1,1]
fl_fixed=15.0d0 ; cm
wavelength=425.0d0 ; in nm
; Generate a suitable Moon image - either fake or from synth
;im_org=1.0d0*readfits('./OUTPUT/IDEAL/ideal_image_JD2455958.0000000.fits') ; Half Moon
im_org=1.0d0*readfits('./OUTPUT/IDEAL/ideal_image_JD2455953.0000000.fits') ; New Moon
;im_org=1.0d0*readfits('./OUTPUT/IDEAL/ideal_image_JD2455962.0000000.fits') ; Old Moon
tot_org=total(im_org,/double)
; loop over ODs for panel 1 of figure
ic=0
print,'------------------------------------------------------------------------------'
;for OD=5.0d0,9.0d0,4.0d0 do begin ; Diameter of the objective
for f_number=2.1d0,8.4d0,2.1d0 do begin ; System f#
	fl=fl_fixed ; OD*f_number ; focal length cm
        ;f_number=fl/OD
	OD = fl/f_number
	print,'OD, fl, f# : ',OD,fl,f_number
; generate a PSF for the OD
	PSF_in=dblarr(3*512,3*512)
; pad it to 3x3, and fill it with the Airy function
	gofillthePSF,PSF_in,OD,fl,PSF,wavelength
        print,'Volume of PSF returning : ',total(PSF,/double)
; fold each Moon image with the PSF
	im_folded=foldit(PSF,im_org)
	tot_folded=total(im_folded,/double)
	; scale to same sum
	factor=tot_org/tot_folded
	;im_folded=im_folded*factor
        print,"Total im_folded:",total(im_folded,/double)
; extract profile and plot
	profile=im_folded[*,512/2.]
        org_profile=im_org[*,512/2.]
	diff_profile=profile-org_profile
	print,'RMS error : ',sqrt(mean(diff_profile^2))
	rat_profile=profile/org_profile
	if (ic eq 0) then plot,profile,/ylog,yrange=[3e-3,4e2],/nodata,color=fsc_color('black'),thick=4,xtitle="Image column number",ytitle="Irradiance [arb. units]",POSITION=[0.25, 0.55, 0.90, 0.95],title=strcompress(string(wavelength,format='(f4.0)')+' nm')
	if (ic eq 0) then oplot,profile,color=fsc_color('red')
	if (ic gt 0) then oplot,profile,color=fsc_color('green'),thick=3
	oplot,org_profile,thick=4,color=fsc_color('blue')
ic=ic+1
print,'------------------------------------------------------------------------------'
endfor ; end OD loop
; loop over ODs for panel 2 of figure
ic=0
print,'-------------------------------------------------------'
for f_number=2.1d0,8.4d0,2.1d0 do begin ; System f#
        fl=fl_fixed ; OD*f_number ; focal length cm
        ;f_number=fl/OD
        OD = fl/f_number
        print,'OD, fl, f# : ',OD,fl,f_number
;for OD=5.0d0,9.0d0,4.0d0 do begin ; Diameter of the objective
;	fl=fl_fixed ; OD*f_number ; focal length cm
;        f_number=fl/OD
;	print,'OD, fl, f# : ',OD,fl,f_number
; generate a PSF for the OD
	PSF_in=dblarr(3*512,3*512)
; pad it to 3x3, and fill it with the Airy function
	gofillthePSF,PSF_in,OD,fl,PSF,wavelength
        print,'Volume of PSF returning : ',total(PSF,/double)
; fold each Moon image with the PSF
	im_folded=foldit(PSF,im_org)
	tot_folded=total(im_folded,/double)
	; scale to same sum
	factor=tot_org/tot_folded
	;im_folded=im_folded*factor
        print,"Total im_folded:",total(im_folded,/double)
; extract profile and plot
	profile=im_folded[*,512/2.]
        org_profile=im_org[*,512/2.]
	diff_profile=profile-org_profile
	print,'RMS error : ',sqrt(mean(diff_profile^2))
	rat_profile=profile/org_profile
	if (ic eq 0) then plot,diff_profile/org_profile*100.0,xtitle="Image column number",ytitle="Irradiance Difference in %",/ylog,yrange=[1e-3,1e4],thick=4,xrange=[10,522],/nodata,color=fsc_color('black'),title=strcompress(string(wavelength,format='(f4.0)')+' nm'),POSITION=[0.25, 0.55, 0.90, 0.95]

	if (ic eq 0) then oplot,diff_profile/org_profile*100.0,color=fsc_color('red')
	if (ic gt 0) then oplot,diff_profile/org_profile*100.0,color=fsc_color('green'),thick=2
	oplot,[100,511],[10,10],color=fsc_color('blue'),thick=2
	oplot,[100,511],[1,1],color=fsc_color('blue'),thick=2
	oplot,[100,511],[0.1,0.1],color=fsc_color('blue'),thick=2
	oplot,[100,511],[0.01,0.01],color=fsc_color('blue'),thick=2
ic=ic+1
print,'------------------------------------------------------------------------------'
endfor ; end OD loop

end
