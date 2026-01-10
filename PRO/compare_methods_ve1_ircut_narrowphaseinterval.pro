

fmnames=['RAW','BBSOlin','BBSOlog','EFM']
step=8
openw,77,'justsomeJDS.dat'
for inam=0,3,1 do begin
str=fmnames(inam)
print,str
data=get_data('safe.comparative_ve1_ircut'+str+'.dat')
ve1=reform(data(0,*))
errve1=reform(data(1,*))
ircut=reform(data(2,*))
errircut=reform(data(3,*))
ph=reform(data(4,*))
idx=where(ph gt -100 and ph lt -95)
for k=0,n_elements(idx)-1,1 do begin
print,inam*step+ph(idx(k)),ve1(idx(k)),errve1(idx(k)),ircut(idx(k)),errircut(idx(k))
printf,77,inam*step+ph(idx(k)),ve1(idx(k)),errve1(idx(k)),ircut(idx(k)),errircut(idx(k))
endfor
endfor
close,77
data=get_data('justsomeJDS.dat')
x=reform(data(0,*))
ve1=reform(data(1,*))
errve1=reform(data(2,*))
ircut=reform(data(3,*))
errircut=reform(data(4,*))
!P.COLOR=fsc_color('white')
!P.COLOR=fsc_color('black')
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot,XTickformat='(A1)',ytitle='A*',/nodata,x,ve1,psym=7,xrange=[-98,-70],yrange=[0.2,0.4],xstyle=3,ystyle=3
!P.color=fsc_color('red')
oplot,x,ve1,psym=7
errplot,x,ve1-errve1,ve1+errve1
!P.color=fsc_color('blue')
oplot,x,ircut,psym=7
errplot,x,ircut-errircut,ircut+errircut
!P.COLOR=fsc_color('white')
!P.COLOR=fsc_color('black')
xyouts,-97,0.37,'RAW'
xyouts,-89.6,0.37,'BBSOlin'
xyouts,-81.5,0.37,'BBSOlog'
xyouts,-73,0.37,'EFM'
end
