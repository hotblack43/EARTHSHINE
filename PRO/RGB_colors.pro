PRO matchcoords2,alfa_1,delta_1,alfa_2,delta_2,alfa_3,delta_3,idx,jdx,kdx
 common limits,errlim
 ; will match the coordinates in alfa_1,delta_1,alfa_2,delta_2 and alfa_3,delta_3
 ; returning idx, jdx and kdx which point to the SAME coordinates
 ; in lists 1, 2 and 3, respectively
 n1=n_elements(alfa_1)
 idx=[]
 jdx=[]
 kdx=[]
 for i=0,n1-1,1 do begin
     print,i,' of ',n1
     INDEX = MINDIST(alfa_1(i),delta_1(i),alfa_2,delta_2,distance=distance)
     ;if (distance le errlim) then begin
     INDEX2 = MINDIST(alfa_2(index),delta_2(index),alfa_3,delta_3,distance=distance2)
     print,distance,distance2
     if (sqrt(distance2*distance) le errlim) then begin
         idx=[idx,i]
         jdx=[jdx,index]
         kdx=[kdx,index2]
         endif
     ;endif
     endfor
 return
 end
 
 PRO getdatafromcatfile,catfilename,mag,magerr,alfa,delta,maxflux
 data=get_data(catfilename)
 mag=reform(data(3,*))
 magerr=reform(data(4,*))
 maxflux=reform(data(8,*))
 alfa=reform(data(11,*))
 delta=reform(data(12,*))
 return
 end
 
 ;==============================
 common limits,errlim
 errlim=.1	; degrees
 close,/all
 getdatafromcatfile,'R_new.cat',R,Rerr,alfa_R,delta_R,maxflux_R
 getdatafromcatfile,'G_new.cat',G,Gerr,alfa_G,delta_G,maxflux_G
 getdatafromcatfile,'B_new.cat',B,Berr,alfa_B,delta_B,maxflux_B
 nbri=min([n_elements(r),n_elements(G),n_elements(b)])
 print,'All data fetched, and the brightest selected'
 matchcoords2,alfa_R,delta_R,alfa_G,delta_G,alfa_B,delta_B,idx,jdx,kdx
 ; restrict the choice now
 alfa_R=alfa_R(idx)
 delta_R=delta_R(idx)
 R=R(idx)
 Rerr=Rerr(idx)
 maxflux_R=maxflux_R(idx)
 
 alfa_G=alfa_G(jdx)
 delta_G=delta_G(jdx)
 G=G(jdx)
 Gerr=Gerr(jdx)
 maxflux_G=maxflux_G(jdx)
 
 alfa_B=alfa_B(kdx)
 delta_B=delta_B(kdx)
 B=B(kdx)
 Berr=Berr(kdx)
 maxflux_B=maxflux_B(kdx)
 ; save the data
 openw,44,'triples.dat'
 fmt='(6(1x,f11.7),6(1x,f7.3))'
 n=n_elements(r)
 ic=0
 for i=0,n-1,1 do begin
     if (Gerr(i) lt errlim and berr(i) lt errlim and rerr(i) lt errlim) then begin
         printf,44,format=fmt,alfa_R(i),delta_R(i),alfa_G(i),delta_G(i),alfa_B(i),delta_B(i),r(i),Rerr(i),g(i),Gerr(i),b(i),berr(i)
         print,format=fmt,alfa_R(i),delta_R(i),alfa_G(i),delta_G(i),alfa_B(i),delta_B(i),r(i),Rerr(i),g(i),Gerr(i),b(i),berr(i)
         ic=ic+1
         endif
     endfor
 print,'I wrote ',ic,'lines in triples.dat'
 close,44
 data=get_data('triples.dat')
 R=data(6,*)
 N=n_elements(R)
 Rerr=data(7,*)
 G=data(8,*)
 Gerr=data(9,*)
 B=data(10,*)
 Berr=data(11,*)
 plot,B-G,G,xtitle='B-G',ytitle='G',charsize=2,thick=3,charthick=2,psym=1,yrange=[max(g),min(g)]
 print,'N: ',N
 end
