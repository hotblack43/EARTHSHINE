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
openw,12,'res.dat'
for power=0.3,5.0,0.1 do begin
get_pdf_King,l,psf,power
z=fft(psf,-1)
powK=abs(z)*1e14/320
;...................
;file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_new_349_float.FIT'
; get the folded observed image
file='H:\Processed\KING_0040.fit'
c_image=readfits(file)
c_image=congrid(c_image,256,256)
z=fft(c_image,-1,/double)
pow=abs(z) 		; |A(u)|
; get the ideal version of the observed folded image
file_ideal='H:\aaRaw\ideal_LunarImg_0040.fit'
ideal=readfits(file_ideal)
ideal=congrid(ideal,256,256)
; do the FFT of theideal image, an dthe power
z=fft(ideal,-1,/double)
powi=abs(z)    ; |H(u)|
; -- eqn 52.9 in Bates & McDonnell
absH=sqrt(pow/powi)
;------------ plots
!P.MULTI=[0,1,2]
device,decomposed=0
loadct,7
sc=alog(bytscl(pow))
;contour,sc,charsize=1.2,title='|A(u)|',/cell_fill,nlevels=101
sci=alog(bytscl(powi))
;contour,sci,charsize=1.2,title='|Ftilde(u)|',/cell_fill,nlevels=101
;contour,(bytscl(pow/powi)),charsize=1.2,title='|A(u)|/|Ftilde(u)|',/cell_fill,nlevels=101
surface,absH,charsize=3,title='|H(u)|'
;surface,powK,charsize=3,title='|King(u)|'
smooratio=smooth(powK/absH,9,/edge_truncate)
lookmax=50
surface,smooratio,/zlog,charsize=3,title='|H(u)|/|King(u)|'
errmess=alog(max(smooratio(0:lookmax,0:lookmax)))-alog(min(smooratio(0:lookmax,0:lookmax)))
errmess=alog(smooratio(lookmax,lookmax))-alog(smooratio(0,0))
print,power,errmess
printf,12,power,errmess
endfor
close,12
data=get_data('res.dat')
p=reform(data(0,*))
y=reform(data(1,*))
plot,p,y,xtitle='King profile power',ytitle='log error',charsize=2
end