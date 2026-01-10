PRO plot_all,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr,tstreng
jd=hjd+2400000.0d0
caldat,jd,mm,dd,yy,hr,min,sec
fracyear=yy+(mm-1)/12.0d0+dd/365.25
plot,fracyear,ku,xtitle='year',ytitle='k!dU!n',charsize=1.8,xstyle=1,ystyle=1,title=tstreng,psym=4
plot,fracyear,kb1,xtitle='Year',ytitle='k!dB1!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,kb,xtitle='Year',ytitle='k!dB!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,kb2,xtitle='Year',ytitle='k!dB2!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,kv1,xtitle='Year',ytitle='k!dV1!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,kv,xtitle='Year',ytitle='k!dV!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,kg,xtitle='Year',ytitle='k!dG!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
; plot colors
plot,fracyear,ku-kg,xtitle='Year',ytitle='k!dU!n-k!dG!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,ku-kv,xtitle='Year',ytitle='k!dU!n-k!dV!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,ku-kv1,xtitle='Year',ytitle='k!dU!n-k!dV1!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,ku-kb2,xtitle='Year',ytitle='k!dU!n-k!dB2!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,ku-kb,xtitle='Year',ytitle='k!dU!n-k!dB!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
plot,fracyear,ku-kb1,xtitle='Year',ytitle='k!dU!n-k!dB1!n',charsize=1.8,xstyle=1,ystyle=1,psym=4
; plot indices
!P.MULTI=[0,2,1]
idx=where(fracyear gt 1986.75)
plot,ku(idx)-kb2(idx),kb2(idx)-kg(idx),xtitle='k!dU!n-k!dB2!n',ytitle='k!dB2!n-k!dG!n',charsize=1.8,xstyle=1,ystyle=1,psym=4,title='After 1986.75',yrange=[.01,.21],xrange=[.35,.51]
idx=where(fracyear le 1986.75)
plot,ku(idx)-kb2(idx),kb2(idx)-kg(idx),xtitle='k!dU!n-k!dB2!n',ytitle='k!dB2!n-k!dG!n',charsize=1.8,xstyle=1,ystyle=1,psym=4,title='Before 1986.75',yrange=[.01,.21],xrange=[.35,.51]                  
idx=where(fracyear gt 1986.75)
oplot,ku(idx)-kb2(idx),kb2(idx)-kg(idx),psym=5,color=fsc_color('red')
return
end


PRO extract_data,data,date,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr
date=reform(data(0,*))
hjd=reform(data(1,*))
ku=reform(data(2,*))
kuerr=reform(data(3,*))
kb1=reform(data(4,*))
kb1err=reform(data(5,*))
kb=reform(data(6,*))
kberr=reform(data(7,*))
kb2=reform(data(8,*))
kb2err=reform(data(9,*))
kv1=reform(data(10,*))
kv1err=reform(data(11,*))
kv=reform(data(12,*))
kverr=reform(data(13,*))
kg=reform(data(14,*))
kgerr=reform(data(15,*))
return
end
  
;=============Programme=================================
common wave,wave,o3_corr
o3_corr=[.016d0,0.0d0,0.0d0,0.01d0,.025d0,.030d0,.039d0]	; abs per airmass at the filter bands due to O3
file='/data/pth/G3526/NBI/ALL/LASILLA/lasilla_77_92.dat'
file='lasilla_77_92.dat'
data=get_data(file)
extract_data,data,date,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr
plot_all,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr,'Before selection'
end
