
FUNCTION H63deriv,i,o
value=2*sin(i)*sin(o)/(cos(i)+cos(o))^2
return,value
end

Function H63,i,o
H63=1./(cos(i)+cos(o))
return,H63
end

 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),11,19))
     endelse
 x0=x0(0)
 y0=y0(0)
 radius=radius(0)
 return
 end


obs=readfits('./observed_image_JD2456016.8085808.fits',header)
gofindradiusandcenter_fromheader,header,x0,y0,radius
data=readfits('./TRIALIMAGES/OUTPUT/Angles_JD2456016.8085808.fits')
i=shift(reform(data(*,*,0)),x0-256,y0-256)
o=shift(reform(data(*,*,1)),x0-256,y0-256)
disk=H63(i,o)
contour,obs,/isotropic,/cell_fill,nlevels=101
contour,disk,/overplot
end
