 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

 PRO get_radius,header,radius
 idx=where(strpos(header, 'RADIUS') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 RADIUS=float(strmid(str,16,15))
 return
 end

 PRO get_discy0,header,discy0
 idx=where(strpos(header, 'DISCY0') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 discy0=float(strmid(str,16,15))
 return
 end

 PRO get_discx0,header,discx0
 idx=where(strpos(header, 'DISCX0') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 discx0=float(strmid(str,16,15))
 return
 end

 PRO get_cycletime,header,acttime
 idx=where(strpos(header, 'ACT') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 acttime=float(strmid(str,16,15))
 return
 end

 PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end

 PRO get_measuredexptime,header,measuredtexp
 idx=where(strpos(header, 'DMI_ACT_EXP') ne -1)
 str='999'
 measuredtexp=911
 if (idx(0) ne -1) then begin
	str=header(idx(0))
 	measuredtexp=float(strmid(str,24,8))
 endif
 return
 end

PRO get_times,h,exptime
get_EXPOSURE,h,exptime
end

 PRO getbasicfilename,namein,basicfilename
 print,namein
 basicfilename=strmid(namein,strpos(namein,'.')-7)
 ;basicfilename=strmid(namein,strpos(namein,'2455'))
 return
 end

 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end


PRO gofindDSandBSinboxes,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
; determine if BS is to the right or the left of the center
; iflag = 1 means position 1
; iflag = 2 means position 2
if (iflag eq 1) then ipos=4./5.
if (iflag eq 2) then ipos=2./3.
 BS=911.999
 DS=911.999
if (cg_x gt x0) then begin
 if ((cg_x-w ge 0 and cg_x+w le 511 and cg_y-w ge 0 and cg_y+w le 511) and (x0-radius*ipos-w ge 0 and x0-radius*ipos+w le 511 and y0-w ge 0 and y0+w le 511)) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*ipos-w:x0-radius*ipos+w,y0-w:y0+w))
endif
endif
if (cg_x lt x0) then begin
 if ((cg_x-w ge 0 and cg_x+w le 511 and cg_y-w ge 0 and cg_y+w le 511) and (x0+radius*ipos-w ge 0 and x0+radius*ipos+w le 511 and y0-w ge 0 and y0+w le 511)) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*ipos-w:x0+radius*ipos+w,y0-w:y0+w))
endif
endif
return
end

PRO bestBSspotfinder,im,cg_x,cg_y
; find the coordinates of a spot near the brightest part of the BS
 l=size(im,/dimensions)
smooim=median(im,5)
idx=where(smooim eq max(smooim))
coo=array_indices(smooim,idx)
cg_x=coo(0)
cg_y=coo(1)
if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
return
end

PRO get_mask,FLIPneeded,x0,y0,radius,mask
 ; build a 1/0 mask that is a circle (center x0,y0) and radius r with 1's outside radius and 0's inside
 common sizes,l
 nx=l(0) & ny=l(1) & mask=fltarr(nx,ny)
 for i=0,nx-1,1 do begin
     for j=0,ny-1,1 do begin
         rad=sqrt((i-x0)^2+(j-y0)^2)
         if (rad ge radius) then mask (i,j)=1 else mask(i,j)=0.0
         endfor
     endfor
; blank bits at NP and SP across the frame
ylo=min([511,y0+radius*0.2])
mask(*,ylo:511)=0
ylo=max([0,y0-radius*0.2])
mask(*,0:ylo)=0
; omit BS part of the sky in the mask
;if (FLIPneeded ne 1) then mask(x0:511,*)=0
;if (FLIPneeded eq 1) then mask(0:x0-1,*)=0
;print,'Masked the BS part of the sky-mask'
 return
 end


 
 PRO gogetjulianday,header,jd
 idx=strpos(header,'JULIAN')
 str=header(where(idx ne -1))
 jd=double(strmid(str,15,15))
 return
 end
 
 
 FUNCTION get_mean_flux_in_box,im_in
 im=im_in
 im=smooth(im,7,/edge_truncate)
 xl=362
 xr=385
 yd=220
 yu=304
 subim=im(xl:xr,yd:yu)
 idx=where(finite(subim) eq 1)
 ; RMSE
 res=sqrt(mean(subim(idx)^2))
 return,res
 end
 
 
 FUNCTION get_errorINwholeIMAGE,im_in
 im=im_in
 im=smooth(im,7,/edge_truncate)
 idx=where(finite(im) eq 1)
 ; RMSE
 res=sqrt(mean(im(idx)^2))
 return,res
 end 

PRO getthesourceimagefromtheobservedimage,observed,im,a
 common cutoff,cuttoffval
 ; subtracting the current guess for the offset
;a=mean(observed(0:20,0:20))
 im=observed-a
 ; generate the '1/75th' source image
 factor=cuttoffval
 idx=where(im lt max(smooth(im,3))/factor)
 im(idx)=0
 writefits,'source.fits',im
return
end

PRO getthetrialimage,a,b,alfa,observed,trialim
 str='./justconvolve source.fits source_folded_out.fits '+string(alfa)
 spawn,str
 source_folded=readfits('source_folded_out.fits',/silent)
;b=(total(observed,/double))/total(source_folded+a,/double)
 trialim=a+b*source_folded
return
end

 FUNCTION minimize_me_2, X, Y, P
; object function for case:
 ; we supply offset, fcator and alfa and minimize on the sum² of 
