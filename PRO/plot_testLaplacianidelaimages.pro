PRO goploitit,Iearth,DSstep,stddevDSstep,sig1,SDsig1
; first plot first 4 then overplot last 4
!P.CHARSIZE=2
!P.CHARthick=2
!P.THICK=4
!x.THICK=4
!y.THICK=4
!P.MULTI=[0,1,3]
tstr='100 Synth. images, !7a!3=1.7, noised.'
plot_oo,title=tstr,/isotropic,xtitle='Step size',ytitle='Signature size',DSstep,sig1,psym=7,xstyle=3,ystyle=3,xrange=[1,200L],yrange=[1,200L]
for i=0,N_elements(DSstep)-1,1 do begin
oplot,[DSstep(i)-stddevDSstep(i),DSstep(i)+stddevDSstep(i)],[sig1(i),sig1(i)]
oplot,[DSstep(i),DSstep(i)],[sig1(i)-SDsig1(i),sig1(i)+SDsig1(i)]
;
endfor
plot_oo,Iearth,DSstep,psym=7,xtitle='Iearth [w/m!u2!n]',ytitle='Step size'
plot_oo,Iearth,sig1,psym=7,xtitle='Iearth [w/m!u2!n]',ytitle='Signature size'
print,'R (Iearth, Step): ',correlate(Iearth,DSstep)
print,'R (Iearth, Signature): ',correlate(Iearth,sig1)
idx=where(iearth gt 0.02)
print,'linear part: R (Iearth, Step): ',correlate(Iearth(idx),DSstep(idx))
print,'linear part: R (Iearth, Signature): ',correlate(Iearth(idx),sig1(idx))
return
end

data=get_data('steps_alfa1p8_100ims_sum11rows.dat')
idx=where(data(3,*) lt 100)
data=data(*,idx)
; DSstep,stddevDSstep,sig1,SDsig1,BSstep,stddevBSstep,sig2,SDsig2
Iearth=reform(data(0,*))
DSstep=reform(data(1,*))
delta_DSstep=reform(data(2,*))
sig1=reform(data(3,*))
delta_sig1=reform(data(4,*))
BSstep=reform(data(5,*))
delta_BSstep=reform(data(6,*))
sig2=reform(data(7,*))
delta_sig2=reform(data(8,*))
;
goploitit,Iearth,DSstep,delta_DSstep,sig1,delta_sig1
end
