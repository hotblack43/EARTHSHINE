
PRO getexptimefromjd,jd,exptime
file=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_1/*'+string(jd,format='(f15.7)')+'*')
im=readfits(file(0),h)
idx=strpos(h,'EXPOSURE')
jdx=where(idx ne -1)
if (jdx eq -1) then stop
exptime=strmid(h(where(idx ne -1)),11,20)*1.0
return

end
name='/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456104.8329071MOON_IRCUT_AIR_DCR.fits'
jd='2456104.8329071'
getexptimefromjd,jd,exptime
print,exptime
end
