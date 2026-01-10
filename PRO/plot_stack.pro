 PRO get_EXPOSURE,h,expt
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 expt=reform(exptime(0))
 return
 end


!P.CHARSIZE=2
!P.THICK=3
!x.THICK=3
!y.THICK=3
!P.MULTI=[0,1,2]
; plots a figure showing a 'stack' of DS profiles for one night in various filters
for plottype=0,1,1 do begin 
files='filestoplot'
openr,1,files
ic=0
while not eof(1) do begin
name=''
readf,1,name
im=readfits(name,header)
print,max(im),name
get_info_from_header,header,'DISCX0',x0
get_info_from_header,header,'DISCY0',y0
get_info_from_header,header,'RADIUS',radius
get_EXPOSURE,header,exptime
print,x0,y0,radius,exptime
if (plottype eq 0) then im=im/exptime(0)
if (plottype eq 1) then im=im/total(im,/double)
line=im(*,y0-10:y0+10)
line=avg(line,1)
mn=mean(line(145:165))
if (plottype eq 0) then if (ic eq 0) then plot,title='JD 2456016',yrange=[-10,200],xtitle='Column #',ytitle='Flux [cts/s]',ystyle=3,/nodata,line-mn,xrange=[150,250]
if (plottype eq 1) then if (ic eq 0) then plot,yrange=[-1e-9,1e-8],xtitle='Column #',ytitle='counts/(total counts)',ystyle=3,/nodata,line-mn,xrange=[150,250]
if (ic eq 0) then oplot,line-mn,color=fsc_color('green')
mn=mean(line(145:165))
;if (ic eq 1) then oplot,shift(line,-1)-mn,color=fsc_color('orange')
mn=mean(line(145:165))
if (ic eq 2) then oplot,shift(line,4)-mn,color=fsc_color('red')
mn=mean(line(145:165))
;if (ic eq 3) then oplot,shift(line,-1)-mn,color=fsc_color('orange')
mn=mean(line(145:165))
if (ic eq 4) then oplot,shift(line,0)-mn,color=fsc_color('blue')
ic=ic+1
endwhile
close,1
endfor
end
