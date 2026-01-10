PRO generate_coords,xnow,ynow,x0,y0,alt0_deg,alt0_min,azi0_deg,azi0_min

azi_min=azi0_deg*60.+azi0_min
alt_min=alt0_deg*60.+alt0_min

dx=xnow-x0
dy=ynow-y0
factor_azi=-.15 ; scale factor 1 to azi minutes
factor_alt=10000.
dazi=dx/factor_azi  ; change in azi in minutes
dalt=dy/factor_alt
ny_azi_min=azi_min+dazi
ny_alt_min=alt_min+dalt
;
new_azi_deg=fix(ny_azi_min/60.)
new_azi_min=ny_azi_min-60*new_azi_deg
azi_str=string(new_azi_deg)+' '+string(new_azi_min)
;
new_alt_deg=fix(ny_alt_min/60.)
new_alt_min=ny_alt_min-60*new_alt_deg
alt_str='+'+string(new_alt_deg)+' '+string(new_alt_min)

openw,5,'C:\Documents and Settings\Peter Thejll\Skrivebord\ASTRO\posnew.ext'
print,format='(a12,i1,1x,i2,1x,i3,1x,i2)','gotoaltaz:+0',new_alt_deg,new_alt_min,new_azi_deg,new_azi_min
printf,5,format='(a12,i1,1x,i2,1x,i3,1x,i2)','gotoaltaz:+0',new_alt_deg,new_alt_min,new_azi_deg,new_azi_min
printf,5,'return:'
close,5

return
end

PRO get_box,left,right,down,up
print,'Click at left'
cursor,a,b
left=a
wait,0.2
print,'Click at bottom'
cursor,a,b
down=b
wait,0.2
print,'Click at right'
cursor,a,b
right=a
wait,0.2
print,'Click at top'
cursor,a,b
up=b
temp_left=min([left,right])
temp_right=max([left,right])
left=temp_left
right=temp_right
temp_down=min([down,up])
temp_up=max([down,up])
down=temp_down
up=temp_up
return
end

alt0_deg=01
alt0_min=10
azi0_deg=000
azi0_min=39
radius_limit=5
cd,'c:/Documents and Settings/Peter Thejll/Skrivebord/ASTRO'
spawn,'go_camera'
print,'Done'
im=read_bmp('candle1.bmp')
im=reform(im(0,*,*))
contour,im,xstyle=1,ystyle=1
get_box,left,right,down,up
openw,6,'section.coords'
printf,6,left,right,down,up
close,6
section=im(left:right,down:up)
window,1
surface,section,charsize=2
window,0
contour,section,charsize=2,title='Click source'
print,'Click on source'
cursor,a,c
wait,0.25
b=[6,220.,2.,2.,a,c,0.0]
plots,[a,a],[!Y.CRANGE],linestyle=1
plots,[!X.CRANGE],[c,c],linestyle=1
zz=section
res=GAUSS2DFIT(zz,b,/tilt)
print,'Fit:',b
x0=b(4)
y0=b(5)
print,'Absolute coord 1:',left+x0
print,'Absolute coord 2:',down+y0
radius=sqrt(b(2)^2+b(3)^2)
if (radius gt radius_limit) then begin
    print,'The Gaussian fit is bad - radius is too large for limit:',radius,' Stopping...'
        stop
endif
for iloop=1,100,1 do begin
    spawn,'go_camera'
    wait,10
    im=read_bmp('candle1.bmp')
    im=reform(im(0,*,*))
    section=im(left:right,down:up)
    zz=section
    res=GAUSS2DFIT(zz,b,/tilt)
    print,'Fit:',b
    generate_coords,b(4),b(5),x0,y0,alt0_deg,alt0_min,azi0_deg,azi0_min
endfor  ; end of iloop loop
end