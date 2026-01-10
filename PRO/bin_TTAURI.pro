 PRO align_2_images,ref,im
!P.MULTI=[0,2,2]
shifts=alignoffset(im,ref,corr)
 im=shift(im,-shifts(0),-shifts(1))
 return
 end

PRO get_numbered_name,ic,numstr
         if (ic le 9) then numstr='000'+string(ic)
         if (ic le 99 and ic gt 9) then numstr='00'+string(ic)
         if (ic le 999 and ic gt 99) then numstr='0'+string(ic)
         if (ic gt 999 ) then numstr=string(ic)
return
end

 PRO get_inner_circle,im,x0,y0,inner_radius,star_and_sky
 common radius,r
 idx=where(r le inner_radius)
 print,n_elements(idx),' pixels inside inner circle.'
 print,'Circle: min and max',min(im(idx)),max(im(idx))
 star_and_sky=total(im(idx))
 print,'star_and_sky=',star_and_sky
 return
 end
 
 PRO get_sky,im,x0,y0,outer_radius,inner_radius,medianval
 common radius,r
 idx=where(r gt inner_radius and r le outer_radius)
 print,n_elements(idx),' pixels inside anulus.'
 print,'Anulus: min and max',min(im(idx)),max(im(idx))
 medianval=median(im(idx))
 print,'MV=',medianval
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
 
 
 common radius,r
 spawn,'rm TEMP/*'
 spawn,'rm JPEGS/*'
 loadct,13
 decomposed=0
 r=dblarr(512,512)
 bias=readfits('DAVE_BIAS.fits')
 l=size(bias,/dimensions)
 ncols=l(0)
 nrows=l(1)
 refim=readfits('ideal4chris.fits')
 refim=reverse(refim)
 files=file_search('/media/SAMSUNG/EARTHSHINE/TTAURI/SPECIAL/*TAURI*.fits',count=n)
 print,'Found ',n,' files.'
 print,files(0)
 flat=bias*0.0+1.0
 ADU=3.78	; photons/ADU 
 im=(readfits(files(0),h)-bias)/flat*ADU
     align_2_images,refim,im
 get_time,h,dectime0
 ic=0
 stack=im	
 dectime_arr=dectime0
 delta_t_JD=1.0d0/60./24.	; 1 minute in units of a day
 ic=0
	stack_count=0
 for ibild=1,n-1,1 do begin
	print,'Image # ',ibild,' of ',n
     im=(readfits(files(ibild),h,/silent)-bias)/flat*ADU
     get_time,h,dectime
     align_2_images,refim,im
     if (dectime-dectime0 le delta_t_JD) then  begin
         stack=[[[stack]],[[im]]]
         dectime_arr=[dectime_arr,dectime]
	stack_count=stack_count+1
         endif
     if (dectime-dectime0 gt delta_t_JD) then  begin
         result_im=total(stack,3,/DOUBLE)
         ;result_im=avg(stack,2,/DOUBLE)
         get_numbered_name,ic,numstr
         avg_name_str=strcompress('TEMP/AVG_tau_TAURI'+numstr+'.fits',/remove_all)
         aha=mean(dectime_arr)
         sxaddpar, h, 'AV_TIME', aha, 'Mean time of capture (JD)'
         writefits,avg_name_str,result_im,h
	 print,format='(a,f15.6,a,2(1x,f15.6))','Wrote at ',aha,' via ',dectime,dectime0
         imb=HistoMatch(result_im/160000.0d0*65000.0d0, bytarr(256)*0+1)
         write_gif,strcompress('JPEGS/AVG_tau_TAURI'+numstr+'.gif',/remove_all),imb
         dectime0=dectime
         stack=im	
         dectime_arr=dectime
         ic=ic+1
	print,'This stack contained ',stack_count,' images.'
        stack_count=0
         endif
     endfor
 close,2
 end

