in=readfits('in.fits')
out1=readfits('out1p6.fits')
out2=readfits('out1p8.fits')
!P.MULTI=[0,2,3]
plot,in,out1,psym=1,/isotropic,xtitle='Synthetic image',ytitle='Folded',xrange=[0,6e4],yrange=[0,6e4],title='1.6'
oplot,[0,6e4],[0,6e4],color=fsc_color('red')
plot,in,out2,psym=1,/isotropic,xtitle='Synthetic image',ytitle='Folded',xrange=[0,6e4],yrange=[0,6e4],title='1.8'
oplot,[0,6e4],[0,6e4],color=fsc_color('red')
pct1=(out1-in)/in*100.0
pct2=(out2-in)/in*100.0
plot,xrange=[-1e3,4e4],yrange=[-1e3,4e4],pct1,pct2,psym=1,xtitle='% change at a=1.6',/isotropic,ytitle='% change at a=1.8'
oplot,[0,4e4],[0,4e4],color=fsc_color('red')
; now find the pixels that cghange alot
idx=where(pct1 gt 1e3 and pct2 gt 1e3 and in ne 0)
print,'Found ',n_elements(idx),' pixels thath ave more than 1e4 % change.'
plot_oo,in,out1,psym=1,/isotropic,xtitle='Synthetic image',ytitle='Folded',xrange=[1,6e4],yrange=[1,6e4],title='1.6'
oplot,[1,6e4],[1,6e4],color=fsc_color('red')
oplot,in(idx),out1(idx),psym=1,color=fsc_color('red')

plot_oo,in,out2,psym=1,/isotropic,xtitle='Synthetic image',ytitle='Folded',xrange=[1,6e4],yrange=[1,6e4],title='1.8'
oplot,[1,6e4],[1,6e4],color=fsc_color('red')
oplot,in(idx),out2(idx),psym=1,color=fsc_color('red')
;
nsquares=10000
w=9
openw,11,'squares.dat'
for isq=0,nsquares-1,1 do begin
print,isq
ix=randomu(seed)*512
iy=randomu(seed)*512
if (ix-w ge 0 and ix+w le 511 and iy-w ge 0 and iy+w le 511) then begin
print,'heja!'
subim_in=in(ix-w:ix+w,iy-w:iy+w)
if (mean(subim_in) ne 0) then begin
subim_out1=out1(ix-w:ix+w,iy-w:iy+w)
subim_out2=out2(ix-w:ix+w,iy-w:iy+w)
pct1=(mean(subim_out1)-mean(subim_in))/mean(subim_in)*100.
pct2=(mean(subim_out2)-mean(subim_in))/mean(subim_in)*100.
printf,11,mean(subim_in),mean(subim_out1),mean(subim_out2),pct1,pct2
endif
endif
endfor
close,11
data=get_data('squares.dat')
in=reform(data(0,*))
out1=reform(data(1,*))
out2=reform(data(2,*))
pct1=reform(data(3,*))
pct2=reform(data(4,*))
!P.MULTI=[0,2,2]
plot_oo,in,out1,psym=1,/isotropic,xtitle='Synthetic image',ytitle='Folded',xrange=[1,6e4],yrange=[1,6e4],title='Squares and 1.6'
oplot,[1,6e4],[1,6e4],color=fsc_color('red')
plot_oo,in,out2,psym=1,/isotropic,xtitle='Synthetic image',ytitle='Folded',xrange=[1,6e4],yrange=[1,6e4],title='Squares and 1.8'
oplot,[1,6e4],[1,6e4],color=fsc_color('red')
; plot % change,f irstthepositive then the negative with other color
idx=where(pct1 gt 0)
plot_oo,in(idx),pct1(idx),psym=1,/isotropic,xtitle='Synthetic image',ytitle='% change at 1.6',xrange=[1e-3,6e4],yrange=[1e-3,6e4],title='Squares',xstyle=3
idx=where(pct1 lt 0)
oplot,in(idx),abs(pct1(idx)),psym=3,color=fsc_color('red')
jdx=where(pct2 gt 0)
plot_oo,in(jdx),pct2(jdx),psym=1,/isotropic,xtitle='Synthetic image',ytitle='% change at 1.8',xrange=[1e-3,6e4],yrange=[1e-3,6e4],title='Squares',xstyle=3
jdx=where(pct2 lt 0)
oplot,in(jdx),abs(pct2(jdx)),psym=3,color=fsc_color('red')
end
