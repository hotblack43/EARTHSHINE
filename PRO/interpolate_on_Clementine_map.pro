data=get_data('Clem_on_othergrid.txt')
;data=get_data('Clem.txt')
Clem=reform(data(0,*))
lonClem=-reform(data(1,*))
latClem=reform(data(2,*))
print,'Done reading Clem_on_othergrid.txt'
; get the points we want values at
data=get_data('Wild.txt')
Wild=reform(data(0,*))
lonWildey=reform(data(1,*))
latWildey=reform(data(2,*))
grid = GRIDDATA(lonClem,latClem,Clem,/inverse_distance,xout=lonWildey,yout=latWildey)
openw,3,'Clementine_minus_Wildey_relativediff.txt'
for i=0,n_elements(Wild)-1,1 do begin
diff=(grid(i)-Wild(i))/Wild(i)
printf,3,diff,lonWildey(i),latWildey(i)
endfor
close,3
print,'Done Clementine_minus_Wildey_relativediff.txt'
end
