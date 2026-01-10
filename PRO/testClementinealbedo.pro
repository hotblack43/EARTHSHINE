datalib = 'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\Eshine\data_eshine/'
  X = read_ascii(datalib+'/'+'HIRES_750_3ppd.alb',data_start=0)
  PNORMmoon = float(X.field0001)
  z=smooth(PNORMmoon,15,/edge_truncate)
; Make the surface, save transform:
SURFACE, z, /SAVE,charsize=2

; Now display a flat contour plot, at the maximum Z value
; (normalized coordinates):
device,decomposed=0
loadct,39
CONTOUR, z, /NOERASE, /T3D, ZVALUE=1.0 ,/cell_fill,charsize=2 ,nlevels=31
;
print,'Meanof PNORMMoon=',mean(PNORMMoon)
lat=indgen(540)/539.*2.-1.
lat=lat*90.
w=cos(lat/180.0d0*!pi)
;w=w/total(w)
print,'Sum of w:',total(w)
for i=0,1080-1,1 do  PNORMMoon(i,*)=PNORMMoon(i,*)*w(*)
print,'Meanof PNORMMoon*cos(lat)=',mean(PNORMMoon)
END
