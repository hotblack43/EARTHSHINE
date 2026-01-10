PRO gofindDSBS,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS
; determine if BS is to the right or the left of the center
if (cg_x gt x0) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*2./3.-w:x0-radius*2./3.+w,y0-w:y0+w))
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*2./3.-w:x0+radius*2./3.+w,y0-w:y0+w))
endif
return
end

PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
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
 fitsname=arr(1)
 strput,fitsname,'.',strpos(fitsname,'d')
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
 ; First unpack the tar file that comes back from the CRAY - this will place all output
 ; among the input files used below.
 ;----------------------------------------------------------------------------------------
 common vizualize,viz
 viz=1
 ;----------------------------------------------------------------------------------------
	ww=9	; falf-width of patch to find BS and DS inside
 nn=512
 im=fltarr(nn,nn)
 mask=fltarr(nn,nn)
 model=fltarr(nn,nn)
 target=fltarr(nn,nn)
 ;..........................
 bias=readfits('TTAURI/superbias.fits',/SILENT)
 !P.MULTI=[0,1,2]
 !P.CHARSIZE=1.3
 ; point to the path where all the input was - used for making the tar file given to the CRAY
 namstr='RUN4_CRAY'
 namstr='/data/pth/InOutBIGRUN/FORCRAY/'
 files=file_search(strcompress(namstr+"/*",/remove_all),count=n)
; get rid of the GENERAL directory
 idx=where(strpos(files,'GENERAL') eq -1)
 if (idx(0) ne -1) then begin
	files=files(idx)
	n=n_elements(files)
 endif
 openw,88,strcompress('errors_'+namstr+'.dat',/remove_all)
 openw,77,'threeetc.dat'
 for ifil=0,n-1,1 do begin
     getbasepath,files(ifil),basepath
     getFITSname,files(ifil),fitsname
;	print,'files(i): ',files(ifil)
;	print,'basepath: ',basepath
;	print,'FITSanme: ',fitsname
     known_im=readfits(strcompress('VALIDATION_EXPT/SYNTHETICS/'+fitsname,/remove_all),/silent)
     ;EXAMPLE: basepath='./FORCRAY/2455865d7215180MOON_V_AIR/'
     ; Now collect various data from input and output files
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
; find the center of gravity
     cgfinder,target,cg_x,cg_y
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
     ; Get the rim circle
     openr,1,basepath+'coords.dat'
     readf,1,x0,y0,radius
     close,1
     ; get the filter name
;    spawn,"grep DMI_COLOR_FILTER "+basepath+"/header.txt | awk '{print $4}' > filtername.txt"
     ; get hold of the JD
;    spawn,"grep 'FRAME ' "+basepath+"header.txt > JD.str"
;    openr,61,'JD.str' & str='' & readf,61,str & close,61
;    get_time,str,JD
	JD=12356
     ; do some plotting
     ;imsho=sobel(im)
     imsho=(im)
     for l=c-w,c+w,1 do begin
         for k=a-w,a+w,1 do imsho(k,l)=5.*max(im)
         for k=b-w,b+w,1 do imsho(k,l)=5.*max(im)
         endfor
     residuals=target(*,c)-model(*,c)
;    openr,77,'filtername.txt' & filtername='' & readf,77,filtername & close,77
	filtername='X'
     printf,88,format='(f15.7,1x,f7.5,2(1x,g11.5),1x,a)',JD,alpha,total(residuals^2),total(mask*(target-model)^2),filtername
     if (viz eq 1) then begin
     plot,title=basepath,total(im^2,2),yrange=[-10,1e3],xstyle=3,xtitle='Column #',ytitle='Tot((Observed - Model)!u2!n)'
     plots,[!X.crange],[0,0]
;    print,'Total error along slice: ',total(residuals^2)
;    print,'Total error outside disc: ',total(mask*(target-model)^2)
     ; plot slice
	bb=390
     plot,target(*,c),yrange=[0+bb,30+bb],ystyle=3,title='!7a!3='+string(alpha),ytitle='Slice at c.g: Model and Obs',xstyle=3
     oplot,model(*,c),color=fsc_color('red')
     plots,[b-w,b-w],[1,1e6]
     plots,[b+w,b+w],[1,1e6]
     ; plot the intercept with the circle
     l=sqrt(radius^2+(c-y0)^2)
     if (x0-l ge 0 and x0-l le nn-1) then plots,[x0-l,x0-l],[1,1e6],linestyle=2
     if (x0+l ge 0 and x0+l le nn-1) then plots,[x0+l,x0+l],[1,1e6],linestyle=2
     xyouts,/normal,0.2,0.4,strcompress('SSE along slice: '+string(total(residuals(where(target(*,c) le 200))^2))),charsize=2
	gofindDSBS,target,im,x0,y0,radius,cg_x,cg_y,ww,BS,DS
     xyouts,/normal,0.2,0.35,strcompress('DS: '+string(DS)),charsize=2
     endif
; get DS,BS ratio in the observed image 
	gofindDSBS,target-bias,target-bias,x0,y0,radius,cg_x,cg_y,ww,BSobs,DSobs
; get DS,BS ratio in the cleanedup image 
	gofindDSBS,im,im,x0,y0,radius,cg_x,cg_y,ww,BS,DS
; get DS,BS ratio in the original 'known' image 
	gofindDSBS,known_im,known_im,x0,y0,radius,cg_x,cg_y,ww,BStrue,DStrue
	print,format='(5(1x,f9.3),1x,i3,3(1x,f9.2),1x,a)',x0,y0,radius,cg_x,cg_y,ww,DS,DStrue,DSobs,files(ifil)
        printf,77,DS,DStrue,DSobs,files(ifil)
     endfor
 close,88
 close,77
 end
