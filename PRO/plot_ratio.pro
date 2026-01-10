!P.MULTI=[0,1,4]
charsize=1.6
file='aha
file='ratio.dat'
data=get_data(file)
;       70.17     0.5729     0.4435     0.7204      354.4      1.331
      phase=reform(data(0,*))
      ratio=reform(data(1,*))
      ratio_err=reform(data(2,*))
      k=reform(data(3,*))
      doy=reform(data(4,*))
      am=reform(data(5,*))
; select
idx=where(ratio lt 2000 and am lt 7 and k lt 0.8)
phase=phase(idx)
ratio=ratio(idx)
ratio_err=ratio_err(idx)
k=k(idx)
doy=doy(idx)
am=am(idx)
; plot 1
plot,doy,ratio,psym=7,xtitle='doy',ytitle=' Grimaldi/Crisium',charsize=charsize,ystyle=1,yrange=[min(ratio-ratio_err),max(ratio+ratio_err)]
oploterr,doy,ratio,ratio_err
; plot 2
plot,phase,ratio,xtitle='Phase angle',ytitle='Grimaldi/Crisium',title='Simulated, filtered images',psym=7,charsize=charsize,ystyle=1,xstyle=1,yrange=[min(ratio-ratio_err),max(ratio+ratio_err)]

oploterr,phase,ratio,ratio_err
; plot 3
plot,k,ratio,psym=7,xtitle='Illuminated fraction of Moon',ytitle=' Grimaldi/Crisium',charsize=charsize,ystyle=1,yrange=[min(ratio-ratio_err),max(ratio+ratio_err)]

oploterr,k,ratio,ratio_err
; plot 4
plot,am,ratio,psym=7,xtitle='Airmass',ytitle=' Grimaldi/Crisium',charsize=charsize,yrange=[min(ratio-ratio_err),max(ratio+ratio_err)],ystyle=1

oploterr,am,ratio,ratio_err
device,/close
end
