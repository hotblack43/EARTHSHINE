PRO go_get_data,file,mm,dd,yy,hh,mi,ext,delext
data=get_data(file)
yy=reform(data(0,*))
mm=reform(data(1,*))
dd=reform(data(2,*))
hh=reform(data(3,*))
mi=reform(data(4,*))
ext=reform(data(5,*))
delext=reform(data(6,*))
return
end


!P.MULTI=[0,1,2]
file='/home/daddyo/Desktop/ASTRO/La_Palma_extinction_on_good_nights.dat'
go_get_data,file,mm,dd,yy,hh,mi,ext,delext
jd=double(julday(mm,dd,yy,hh,mi))
; select lowest extinction for each month
yystart=min(yy)
yystop=max(yy)
openw,12,'/home/daddyo/Desktop/ASTRO/minext.dat'
for iy=yystart,yystop,1 do begin
for im=1,12,1 do begin
idx=where(yy eq iy and mm eq im)
if (idx(0)  ne -1) then begin
	jdx=where(ext(idx) eq min(ext(idx)))
        print,ext(idx(jdx(0))),delext(idx(jdx(0)))
	printf,12,iy+(im-0.5)/12.,ext(idx(jdx(0))),delext(idx(jdx(0)))
endif
endfor
endfor
close,12
data=get_data('/home/daddyo/Desktop/ASTRO/minext.dat')
fracyear=reform(data(0,*))
ext=reform(data(1,*))
del=reform(data(2,*))
idx=where(ext/del gt 5)
plot,yrange=[0,0.3],ystyle=1,fracyear(idx),ext(idx),psym=7
oploterr,fracyear(idx),ext(idx),del(idx)
histo,ext(idx)/del(idx),0,20,1
end
