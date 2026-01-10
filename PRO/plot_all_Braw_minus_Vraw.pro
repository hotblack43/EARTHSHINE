files=file_search('BmVimages/*Braw_minus_Vraw*',count=n)
files2=file_search('BmVimages/*BbbsoLIN_minus_VbbsoLIN*',count=m)
print,n,m
!P.MULTI=[0,1,2]
for i=0,n-1,1 do begin
print,files(i),files2(i)
im=readfits(files(i))
im2=readfits(files2(i))
plot,avg(im(*,246:266),1),title=files(i),ytitle='B-V',xtitle='Col #',xstyle=3,ystyle=3,yrange=[0.5,1.3]
oplot,avg(im2(*,246:266),1),color=fsc_color('red')
;plot,avg(im2(*,246:266),1),title=files2(i),ytitle='B-V',xtitle='Col #',xstyle=3,ystyle=3,yrange=[0.5,1.3]
endfor
end
