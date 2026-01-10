files=file_search('OUTPUT/IDEAL/idea*.fit*',count=n)
openw,22,'moonbri.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),/SILENT)
im=smooth(im,5,/edge_truncate)
idx=where(im eq max(im))
coords=array_indices(im,idx)
ic=coords(0)
jc=coords(1)
w=3
printf,22,i*4./24.-18.756248-29.517234,total(im),median(im(ic-w:ic+w,jc-w:jc+w))
endfor
close,22
data=get_data('moonbri.dat')
i=reform(data(0,*))
tot=reform(data(1,*))
pix=reform(data(2,*))
!P.MULTI=[0,1,1]
!P.CHARSIZE=1.2
!P.thick=2
!x.thick=2
!y.thick=2
plot_io,/NODATA,i,tot,xtitle='Day',ytitle='MOON total, and brightest pixel (arb units)'
oplot,i,tot,color=fsc_color('red'),psym=-7
oplot,i,pix*1000,color=fsc_color('blue'),psym=-7

end
