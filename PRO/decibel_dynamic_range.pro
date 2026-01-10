


FUNCTION dynamicrange,ratio
dB=20.0d0*alog10(ratio)
return,db
end

openw,33,'dynamicarange.dat'
for xpowr=2.0d0,30.0d0,.2d0 do begin
print,xpowr,' bits is: ',dynamicrange(2.0d0^xpowr),' dB'
printf,33,xpowr,dynamicrange(2.0d0^xpowr)
endfor
close,33
data=get_data('dynamicarange.dat')
plot,xstyle=3,ystyle=3,title='Dynamic range of N-bit sensors',data(0,*),data(1,*),xtitle='N',ytitle='DR [dB]',charsize=2,charthick=2,thick=3
end
