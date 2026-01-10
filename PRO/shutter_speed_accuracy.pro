x=indgen(9999L)+1	; exposure time in msec
x=x*1e-3	; exposure  time in seconds
plot_oo,/nodata,[1,10000],[1e-5,1],$
	ytitle='Exposure fractional error',xtitle='Exposure time in msec',$
	charsize=2,xstyle=1,ystyle=1
for power=-4,-1,1 do begin
error_in_filter=10.0^power
error_in_shutter=40.0e-6	; Klaus Reif
error_in_shutter=6.0e-6	; Vincent associates : "repeatability is 40 mu-sec"
totalerror= sqrt(error_in_filter^2 + (error_in_shutter/x)^2)
oplot,x*1e3,totalerror
idx=where(abs(x*1e3 - 200) lt 0.1)
xyouts,x(idx)*1e3,totalerror(idx),strcompress('!7e!3 = '+string(power)),charsize=1.7
endfor
end
