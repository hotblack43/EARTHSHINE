PRO gostripthename,str,basename
 xx=strpos(str,'245')
 basename=strmid(str,xx,strlen(str)-xx)
 return
 end
 
 PRO go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light,whichcleaned
 ; find the cone of the image that can be corrected using the coefficients in 'res'
 ;------------------------------------------------------
 idx=where(angle gt theta and angle le theta+theta_step)
 coords=array_indices(clean_image,idx)
 whichcleaned(coords(0,*),coords(1,*))=1	; flag cleaned pixel
 for i=0,n_elements(idx)-1,1 do begin
     correction=radii(idx(i))*res(1)+res(0)
     clean_image(idx(i))=clean_image(idx(i))-correction
     removed_light(idx(i))=correction
     endfor
 return
 end
 
 PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 ; im=laplacian(im,/CENTER)
 im=sobel(im)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 ; remove specks
 im=median(im,3)
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 openw,49,'trash.dat'
 for i=0,ntries-1,1 do begin 
     irnd=randomu(seed)*nels
     x1=reform(coords(0,irnd))
     y1=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x2=reform(coords(0,irnd))
     y2=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x3=reform(coords(0,irnd))
     y3=reform(coords(1,irnd))
     ;oplot,[x1,x1],[y1,y1],psym=7
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,49,x0,y0,radius
     endfor
 close,49
 spawn,'grep -v NaN trash.dat > aha.dat'
 spawn,'mv aha.dat trash.dat'
 data=get_data('trash.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 openw,47,'circle.dat' & printf,47,x0,y0,radius & close,47
 return
 end
 
 PRO go_fit_line,filename,intercept,slope,radius,res,p
 common vizualise,viz
 ; will fit a straight line to the data in 'filename'
 data=get_data(filename)
 number=reform(data(0,*))
 theta=reform(data(1,*))
 x=reform(data(2,*))
 y=reform(data(3,*))
 sigs=reform(data(4,*))
 idx=where(x gt radius)
 p=0.000000
 if (n_elements(idx) ge 3) then begin
     res=linfit(x(idx),y(idx),sigma=par_sigs,/double,yfit=yfit,measure_errors=sigs(idx),prob=p)
     if (p gt 0.1) then print,p,' probably a good fit'
     if (p le 0.1) then print,p,' NOT a good fit'
     if (viz eq 1) then begin
         window,1,xsize=400,ysize=300
         plot,x(idx),y(idx),psym=7,ystyle=1,title='Angle='+string(theta(0)),xtitle='Distance from Moon ctr.'
         errplot,x(idx),y(idx)-sigs(idx),y(idx)+sigs(idx)
         oplot,x(idx),yfit
         endif
     endif
 return
 end
 
 FUNCTION test_if_same_side,line,point1,point2
 ; Will test if two points are on the same side of a line
 ; INPUTS:
 ; line = [a1,a2,b1,b2], coords of two points ON the line
 ; point1 = [c1,c2], coords of the first point
 ; point2 = [d1,d2], coords of the second point
 a1=double(line(0))
 a2=double(line(1))
 b1=double(line(2))
 b2=double(line(3) )
 c1=double(point1(0))
 c2=double(point1(1))
 d1=double(point2(0))
 d2=double(point2(1))
 stat1=crossp([a1-c1,a2-c2,0],[a1-b1,a2-b2,0])
 stat2=crossp([a1-d1,a2-d2,0],[a1-b1,a2-b2,0])
 test=(stat1(2)/abs(stat1(2)) eq stat2(2)/abs(stat2(2)))
 return,test
 end
 
 PRO find_circle_inside_outside,radius,CENTER,inside,outside,l,idx_inside,idx_outside
 common lineandpoint,line,point1
 inside=intarr(l)
 outside=intarr(l)
 radius2=radius^2
 ;..........
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         r2= (i-CENTER(0))^2+(j-CENTER(1))^2
         ;if (r2 gt radius2 and test_if_same_side(line,point1,[i,j,0]) eq 1) then outside(i,j)=1 ELSE inside(i,j)=1
         if (r2 gt radius2) then outside(i,j)=1 ELSE inside(i,j)=1
         endfor
     endfor
 idx_inside=where(inside eq 1)
 idx_outside=where(outside eq 1)
 return
 end
 
 PRO remove_scattered_light_linear_method,observed_image,clean_image,inside,outside
 common moonres,im1,im2,im3
 common uselater,im4,difference
 common fitedresults,P
 common type,typeflag
 common circleSTUFF,circle,radius,moon_coords
 common vizualise,viz
 common paths,path
 common which,whichcleaned
 ; BBSO - i.e. sky extrapolation - method
 ; take the image observed_image and generate a correction for the scattered light
 ; place the corrected image in clean_image
 ;----------------------------------------------------
 clean_image=observed_image
 removed_light=clean_image*0.0d0
 whichcleaned=clean_image*0
 l=size(observed_image,/dimensions)
 x0=moon_coords(0)
 y0=moon_coords(1)
 rtod=180.0d0/!pi
 ; fill the fields radius and angle with the values
 x=findgen(l(0))
 y=findgen(l(1))
 xx=rebin(x,[l(0),l(1)])
 yy=transpose(rebin(y,[l(1),l(0)]))
 radii=sqrt((xx-x0)^2+(yy-y0)^2)
 ;angle=atan((yy-y0),(xx-x0))/!dtor + 180
 angle=atan((xx-x0),-(yy-y0))/!dtor + 180
 xline=xx
 yline=yy
 if (viz eq 1) then begin
     window,2
     surface,radii,charsize=2
     window,3
     surface,angle,charsize=2
     endif
 ; loop over angle and radii
 nbins=100
 binsize=5.
 p_lim=0.1
 radbins=indgen(nbins)*binsize
 theta_step=6.0
 fudge=2.0	; an arbitrary factor that compensates for dependency between data points
 fstr='(f8.3,1x,f9.2,1x,f8.3,1x,i5,1x,i2)'
 for theta=0.0d0,180.0d0-theta_step,theta_step do begin
     openw,44,path+'bins.dat'
     print,'Theta=',theta
     for ibin=0,nbins-2,1 do begin
         idx=where(radii ge radbins(ibin) and radii lt radbins(ibin+1) and angle ge theta and angle lt theta+theta_step)
         if (idx(0) ne -1) then begin
             if (n_elements(idx) ge 4) then printf,44,ibin,theta,mean(radii(idx)),mean(observed_image(idx)),stddev(observed_image(idx))/sqrt(n_elements(idx))*fudge
             if (viz eq 1) then begin
                 window,0
                 im=observed_image
                 im(idx)=max(im)
                 contour,im,/isotropic,/cell_fill,xstyle=1,ystyle=1
                 endif
             endif
         endfor	; end ibin
     close,44
     go_fit_line,'bins.dat',intercept,slope,radius,res,p
     if (p gt p_lim) then go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light,whichcleaned
     endfor	; end theta
 im4=removed_light
 difference=observed_image-removed_light
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
     if ((x ge 0 and x le l(0)-1) and (y ge 0 and y le l(0)-1)) then circle(x,y)=maxval
     endfor
 return
 end
 PRO get_observed_image,inname,observed_image,header
 common circleSTUFF,circle,radius,moon_coords
 common vizualise,viz
 observed_image=readfits(inname,header)
 l=size(observed_image,/dimensions)
 gofindradiusandcenter,observed_image,x0,y0,radius
 radius=radius*1.05
 moon_coords=[x0,y0]
 get_circle,l,moon_coords,circle,radius,max(observed_image)
 ;----------------------------------------------------------
 ; Build a composite image of Moon and circle
 imin2=observed_image+circle
 if (viz eq 1) then tvscl,alog(imin2)
 ;----------------------------------------------------------
 ; find the inside and the outside of the circle around the Moon
 find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
 im3=outside     ; the skymask
 im2=observed_image
 return
 end
 
 ;.....................................................................................
 ; New version of the code that uses the BBSO method to remove the DS scattered light
 ; Version 4: Works by setting up a loop on the files to be treated.
 ;.....................................................................................
 common paths,path
 t1=systime(/julian)
 path='./'
 common vizualise,viz
 viz=0
 common lineandpoint,line,point1
 common which,whichcleaned
 outpath='BBSO_CLEANED_IMAGES/'
 spawn,'rm '+outpath+'* '
 line=[256,0,256,511]
 point1=[511,0]
 files=file_search('VALIDATION_EXPT/NOISEADDED/LunarImg_*.fit',count=n)
 print,'Found ',n,' files to work on.'
 for i=0,n-1,1 do begin
     gostripthename,files(i),basename
     observed_image_name=files(i)
     get_observed_image,observed_image_name,observed_image,header
     ;----------------------------------------------------------
     ; try to remove the scattered light from "observed_image" using BBSOs linear method
     remove_scattered_light_linear_method,observed_image,cleaned_image,inside,outside
     ;
     writefits,strcompress(outpath+'BBSO_CLEAN_'+basename,/remove_all),cleaned_image,header
     writefits,strcompress(outpath+'cleanedflags_'+basename,/remove_all),fix(whichcleaned)
     t2=systime(/julian)
     print,'That took ',24.*3600.*(t2-t1),' seconds.'
     endfor
 end
 
