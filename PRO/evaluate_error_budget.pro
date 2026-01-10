PRO four_error_terms,term1,term2,term3,term4
common stuff,tBS,delcDSDC,cBS,cBSDC,tDS,delcDS,cDS,cDSDC,delcBSDC,delcBS
term1=(-tBS*delcDSDC/((cBS-cBSDC)*tDS))^2
term2=(+tBS*delcDS/((cBS-cBSDC)*tDS))^2
term3=(+(cDS-cDSDC)*tBS*delcBSDC/((cBS-cBSDC)^2*tDS))^2
term4=(-(cDS-cDSDC)*tBS*delcBS/((cBS-cBSDC)^2*tDS))^2

return
end

common stuff,tBS,delcDSDC,cBS,cBSDC,tDS,delcDS,cDS,cDSDC,delcBSDC,delcBS
; first BBSO
delcDSDC=2.14
delcBSDC=2.14
delcDS=sqrt(4.5e4)	; poisson errors of the counts
cBSDC=300.
cDSDC=300.
cDS=4.5e4-3.5e4
cBS=50000.
tBS=23e-3
tDS=60.
delcBS=sqrt(cBS)
ES=cDS/tDS/(cBS/tBS)
four_error_terms,term1,term2,term3,term4
print,'BBSO relative to ES²:'
print,format='(f20.15)',term1/ES^2
print,format='(f20.15)',term2/ES^2
print,format='(f20.15)',term3/ES^2
print,format='(f20.15)',term4/ES^2
print,'rel err on ES: ',sqrt(term1+term2+term3+term4)/ES*100.,' %'
; then MLO 
delcDSDC=2.14
delcBSDC=2.14
delcDS=0.08	; empirically from good fits
cBSDC=400.
cDSDC=400.
tBS=20e-3	; exp time
tDS=20e-3	; exp time
cBS=50000.
cDS=405.
delcBS=sqrt(cBS)	; Poisson errors
ES=cDS/tDS/(cBS/tBS)
four_error_terms,term1,term2,term3,term4
print,'MLO relative to ES²:'
print,format='(f20.15)',term1/ES^2
print,format='(f20.15)',term2/ES^2
print,format='(f20.15)',term3/ES^2
print,format='(f20.15)',term4/ES^2
print,'rel err on ES: ',sqrt(term1+term2+term3+term4)/ES*100.,' %'
; then for area means
; first BBSO
delcDSDC=sqrt(0.06^2+0.088^2)
delcBSDC=sqrt(0.06^2+0.088^2)
print,'BBSO delta DC:',delcDSDC
delcDS=sqrt(4.5e4)	; poisson errors of the counts
cBSDC=300.
cDSDC=300.
cDS=4.5e4-3.5e4
cBS=50000.
tBS=23e-3
tDS=60.
delcBS=sqrt(cBS)
ES=cDS/tDS/(cBS/tBS)
four_error_terms,term1,term2,term3,term4
print,'BBSO relative to ES²:'
print,format='(f20.15)',term1/ES^2
print,format='(f20.15)',term2/ES^2
print,format='(f20.15)',term3/ES^2
print,format='(f20.15)',term4/ES^2
print,'rel err on ES: ',sqrt(term1+term2+term3+term4)/ES*100.,' %'
; then MLO 
delcDSDC=sqrt(0.0046+0.088^2)
delcBSDC=sqrt(0.0046+0.088^2)
print,'MLO delta DC:',delcDSDC
delcDS=0.08	; empirically from good fits
cBSDC=400.
cDSDC=400.
tBS=20e-3	; exp time
tDS=20e-3	; exp time
cBS=50000.
cDS=405.
delcBS=sqrt(cBS)	; Poisson errors
ES=cDS/tDS/(cBS/tBS)
four_error_terms,term1,term2,term3,term4
print,'MLO relative to ES²:'
print,format='(f20.15)',term1/ES^2
print,format='(f20.15)',term2/ES^2
print,format='(f20.15)',term3/ES^2
print,format='(f20.15)',term4/ES^2
print,'rel err on ES: ',sqrt(term1+term2+term3+term4)/ES*100.,' %'
end
