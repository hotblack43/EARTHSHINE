FUNCTION minimize_me,  P
common thingstoknow,k,imnum
print,p
bias=p(0)
RON=p(1)
original=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456004/2456004.1639861MOON_V_AIR.fits.gz',/silent))
original=original-bias
!P.CHARSIZE=3
!P.MULTI=[0,2,3]
ADU=3.8	; electrons/ADU
;RON=8.3/ADU	; the S.D. not the variance
im1=reform(original(*,*,imnum))*ADU
im2=reform(original(*,*,imnum+1))*ADU
; the noise is the difference divided by sqrt(2)
im=(im1-im2)/sqrt(2.)
VOM=fltarr(2^k,2^k)
AVR=fltarr(2^k,2^k)
for i=0,2^k-1,1 do begin
for j=0,2^k-1,1 do begin
step=512/2^k
from=i*step
to=((i+1)*step)-1
fromj=j*step
toj=((j+1)*step)-1
SD=stddev(im(from:to,fromj:toj),/double)-RON
mn=mean(im1(from:to,fromj:toj),/double)
VOM(i,j)=SD^2
avr(i,j)=mn
endfor
endfor
histo,VOM,-2,10,0.1,title='Bins : '+strcompress(string(step)+'x'+string(step),/remove_all)+' pixels.'
plots,[1,1],[!Y.CRANGE]
w=5
plot_io,xstyle=3,avg(VOM(2^(k-1)-w:2^(k-1)+w,*),0),yrange=[0.1,100]
tvscl,hist_equal(VOM)
print,total(VOM-AVR)^2
return,total(VOM-AVR)^2
end

;======================================================================
common thingstoknow,k,imnum
 k=7
 imnum=35
P=[390.0,2.2]
; Define the starting directional vectors in column format:
 xi = TRANSPOSE([[1.,0.0],[0.,1.]])
Ftol=1d-9
POWELL, P, Xi, Ftol, Fmin, 'minimize_me', /DOUBLE
print,'POWELL done, pars found = ',p
end
