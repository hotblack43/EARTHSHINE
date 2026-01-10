!P.CHARSIZE=1.7
!P.THICK=2
idelname='./BMINUSVWORKAREA/ideal_LunarImg_SCA_0p310_JD_2455945.1760145.fit'
str='./syntheticmoon '+idelname+' out1.fits 1.7 100 767655'
spawn,str
str='./syntheticmoon '+idelname+' out2.fits 1.7 100 8755'
spawn,str
id1=readfits('out1.fits')+4
id2=readfits('out2.fits')+4
!P.MULTI=[0,1,5]
plot_io,id1(*,256),xstyle=3,ystyle=3
plot_io,id2(*,256),xstyle=3,ystyle=3
sid1=median(id1,3)
sid2=median(id2,3)
idx=where(finite(id1) ne 1)
jdx=where(finite(id2) ne 1)
if (idx(0) ne -1) then id1(idx)=sid1(idx)
if (jdx(0) ne -1) then id2(jdx)=sid2(jdx)
plot_io,id1(*,256),xstyle=3,ystyle=3
plot_io,id2(*,256),xstyle=3,ystyle=3
id1=18.64-2.5*alog10(id1)
id2=18.-2.5*alog10(id2)
BmV=id1-id2
plot,BmV(*,256),xstyle=3,ystyle=3
print,'min,max of the fake B-V image: ',min(BmV),max(BmV)
writefits,'fake_BmVimage_JD2455945.fits',BmV
print,'Image written'
end
