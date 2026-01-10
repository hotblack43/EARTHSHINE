im=readfits('observed.fits')
lap=laplacian(im)
so=readfits('source.fits')
idx=where(so gt 0)
mask=im*0+1
mask(idx)=0
newidx=region_grow(so,idx)
mask(newidx)=4
tvscl,lap*mask
end


