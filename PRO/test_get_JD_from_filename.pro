PRO get_JD_from_filename,name,JD
liste=strsplit(name,'_',/extract)
idx=strpos(liste,'24')
ipoint=where(idx ne -1)
JD=double(liste(ipoint))
return
end

name='cube_MkIII_twoalfas_2456016.7917506_VE1_.fits'
get_JD_from_filename,name,JD
end
