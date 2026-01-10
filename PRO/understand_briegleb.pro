!X.THICK=2
!Y.THICK=2
!P.CHARSIZE=2
theta_s=findgen(91)
for d=0.1,0.6,0.1 do begin
formula=(1+d)/(1+2*d*cos(theta_s*!dtor))
if (d eq 0.1) then plot,xtitle='Solar zenith angle',ytitle='Albedo senith angle dependence',theta_s,formula,yrange=[0.7,1.6],ystyle=1,thick=2,title='thick line is d=0.1, then steps of 0.1'
if (d gt 0.1) then oplot,theta_s,formula
endfor
end
