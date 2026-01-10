PRO getthecommondata,JD1,albedo1,albedo1SD,JD2,albedo2,albedo2SD,JD,albedo,albedoSD
 JD=[JD1,JD2]
 JD=JD(sort(JD))
 JD=JD(uniq(JD))
 n=n_elements(JD)
 openw,23,'albedos_from_two_methods.dat'
 for i=0,n-1,1 do begin
     idx=where(JD1 eq JD(i))
     jdx=where(JD2 eq JD(i))
     if (idx(0) ne -1 and jdx(0) ne -1) then begin
         for k=0,n_elements(idx)-1,1 do begin
             printf,23,format='(f15.7,4(1x,f10.6))',JD1(idx(k)),albedo1(idx(k)),albedo1SD(idx(k)),albedo2(jdx(k)),albedo2SD(jdx(k))
             endfor
         endif
     endfor
 close,23
 return
 end
 
 PRO reducemultiplestomeans,JD,albedo,albedoSD
 uniqJDs=JD(SORT(JD))
 uniqJDs=uniqJDs(uniq(uniqJDs))
 n=n_elements(uniqJDs)
 liste=[]
 for i=0,n-1,1 do begin
     idx=where(JD eq uniqJDs(i))
     if (n_elements(idx) ge 2) then begin
         liste=[[liste],[uniqJDs(i),median(albedo(idx),/double),robust_sigma(albedo(idx))]]
         endif else begin
         liste=[[liste],[uniqJDs(i),median(albedo(idx),/double),-0.00]]
         endelse
     endfor
 JD=reform(liste(0,*))
 albedo=reform(liste(1,*))
 albedoSD=reform(liste(2,*))
 return
 end
 
 PRO extract_albedo_list_1,file,JD,albedo
 spawn,"awk '{print $1,$3,$6}' "+file+" > getme.dat"
 openr,1,'getme.dat'
 albedo=[]
 jd=[]
 while not eof(1) do begin
     jdin=0.0d0
     alb1=0.0d0
     alb2=0.0d0
     readf,1,jdin,alb1,alb2
     jd=[jd,jdin]
     albedo=[albedo,alb1]	; ignore alb2 for now
     endwhile
 close,1
 return
 end
 
 PRO extract_albedo_list_2,otherlistname,JD,albedo2
 n=n_elements(JD)
 liste=[]
 for i=0,n-1,1 do begin
     spawn,'rm getme.dat'
     str="grep "+string(JD(i),format='(f15.7)')+" "+otherlistname+" | awk '{print $1,$2}' > getme.dat "
     spawn,str
     if (file_test('getme.dat',/zero_length) eq 0) then begin
         data=get_data('getme.dat')
         l=size(data,/dimensions)
         nrows=l(1)
         for k=0,nrows-1,1 do liste=[[liste],[jd(i),data(1,k)]]
         endif
     endfor
 JD=reform(liste(0,*))
 albedo2=reform(liste(1,*))
 return
 end
 
 ;===================================================
 ; Code that produces means of common entries from two lists
 fmt='(f15.7,1x,f10.6)'
 listname='albedo_estimated_from_his.dat'
 extract_albedo_list_1,listname,JD,albedo1
 JD1=JD
 reducemultiplestomeans,JD1,albedo1,albedo1SD
 ;
 otherlistname='CLEM.testing_JAN_21_2015.txt'
 extract_albedo_list_2,otherlistname,JD,albedo2
 JD2=JD
 reducemultiplestomeans,JD2,albedo2,albedo2SD
 ;
 getthecommondata,JD1,albedo1,albedo1SD,JD2,albedo2,albedo2SD,JD,albedo,albedoSD
 data=get_data('albedos_from_two_methods.dat')
 jd=reform(data(0,*))
 albedo1=reform(data(1,*))
 albedo1SD=reform(data(2,*))
 albedo2=reform(data(3,*))
 albedo2SD=reform(data(4,*))
 plot,charsize=1.7,xrange=[min([albedo1,albedo2]),max([albedo1,albedo2])],yrange=[min([albedo1,albedo2]),max([albedo1,albedo2])],albedo1,albedo2,xstyle=3,ystyle=3,/isotropic,psym=7,xtitle='A from histogram',ytitle='A from fits'
 oploterr,albedo1,albedo1SD
 ldx=where(abs(albedo1-albedo2) gt 0.01)
 nldx=n_elements(ldx)
 if (ldx(0) ne -1) then begin
     print,'Bad albedo determinations:'
     print,'   JD             delta Albedo'
     for kl=0,nldx-1,1 do print,format=fmt,jd(ldx(kl)),albedo1(ldx(kl))-albedo2(ldx(kl))
     endif
 xyouts,albedo1(ldx),albedo2(ldx),string(JD(ldx),format='(f15.7)'),orientation=35
 oplot,[0,1],[0,1],linestyle=1
 print,'... touch a key to see a histogram ...'
 a=get_kbrd()
 histo,albedo1-albedo2,-0.2,0.2,0.006,/abs,xtitle='!7D!3 A'
 end
