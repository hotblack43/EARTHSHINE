PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 im=sobel(im)
 ;im=laplacian(im,/CENTER)
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
 data=get_data('trash.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 return
 end

PRO gofindDSandBSinboxes,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
; determine if BS is to the right or the left of the center
; iflag = 1 means position 1
; iflag = 2 means position 2
if (iflag eq 1) then ipos=4./5.
if (iflag eq 2) then ipos=2./3.
if (cg_x gt x0) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*ipos-w:x0-radius*ipos+w,y0-w:y0+w))
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*ipos-w:x0+radius*ipos+w,y0-w:y0+w))
endif
return
end

PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
return
end

 PRO get_time,str,dectime
 ;
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end
 
 PRO getFITSname,str_in,fitsname
 str=str_in
 arr=strsplit(str,'/',/extract)
 fitsname=arr(n_elements(arr)-1)
 return
 end
 
 
 PRO getbasepath,str,basepath
 basepath=strcompress(str+'/',/remove_all)
 return
 end
 
 PRO parseit,str,part1,part2
 idx=strpos(str,' ')
 part1=strmid(str,0,idx)
 part2=strmid(str,idx+1,strlen(str))
 return
 end
 
 PRO parse_str,s_in,a,b,c,w
 s=' '+s_in+' '
 j=0
 openw,5,'junk.dat'
 for i=1,strlen(s)-1,1 do begin
     if (strmid(s,i,1) eq ' ') then begin
         ss=strmid(s,j,i-j)
         if (valid_num(ss) ne 0) then printf,5,ss
         j=i
         endif
     endfor
 close,5
 data=get_data('junk.dat')
 a=data(0,0)
 b=data(0,1)
 c=data(0,2)
 w=data(0,3)
 return
 end
 


 ;---------------------------------------------------------------------------------------
 ; Code to inspect output from the BBSO linear method
 ; 2 patch version
 ;---------------------------------------------------------------------------------------
 common vizualize,viz
 viz=0
 ;---------------------------------------------------------------------------------------
 for iflag=1,2,1 do begin	; set 1 or 2 for 4/5ths or 2/3rds of radius to place DS patch
 for iflog=1,2,1 do begin	; set 1 or 2 for  yes/no on log10 images
 if (iflag eq 1 and iflog eq 1) then idstring='35_yeslog'	; note INCIRRECT labelling as 35 - should be 45
 if (iflag eq 1 and iflog eq 2) then idstring='35_nolog'	; note INCIRRECT labelling as 35 - should be 45
 if (iflag eq 2 and iflog eq 1) then idstring='23_yeslog'
 if (iflag eq 2 and iflog eq 2) then idstring='23_nolog'
 ww=11
 nn=512
 im=fltarr(nn,nn)
 mask=fltarr(nn,nn)
 model=fltarr(nn,nn)
 observed=fltarr(nn,nn)
 ;..........................
 bias=readfits('TTAURI/superbias.fits',/silent)
 !P.MULTI=[0,1,2]
 !P.CHARSIZE=1.3
 ; point to where the ideal images are 
 idealpath='/data/pth/RESULTS/INPUT/IDEAL/'
 ; point to where the synethic observed images are 
 ;obspath='/data/pth/RESULTS/INPUT/NOISEADDED_18500/'
 ;obspath='/data/pth/RESULTS/INPUT/NOISEADDED_181/'
 ;obspath='/data/pth/RESULTS/INPUT/NOISEADDED_161/'
 obspath='/data/pth/RESULTS/INPUT/NOISEADDED_16500/'
 ; point to where all the cleaned-up output is
 if (iflog eq 1) then cleanedpath=obspath+'/BBSO_CLEANED_LOG/'
 if (iflog eq 2) then cleanedpath=obspath+'/BBSO_CLEANED/'
 ; now collect all images
 files=file_search(strcompress(obspath+"/Lu*.fit",/remove_all),count=n)
 openw,77,strcompress('threeetc_'+idstring+'.dat',/remove_all)
 for ifil=0,n-1,1 do begin
     getFITSname,files(ifil),fitsname
	print,'files(i): ',files(ifil)
	print,'FITSname: ',fitsname
print,'Trying to read ideal images'
print,strcompress(idealpath+fitsname,/remove_all)
     ideal_im=readfits(strcompress(idealpath+fitsname,/remove_all),/silent)
     ; Get the observed image
print,'Trying to read observed images'
print,strcompress(obspath+fitsname,/remove_all)
     observed=readfits(strcompress(obspath+fitsname,/remove_all),/silent)
	observed=observed;-bias
     ; find the center of gravity
     cgfinder,observed,cg_x,cg_y
     ; find the center and radius
     gofindradiusandcenter,ideal_im,x0,y0,radius
     ; Get the cleaned image
print,'Trying to read cleaned-up images'
print,cleanedpath+fitsname
     im=readfits(cleanedpath+fitsname,/silent)
	JD=12356
	filtername='X'
; find the DS intensity in the ideal image
	gofindDSandBSinboxes,ideal_im,ideal_im,x0,y0,radius,cg_x,cg_y,ww,dummy,DSideal,iflag
; get DS,BS ratio in the observed image 
	gofindDSandBSinboxes,observed,observed,x0,y0,radius,cg_x,cg_y,ww,dummy,DSobs,iflag
; get DS,BS ratio in the cleanedup image 
	gofindDSandBSinboxes,im,im,x0,y0,radius,cg_x,cg_y,ww,dummy,DScleaned,iflag
        printf,77,format='(6(1x,f12.6),a,1x,a)',DScleaned,DSideal,DSobs,x0,y0,radius,' ',ifil
     endfor
 close,77
 endfor
 endfor

 end
