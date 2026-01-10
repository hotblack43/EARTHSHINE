 PRO get_UBV,wave,U,B,V,R,I
 openr,1,'/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/ph11.U'
 readf,1,nfilters
 for i=0,nfilters-1,1 do begin
     readf,1,npoints
     for j=0,npoints-1,1 do begin
         readf,1,lamda,trans
         trans=trans/100.
         if (j eq 0) then table=[lamda/10.,trans]
         if (j gt 0) then table=[[table],[lamda/10.,trans]]
         endfor
     endfor
 close,1
 U=table
 ;.........................
 openr,1,'/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/MKO_f4_Bessel_B.dat'    
 readf,1,nfilters
 for i=0,nfilters-1,1 do begin
     readf,1,npoints
     for j=0,npoints-1,1 do begin
         readf,1,lamda,trans
         trans=trans/100.
         if (j eq 0) then table=[lamda,trans]
         if (j gt 0) then table=[[table],[lamda,trans]]
         endfor
     endfor
 close,1
 B=table
 ;.........................
 openr,1,'/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/MKO_f4_Bessel_V.dat'    
 readf,1,nfilters
 for i=0,nfilters-1,1 do begin
     readf,1,npoints
     for j=0,npoints-1,1 do begin
         readf,1,lamda,trans
         trans=trans/100.
         if (j eq 0) then table=[lamda,trans]
         if (j gt 0) then table=[[table],[lamda,trans]]
         endfor
     endfor
 close,1
 V=table
 ;.........................
 openr,1,'/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/MKO_f4_Bessel_R.dat'    
 readf,1,nfilters
 for i=0,nfilters-1,1 do begin
     readf,1,npoints
     for j=0,npoints-1,1 do begin
         readf,1,lamda,trans
         trans=trans/100.
         if (j eq 0) then table=[lamda,trans]
         if (j gt 0) then table=[[table],[lamda,trans]]
         endfor
     endfor
 close,1
 R=table
 ;.........................
 openr,1,'/home/thejll/SCIENCEPROJECTS/EARTHSHINE/FILTERS/CTIO_f4_I.dat'    
 readf,1,nfilters
 for i=0,nfilters-1,1 do begin
     readf,1,npoints
     for j=0,npoints-1,1 do begin
         readf,1,lamda,trans
         trans=trans/100.
         if (j eq 0) then table=[lamda,trans]
         if (j gt 0) then table=[[table],[lamda,trans]]
         endfor
     endfor
 close,1
 I=table
 ;.........................
 ; now convert to tables that cover the range of 'wave'
 for ifilter=1,5,1 do begin
     if (ifilter eq 1) then old=U
     if (ifilter eq 2) then old=B
     if (ifilter eq 3) then old=V
     if (ifilter eq 4) then old=R
     if (ifilter eq 5) then old=I
     oldx=reform(old(0,*))
     oldy=reform(old(1,*))
     for k=0,n_elements(wave)-1,1 do begin
         interpolated_transm=INTERPOL(oldy,oldx,wave(k))
         if (wave(k) lt min(oldx)) then interpolated_transm=0.0
         if (wave(k) gt max(oldx)) then interpolated_transm=0.0
         if (k eq 0) then newtable=[wave(k),interpolated_transm]
         if (k gt 0) then newtable=[[newtable],[wave(k),interpolated_transm]]
         endfor
     if (ifilter eq 1) then U=newtable
     if (ifilter eq 2) then B=newtable
     if (ifilter eq 3) then V=newtable
     if (ifilter eq 4) then R=newtable
     if (ifilter eq 5) then I=newtable
     endfor
 return
 end
