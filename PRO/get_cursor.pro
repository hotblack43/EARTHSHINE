
PRO get_cursor,a,b,txt
; Reads the value of an image when the left mouse button is clicked
; returns coordinates of the click..

common imsize, image, icount, x1, y1, x2, y2, if_show, device_str, if_poisson
print,'Now click on '+txt
Cursor,a,b,/normal
a=imsize*a
b=imsize*b
print,txt+' coords:',a,b
print,'value:',image[a,b]
wait,1
return
end


