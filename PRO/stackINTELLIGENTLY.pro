PRO godosomething,im,sum,header
; will use various methods to suggest a good 'stacking' of the available files in im
imethod=1
if (imethod eq 1) then begin
; this is just scaling from the median
l=size(im,/dimensions)
nims=l(2)	
sum=reform(im(*,*,0))
scalemed=median(sum)
print,'Median is: ',scalemed
for ii=1,nims-1,1 do begin
subim=reform(im(*,*,0))
ownmedi=median(subim)
print,'Median is: ',ownmedi
sum=sum+subim/ownmedi*scalemed
endfor
sum=sum/float(nims)
sxaddpar, header, 'PROCESSING', nims, 'frames used in median-scaling'
endif else begin
stop
endelse
return
end



files='goodMOONhaloFILES'
path='~/Desktop/ASTRO/EARTHSHINE/TEMP/'
openr,1,files
while not eof(1) do begin
name=''
readf,1,name
im=readfits(path+name,header)
godosomething,im,sum,header
bits=strsplit(name,'.',/extract)
nameforoutput=bits(0)+'.'+bits(1)
nameforoutput=strcompress(nameforoutput+'_averaged.fits',/remove_all)
writefits,nameforoutput,sum,header
endwhile
close,1
end
