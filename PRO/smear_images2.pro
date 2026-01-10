

PRO get_flat,l,flat
flat=(dindgen(l)/l(0)/l(1)+1)+dist(l)/100.
flat=flat*flat
flat=flat/mean(flat,/double)/100.0d0+1.0d0
flat=flat/mean(flat,/double)

return
end

PRO get_smeared_images,im1,im2,Mdec,Mha
help,im1,im2

Mdec=total(im1,1)

Mha=total(im2,1)
return
end


read_jpeg,'C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\kommode001.jpg',im1
read_jpeg,'C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\kommode002.jpg',im2
get_smeared_images,im1,im2,Mdec,Mha

amask=(Mdec*0.0d0)+1.0d0
flat=mflat_make_flat( Mdec, Mha, amask)

subim=flat(570:790,440:630)
contour,subim,charsize=3
print,stddev(subim)
surface,subim
end