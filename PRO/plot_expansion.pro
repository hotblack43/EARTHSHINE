FUNCTION fun,f,g,t
val= exp(-g/f)*(f*(t+4)/(g*!pi)/6.0+f^2*(t+4)/!pi/18)+exp(-2*g/f)*(-f*(t+4)/(g*!pi)/24-f^2*(t+4)/!pi/36)-f*(t+4)/(g*!pi)/8.0+(t+4)/!pi/6.0+f^2*(t-2)/!pi/6.0
return,val
end

f=findgen(100)/99.*!pi/10.
!P.thick=2
!x.thick=2
!y.thick=2
!P.charthick=2
!P.charsize=1.4
plot,f/!dtor,fun(f,0.6,0.1),title='Series expansion to 2nd order',xtitle='angle [degrees]',ytitle='BRDF'
end
