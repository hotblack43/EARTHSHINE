PRO get_PSF_CIE,l,PSF,scale
PSF=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r=sqrt((i-l(0)/2)^2+(j-l(1)/2.)^2)
		PSF(i,j)=exp(-abs(r/scale))
	endfor
endfor
; shift the PSF to the origin
PSF=shift(PSF,l(0)/2,l(1)/2.)
; normalize it
PSF=PSF/total(PSF,/double)
return
end

PRO fold_image_with_PSF,imin,l,folded_image,PSF
folded_image=fft(fft(imin,-1,/double)*fft(PSF,-1,/double),1,/double)
folded_image=sqrt(folded_image*conj(folded_image))
folded_image=double(folded_image)
folded_image=folded_image/total(folded_image)*total(imin)
return
end

imin=readfits('OUTPUT/IDEAL/ideal_LunarImg_0000.fit')
imin=imin(0:1023,0:1023)	; must be 2^N
imin=rebin(imin,256,256)
l=size(imin,/dimensions)
sky=imin*0.0
w=imin*0.0+1.0
conv_wf=imin*0.0+1.0
conv_sup=imin*0.0+1.0
obj_sup=imin*0.0+1.0
psf_sup=imin*0.0+1.0
obj=imin	; base this on observed, not ideal, image!
; Define array dimensions:  
nx = l(0)& ny = l(1)
; Create X and Y arrays:  
X = FINDGEN(nx) # REPLICATE(1.0, ny)  
Y = REPLICATE(1.0, nx) # FINDGEN(ny)  
; Create gaussian Z:  
psf =  exp(-((x-nx/2)^2+(y-ny/2)^2)/200.)	; simple guess at PSF
scale=5.0
get_PSF_CIE,l,PSF,scale
fold_image_with_PSF,imin,l,folded_image,PSF

; modify header and save
if_double=0
im=folded_image
if (if_double eq 0) then im=float(im/max(im)*(2L^16-1))
if (if_double eq 1) then im=double(im/max(im)*(2L^16-1))
writefits,'CIE_folded_im',im


if (if_double eq 0) then im=float(conv_wf)
if (if_double eq 1) then im=double(conv_wf)
writefits,'conv_wf',im

im=folded_image ; starting guess for the cleaned image
if (if_double eq 0) then im=float(im/max(im)*(2L^16-1))
if (if_double eq 1) then im=double(im/max(im)*(2L^16-1))
writefits,'obj',float(im)

; shift the PSF to the origin
PSF_sh=shift(PSF,l(0)/2,l(1)/2.)
im=psf_sh
if (if_double eq 1) then  im=double(im/max(im)*(2L^16-1))
if (if_double eq 0) then  im=float(im/max(im)*(2L^16-1))
writefits,'psf',float(im)

im=sky
if (if_double eq 0) then im=float(im)
if (if_double eq 1) then im=double(im)
writefits,'sky',float(im)

if (if_double eq 0) then ones=float(im*0+1)
if (if_double eq 1) then ones=double(im*0+1)
writefits,'w',float(ones)
writefits,'CIE_folded_im_sup',float(ones)
writefits,'CIE_folded_im_wf',float(ones)
writefits,'psf_sup',float(ones)
writefits,'obj_sup',float(ones)
writefits,'conv_sup',ones
end
