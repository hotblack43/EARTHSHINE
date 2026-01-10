s=''
x=0.0
y=0.0
v=0.0
verr=0.0
file='Bim.cat'
openr,1,file
openw,2,'Bim.cat2'
for k=0,3,1 do readf,1,s
while not eof(1) do begin
readf,1,x,y,v,verr
printf,2,x,y,v,verr
endwhile
close,2
close,1
file='Vim.cat'
openr,1,file
openw,2,'Vim.cat2'
for k=0,3,1 do readf,1,s
while not eof(1) do begin
readf,1,x,y,v,verr
printf,2,x,y,v,verr
endwhile
close,2
close,1
file='VE1im.cat'
openr,1,file
openw,2,'VE1im.cat2'
for k=0,3,1 do readf,1,s
while not eof(1) do begin
readf,1,x,y,v,verr
printf,2,x,y,v,verr
endwhile
close,2
close,1
data=get_data('Bim.cat2')
xB=reform(data(0,*))
yB=reform(data(1,*))
magB=reform(data(2,*))
magBerr=reform(data(3,*))
data=get_data('Vim.cat2')
xV=reform(data(0,*))
yV=reform(data(1,*))
magV=reform(data(2,*))
magVerr=reform(data(3,*))
data=get_data('VE1im.cat2')
xVE1=reform(data(0,*))
yVE1=reform(data(1,*))
magVE1=reform(data(2,*))
magVE1err=reform(data(3,*))
nB=n_elements(xB)
nV=n_elements(xV)
nVE1=n_elements(xVE1)
print,nB,nV,nVE1
openw,3,'stars.cat'
dlim=1
for i=0,nB-1,1 do begin
for j=0,nV-1,1 do begin
for k=0,nVE1-1,1 do begin
d1=sqrt((xB(i)-xV(j))^2+(yB(i)-yV(j))^2)
d2=sqrt((xB(i)-xVE1(k))^2+(yB(i)-yVE1(k))^2)
if (d1 lt dlim and d2 lt dlim) then print,format='(3(1x,i4),3(1x,f9.3,1x,f9.3))',i,j,k,magV(j),magVerr(j),magB(i),magBerr(i),magVE1(k),magVE1err(k)
if (d1 lt dlim and d2 lt dlim) then printf,3,format='(3(1x,f9.3,1x,f9.3))',magV(j),magVerr(j),magB(i),magBerr(i),magVE1(k),magVE1err(k)
endfor
endfor
endfor
close,3
end
