files=file_search('/data/pth/DATA/ANDOR/','*BIAS*.fits',/FOLD_CASE,count=n)
openw,44,'biasdata.dat'
for i=0,n-1,1 do begin
im=readfits(files(i))
l=size(im)
if (l(0) eq 2) then begin
printf,44,moment(im)
endif
if (l(0) eq 3) then begin
for j=0,l(3)-1,1 do begin
printf,44,moment(im(*,*,j))
endfor
endif
endfor
close,44
data=get_data('biasdata.dat')
!p.multi=[0,1,4]
plot,data(0,*),ytitle='Mean',ystyle=1
plot,data(1,*),ytitle='Var',ystyle=1
plot,data(2,*),ytitle='mom 2',ystyle=1
plot,data(3,*),ytitle='mom 3',ystyle=1
end
