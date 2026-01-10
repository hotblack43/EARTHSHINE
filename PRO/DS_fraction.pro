PRO get_mphase,h,phase
idx=where(strpos(h,'MPHASE') eq 0)
phase=float(strmid(h(idx),12,30-12))
return
end

path='OUTPUT/IDEAL/'
openw,33,'DS_fraction.dat'
for i=0,62,1 do begin
print,i
if (i le 9)then numstr='000'+string(i)
if (i gt 9 and i le 99 )then numstr='00'+string(i)
if (i gt 99)then numstr='0'+string(i)
Luname=strcompress(path+'ideal_LunarImg_'+numstr+'.fit',/remove_all)
Suname=strcompress(path+'SunMask_'+'LunarImg_'+numstr+'.fit',/remove_all)
Lu=readfits(Luname,/silent,h)
get_mphase,h,phase
Su=readfits(Suname,/silent)
idx=where(Su ne 0)
ds=total(Lu,/double)-total(Lu(idx),/double)
printf,33,ds/total(Lu,/double)*100.,phase
endfor
close,33
data=get_data('DS_fraction.dat')
fraction=reform(data(0,*))
phase=reform(data(1,*))
idx=sort(phase)
data=data(*,idx)
fraction=reform(data(0,*))
phase=reform(data(1,*))
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot_io,yrange=[0.1,100],ystyle=3,xstyle=3,phase,fraction,xtitle='Lunar phase',ytitle='ES (% of total flux)',psym=-7
plots,[!X.crange],[1.0,1.0],linestyle=2
plots,[!X.crange],[10.0,10.0],linestyle=2
end
