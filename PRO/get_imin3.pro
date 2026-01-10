
PRO get_imin3,imin,l
common describstr,exp_str
common paths,path
;imin=readfits(path+'stacked_ChrisAlg_PeterStack_349_float.FIT')
imin=readfits(path+'ANDREW/stacked_new_349_float.FIT')
l=size(imin,/dimensions)
writefits,strcompress(path+'Original_image_readin_'+exp_str+'_EX3.fit',/remove_all),imin
return
end
