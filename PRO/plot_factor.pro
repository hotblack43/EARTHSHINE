


; Plotting 'factor_series'
airma=findgen(30)/29.*6.0
!P.MULTI=[0,3,4]
for dk=0.1,0.0,-0.01 do begin
print,dk
f=10^(0.4*dk*airma)
plot,airma,f,ystyle=3,xstyle=3
endfor
end
