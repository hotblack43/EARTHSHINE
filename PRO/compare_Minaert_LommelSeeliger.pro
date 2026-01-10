FUNCTION minnaert,i,o,k
value=cos(i)^k*cos(o)^(k-1)
return,value
end
FUNCTION LommelSeeliger,i,o
value=(cos(i)*cos(o))/(cos(i)+cos(o))
return,value
end

i=60.*!dtor
k=1.1
openw,33,'p'
for o=0.,!pi/2.,0.1 do begin
print,i,o,minnaert(i,o,k),LommelSeeliger(i,o)
printf,33,i,o,minnaert(i,o,k)/2.,LommelSeeliger(i,o)
endfor
close,33
data=get_data('p')
!P.CHARSIZE=2.5
plot,data(1,*)/!dtor,data(2,*),xtitle='o',title='Minnaert (solid), LS (dashed)',ytitle='BRDF'
oplot,data(1,*)/!dtor,data(3,*),linestyle=2
end
