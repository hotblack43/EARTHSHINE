pro getstuff,str,dummystr,x000,y000,radius
openw,54,'tmp'
printf,54,str
close,54
fmt='(3(1x,f12.4),1x,a)'
openr,38,'tmp'
dummystr=''
readf,38,format=fmt,x000,y000,radius,dummystr
close,38
return
end
