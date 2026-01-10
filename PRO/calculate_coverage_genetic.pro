PRO    cksum,chromosome
n=n_elements(chromosome)
sum=0.0
base=2.0d0^findgen(n)
for i=0,n-1,1 do begin
sum=sum+chromosome(i)*base(i)
endfor
print,chromosome
print,'Checksum: ',sum
return
end


PRO mixtwochromosomes,chromosome1,chromosome2,OC1,OC2,newChromosome
 ; takes two chromosomes and swap bits randomly
 n=n_elements(chromosome1)
 newChromosome=indgen(n)*0
 swapxrnd=randomu(seed,n)
 limit=0.5	; chance of swapover
 swapflag=swapxrnd lt limit
 if (OC1 gt OC2) then begin
     for i=0,n-1,1 do begin
         newChromosome(i)=chromosome1(i)
         if (swapflag(i) eq 1) then begin
             newChromosome(i)=chromosome2(i)
             endif
         endfor
     endif else begin
     for i=0,n-1,1 do begin
         newChromosome(i)=chromosome2(i)
         if (swapflag(i) eq 1) then begin
             newChromosome(i)=chromosome1(i)
             endif
         endfor
     endelse
 return
 end
 
 PRO returnNnames,chromosome,names
 ; chromosome is a 44-element array of 1s and 0s
 obsnames= ['lund', 'tug', 'dmi', 'kpno', 'ctio', 'eso', 'lick', $
 'mmto', 'cfht', 'mlo', 'lapalma', 'mso', 'sso', 'aao', 'mcdonald',$
 'lco', 'mtbigelow', 'dao', 'spm', 'tona', 'Palomar', 'mdm', $
 'NOV', 'bmo', 'BAO', 'keck', 'ekar', 'apo', 'lowell', 'vbo', $
 'flwo', 'oro', 'lna', 'saao', 'casleo', 'bosque', 'rozhen', $
 'irtf', 'bgsuo', 'ca', 'holi', 'lmo', 'fmo', 'whitin']
 names=obsnames(where(chromosome eq 1))
 return
 end
 
 PRO getjustheobservablemoments,jd,eshine,jduse,eshineuse,obsname
 ic=0
 for i=0,n_elements(jd)-1,1 do begin
     xJD=jd(i)
     MOONPOS, xJD, ramoon, decmoon
     eq2hor, ramoon, decmoon, xJD, altmoon, azmoon,  OBSNAME=obsname,refract_=0
     SUNPOS, xJD, rasun, decsun
     eq2hor, rasun, decsun, xJD, altsun, azsun,  OBSNAME=obsname,refract_=0
     if (altmoon gt 0 and altsun lt 0) then begin
         ; Moon is observable
         if (ic eq 0) then begin
             jduse=xJD
             eshineuse=eshine(i)
             endif else begin
             jduse=[jduse,xJD]
             eshineuse=[eshineuse,eshine(i)]
             endelse
         ic=ic+1
         endif
     endfor
 return
 end
 
 PRO getOC,chromosome,OC,imonth
 ;----------------------------------------------------------------------
 ; Code to evaluate Observability Coverage (OC) of earthshine
 ; given a choice of observatories.that 
 ; OC = percent of time where there are no gaps in the observability.
 ; INPUT: 
 ; chromosome = A 44 element array (1s and 0s) selecting for N places
 ; imonth = 1 (january) or 2(July)
 ; OUTPUT: OC = the percentage covergae with continous observability given 
 ; the N chosen observatories
 ;----------------------------------------------------------------------
 returnNnames,chromosome,obsnames
 print,'Using: ',obsnames
 months=['january','july']
 get_lun,zz
 openw,zz,'deltas.dat'
 month=months(imonth-1)
 for iobs=0,n_elements(obsnames)-1,1 do begin
     data=get_data(strcompress('earthshine_intensity_'+month+'.dat',/remove_all))
     kdx=indgen(4000)+0
     jd=reform(data(0,kdx))
     Sshine=reform(data(1,kdx))
     eshine=reform(data(2,kdx))
     ph_M=reform(data(3,kdx))
     ph_E=reform(data(4,kdx))
     getjustheobservablemoments,jd,eshine,jduse,eshineuse,obsnames(iobs)
     offset=0.000
     delta=jduse-shift(jduse,1)
     delta=delta(1:n_elements(delta)-1)
     idx=where(delta gt 0.011)
     for kl=0,n_elements(jduse)-1,1 do printf,zz,format='(f15.7)',jduse(kl)
     endfor
 close,zz 
 free_lun,zz
 jduse=get_data('deltas.dat')
 jduse=jduse(sort(jduse))
 jduse=jduse(uniq(jduse))
 delta=jduse-shift(jduse,1)
 delta=delta(1:n_elements(delta)-1)
 idx=where(delta gt 0.011)
 globcov=100.-total(delta(idx))/(max(jd)-min(jd))*100.
 OC=globcov
 return
 end
 
 N=22
 imonth=1
 ; get first
 idx=fix(randomu(seed,n)*44)
 chromosome=indgen(44)*0
 chromosome(idx)=1
 chromosome1=chromosome
 getOC,chromosome1,OC1,imonth
 print,OC1
 ; get second
 idx=fix(randomu(seed,n)*44)
 chromosome=indgen(44)*0
 chromosome(idx)=1
 chromosome2=chromosome
 getOC,chromosome2,OC2,imonth
 print,OC2
 ; mix the two
 for igeneration=1,100,1 do begin
 print,'--------------------------------------------------------------'
     mixtwochromosomes,chromosome1,chromosome2,OC1,OC2,newChromosome
     getOC,newChromosome,OCnew,imonth
     print,OCnew
     chr=[[chromosome1],[chromosome2],[newChromosome]]
     ; select best two
     OC=[OC1,OC2,OCnew]
     OCsorted=reverse(OC(sort(OC)))
     idx=where(OC eq OCsorted(0))
     jdx=where(OC eq OCsorted(1))
     chromosome1=chr(*,idx(0))
     chromosome2=chr(*,jdx(0))
 ;   cksum,chromosome1
;    cksum,chromosome2
     endfor
 end
