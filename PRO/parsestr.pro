PRO parsestr,str_in,hh,mm,ss,deg,mi,sec
str=strcompress(' '+str_in+' ')
idx=strsplit(str,' ')
idx=[idx,strlen(str)]
for k=0,n_elements(idx)-2,1 do print,strmid(str,idx(k),idx(k+1)-idx(k))
hh=fix(strmid(str,idx(0),idx(1)-idx(0)))
mm=fix(strmid(str,idx(1),idx(2)-idx(1)))
ss=fix(strmid(str,idx(2),idx(3)-idx(2)))
deg=fix(strmid(str,idx(3),idx(4)-idx(3)))
mi=fix(strmid(str,idx(4),idx(5)-idx(4)))
sec=fix(strmid(str,idx(5),idx(6)-idx(5)))
return
end
