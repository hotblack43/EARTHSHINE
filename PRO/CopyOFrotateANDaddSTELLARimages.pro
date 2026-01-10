;+
; NAME:
;  lowess
; PURPOSE:
;  Lowess smoothing of data.
; DESCRIPTION:
;
;  This algorithm was gleaned from a description of LOWESS, standing
;  for LOcally WEighted Scatterplot Smoother, found in "The Elements of
;  Graphing Data", by William S. Cleveland, Wadsworth Advanced Books and
;  Software.  This implementation is probably not the same as the one
;  described.  I have tried to include the provision for using different
;  weighting functions.  At the time of writing I don't know what effect
;  different functions have upon the smoothing process.  This procedure
;  in itself is not intended to be robust (as defined by Cleveland). By
;  including the possiblity of varying weights for the data points it is
;  possible to acheive robustness by multiple calls of this routine.
;
; CATEGORY:
;  Numerical
; CALLING SEQUENCE:
;  lowess,x,y,width,ysmoo,WEIGHT=weight
; INPUTS:
;  x      - Independant variable values.
;  y      - Dependant variable values.
;  width  - Width of smoothing function (in same units sa X).
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORD INPUT PARAMETERS:
;  NEWX   - If provided, the smoothed curve is computed over this input
;             range of x values rather than the input x range.  ysmoo
;             will have the same length as NEWX if it is provided.
;  ORDER  - Order of polynomial fit during the lowess smoothing. (default=1)
;  WEIGHT - Weight to use for each point (default is to have equal weight)
;
; OUTPUTS:
;  ysmoo  - Smoothed version of Y, same number of points as input x and y.
;  yband  - 1 S.D. interval for each value of y
; KEYWORD OUTPUT PARAMETERS:
;
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;  By default, the weighting function is triangular where the weight is
;  1 at the output point location, and drops linearly to zero +/- width from
;  the output point.
;
; MODIFICATION HISTORY:
;  98/06/16, Written by Marc W. Buie, Lowell Observatory
;  2001/02/01, MWB, changed polyfitw call to poly_fit equivalent
;  2006/17/02, PTH added YBAND in call to poly_fit and to call list
;-
pro lowess,x,y,width,ysmoo,WEIGHT=weight,ORDER=order,NEWX=newx,YBAND=yband

   if badpar(x,[2,3,4,5],1,CALLER='LOWESS: (x) ',npts=nx) then return
   if badpar(y,[2,3,4,5],1,CALLER='LOWESS: (y) ',npts=ny) then return
   if badpar(width,[2,3,4,5],0,CALLER='LOWESS: (width) ') then return
   if badpar(weight,[0,2,3,4,5],1,CALLER='LOWESS: (WEIGHT) ', $
                       default=replicate(1.0,nx),npts=nw) then return
   if badpar(order,[0,2,3],0,CALLER='LOWESS: (ORDER) ',default=1) then return
   if badpar(newx,[0,2,3,4,5],1,CALLER='LOWESS: (NEWX) ',default=-1) then return

   if nx ne ny then begin
      print,'LOWESS: lengths of x and y must match'
      return
   endif

   TRIBASE=0.01

   if nw ne nx then begin
      print,'LOWESS: length of weight vector must match x and y'
      return
   endif

   if newx[0] eq -1 and n_elements(newx) eq 1 then $
      nnx=0 $
    else $
      nnx=n_elements(newx)

   ; return smoothed points for all input X
   if nnx eq 0 then begin
      ysmoo = y * 0.
      for i=0,nx-1 do begin

         ; Set limits on smoothing width
         xl = x[i] - width
         xr = x[i] + width

         z=where(x ge xl and x le xr, count)

         if count le order+1 then begin
            ysmoo[i] = y[i]
         endif else begin
            w = weight[z]*(1.0 - ((1.0-TRIBASE)/width) * abs(x[z]-x[i]))
;            coeff=polyfitw(x[z]-x[i],y[z],w,order,status=status)
            coeff=poly_fit(x[z]-x[i],y[z],order, $
                           measure_errors=sqrt(1.0/w),status=status, yband=yband,/DOUBLE)
            ysmoo[i] = poly(0.0,coeff)
         endelse
      endfor

   ; return smoothed points for only the requested X locations
   endif else begin
      ysmoo = fltarr(nnx)
      for i=0,nnx-1 do begin

         ; Set limits on smoothing width
         xl = newx[i] - width
         xr = newx[i] + width

         z=where(x ge xl and x le xr, count)

         if count eq 1 then begin
            ysmoo[i] = y[z[0]]
         endif else if count le order+1 then begin
            interp,x,y,newx[i],newy
            ysmoo[i] = newy
         endif else begin
            w = weight[z]*(1.0 - ((1.0-TRIBASE)/width) * abs(x[z]-newx[i]))
;            coeff=polyfitw(x[z]-newx[i],y[z],w,order,status=status)
            coeff=poly_fit(x[z]-newx[i],y[z],order, $
                           measure_errors=sqrt(1.0/w),status=status,yband=yband,/DOUBLE)
            ysmoo[i] = poly(0.0,coeff)
         endelse
      endfor
   endelse

end

PRO check,win,image,coords,names
; check if coordinates are too close to the edge of the image
n=n_elements(names)
l=size(image,/dimensions)
for i=0,n-1,1 do begin
    if (coords(0,i) lt win or coords(0,i) gt l(0)-win or coords(1,i) lt win or coords(1,i) gt l(1)-win) then names(i)='Hostesaft'
