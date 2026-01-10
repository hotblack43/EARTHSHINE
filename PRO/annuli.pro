 data=get_data('AvDsurafcebrightness.dat')
 x=reform(data(0,*))	; this is log10(r)
 y=reform(data(1,*))	; this is in mags/asec²
 idx=sort(x)
 x=x(idx)
 y=y(idx)
 n=n_elements(x)
 ;
 r=60.*10^x	; r in arc seconds
 y=10^(-y/2.5)	; flux
;-------------------------------------
 sum1=0.0
 for k=1,n-2,1 do begin
  area0=!dpi*r(k-1)^2
  area1=!dpi*r(k)^2
  area2=!dpi*r(k+1)^2
  d_area=(area2-area1)/2.+(area1-area0)/2.
  if (k eq 1) then xx=d_area
  if (k eq 1) then yy=y(k)
  if (k gt 1) then xx=[xx,d_area]
  if (k gt 1) then yy=[yy,y(k)]
  sum1=sum1+y(k)*d_area
 endfor
 sum2=int_tabulated(xx,yy,/double,/sort)
 print,'Sum is:',sum1*10.
 print,'mags= -2.5*alog10(sum):',-2.5*alog10(sum1)
 print,'int_tab is:',sum2*10.
 print,'mags= -2.5*alog10(sum):',-2.5*alog10(sum2)
 end
