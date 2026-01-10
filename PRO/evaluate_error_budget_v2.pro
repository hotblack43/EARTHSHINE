PRO goprintit,strin,term1,term2,term3,term4,term5,term6
 array=abs([term1,term2,term3,term4,term5,term6])
 idx=where(array eq max(array))
 postr=['','','','','','']
 postr(idx)=' ***'
 print,strin
 print,format='(f20.15,1x,a,1x,a)',term1,' due to delta t DS',postr(0)
 print,format='(f20.15,1x,a,1x,a)',term2,' due to delta t BS',postr(1)
 print,format='(f20.15,1x,a,1x,a)',term3,' due to delta SB',postr(2)
 print,format='(f20.15,1x,a,1x,a)',term4,' due to delta DS',postr(3)
 print,format='(f20.15,1x,a,1x,a)',term5,' due to delta BS',postr(4)
 print,format='(f20.15,1x,a,1x,a)',term6,' due to delta f',postr(5)
 print,'rel err on ES: ',sqrt(term1^2+term2^2+term3^2+term4^2+term5^2+term6^2)*100.,' %'
 return
 end
 
 PRO fill_errors,commandstring
 common stuff,npixels,f,del_f,SB,delSB,tBS,deltBS,delcDSDC,cBS,cBSDC,tDS,deltDS,delcDS,cDS,cDSDC,delcBSDC,delcBS
 if (commandstring eq 'BBSOsinglepixel') then begin
     f=1.0	; superbias factor is very close to 1
     del_f=1.0536184e-05 ; delta on factor given SD of bias1+bias2 and nxn
     SB=300
     delSB=0.088	; Henriettes sigma (i.e. noise per pixel) for the superbias
     delcDSDC=2.14	; just RON 1 pixel
     delcBSDC=2.14	; just RON 1 pixel
     delcDS=sqrt(4.5e4)	; poisson errors of the counts
     cBSDC=300.
     cDSDC=300.
     cDS=4.5e4-3.5e4
     cBS=50000.
     tBS=23e-3
     tDS=60.
     deltBS=1e-6
     deltDS=1e-6
     delcBS=sqrt(cBS)
     endif
 if (commandstring eq 'BBSO_many_pixels') then begin
     f=1.0	; superbias factor is very close to 1
     del_f=1.0536184e-05 ; delta on factor given SD of bias1+bias2 and nxn
     SB=300
     delSB=0.088/sqrt(npixels-1)	; Henriettes sigma (i.e. noise per pixel) for the superbias
     delcDSDC=2.14/sqrt(npixels-1)	; if the area has npixels SD_m isless
     delcBSDC=2.14/sqrt(npixels-1)     	; if the area has npixels SD_m isless
     cBSDC=400.
     cDSDC=400.
     cBS=50000.
     cDS=4.5e4-3.5e4	; DS disc minus DS sky
     tBS=23e-3	; exp time
     tDS=60.	; exp time
     deltBS=1e-6
     deltDS=1e-6
     delcBS=sqrt(cBS)/sqrt(npixels-1)	; Poisson errors
     delcDS=sqrt(cDS+3.5e4)/sqrt(npixels-1)	; Poisson is due to obserevd counts, not the signal!
     endif
 if (commandstring eq 'MLOsinglepixel') then begin
     f=1.0	; superbias factor is very close to 1
     del_f=1.0536184e-05 ; delta on factor given SD of bias1+bias2 and nxn
     SB=400
     delSB=0.088	; Henriettes sigma (i.e. noise per pixel) for the superbias
     delcDSDC=2.14/sqrt(100.-1)	; RON in a single DC pixel averages over 100 images
     delcBSDC=2.14/sqrt(100.-1)	; RON in a single DC pixel averaged over 100 images
     delcDS=0.08	; empirically from rMSE of good fits
     cBSDC=400.
     cDSDC=400.
     cBS=50000.
     cDS=405.
     tBS=20e-3	; exp time
     tDS=20e-3	; exp time
     deltBS=1e-6
     deltDS=1e-6
     delcBS=sqrt(cBS)/sqrt(100.-1)	; Poisson errors
     endif
 if (commandstring eq 'MLO_many_pixels') then begin
; factor on superbias
     f=1.0	; superbias factor is very close to 1
