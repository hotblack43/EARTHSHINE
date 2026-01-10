 
 ; Version 2: find same stars different filters 
 filternames=['B','V','VE1','VE2','IRCUT']
 !P.MULTI=[0,3,4]
 !P.CHARSIZE=1.8
 ; for ifilter=0,4,1 do begin
 ;     print,'Filter '+filternames(ifilter)
 spawn,"cat colated_NGC6633_filternums.dat | awk '{print $1,$2,$3,$4,$5,$6,$7}' > data.dat"
 ;    spawn,"grep "+filternames(ifilter)+" colated_NGC6633.dat | awk '{print $1,$2,$3,$4,$5,$6}' > data.dat"
 for iloop=0,10000L,1 do begin
 data=get_data('data.dat')
 l=size(data,/dimensions)
 nstars=l(1)
     print,'Loop # ',iloop
     ;    for i=0,nstars-2,1 do begin
     idx=[]
     jdx=[]
     for j=0,nstars-1,1 do begin
         r=[]
         d=great_circle_simple(data(3,0),data(4,0),data(3,j),data(4,j),rad=1)/!dtor
         if (d le 2./512.) then idx=[idx,j]
         if (d gt 2./512.) then jdx=[jdx,j]
         endfor	; j loop
     if (idx ne !NULL) then begin
         kdx=sort(data(5,*))
         data=data(*,kdx)
         JDs=reform(data(0,idx))
         mags=reform(data(1,idx))
         magerrss=reform(data(2,idx))
         RA=reform(data(3,idx))
         DEC=reform(data(4,idx))
         airmass=reform(data(5,*))
         filternumbers=reform(data(6,*))
         nu=n_elements(JDs)
         openw,99,strcompress('Star_'+string(iloop)+'_photometry.dat',/remove_all)
         for kl=0,nu-1,1 do begin
	print,format='(f15.7,5(1x,f9.4),1x,i2)',JDs(kl),mags(kl),magerrss(kl),airmass(kl),RA(kl),DEC(kl),filternumbers(kl)
	printf,99,format='(f15.7,5(1x,f9.4),1x,i2)',JDs(kl),mags(kl),magerrss(kl),airmass(kl),RA(kl),DEC(kl),filternumbers(kl)
	 endfor
         close,99
         data=data(*,jdx)
         openw,44,'data.dat'
         for klu=0,n_elements(jdx)-1,1 do printf,44,format='(7(1x,f20.10))',data(*,klu)
         close,44
         endif else begin
         print,'Found no matches!'
         goto, here
         endelse
     ;endfor	; i loop
     ;endfor	; ifilter loop
     endfor	; iloop
     here:
 end
 
 
