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

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 PRO get_image_and_exptime,JD,im,header,exptime,x0,y0,radius,step,cornerval
 path='/data/pth/DARKCURRENTREDUCED/SELECTED_4/'
 name=path+string(jd,format='(f15.7)')+'*.fit*'
 files=file_search(name,count=n)
 exptime=-999
 if (files(0) ne '') then begin
 im=readfits(files(0),header,/silent)
 get_EXPOSURE,header,exptime
 get_radius,header,radius
 get_discx0,header,x0
 get_discy0,header,y0
 im=shift_sub(im,256-x0,256-y0)
 line=im(*,256)
 step=line(256-radius+10)-line(256-radius-10)
 cornerval=mean(im(0:10,0:10))
 plot,line,yrange=[-1,20]
 oplot,[256-radius+10,256-radius+10],!Y.crange,linestyle=2
 oplot,[256-radius-10,256-radius-10],!Y.crange,linestyle=2
 endif
 return
 end

common zodiacal,iflag,zoddata,delta_lon,delta_lat
common sukminkwoon,iflagSMK,delta_lonSMK,delta_latSMK,zoddataSMK
 iflagSMK=1
openw,33,'zodi_cts.dat'
iflag=1
jdarray=get_data('DMI_and_ROLFSVEJ_JDs.txt')
for i=0,n_elements(jdarray)-1,1 do begin
jd=jdarray(i)
;get_zodiacal,jd(i),zdflux
get_zodiacal_SMK,jd,zdflux
get_image_and_exptime,JD,im,header,exptime,x0,y0,radius,step,cornerval
 if(exptime gt 0) then begin
zdcounts=zdflux*exptime
printf,33,format='(f15.7,4(1x,f12.9))',jd,zdcounts,step,zdcounts/step*100.,cornerval
    print,format='(f15.7,4(1x,f12.9))',jd,zdcounts,step,zdcounts/step*100.,cornerval
 endif
endfor
close,33
end


