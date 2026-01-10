PRO get_inner_circle,im,x0,y0,inner_radius,star_and_sky
 common radius,r
 idx=where(r le inner_radius)
 ;print,n_elements(idx),' pixels inside inner circle.'
 ;print,'Circle: min and max',min(im(idx)),max(im(idx))
 star_and_sky=total(im(idx))
 ;print,'star_and_sky=',star_and_sky
 return
 end
 
 PRO get_sky,im,x0,y0,outer_radius,inner_radius,medianval
 common radius,r
 idx=where(r gt inner_radius and r le outer_radius)
 ;print,n_elements(idx),' pixels inside anulus.'
 ;print,'Anulus: min and max',min(im(idx)),max(im(idx))
 medianval=median(im(idx))
 ;print,'MV=',medianval
 return
 end
 
 PRO do_annulus_ph,im,detectedtstars
 common radius,r
 set_plot,'X'
 r=dblarr(512,512)
 starname='ngc6633'
 outer_radius=25.*1
 inner_radius=20.*1
 ADU=3.78	; photons/ADU 
 im=im*ADU
 ncols=512
 nrows=512
 im_looker=im
 openw,83,'table.dat'
 for istar=0,50,1 do begin
     tvscl,hist_equal(im_looker)
     idx=where(im_looker eq max(im_looker))
     b=array_indices(im_looker,idx)
     ;print,'Found a trial source at x0,y0:',b
     
     res=gauss2dfit(im_looker,b)
     x0=b(4)
     y0=b(5)
     print,'Found a source at x0,y0:',x0,y0
; first distance from centroid
         for i=0,ncols-1,1 do begin
             for j=0,nrows-1,1 do begin
                 star_and_sky=sqrt(float(i-x0)^2+float(j-y0)^2)
                 r(i,j)=star_and_sky
                 endfor
             endfor
     get_sky,im,x0,y0,outer_radius,inner_radius,medianval
     sky=medianval*!pi*inner_radius^2
     get_inner_circle,im,x0,y0,inner_radius,star_and_sky
     star=star_and_sky-sky
     err_star=sqrt(star)
     err_sky=sqrt(sky)
     tot_err=sqrt(star+sky)
     if (star gt 0) then printf,83,istar,x0,y0,star,err_star
	kdx=where(r le inner_radius/2.)
        im_looker(kdx)=medianval
     endfor
 close,83
 detectedtstars=get_data('table.dat')
 end


im=readfits('im.fits',/NOSCALE)
do_annulus_ph,im,detectedtstars
end
