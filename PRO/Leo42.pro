path='~/Desktop/ASTRO/MOON/May26/Obsrun1/'
level=6000.
scale=65000.
a=2.
b=2.
theta=0.0
for imnum=91,149,1 do begin
imname=strcompress(path+'IMG'+string(IMNUM)+'.FIT',/remove_all)
print,imname
im=readfits(imname,header)
date_str=strmid(header(10),11,10)
time_str=strmid(header(11),11,8)
expo_str=strmid(header(40),12,17)
exptime=float(expo_str)
window=50
contour,im,/cell_fill,nlevels=10
l=size(im,/dimensions)
cursor,x,y
subim=im(x-window/2.:x+window/2.,y-window/2.:y+window/2.)
contour,subim
prs=[level,scale,a,b,window/2.,window/2.,theta]
yfit = GAUSS2DFIT(subim, prs,/tilt)
residuals=subim-yfit
print,'Mean residuals:',mean(residuals)
surface,residuals,charsize=2
wait,5
print,prs
endfor
end
