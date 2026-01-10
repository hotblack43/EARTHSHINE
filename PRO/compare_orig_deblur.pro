dlim=0.01
data_deblur=get_data('test_mrnsd.cat')
xd=reform(data_deblur(0,*))
yd=reform(data_deblur(1,*))
md=reform(data_deblur(2,*))
data_orig=get_data('test_orig_coadded.cat')
xo=reform(data_orig(0,*))
yo=reform(data_orig(1,*))
mo=reform(data_orig(2,*))
nd=n_elements(xd)
no=n_elements(xo)
get_lun,w
openw,w,'delta_mags.dat'
for i=0,nd-1,1 do begin
dist=sqrt((xo-xd(i))^2+(yo-yd(i))^2)
idx=where(dist eq min(dist))
print,format='(4(1x,f9.4))',mo(idx),md(i),mo(idx)-md(i),dist(idx)
printf,w,format='(4(1x,f9.4))',mo(idx),md(i),mo(idx)-md(i),dist(idx)
endfor
close,w
free_lun,w
data=get_data('delta_mags.dat')
mo=reform(data(0,*))
md=reform(data(1,*))
dmag=reform(data(2,*))
dpos=reform(data(3,*))
;
idx=where(dpos lt dlim)
mo=mo(idx)
md=md(idx)
dmag=dmag(idx)
dpos=dpos(idx)
plot,mo,md,psym=7,xtitle='Original m',ytitle='Deblurred mag',charsize=2
oplot,[!X.crange(0),!X.CRANGE(1)],[!y.crange(0),!Y.CRANGE(1)]
histo,dmag,-0.6,0.6,0.02,xtitle='Mag_orig - Mag_deblurred'
xyouts,/data,-0.04,0.2,'S.D. ='+string(stddev(dmag))
end
