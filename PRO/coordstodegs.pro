PRO coordstodegs,RAstr,DECstr,RAdegs,DECdegs
; converts the given strings to doubleing point degrees
; First RA
hh=double(strmid(RAstr,0,2))
mm=double(strmid(RAstr,3,2))
sec=double(strmid(RAstr,6,6))
RAdegs=ten(hh*15.,mm,sec)
; now DEC
deg=double(strmid(DECstr,0,3))
mm=double(strmid(DECstr,4,2))
sec=double(strmid(DECstr,7,6))
DECdegs=ten(deg,mm,sec)
return
end
