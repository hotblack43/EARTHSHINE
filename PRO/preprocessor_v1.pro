PRO gofindradiusandcenter,im,x0,y0,radius
; given the array of im (whcihis an edge-enhaved imge)
; find good estimates of the circle radius and centre
ntries=100
idx=where(im ne 0)
coords=array_indices(im,idx)
nels=n_elements(idx)
openw,49,'trash.dat'
for i=0,ntries-1,1 do begin 
irnd=randomu(seed)*nels
x1=reform(coords(0,irnd))
y1=reform(coords(1,irnd))
irnd=randomu(seed)*nels
x2=reform(coords(0,irnd))
y2=reform(coords(1,irnd))
irnd=randomu(seed)*nels
x3=reform(coords(0,irnd))
y3=reform(coords(1,irnd))
;print,x1,y1
;print,x2,y2
;print,x3,y3
;stop
oplot,[x1,x1],[y1,y1],psym=7
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
printf,49,x0,y0,radius
;print,i,x0,y0,radius
endfor
close,49
data=get_data('trash.dat')
x0=median(reform(data(0,*)))
y0=median(reform(data(1,*)))
radius=median(reform(data(2,*)))
return
end

PRO edge_detector,im
im=smooth(im,3)
; detect the edges of the BS
im=laplacian(im,/CENTER)
; im treshold and remove some single pixels
idx=where(im gt max(im)/4.)
jdx=where(im le max(im)/4.)
im(idx)=1
im(jdx)=0

; remove specks
im=median(im,3)
return
end

;---------------------------------------------------------------
; 
;files=file_search('TTAURI/TEMP/AVG*.fits',count=n)
files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455769/*TAURI*',count=n)
get_lun,w
openw,w,'circle_seqeunce.dat'
for i=0,n-1,1 do begin
im_in=readfits(files(i),/silent)
im=im_in
edge_detector,im
contour,im,/isotropic,xstyle=3,ystyle=3
gofindradiusandcenter,im,x0,y0,radius
print,' estimated circle: ',x0,y0,radius
printf,w,x0,y0,radius
endfor
close,w
free_lun,w
end
