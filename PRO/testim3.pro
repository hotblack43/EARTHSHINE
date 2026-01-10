jacobs=fltarr(512,512)
subim=dblarr(512,512)
openr,1,'JACOBTEST/subimg_after.raw' & readu,1,jacobs & close,1
openr,2,'JACOBTEST/subim_after.bin' & readu,2,subim& close,2
;
diff=double(subim)-double(jacobs)
pct=diff/jacobs*100.0
help
!P.multi=[0,2,2]
!P.CHARSIZE=3
surface,subim
surface,jacobs
surface,diff
surface,pct
end