; uncertainty of factor comes from uncertainty SD_m andis empirical
     del_f=1.0536184e-05 ; delta on factor given SD of bias1+bias2 and nxn
; superbias is at near 400 counts
     SB=400
; superbias has some noise in each picxel which Henritet estimated,; area average feels thisless
     delSB=0.088/sqrt(npixels-1)	; Henriettes sigma (i.e. noise per pixel) for the superbias
; in each image in thge 100-image stack there is RON, this is avregaed by the stacking,a nd the area looked at
     delcDSDC=2.14/sqrt(100.-1.)/sqrt(npixels-1)	; if the area has npixels SD_m isless
     delcBSDC=2.14/sqrt(100.-1.)/sqrt(npixels-1)     	; if the area has npixels SD_m isless
     cBSDC=400.
     cDSDC=400.
     cBS=50000.
     cDS=405.	; DS disc minus DS sky
     tBS=20e-3	; exp time
     tDS=20e-3	; exp time
     deltBS=1e-6
     deltDS=1e-6
     delcBS=sqrt(cBS)/sqrt(100.-1.)/sqrt(npixels-1)	; Poisson errors and avg of 100 images
     delcDS=0.08/sqrt(npixels-1)	; empirical RMSE from good fits
     endif
 return
 end
 

 
 PRO error_terms,term1,term2,term3,term4,term5,term6
 common stuff,npixels,f,del_f,SB,delSB,tBS,deltBS,delcDSDC,cBS,cBSDC,tDS,deltDS,delcDS,cDS,cDSDC,delcBSDC,delcBS
 outside = (cBS-f*SB)*tDS/((cDS-f*SB)*tBS)
 
 t1=-(cDS-f*SB)*tBS*deltDS/((cBS-f*SB)*tDS^2)
 t2=+(cDS-f*SB)*deltBS/((cBS-f*SB)*tDS)
 t3=+(f*(cDS-f*SB)*tBS/((cBS-f*SB)^2*tDS)-f*tBS/((cBS-f*SB)*tDS))*delSB
 t4=+tBS*delcDS/((cBS-f*SB)*tDS)
 t5=-(cDS-f*SB)*tBS*delcBS/((cBS-f*SB)^2*tDS)
 t6=+(SB*(cDS-f*SB)*tBS/((cBS-f*SB)^2*tDS)-SB*tBS/((cBS-f*SB)*tDS))*del_f
 
 term1=outside*t1
 term2=outside*t2
 term3=outside*t3
 term4=outside*t4
 term5=outside*t5
 term6=outside*t6
 
 return
 end
 
 common stuff,npixels,f,del_f,SB,delSB,tBS,deltBS,delcDSDC,cBS,cBSDC,tDS,deltDS,delcDS,cDS,cDSDC,delcBSDC,delcBS
 openw,44,'effectofnpixels.dat'
 for npixels=5,1000,5 do begin	; for use in area-means
 print,'------------------------------------------------------------'
 ;..............................................
 ; BBSO, single pixels
 fill_errors,'BBSOsinglepixel'
 error_terms,term1,term2,term3,term4,term5,term6
 goprintit,'BBSO - single-pixel term-errors :',term1,term2,term3,term4,term5,term6
 print,'------------------------------------------------------------'
 ;..............................................
 ; then MLO 
 fill_errors,'MLOsinglepixel'
 error_terms,term1,term2,term3,term4,term5,term6
 goprintit,'MLO - single-pixel term-errors :',term1,term2,term3,term4,term5,term6
 print,'------------------------------------------------------------'
 ;..............................................
 ; then BBSO areas
 fill_errors,'BBSO_many_pixels'
 error_terms,term1,term2,term3,term4,term5,term6
 goprintit,'BBSO - many-pixel term-errors :',term1,term2,term3,term4,term5,term6
 print,'------------------------------------------------------------'
 ;..............................................
 ; then MLO  areas
 fill_errors,'MLO_many_pixels'
 error_terms,term1,term2,term3,term4,term5,term6
 goprintit,'MLO - many-pixel term-errors :',term1,term2,term3,term4,term5,term6
 printf,44,format='(i3,1x,6(1x,f20.15))',npixels,term1,term2,term3,term4,term5,term6
 print,'------------------------------------------------------------'
 ;..............................................
 endfor
 close,44
 end
