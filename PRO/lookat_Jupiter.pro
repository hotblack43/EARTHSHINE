PRO remove_bias,image,bias
bias=readfits('Bias_frame.FIT')
image=image-bias
print,'Removed bias'
return
end

path='~/Desktop/ASTRO/MOON/May29/obs1/'
files=file_search(path,'*.FIT')
n=n_elements(files)
for i=0,n-1,1 do begin
im=readfits(files(i))
remove_bias,im,bias
l=size(im,/dimensions)
;tvscl,rebin(im,l/4)
contour,im,levels=findgen(21)*10+1000,/cell_fill
endfor
end

