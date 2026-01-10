PRO buildakernel,kernel
n=2
     Nx=n*2+1
     Ny=n*2+1
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
r=sqrt((x-(n+0.5))^2+(y-(n+0.5))^2)
scale=0.05
kernel=exp(-(r/scale)^2)
kernel=kernel/total(kernel)
return
end

 PRO get_discy0,header,discy0
 idx=where(strpos(header, 'DISCY0') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 discy0=float(strmid(str,16,15))
 return
 end

 PRO get_discx0,header,discx0
 idx=where(strpos(header, 'DISCX0') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 discx0=float(strmid(str,16,15))
 return
 end

efm=readfits('EFMCLEANED_0p7MASKED/2456034.1142920MOON_B_AIR_DCR.fits',header)
get_discx0,header,discx0
get_discy0,header,discy0
efm=shift(efm,256-discx0,256-discy0)
efm=reverse(efm,1)
ideal=readfits('FORHANS/OUTPUT/IDEAL/ideal_LunarImg_SCA_0p310_JD_2456034.1143634.fit')
;buildakernel,kernel
;ideal=convol(ideal,kernel)
;ideal=smooth(ideal,3,/edge_truncate)
bbsolin=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/BBSO_CLEANED/2456034.1142920MOON_B_AIR_DCR.fits')
bbsolin=shift(bbsolin,256-discx0,256-discy0)
bbsolin=reverse(bbsolin,1)
;
!P.MULTI=[0,1,3]
!P.CHARSIZE=2
!P.THICK=3
!x.THICK=4
!y.THICK=4
!P.CHARTHICK=3
for row=130,350,10 do begin	; chosen to intersect Grimaldi
plot,title='Black - ideal; Red - EFM; Blue - BBSO-lin',xstyle=3,ideal(*,row),ystyle=3,yrange=[-0.003,0.03],ytitle='Flux [W/m!u2!n]'
f=0.01*0.8/5.
o=0.0006
print,'Factor: ',f,' Offset: ',o
oplot,efm(*,row)*f+o,color=fsc_color('red')
oplot,bbsolin(*,row)*f+o,color=fsc_color('blue')
;
plot,xstyle=3,ideal(*,row),xrange=[300,400],ystyle=3,yrange=[0.01,0.02],ytitle='Flux [W/m!u2!n]'
oplot,efm(*,row)*f+o,color=fsc_color('red')
oplot,bbsolin(*,row)*f+o,color=fsc_color('blue')
plot,(ideal(*,row)-(efm(*,row)*f+o))/ideal(*,row)*100.0,$
xrange=[300,400],ystyle=3,yrange=[-20,20],ytitle='100*(I-C)/I'
oplot,(ideal(*,row)-(efm(*,row)*f+o))/ideal(*,row)*100.0,color=fsc_color('red')
oplot,(ideal(*,row)-(bbsolin(*,row)*f+o))/ideal(*,row)*100.0,color=fsc_color('blue')
oplot,[!X.CRANGE],[0,0],linestyle=1
;
endfor
writefits,'efmout.fits',efm
writefits,'idealout.fits',ideal
writefits,'bbsolinout.fits',bbsolin

end