; residuals on sky (times mask).
; returns the error model - i.e. the image of the residuals
; The independent variables are X and Y
;....................................................
 common names,filename
 common vizualiz,ifviz
 common ims,observed,source,residual,mask,trialim,cleanup
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b,idealbiasinbox
 common cutoff,cuttoffval
 common circle,x0,y0,radius
 common centerofgravity,cg_x,cg_y
;.........parse the input guesses for the parameters..........
 a=p(0)
 alfa=p(1)
 b=p(2)
print,'in minimize_me_2 p:',p
; first determine if DS is on the right or the left side of the disc
ifleft=0 & ifright=0
if (cg_x gt x0) then ileft=1
if (cg_x lt x0) then iright=1
; Define sky patch
if (ileft eq 1) then begin
xSkyPath=(x0-radius)/2.
endif else begin
xSkyPath=(512+(x0+radius))/2.
endelse
ySkyPatch=y0
print,'Patch coords: ',xSkyPath,ySkyPatch
w=7
subim=observed(xSkyPath-w:xSkyPath+w,ySkyPatch-w:ySkyPatch+w)
sky=mean(subim)
;.............................................................
; generate a Source image from the observed image 
getthesourceimagefromtheobservedimage,observed,im,sky
; im is the source and needs to be convolved with the PSF
str='./justconvolve source.fits source_folded_out.fits '+string(alfa)
spawn,str
source_folded=readfits('source_folded_out.fits',/silent)
;.............................................................
;; im is the source and needs to be convolved with the PSF
; str='./justconvolve source.fits source_folded_out.fits '+string(alfa)
; spawn,str
; source_folded=readfits('source_folded_out.fits',/silent)
print,'In minimize_me_2 I have (a,b)=',a,b
;.............................................................
; then use a,b to create the trial image
trialim=a+b*source_folded
;.............................................................
; get residuals wrt observed image
 cleanup=observed-trialim
 writefits,'cleanup.fits',cleanup & writefits,'mask.fits',mask
 ;
 residual=(cleanup)/observed*100.0
 ;residual=cleanup
;......................................................
; Evaluate size of residuals
 idx=where(finite(residual) ne 1)
 if (idx(0) ne -1) then residual(idx)=0.0
 ; evaluate model fit 
 errorwholeimage=get_errorINwholeIMAGE(mask*residual)
 ; print out some results
 print,'----------------->',p,b,' error whole image times mask: ',errorwholeimage
 if (ifviz eq 1 ) then plot3things,filename,observed,trialim,cuttoffval,alfa
;......................................................
 thing=residual^2*(mask)
 writefits,'thing.fits',thing
 return, thing
 END

 
 FUNCTION minimize_me, X, Y, P
; object function for case:L we want the residuals on the sky (*mask) be minimized
 common names,filename
 common vizualiz,ifviz
 l=size(x,/dimensions)
 n=l(0)
 ; should return the error model - i.e. the image of the residuals
 common ims,observed,source,residual,mask,trialim,cleanup
 common errs,errorwholeimage,errorinabox,idealerrorinabox,b,idealbiasinbox
 common cutoff,cuttoffval
 ; The independent variables are X and Y
 a=p(0) & alfa=p(1)
 ; generate a Source image from the observed image 
 ; subtracting the current guess ofr the offset
 im=observed-a
 ; generate the '1/75th' source image
 factor=cuttoffval
 idx=where(im lt max(smooth(im,3))/factor)
 im(idx)=0
 writefits,'source.fits',im
 ; then use that estimate of the source to fold etc
 str='./justconvolve source.fits source_folded_out.fits '+string(alfa)
 spawn,str
 source_folded=readfits('source_folded_out.fits',/silent)
 b=(total(observed,/double))/total(source_folded+a,/double)
 trialim=a+b*source_folded
 ; get residuals wrt observed image
 cleanup=observed-trialim
 ; set up the removal of a linear fitted surface
 writefits,'cleanup.fits',cleanup & writefits,'mask.fits',mask
; find the proper fitted linear surafce from the observed image
;findafittedlinearsurface,cleanup,thesurface
; but ADD the surface to the trial image
; trialim=trialim+thesurface
 cleanup=observed-trialim
 ;
 residual=(cleanup)/observed*100.0
 idx=where(finite(residual) ne 1)
 if (idx(0) ne -1) then residual(idx)=0.0
 ; evaluate model fit 
 errorwholeimage=get_errorINwholeIMAGE(mask*residual)
 ; print out some results
 print,'----------------->',p,b,errorwholeimage
 if (ifviz eq 1 ) then plot3things,filename,observed,trialim,cuttoffval,alfa 
 return, (residual*mask)
 END

PRO get_info_from_header,header,str,valout
if (str eq 'RADIUS') then begin
        get_radius,header,valout
	return
endif
if (str eq 'DISCY0') then begin
        get_discy0,header,valout
	return
endif
if (str eq 'DISCX0') then begin
        get_discx0,header,valout
	return
endif
if (str eq 'ACT') then begin
        get_cycletime,header,valout
	return
endif
if (str eq 'UNSTTEMP') then begin
        get_temperature,header,valout
	return
endif
if (str eq 'DMI_ACT_EXP') then begin
        get_measuredexptime,header,valout
	return
endif
if (str eq 'DMI_COLOR_FILTER') then begin
        get_filtername,header,valout
	return
endif
if (str eq 'FRAME') then begin
	get_time,header,valout
	return
endif
return
end
