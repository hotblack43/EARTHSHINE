FUNCTION reuleaux, L, N
;
; returns N equidistant positions from the Reuleaux triangle with base L
;

b = double(L)
Npos = fix(N)

x = dblarr(Npos)
y = dblarr(Npos)

h = b*sin(!DPI/3.0)
xc1 = b/2
yc1 = -h/3
xc2 = -b/2
yc2 = -h/3
xc3 = 0.0d
yc3 = 2*h/3
O = !DPI*b

betastep = 180.0d/Npos
for ii=0,Npos-1 do begin
  beta = ii*betastep
  if (beta GE 0.0d AND beta LT 60.0d) then begin
    x[ii] = xc1 - b*cos(beta*!DPI/180.0d)
    y[ii] = yc1 + b*sin(beta*!DPI/180.0d)
  endif else if (beta GE 60.0d AND beta LT 120.0d) then begin
    beta = beta - 60.0d
    x[ii] = xc2 + b*cos((60.0-beta)*!DPI/180.0d)
    y[ii] = yc2 + b*sin((60.0-beta)*!DPI/180.0d)
  endif else if (beta GE 120.0d AND beta LT 180.0d) then begin
    beta = beta - 120.0d
    x[ii] = xc3 + b*sin((30.0-beta)*!DPI/180.0d)
    y[ii] = yc3 - b*cos((30.0-beta)*!DPI/180.0d)
  endif
endfor
return, [[x],[y]]
END

N=11
L=0.2
tri=reuleaux(L, N)
openw,33,'triangle.dat'
plot,xstyle=1,ystyle=1,tri(*,0),tri(*,1),psym=7,/isotropic,xrange=[-0.5,0.5],yrange=[-0.5,0.5]
for i=0,n-1,1 do begin
printf,33,tri(i,0),tri(i,1)
endfor
N=7
L=0.1
tri=reuleaux(L, N)
oplot,tri(*,0),tri(*,1),psym=7
for i=0,n-1,1 do begin
printf,33,tri(i,0),tri(i,1)
endfor
close,33
end
