files=file_search('Eshine/lib_eshine/OUTPUT/IDEAL/ideal*',count=n)
files_reduced=file_search('Eshine/lib_eshine/OUTPUT/UNflatdar*',count=nn)
openw,23,'data.dat'
for i=0,n-1,1 do begin
print,files(i)
print,files_reduced(i)
im=readfits(files(i))
im2=readfits(files_reduced(i))
sky2=mean(im2(260:329,269:331))
pixel1=mean(im(55:57,155:162))
pixel2=mean(im(267:278,201:211))
pixel3=mean(im2(55:57,155:162))-sky2
pixel4=mean(im2(267:278,201:211))-sky2
fmt='(i4,6(1x,g15.9))'
print,format=fmt,i,pixel1,pixel2,pixel1/pixel2,pixel3,pixel4,pixel3/pixel4
printf,23,format=fmt,i,pixel1,pixel2,pixel1/pixel2,pixel3,pixel4,pixel3/pixel4
endfor
close,23
;------------- plot it
data=get_data('data.dat')
p1=reform(data(1,*))
p2=reform(data(2,*))
rat=reform(data(3,*))
p3=reform(data(4,*))
p4=reform(data(5,*))
rat2=reform(data(6,*))
days=indgen(n_elements(p1))
!P.MULTI=[0,1,1]
;idx=where(rat lt 1e-2)
;rat(idx)=1./rat(idx)
;rat2(idx)=1./rat2(idx)
;kdx=where(rat gt 1e2)
plot_io,days/24./30.,rat,ytitle='Grimaldi/Crisium ratio',charsize=2,psym=-3,xstyle=1,xtitle='Days'
oplot,days/24./30.,rat2,psym=3,linestyle=2
;plot_io,days,p1,title='Grimaldi (cross) and Crisium',charsize=2,psym=7,yrange=[1e-5,1e3]
;oplot,days,p2,linestyle=2,psym=4
;oplot,days,p3,linestyle=2,psym=4
;oplot,days,p4,linestyle=2,psym=4
end
