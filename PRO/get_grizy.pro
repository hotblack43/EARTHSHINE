PRO get_grizy,wave,gprime,rprime,iprime,zprime,yprime
 file='/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/panSTARSS_gprime.txt'
 data=get_data(file)
 data(0,*)=data(0,*)/10.	; convert to nm
 data(1,*)=data(1,*)/100.; convert from percent
 gprime=data
 ;.........................
 file='/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/panSTARSS_rprime.txt'
 data=get_data(file)
 data(0,*)=data(0,*)/10.	; convert to nm
 data(1,*)=data(1,*)/100.; convert from percent
 rprime=data
 ;.........................
 file='/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/panSTARSS_iprime.txt'
 data=get_data(file)
 data(0,*)=data(0,*)/10.	; convert to nm
 data(1,*)=data(1,*)/100.; convert from percent
 iprime=data
 ;.........................
 file='/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/panSTARSS_zprime.txt'
 data=get_data(file)
 data(0,*)=data(0,*)/10.	; convert to nm
 data(1,*)=data(1,*)/100.; convert from percent
 zprime=data
 ;.........................
 file='/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/panSTARSS_yprime.txt'
 data=get_data(file)
 data(0,*)=data(0,*)/10.	; convert to nm
 data(1,*)=data(1,*)/100.; convert from percent
 yprime=data
 ;.........................
 ; now convert to tables that cover the range of 'wave'
 for ifilter=1,5,1 do begin
     if (ifilter eq 1) then old=gprime
     if (ifilter eq 2) then old=rprime
     if (ifilter eq 3) then old=iprime
     if (ifilter eq 4) then old=zprime
     if (ifilter eq 5) then old=yprime
     oldx=reform(old(0,*))
     oldy=reform(old(1,*))
     for k=0,n_elements(wave)-1,1 do begin
         interpolated_transm=INTERPOL(oldy,oldx,wave(k))
         if (wave(k) lt min(oldx)) then interpolated_transm=0.0
         if (wave(k) gt max(oldx)) then interpolated_transm=0.0
         if (k eq 0) then newtable=[wave(k),interpolated_transm]
         if (k gt 0) then newtable=[[newtable],[wave(k),interpolated_transm]]
         endfor
     if (ifilter eq 1) then gprime=newtable
     if (ifilter eq 2) then rprime=newtable
     if (ifilter eq 3) then iprime=newtable
     if (ifilter eq 4) then zprime=newtable
     if (ifilter eq 5) then yprime=newtable
     endfor
 return
 end
