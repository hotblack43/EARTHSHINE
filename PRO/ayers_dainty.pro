PRO impose_non_negativity,im,errlim
common sizes,l
N=l(0)*l(1)
im_in=im
idx=where(im lt 0)
err=1000
if (idx(0) ne -1) then err=abs(total(im(idx)))
count=0
energy=total(im_in)/N	; mean pixel value
while (idx(0) ne -1 and abs(err) gt errlim and count lt 1000) do begin
;while (idx(0) ne -1 and abs(err/energy) gt errlim and count lt 1000) do begin
  	im(idx)=0.0 ; set all negative pixels to zero
  	negs2=total(im_in-im) ; calculate the total of the negs
  	err=negs2/N   ; E/N the average pixel error
	im=im+err	; eqn 3
	idx=where(im lt 0)
	count=count+1
endwhile
  	if (idx(0) ne -1) then im(idx)=0.0 ; set all negative pixels to zero
return
end
PRO get_mask,x0,y0,radius,mask
  ; build a 1/0 mask that is a circle (center x0,y0) and radius r with 
  ; 1's outside radius and 0's inside
  common sizes,l
  nx=l(0) & ny=l(1) & mask=fltarr(nx,ny)
  for i=0,nx-1,1 do begin
      for j=0,ny-1,1 do begin
          rad=sqrt((i-x0)^2+(j-y0)^2)
          if (rad ge radius) then mask (i,j)=1 else mask(i,j)=0.0
          endfor
      endfor
; blank bits at NP and SP across the frame
ylo=min([511,y0+radius*0.7])
mask(*,ylo:511)=0
ylo=max([0,y0-radius*0.7])
mask(*,0:ylo)=0
  return
  end
PRO setupsupportforlunardisc,c_image,mask
help,c_image
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
return
end

PRO get_circle,l,coords,circle,radius,maxval
circle=fltarr(l)*0.0
astep=0.1d0
x0=coords(0)
y0=coords(1)
for angle=0.0d0,360.0d0-astep,astep do begin
	x=x0+radius*cos(angle*!dtor)
	y=y0+radius*sin(angle*!dtor)
print,x,y
	circle(x,y)=maxval
endfor
return
end
PRO getimage,c_image
 common sizes,l
 common imagedescrip,noise
;-----------------------

;file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_new_349_float.FIT'
;file='H:\Processed\KING_0040.fit'
;-----------------------
; file='/home/pth/SCI/moon/ANDREW/stacked_new_349_float.FIT'
 file='observed.fits'
;-----------------------
 c_image=readfits(file)
;.............................
; add some noise if you want
; c_image=c_image/max(c_image)*50000.+10.*randomn(seed)
;.............................
 l=size(c_image,/dimensions)
 ll=min(l)
 c_image=c_image(0:ll-1,0:ll-1)	; clip so its square
 c_image=congrid(c_image,512,512) ; resize to 2^n
 ;c_image=congrid(c_image,128,128) ; resize to 2^n
 l=size(c_image,/dimensions)
;--------------------------------------------------------
; measure the noise in the high-pass filtered image
 nn=3
 noise=c_image-smooth(c_image,nn,/edge_truncate)
 noise=sqrt(mean(noise^2))
 noise=10.0
 return
 end
PRO switch_f_and_g,f,g
common fgswitch,fg_switch
  	hold=f
 	f=g
	g=hold
	if (fg_switch eq 0) then begin
		fg_switch=1
	endif else begin
		fg_switch=0
	endelse
	return
end

PRO do_residuals,f,g,c_image,shouldbeoriginal,iter,l,old_err
        shouldbeoriginal= double(fft(fft(f,-1)*fft(g,-1),1))
        residuals = c_image - shouldbeoriginal
        rse=sqrt(total(residuals^2))/l(0)/l(1) & print,iter,rse
        window,3,title='residuals',xsize=l(0),ysize=l(1) & tvscl,residuals
         if (rse lt old_err) then begin
; write out the best-yet results
                writefits,'f.fit',double(f)
                writefits,'g.fit',shift(double(g),l(0)/2.,l(1)/2.)
                old_err=rse
         endif
	openw,11,'error.dat',/append
	printf,11,rse,iter
	close,11
