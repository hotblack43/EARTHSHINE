; Driver for the flat-fielding method of Dalrymple, Bianda, and Wiborg
;
; This code calls the mflat_make_flat subroutine with a simulated observation
;-----------------------------------------------------------------------------
; first read in an image
file='MSO_observed.fit'
im=double(readfits(file))
; find the dimensions of the image, allowing for rectangular images
l=size(im,/dimensions)
n=l(0)	; number of columns
m=l(1)	; number of rows
; simulate a flat field with noise and a sloping plane
r1=randomn(seed,n,/double)/8.+.5
r2=randomn(seed,m,/double)/8.+.5
er=r1#r2;+findgen(n,m)/float(n)/float(m)/20.
er=er/mean(er)	; give the flat field unit mean value
c_n=dindgen(m)*0.0+1.0
c_m=dindgen(n)*0.0+1.0
a=total(im,2)	; sum along 
; calculate the images that are 'smeared' along columns and along rows
b=total(im,1)	; sum along 
md=(a#c_n)*er
ma=(b##c_m)*er
; calculate the flat field
mask=im*0+1
ff=mflat_make_flat(md,ma,mask)
; Plot the results
!P.MULTI=[0,3,2]

surface,im,charsize=3,title='im',/lego,min=0
surface,md,charsize=3,title='md',/lego
surface,ma,charsize=3,title='ma',/lego
surface,ff,charsize=3,title='ff',/lego
print,moment(ff)
surface,im/ff,charsize=3,title='im/ff',min=0,/lego
end
