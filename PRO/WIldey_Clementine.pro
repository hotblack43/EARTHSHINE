;window,3,xsize=512,ysize=1024
data=get_data('Clem.txt')
Clem=reform(data(0,*))
lonClem=reform(data(1,*))
idx=where(lonClem gt 180)
lonClem(idx)=-(360-lonClem(idx))
lonClem=-lonClem
latClem=reform(data(2,*))
print,'Done reading Clem.txt'
get_lun,edx
openw,edx,'Clem_on_othergrid.txt'
for i=0,n_elements(lonClem)-1,1 do begin
printf,edx,Clem(i),lonClem(i),latClem(i)
endfor
close,edx
free_lun,edx
stop
; get the WIldey data
data=get_data('Wild.txt')
Wild=reform(data(0,*))
lonWildey=reform(data(1,*))
latWildey=reform(data(2,*))
print,'Done reading WIld.txt'
!P.MULTI=[0,1,1]
;map_set,/satellite,sat_p=[6,0,0],/isotropic,/advance,limit=[-90,-90,90,90]
map_set,/isotropic,/advance,limit=[-90,-90,90,90]
contour,Wild,lonWildey,latWIldey,/irregular,/cell_fill,/overplot,nlevels=101,title='Wildey'
!P.MULTI=[0,1,1]
map_set,/isotropic,/advance,limit=[-90,-90,90,90]
contour,Clem,lonClem,latClem,/irregular,/cell_fill,/overplot,nlevels=101,title='Clementine'
end
