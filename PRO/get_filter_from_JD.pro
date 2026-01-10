PRO get_filter_from_JD,JD,filterstr,filternumber
filternames=['B','V','VE1','VE2','IRCUT'] 
filternumbers=indgen(n_elements(filternames))
file='JD_and_filter.txt'
spawn,"grep "+string(JD,format='(f15.7)')+" "+file+" > hkjgvghjkv"
openr,22,'hkjgvghjkv'
str=''
readf,22,str
close,22
bits=strsplit(str,' ',/extract)
JDfound=double(bits(0))
filterstr=bits(1)
if (JD ne JDfound) then stop
filternumber=filternumbers(where(filternames eq filterstr))
return
end
