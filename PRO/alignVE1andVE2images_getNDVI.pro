 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
 return
 end

imname1='/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456045.8499006MOON_VE1_AIR_DCR.fits'
imname2='/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456045.8408621MOON_VE2_AIR_DCR.fits'

R=readfits(imname1,h1)
get_EXPOSURE,h1,exptime
print,'VE1 exptime: ',exptime
R=R/exptime
NIR=readfits(imname2,h2)
get_EXPOSURE,h2,exptime
print,'VE2 exptime: ',exptime
NIR=NIR/exptime
;
shifts=alignoffset(R,NIR)
R=shift_sub(R,-shifts(0),-shifts(1))
ndvi=(NIR-R)/(NIR+R)
writefits,'ndvi.fits',ndvi
tvscl,ndvi
end
