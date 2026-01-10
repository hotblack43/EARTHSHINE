 FUNCTION get_JD_from_filename,name
 print,'In get_JD_from_filename, trying to convert this name to a JD: ',name
 liste=strsplit(name,'/',/extract)
 idx=strpos(liste,'24')
 ipoint=where(idx ne -1)
 JD=double(liste(ipoint))
 return,JD
 end

