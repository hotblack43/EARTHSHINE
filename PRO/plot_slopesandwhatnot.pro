

!P.charsize=2
fnames=['B','V','VE1','VE2','IRCUT']
data=get_data('slopesandwhatnot.dat')
jd=reform(data(0,*))
alb0=reform(data(1,*))
erralb0=reform(data(2,*))
slope=reform(data(3,*))
errslope=reform(data(4,*))
npts=reform(data(5,*))
iband=reform(data(6,*))

for ib=0,4,1 do begin
idx=where(iband eq ib)
x=alb0(idx)
dx=erralb0(idx)
y=-slope(idx)
dy=errslope(idx)
plot,/nodata,xstyle=3,ystyle=3,title=fnames(ib),x,y,psym=7,xtitle='Albedo at z=0',ytitle=' neg. slope [airmass!u-1!n]'
for k=0,n_elements(x)-1,1 do begin
oplot,[x((k))-dx((k)),x((k))+dx((k))],[y((k)),y((k))]
oplot,[x((k)),x((k))],[y((k))-dy(k),y((k))+dy(k)]
endfor
endfor
end
