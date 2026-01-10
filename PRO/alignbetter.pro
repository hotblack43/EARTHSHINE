FUNCTION edgelambert,P
 common images,refim,im_in,xl,xr,x0,y0,yu,yd,len,w,imshifted
 im=im_in
 leftshift=p(0)
 upshift=p(1)
 imshifted=shift_sub(im,leftshift,upshift)
 diffim=refim-imshifted
 diffim=laplacian(diffim)
 tvscl,hist_equal(diffim)
 ;...............................................
 ; first horisontally
 ; first left
 subim=diffim(*,y0-w:y0+w)
 slice=avg(subim,1)
 edgeslice=slice(xl-len:xl+len)
 edgeheight1left=max(edgeslice)-min(edgeslice)
 ; then right
 slice=avg(subim,1)
 edgeslice=slice(xr-len:xr+len)
 edgeheight1right=max(edgeslice)-min(edgeslice)
 edgeheight1=max([edgeheight1left,edgeheight1right])
 ;...............................................
 ;then vertically 
 ; first below 
 subim=diffim(x0-w:x0+w,*)
 slice=avg(subim,0)
 edgeslice=slice(yd-len:yd+len)
 edgeheight2down=max(edgeslice)-min(edgeslice)
 ; then over
 edgeslice=slice(yu-len:yu+len)
 edgeheight2up=max(edgeslice)-min(edgeslice)
 edgeheight2=max([edgeheight2down,edgeheight2up])
 ;...............................................
 edgelambert=max([edgeheight1,edgeheight2])
 ;print,'p: ',p,' goal: ',edgelambert
 return,edgelambert
 end
 
 
 PRO goalignbetter,result,fmin
 common images,refim,im_in,xl,xr,x0,y0,yu,yd,len,w,imshifted
 im=im_in
 xl=48
 xr=342
 x0=198
 y0=290
 yu=440
 yd=146
 w=19
 len=25
 ; Define the fractional tolerance:
 ftol = 1.0d-6
 ; Define the starting point:
 P = [0.0d0,0.0d0]
 ; Define the starting directional vectors in column format:
 xi = TRANSPOSE([[1.0, 0.0],[0.0, 1.0]])
 ; Minimize the function:
 POWELL, P, xi, ftol, fmin, 'edgelambert',/DOUBLE
 print,format='(a,3(1x,f9.4))','Best shifts,FMIN: ',p,fmin
 result=shift_sub(im_in,p(0),p(1))
 return
 end
 
 
 common images,refim,im,xl,xr,x0,y0,yu,yd,len,w,imshifted
 file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1760145MOON_B_AIR.fits.gz'
 stack=readfits(file,h)
 l=size(stack,/dimensions)
 nims=l(2)
 refim=reform(stack(*,*,0))
 window,2
 tvscl,hist_equal(refim)
 niter=5
 for iter=1,niter,1 do begin
     newstack=refim
 for ims=1,nims-1,1 do begin
     im=reform(stack(*,*,ims))
     window,0
     goalignbetter,result,fim
     newstack=[[[newstack]],[[result]]]
     endfor
     writefits,strcompress('iter_'+string(iter)+'refim_new_MOVEME.fits',/remove_all),refim
     refim=avg(newstack,2)
     endfor ; iteration loopp
 end
