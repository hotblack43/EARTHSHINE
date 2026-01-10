file='delta_pwr_1p0.fits'
im=readfits(file)
line=reform(im(*,256))
plot_oo,line(255:511),xrange=[0.1,511],title='!7a!3 = 1.0',xstyle=3
;...............................
file='delta_pwr_1p9.fits'
im=readfits(file)
line=reform(im(*,256))
oplot,line(255:511),color=fsc_color('red')
sll=[]
for i=1,511-1,1 do begin
sl=(-alog10(line(i+1))+alog10(line(i)))/(-alog10(i+1)+alog10(i))
sll=[sll,sl]
;print,i,sl
endfor
;plot,sll
;stop
cursor,x1,y1
wait,0.4
cursor,x2,y2
print,x1,y1,x2,y2
slope=(alog10(y2)-alog10(y1))/(alog10(x2)-alog10(x1))
print,'Slope: ',slope
end
