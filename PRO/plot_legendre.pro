smallangle=findgen(300)/100.-1.5
lamda=.55	; wavelength  in microns
a=20*lamda
!P.MULTI=[0,1,2]
for k=1,3,1 do begin
y=(beselj(2.*!pi*a/lamda*sin(smallangle*!dtor),k)/sin(smallangle*!dtor))^ 2
if (k eq 1) then begin
plot,y,smallangle,/polar
;plot,smallangle,y
endif else begin
oplot,y,smallangle,/polar
;oplot,smallangle,y
endelse
endfor
for k=1,3,1 do begin
y=(beselj(2.*!pi*a/lamda*sin(smallangle*!dtor),k)/sin(smallangle*!dtor))^ 2
if (k eq 1) then begin
;plot,y,smallangle,/polar
plot,smallangle,y
endif else begin
;oplot,y,smallangle,/polar
oplot,smallangle,y
endelse
endfor
end