endfor
; remove those that are too close
idx=where(names ne 'Hostesaft')
if (idx(0) ne -1) then  coords=coords(*,idx)
if (idx(0) ne -1) then  names=names(idx)
return
end

PRO  get_high_points,win,npeaks,image,coords,names
; routine to find first guesses for where the stars are located in the image
l=size(image,/dimensions)
pars=[3600.,20000.,1.,1.,l(0)/2.,l(1)/2.,-0.1]
names=strarr(npeaks)
coords=fltarr(2,npeaks)
nowimage=image
for ipeak=0,npeaks-1,1 do begin
    Result = GAUSS2DFIT(nowimage, pars, /TILT )
    print,format='(i3,7(1x,g20.8),1x,i7)',ipeak,pars,nowimage(pars(4),pars(5))
    nowimage=nowimage-Result
    names(ipeak)=strcompress('Star '+string(ipeak))
    coords(0,ipeak)=pars(4)
    coords(1,ipeak)=pars(5)
endfor
;surface,nowimage
check,win,image,coords,names
return
end



;============================================================
; IDL code to analyze intensity dropoff around stellar images
; Version 1.0 November 10 2006
;============================================================
set_plot,'ps
device,filename='Fitted_rotated_stars.ps'
npeaks=5   ; Set number of peaks to fit
win=19          ; Set half-width of window to use - must use odd number
;--set path to image file
path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\May29\obs1\'
image=readfits(path+'IMG7.FIT')
; Trim image to avoid bad stuff (can be removed if images are well-behaved)
part1=image(0:198,*)
part2=image(279:544,*)
image=[part1,part2]
help,part1,part2,image

;
get_high_points,win,npeaks,image,coords,names
npeaks=n_elements(names)
!P.MULTI=[0,1,1]
for ipeak=0,npeaks-1,1 do begin
    a=coords(0,ipeak)
    b=coords(1,ipeak)
    subim=image(a-win:a+win,b-win:b+win)
    ; subtract sky background fitted by a poly surface
skyfit,subim,skyimage, XORDER=2,YORDER=2,HICLIP=0.9
subim=subim-skyimage
    name=names(ipeak)

    contour,alog(image),nlevels=11
    xyouts,a,b,'Current star'
    subim=image(a-win:a+win,b-win:b+win)
        ; subtract sky background fitted by a poly surface
skyfit,subim,skyimage, XORDER=2,YORDER=2,HICLIP=0.9
subim=subim-skyimage
    surface,subim,charsize=2,title='Selected subframe'

    pars=[3600.,20000.,1.,1.,win/2.,win/2.,-0.1]
    Result = GAUSS2DFIT( subim, pars, /TILT)
     Result = GAUSS2DFIT( subim, pars, /TILT )
    print,format='(a,i3,7(1x,g20.8),1x,i7)','Fitted parameters:',ipeak,pars,max(subim)
    surface,Result,charsize=2,title='Fitted 2D Gaussian'
    surface,subim-Result,charsize=2,zrange=[!Z.CRANGE],title='residuals'
; perform rotation summation
    sum=subim*0.0d0
    count=0.
    for rot_angle=0.,360.,0.333 do begin
        Rotated = ROT( subim, rot_angle, 1.,pars(4),pars(5),CUBIC=-.5)
        sum=sum+Rotated
        count=count+1.
    endfor
    str=''
    if (max(subim) eq  65535)  then str='SATURATED'
    surface,sum/count,/zlog,title='Sum of 360 rotations'+str
    plot_oo,sum(win,win:2*win)/count,xrange=[0.1,win],xstyle=1,psym=-7,title=name

;perform scatter plotting
    l=size(subim,/dimensions)
    openw,44,'plotme.dat'
    for icol=0,l(0)-1,1 do begin
        for irow=0,l(1)-1,1 do begin
            dist=sqrt((icol-pars(4))^2+(irow-pars(5))^2)
            printf,44,dist,subim(icol,irow)
        endfor
    endfor
    close,44
    openr,44,'plotme.dat'
    radial=31415.
    counts=31415.
    while not eof(44) do begin
        readf,44,a,b
        radial=[radial,a]
        counts=[counts,b]
    endwhile
    idx=where(counts ne 31415.)
    radial=radial(idx)
    counts=counts(idx)
    close,44
    kdx=where(radial gt 11 and radial lt 17)
    if (kdx(0) ne -1) then print,'Stddev of anulus at 13-17 pixels is:',stddev(counts(kdx))
    plot_oo,radial,counts,psym=4,xtitle='Distance from star (pixels)',ytitle='counts',title=names(ipeak),yrange=[1,max(counts)]
endfor
; fit psf_stacked
dw=11
    psfstack,float(image),reform(coords(0,*)),reform(coords(1,*)),psf,DW=dw,SNR=100
    surface,psf,title='PSF found by "psf_stacked.pro"',/zlog,zrange=[1e-6,1]
    ; produce a scatterplot for this PSF as function of radius
        pars=[0.,1.,4.,4.,dw,dw,-0.1]
    Result = GAUSS2DFIT(psf, pars, /TILT)
    print,'PSF fitted 2d agussian:',pars

    device,/close
print,'Finished'
end