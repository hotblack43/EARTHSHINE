im=readfits('ideal_LunarImg_0000.fit')
im=im(300:800,300:800)
contour,im,/cell_fill,nlevels=101
cursor,a,b
 l=size(im,/dimensions)
 ; scale to reasonable CCD count
 maxval=max(im)
 im=fix(im/maxval*40000.)
 ; block lower half
 factor=100.0
 im(*,b:l(1)-1)=fix(im(*,b:l(1)-1)/factor)
 ; apply Poisson statsq
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         value=im(i,j)
         if (im(i,j) gt 0) then im(i,j)=randomn(seed,poisson=value)
         endfor
     endfor
    ; scale it back up, visually

w=10
gf=1
x='k'
im_orig=im

while (x ne 'q') do begin
im=im_orig
im(*,b:l(1)-1)=im_orig(*,b:l(1)-1)*gf
strip=im(a-w:a+w,*)
str=total(strip,1)
plot,str,/ylog ,yrange=[1e4,max(str)]
x=get_kbrd()

if (x eq 'u') then gf=gf*1.0234432
if (x eq 'd') then gf=gf/1.034432
print,gf
endwhile

end

