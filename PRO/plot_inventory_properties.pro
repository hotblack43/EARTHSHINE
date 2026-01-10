filter=['B','V','VE1','VE2','IRCUT']
data=get_data('inventory_properties.dat')
f=data(9,*)
openw,5,'JDstoELIMINATE.txt'
;
!P.MULTI=[0,2,5]
!P.CHARSIZE=1.8
for ifn=1,5,1 do begin
idx=where(f eq ifn)
jd=reform(data(0,idx))
k=reform(data(4,idx))
q20=reform(data(7,idx))
q21=reform(data(8,idx))
f=data(9,*)
plot,k,q20,psym=7,/ylog,xtitle='Illuminated fraction',$
ytitle='Q20',title=filter(ifn-1),yrange=[0.0001,0.1]
m=median(q20)
oplot,!X.CRANGE,[m*1.3,m*1.3],linestyle=3
if (ifn ne 4) then kdx=where(q20 gt m*1.3 or q21 gt 2)
if (ifn eq 4) then kdx=where(q20 gt m*1.3 or q21 gt 10)
for k=0,n_elements(kdx)-1,1 do print,format='(i2,1x,f15.7,2(1x,f10.6))',ifn,jd(kdx(k)),q20(kdx(k)),q21(kdx(k))
for k=0,n_elements(kdx)-1,1 do printf,5,format='(f15.7)',jd(kdx(k))
plot_oo,q21,q20,yrange=[0.0001,0.1],psym=7,ytitle='Q20',xtitle='Sky'
oplot,[0.1,100],[m*1.3,m*1.3],linestyle=3
if (ifn ne 4) then oplot,[2,2],[0.0001,0.1],linestyle=3
if (ifn eq 4) then oplot,[10,10],[0.0001,0.1],linestyle=3
endfor
close,5
print,'Look for JDs to eliminate in: JDstoELIMINATE.txt'
end
