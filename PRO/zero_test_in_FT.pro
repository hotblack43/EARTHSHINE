PRO generate_two_arrays,ncols,nrows,row,col
row=transpose(indgen(nrows))
for i=0,ncols-2,1 do row=[row,transpose(indgen(nrows))]
col=indgen(ncols)
for i=0,nrows-2,1 do col=[[col],[indgen(ncols)]]
return
end

PRO get_pdf_King,l,pdf,power
; first set up the arrays that indicate column and row numbers
common radius,radius
ncols=l(0)
nrows=l(1)
generate_two_arrays,ncols,nrows,row,col
;
pp=power
;
half_i=l(0)/2.
half_j=l(1)/2.
;
deltax=col-half_i
deltay=row-half_j
radius=sqrt(deltax^2+deltay^2)
pdf=dblarr(l(0),l(1))*0.0d0+1.0d0
idx=where(radius gt 1.0)
pdf(idx)=1./radius(idx)^pp
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2.,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end

PRO get_pdf_Gaussian,l,pdf,sigma
pdf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2=(i-l(0)/2)^2+(j-l(1)/2.)^2
		pdf(i,j)=exp(-r2/abs(sigma))
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end

PRO get_pdf_CIE,l,pdf,scale
pdf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r=sqrt((i-l(0)/2)^2+(j-l(1)/2.)^2)
		pdf(i,j)=exp(-abs(r/scale))
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end

;------------------- test for zeros in FFT(psf)
!P.MULTI=[0,1,1]
l=[256,256]
;.......................
scale=6
get_pdf_CIE,l,psf,scale & psf=psf-min(psf) & psf=psf/total(psf)
;.....................
sigma=2
get_pdf_Gaussian,l,psf,sigma& psf=psf-min(psf) & psf=psf/total(psf)
;...........................
power=2.0 ; 1.2 ; 1.5
get_pdf_King,l,psf,power & psf=psf-min(psf) & psf=psf/total(psf)
;........................
psf=shift(psf,40,50)
z=fft(psf,-1)
pow=float(z*conj(z))
plot,pow(*,0),/ylog


file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_new_349_float.FIT'
file='H:\Processed\KING_0040.fit'
file_ideal='H:\aaRaw\ideal_LunarImg_0040.fit'
ideal=readfits(file_ideal)
c_image=readfits(file)
c_image=congrid(c_image,256,256)
ideal=congrid(ideal,256,256)
c_image=c_image-min(c_image)
c_image=c_image/total(c_image)
ideal=ideal-min(ideal)
ideal=ideal/total(ideal)
z=fft(c_image,-1)
pow=float(z*conj(z))
oplot,pow(0,*),thick=2
z=fft(ideal,-1)
powi=float(z*conj(z))
 oplot,powi(0,*),thick=2
end