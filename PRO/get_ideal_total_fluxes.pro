PRO get_phase,h,ph
idx=strpos(h,'MPHAS')
ipt=where(idx eq 0)
ph=double(strmid(h(ipt),12,20))
return
end
files=file_search('OUTPUT/IDEAL/ideal_*.fi*',count=n)
openw,33,'ideal_totflux.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),header,/silent)
get_phase,header,phase
printf,33,format='(f9.3,1x,f20.10)',phase,total(im,/double)
endfor
close,33
data=get_data('ideal_totflux.dat')
idphase=reform(data(0,*))
!p.charsize=2
!p.thick=2
!X.thick=2
!y.THICK=2
idflux=reform(data(1,*))
plot_io,TITLE='Triangles: eshine code; Crosses: K&S, Red:LLAMAS',yrange=[.7e4,4e7],psym=5,idphase,idflux,xrange=[0,200],xstyle=3,ystyle=3,xtitle='Lunar phase (FM=0)',ytitle='Irradiance'
; get the Kieffer&Stone reflectances
;data=get_data('Kieffer_stone_reflectance.dat')
data=get_data('Kieffer_stone_reflectance_282nm.dat')
KSphase=reform(data(0,*))
KSflux=reform(data(1,*))
oplot,KSphase,KSflux*.67e8,psym=7
; get the LLAMAS data
data=get_data('LLAMAS.dat')
LLAMASphase=reform(data(0,*))
LLAMASflux=reform(data(1,*))
oplot,LLAMASphase,LLAMASflux*11.5e8,psym=2,color=fsc_color('red')
end
