;
; Generate a set of translated noisy images of a sphere or the Moon,
; each multiplied by a flat field (=gain matrix). These images could
; be used as input to Chae's method for extracting a flat field.
;
; For each one of around 20 images:
;   1. Translate into a position on a xxx triangle.
;   2. Add Poisson noise assuming a CCD with 250,000 electrons/pixel
;   3. Multiply by a flat field
;



FUNCTION Reuleaux, L, N
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




cleanfile = 'LambertSphere_1025x1025_clean.fts'
image_clean = readfits(cleanfile)

l  = size(image_clean,/dimensions)
Nx = l(0)
Ny = l(1)

window,1, xsize=Nx, ysize=Ny
tvscl, image_clean

; compute the positions of the translated images
L  = 0.30*float(Nx)
Nf = 14
ditherpos = Reuleaux(L,Nf)

image_object = uintarr(Nx,Ny,Nf) * uint(0)
for ii=0,Nf-1 do begin

  ; move the clean image to a dithered position
  dx = round(ditherpos[ii,0])
  dy = round(ditherpos[ii,1])
  x = indgen(1025)
  y = indgen(1025)
  xindx = where(((x+dx) GE 0) AND ((x+dx) LE 1024), xcount)
  yindx = where(((y+dy) GE 0) AND ((y+dy) LE 1024), ycount)
  xfrom = x[xindx[0]]
  xto   = x[xindx[xcount-1]]
  yfrom = y[yindx[0]]
  yto   = y[yindx[ycount-1]]
  for ix=xfrom,xto do begin
    for iy=yfrom,yto do begin
      image_object[ix+dx,iy+dy,ii] = image_clean[ix,iy]
    endfor
  endfor

  ; add Poisson noise
  invgain = float(300000)/float(65535)
  for ix=0,1025-1 do begin
    for iy=0,1025-1 do begin
      if image_object[ix,iy,ii] GT uint(0) then begin
        image_object[ix,iy,ii] = (1.0/invgain)*randomu(seed,poisson=image_object[ix,iy,ii]*invgain)
      endif
    endfor
  endfor

  ; view
  tvscl, image_object[*,*,ii]

endfor


; plot,ditherpos[*,0],ditherpos[*,1], psym=1, xrange=[-512,+512], xstyle=1, yrange=[-512,+512], ystyle=1
; oplot, [1.0d,-1.0d,0.0d,1.0d]*double(L)/2, [-1.0d,-1.0d,2.0d,-1.0d]*sin(!PI/3.0)*double(L)/3


slut:
end

