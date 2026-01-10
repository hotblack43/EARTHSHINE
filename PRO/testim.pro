target=dblarr(512,512)
subim=fltarr(512,512)
openr,1,'observed.bin' & readu,1,target & close,1
openr,2,'subim.bin' & readu,2,subim& close,2
;
a=384
b=103
c=296
print,'target(a,c)=',target(a,c),' target(b,c)=',target(b,c)
print,'subim(a,c)=',subim(a,c),' subim(b,c)=',subim(b,c)
end
