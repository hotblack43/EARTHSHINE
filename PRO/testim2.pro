;jacobs=dblarr(1536,1536)
jacobs=fltarr(1536,1536)
subim=fltarr(1536,1536)
openr,1,'JACOBTEST/conv.raw' & readu,1,jacobs & close,1
;openr,1,'conv_dbl.raw' & readu,1,jacobs & close,1
;openr,1,'conv_single.raw' & readu,1,jacobs & close,1
openr,2,'JACOBTEST/convolved.bin' & readu,2,subim& close,2
;
a=384
b=103
c=296
;print,'jacobs(a,c)=',jacobs(a,c),' jacobs(b,c)=',jacobs(b,c)
;print,'subim(a,c)=',subim(a,c),' subim(b,c)=',subim(b,c)
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
