for im=0,83,1 do begin
if (im le 9) then imnum='0'+string(im)
if (im gt 9) then imnum=string(im)
bbso=readfits(strcompress('/data/pth/RESULTS/INPUT/NOISEADDED_16500/BBSO_CLEANED/LunarImg_00'+imnum+'.fit',/remove_all))
bbso_log10=readfits(strcompress('/data/pth/RESULTS/INPUT/NOISEADDED_16500/BBSO_CLEANED_LOG/LunarImg_00'+imnum+'.fit',/remove_all))
noisy=readfits(strcompress('/data/pth/RESULTS/INPUT/NOISEADDED_16500/LunarImg_00'+imnum+'.fit',/remove_all))
ideal=readfits(strcompress('/data/pth/RESULTS/INPUT/IDEAL/LunarImg_00'+imnum+'.fit',/remove_all))
;
bbso_pct=abs((ideal-bbso)/ideal*100.0)
bbso_log10_pct=abs((ideal-bbso_log10)/ideal*100.0)
noisy_pct=abs((ideal-noisy)/ideal*100.0)
print,ideal(300,243),noisy(300,243),bbso(300,243),bbso_log10(300,243)
print,ideal(300,243),noisy_pct(300,243),bbso_pct(300,243),bbso_log10_pct(300,243)
;
!P.MULTI=[0,1,3]
!P.CHARSIZE=2
;plot_io,xstyle=3,ystyle=1,bbso_pct(*,243),xtitle='Column #',ytitle='% difference',title='BBSO method linear image'
;plot_io,xstyle=3,ystyle=1,bbso_log10_pct(*,243),xtitle='Column #',ytitle='% difference',title='BBSO method log10 image'
;plot_io,xstyle=3,ystyle=1,noisy_pct(*,243),xtitle='Column #',ytitle='% difference',title='No removal applied'
; one plot with all graphs
plot_io,xstyle=3,ystyle=1,avg(noisy_pct(*,233:253),1),xtitle='Column #',ytitle='% difference',yrange=[1,100000L]
oplot,avg(bbso_log10_pct(*,233:253),1),linestyle=1
oplot,avg(bbso_pct(*,233:253),1),linestyle=2
contour,ideal,/isotropic,xstyle=3,ystyle=3
oplot,[!X.crange],[243,243],linestyle=1
oplot,[!X.crange],[253,253],linestyle=1
plot_io,xstyle=3,ystyle=1,avg(noisy_pct(*,233:253),1),xtitle='Column #',ytitle='% difference',yrange=[1,1000L]
oplot,avg(bbso_log10_pct(*,233:253),1),linestyle=1
oplot,avg(bbso_pct(*,233:253),1),linestyle=2
endfor
end

