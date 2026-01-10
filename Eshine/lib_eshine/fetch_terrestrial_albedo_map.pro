PRO   fetch_terrestrial_albedo_map,indx0,indx1,indx2,indx3,indx4,indx5,indx6,indx7,indx,count0,count1,count2,count3,count4,count5,count6,count7,count
; read the binary version of the Earth albedo map
; it was set up using the utility 'write_ascii_as_bin.pro'
;---------------------------------------------------------------------------------
openu,11,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\Eshine\data_eshine\Earth.1d.map.binary'
l=[0L,0L]
readu,11,l
x=fltarr(l)
readu,11,x
close,11
  indx0 = where(X EQ 0,count0)   ; water
  indx1 = where(X EQ 1,count1)   ; ice
  indx2 = where(X EQ 2,count2)   ; land
  indx3 = where(X EQ 3,count3)   ; land
  indx4 = where(X EQ 4,count4)   ; land
  indx5 = where(X EQ 5,count5)   ; land
  indx6 = where(X EQ 6,count6)   ; land
  indx7 = where(X EQ 7,count7)   ; ice
  indx  =  where(X LT 0 OR X GT 7, count)
  return
  end