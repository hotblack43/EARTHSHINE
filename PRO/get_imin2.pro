
PRO get_imin2,imin,l
common paths,path
imin=readfits(path+'LunarImg_0001.fts')
;imin=readfits(path+'ANDREW/DATA/moon20060731.00000168.FIT')
imin=congrid(imin,400,400)
l=size(imin,/dimensions)
writefits,path+'EX2_ideal_image_input_400x400.fit',imin
writefits,path+'EX2_ideal_image_input_400x400_LONG.fit',long(imin)
return
end
