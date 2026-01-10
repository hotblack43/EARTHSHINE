
PRO get_imin,imin,l
common describstr,exp_str
common paths,path
;imin=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_ChrisAlg_PeterStack_349_float.FIT')
;l=size(imin,/dimensions)
;width=20
;imin=double(imin(width:l(0)-width-1,width:l(1)-width-1))
imin=readfits(path+'ANDREW/stacked_new_349_float.FIT')
l=size(imin,/dimensions)
writefits,strcompress(path+'Original_image_readin_'+exp_str+'_EX1.fit',/remove_all),imin
return
end