data=get_data('error.dat')
y=reform(data(0,*))
x=reform(data(1,*))
nx=n_elements(x)
if (nx gt 2) then begin
	window,5
	if (nx lt 200) then plot_io,x,y,psym=7,charsize=2,xtitle='Iteration',ytitle='Error per pixel'
	if (nx ge 200) then plot_io,x,y,psym=4,charsize=2,xtitle='Iteration',ytitle='Error per pixel'
endif
return
end

PRO make_starting_guess_for_f,f,c_image,totc_image,mask
 common imagedescrip,errlim
; set up the starting guess of image f
 l=size(c_image,/dimensions)
	if (l(0) ne l(1)) then stop
 n=l(0)
 x=indgen(N) # replicate(1,N)
 y=replicate(1,N) # indgen(N)
 r=sqrt((x-n/2)^2+(y-n/2) ^2)
f=exp(-r^2/100.)
f=smooth(c_image,3,/edge_truncate)
;f(where(f lt 0.1*max(f)))=0.0
f=randomu(seed,n,n)
; constrain f here ..
impose_non_negativity,f,errlim
f=f*mask
;------------ normalize f
 f=f/total(f,/double)*totc_image
 return
 end


;--------------------------------------------------------------------------
; Aplies the iterative deconvolution of
; Ayers and Dainty, 1988, Optics Letters 13, p.547-549.
; Incorporating tricks from Jefferies
; will result in two output FITS files - the estimets of the
; deconvolved image (f.fit) and the PSF (g.fit)
;--------------------------------------------------------------------------
 common sizes,l
 common imagedescrip,errlim
 common mask,mask
 common iternews,iter
 common fgswitch,fg_switch
 fg_switch=0	; start with f=f and g=g
 niter=60
 old_err=1d33
 beta=0.05d0
 cut=47.
 allow_fg_switch=0
;--------------------------------------------------------------------------
FILE_DELETE,'error.dat',/QUIET
;--------------------------------------------------------------------------
 getimage,c_image
;...................
; set up the support function for f - i.e. find the rim of the moon
setupsupportforlunardisc,c_image,mask
;...................
print,'Noise per pixel is:',errlim
totc_image=total(c_image)
writefits,'thiswasinput.fit',c_image
;...........................
capC=fft(c_image,-1,/double)
window,0,title='convolved image',xsize=l(0),ysize=l(1) & tvscl,c_image
;...........................
make_starting_guess_for_f,f,c_image,totc_image,mask
writefits,'thiswasfirstguessfor_f.fit',f
;...........................
; Main iterative loop starts with f as f and g as g
;...........................
for iter=0,niter-1,1 do begin
;.............................
;         STEP 1
;.............................
     capF=fft(f,-1,/double)
;.............................
;         STEP 2
;.............................
    capG=capC/capF
;.............................
;         STEP 3
;.............................
    support_g,capG,cut
    g=double(fft(capG,1,/double))
;.............................
;         STEP 4
;.............................
    impose_non_negativity,g,errlim
;.............................
;         STEP 5
;.............................
    capG=fft(g,-1,/double)
  ;	support_g,capG,cut
;.............................
;         STEP 6, elaborate version
;.............................
 idx=where(abs(capG) le  abs(capC) and f gt errlim)
 jdx=where(abs(capG) gt  abs(capC) and f gt errlim)
 if (idx(0) ne -1) then capF(idx)=1./((1.0-beta)/capF(idx)+beta*(capG(idx)/capC(idx)))
 if (jdx(0) ne -1) then capF(jdx)=(1.0-beta)*capF(jdx)+beta*(capC(jdx)/capG(jdx))
;.............................
;         STEP 6, simple version
;         capF=capC/capG
;.............................
;.............................
;         STEP 7, simple version
;.............................
        ff=fft(capF,1,/double)
        f=double(ff)
;.............................
;         STEP 8
;.............................
     impose_non_negativity,f,errlim
;.................
		f=f*mask
;................. report on cycle
    do_residuals,f,g,c_image,shouldbeoriginal,iter,l,old_err
    show_f,f
    show_g,g
    print,total(f),total(g),total(f)/total(g)
    g=g/total(g)
 endfor
 writefits,'folded.fit', shouldbeoriginal
 end

