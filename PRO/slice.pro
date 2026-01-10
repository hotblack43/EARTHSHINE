
linfil='/media/SAMSUNG/DARKCURRENTREDUCED/JD2456016/BBSO_CLEANED/2456016.8085808MOON_B_AIR_DCR.fits'
logfil='/media/SAMSUNG/DARKCURRENTREDUCED/JD2456016/BBSO_CLEANED_LOG/2456016.8085808MOON_B_AIR_DCR.fits'
orgfil='/media/SAMSUNG/DARKCURRENTREDUCED/JD2456016/2456016.8085808MOON_B_AIR_DCR.fits'
org=readfits(orgfil)
lin=readfits(linfil)
logg=readfits(logfil)
!P.MULTI=[0,1,3]
plot,org(*,256),yrange=[-20,30]
plot,lin(*,256),color=fsc_color('red'),yrange=[-20,30]
plot,logg(*,256),color=fsc_color('blue'),yrange=[-20,30]
print,'original: ',mean(org(30:130,60:460)),stddev(org(30:130,60:460))/sqrt(n_elements(org(30:130,60:460)))
print,'linear  : ',mean(lin(30:130,60:460)),stddev(lin(30:130,60:460))/sqrt(n_elements(org(30:130,60:460)))
print,'log     : ',mean(logg(30:130,60:460)),stddev(logg(30:130,60:460))/sqrt(n_elements(org(30:130,60:460)))
end

