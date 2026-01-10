PRO get_name,str,name
idx=strpos(str,'BIAS',/reverse_search)
jdx=strpos(str,'/',/reverse_search)
name=double(strmid(str,jdx+1,idx-jdx-1))
return
end


path='/media/LaCie/ASTRO/ANDOR/JD2455719/'
openw,33,'moments.dat'
files=file_search(path+'*bias*.fits',/fold_case,count=n)
for i=0,n-1,1 do begin
im=readfits(files(i))
get_name,files(i),name
surf=sfit(im,2,kx=coeffs)
printf,33,format='(5(1x,f9.4),1x,f20.10)',moment(im),coeffs(0,0),name
print,format='(5(1x,f9.4),1x,f20.10)',moment(im),coeffs(0,0),name
endfor
close,33
data=get_data('moments.dat')
l=size(data,/dimensions)
data=data(*,1:l(1)-1)
!P.MULTI=[0,1,2]
nbars=33
histo,data(0,*),min(data(0,*)),max(data(0,*)),(max(data(0,*))-min(data(0,*)))/nbars,xtitle='mean'
plot,data(0,*),24.0*(data(5,*)-min(data(5,*))),xstyle=1,ystyle=1,ytitle='Time in hrs since stars',xtitle='Mean bias frame value',psym=7
end
