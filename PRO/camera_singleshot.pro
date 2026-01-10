
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
return
end


cd,'c:/Documents and Settings/Peter Thejll/Skrivebord/ASTRO'
spawn,'go_camera'
print,'Done'
im=read_bmp('candle1.bmp')
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
end