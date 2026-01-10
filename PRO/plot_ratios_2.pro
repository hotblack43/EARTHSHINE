!P.MULTI=[0,1,2]
file='ideal_ratio.dat'
data=get_data(file)
phase=reform(data(0,*))
ideal=reform(data(1,*))
file='KING_ratio.dat'
KING=get_data(file)
file='BBSO_ratio.dat'
BBSO=get_data(file)
grimaldilit_idx=where(phase gt 0.1 and phase lt 0.9 and ideal gt 1)
crisiumlit_idx=where(phase gt 0.1 and phase lt 0.9 and ideal lt 1)
ymin=500
plot_io,phase(grimaldilit_idx),ideal(grimaldilit_idx),psym=7,xtitle='Illum. fraction',ytitle='Grimaldi/Crisium',charsize=2,title='Grimaldi lit',yrange=[ymin,ymin*1.3e3],ystyle=1
oplot,phase(grimaldilit_idx),BBSO(grimaldilit_idx),psym=5
oplot,phase(grimaldilit_idx),KING(grimaldilit_idx),psym=1
xyouts,/normal,0.3,0.925,'Ideal '
plots,/normal,[0.37,0.37],[0.929,0.929],psym=7
xyouts,/normal,0.3,0.9,'BBSO '
plots,/normal,[0.37,0.37],[0.904,0.904],psym=5
xyouts,/normal,0.3,0.875,'KING '
plots,/normal,[0.37,0.37],[0.879,0.879],psym=1
;
ymin=3e-6
plot_io,phase(crisiumlit_idx),ideal(crisiumlit_idx),psym=7,xtitle='Illum. fraction',ytitle='Grimaldi/Crisium',charsize=2,title='Crisium lit',yrange=[ymin,ymin*1.3e3],ystyle=1
oplot,phase(crisiumlit_idx),BBSO(crisiumlit_idx),psym=5
oplot,phase(crisiumlit_idx),KING(crisiumlit_idx),psym=1
xyouts,/normal,0.3,0.2,'Ideal '
plots,/normal,[0.37,0.37],[0.204,0.204],psym=7
xyouts,/normal,0.3,0.225,'BBSO '
plots,/normal,[0.37,0.37],[0.229,0.229],psym=5
xyouts,/normal,0.3,0.25,'KING '
plots,/normal,[0.37,0.37],[0.254,0.254],psym=1
end