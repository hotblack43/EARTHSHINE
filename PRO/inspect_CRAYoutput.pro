PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
return
end


PRO gofindDSBS,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
;.......................................................................
; finds the DS/BS ratio
; INPUT: 
; obs is the osberved image fromw hich the BS value is extracted
; im is the scattered-light corrected image from which DS is taken
; x0,y0 is the disc centre coordinates
; radius is the disc radius
; cg_x,cg_y arethe coordinate sof the light C.G.
; iflag determines which 'patch' to measure DS in
;     iflag = 1 means position 1
;     iflag = 2 means position 2
; w is the halfwidth-1 width of the patch in which to measure light
; OUTPUT BS, DS 
;.......................................................................
if (iflag eq 1) then ipos=4./5.
if (iflag eq 2) then ipos=2./3.
;.......................................................................
; determine if BS is to the right or the left of the center
if (cg_x gt x0) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
BS=mean(obs)
DS=median(im(x0-radius*ipos-w:x0-radius*ipos+w,y0-w:y0+w))
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
BS=mean(obs)
DS=median(im(x0+radius*ipos-w:x0+radius*ipos+w,y0-w:y0+w))
endif
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
 


 ;----------------------------------------------------------------------------------------
 ; Code to inspect output from the CRAY
 ; NOTE: this version for synthetic image analysis only
 ;----------------------------------------------------------------------------------------
 common vizualize,viz
 viz=1
 ;----------------------------------------------------------------------------------------
 nn=512
 im=fltarr(nn,nn)
 mask=fltarr(nn,nn)
 model=fltarr(nn,nn)
 target=fltarr(nn,nn)
 ;..........................
 !P.MULTI=[0,2,2]
 !P.CHARSIZE=1.3
 ; point to the path where all the input was - used for making the tar file given to the CRAY
 namstr='FORCRAY'
 files=file_search('/data/pth/RESULTS/INPUT/NOISEADDED_161/'+strcompress(namstr+"/*",/remove_all),count=n)
 idx=where(strpos(files,'GENERAL') eq -1)
 files=files(idx)
 n=n_elements(files)
 openw,99,strcompress('DSBS_'+namstr+'.dat',/remove_all)
 openw,88,strcompress('errors_'+namstr+'.dat',/remove_all)
 for ifil=0,n-1,1 do begin
     getbasepath,files(ifil),basepath
     ;EXAMPLE: basepath='./FORCRAY/2455865d7215180MOON_V_AIR/'
     ; Now collect various data from input and output files
     ; Get the rim circle
     openr,1,basepath+'coords.dat'
     readf,1,x0,y0,radius
     close,1
; if Moon inside image frame go ahead
     dummy=file_search(basepath+"/*",count=nfiles)
     if (nfiles eq 10) then begin
     extra=30
	if ((x0 gt radius+extra and x0+extra+radius le 511)$
            and (y0 gt radius+extra and y0+extra+radius le 511)) then begin
     ; Get the mask
     openr,1,basepath+'mask.raw'
     readu,1,mask
     close,1
     ; invert the mask
     idx=where(mask eq 1) & jdx=where(mask eq 0) & invmask=mask*0+1 & invmask(idx)=0
     ; Get the target (i.e. the observation) 
     openr,1,basepath+'target.raw'
     readu,1,target
     close,1
     ; Get the model
     h=file_info(strcompress(basepath+'model.raw',/remove_all))
     if (h.size gt 1.5e6) then model=dblarr(nn,nn)
     openr,1,basepath+'model.raw'
     readu,1,model
     close,1
     ; Get the target - model
     h=file_info(strcompress(basepath+'output.raw',/remove_all))
     if (h.size gt 1.5e6) then im=dblarr(nn,nn)
     openr,1,basepath+'output.raw'
     readu,1,im
     close,1
     ; get the settings
     openr,1,basepath+'runoptions.txt'
     s=''
     readf,1,s
     close,1
     parse_str,strtrim(s),a,b,c,w
     ; Get the alpha
     openr,1,basepath+'alpha.dat'
     readf,1,alpha
     close,1
; extract the DSBS ratio
     cgfinder,target,cg_x,cg_y
     w=11
     iflag=1 & gofindDSBS,target,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag & DSBS1=DS/BS
     iflag=2 & gofindDSBS,target,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag & DSBS2=DS/BS
     ; get the filter name
     ; spawn,"grep DMI_COLOR_FILTER "+basepath+"/header.txt | awk '{print $4}' > filtername.txt"
     ; get hold of the JD
     ; spawn,"grep 'FRAME ' "+basepath+"header.txt > JD.str"
     ; openr,61,'JD.str' & str='' & readf,61,str & close,61
     JD=2455917.0d0+float(ifil)*9./24.
     ;get_time,str,JD
     ; do some plotting
     ;imsho=sobel(im)
     imsho=(im)
     for l=c-w,c+w,1 do begin
         for k=a-w,a+w,1 do imsho(k,l)=5.*max(im)
         for k=b-w,b+w,1 do imsho(k,l)=5.*max(im)
         endfor
     residuals=target(*,c)-model(*,c)
     
     filtername='X' 
     res=file_info('filtername.txt')
     if (res.exists eq 1 and res.size ne 0) then begin
	openr,77,'filtername.txt' 
        readf,77,filtername 
        close,77
     endif
     printf,88,format='(f15.7,1x,f7.5,2(1x,g11.5),1x,a)',JD,alpha,total(residuals^2),total(mask*(target-model)^2),filtername
     if (alpha lt 2) then printf,99,format='(f15.7,1x,3(1x,g11.5),1x,a)',JD,alpha,DSBS1,DSBS2,filtername
     if (viz eq 1) then begin
     plot,title=basepath,total(im^2,2),yrange=[0,50000],xstyle=3,xtitle='Column #',ytitle='Tot((Observed - Model)!u2!n)'
     plots,[!X.crange],[0,0]
     print,'Total error along slice: ',total(residuals^2)
     print,'Total error outside disc: ',total(mask*(target-model)^2)
     ; plot slice through centre of disc
     plot,target(*,y0),yrange=[-30,100],title='!7a!3='+string(alpha),ytitle='Slice at c.g: Model and Obs',xstyle=3
     oplot,model(*,y0),color=fsc_color('red')
     plots,[b-w,b-w],[!Y.crange]
     plots,[b+w,b+w],[!Y.crange]
     ; plot the intercept with the circle
     l=radius
     if (x0-l ge 0 and x0-l le nn-1) then plots,[x0-l,x0-l],[!Y.crange],linestyle=2
     if (x0+l ge 0 and x0+l le nn-1) then plots,[x0+l,x0+l],[!Y.crange],linestyle=2
     xyouts,/normal,0.2,0.4,strcompress('SSE along slice: '+string(total(residuals(where(target(*,y0) le 200))^2))),charsize=2
     endif
     endif
     endif
     endfor
 close,88
 close,99
 end
