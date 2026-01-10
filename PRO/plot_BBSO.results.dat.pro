dev='ps'
set_plot,dev
if (dev eq 'ps') then device,/color
!P.CHARSIZE=2
 !P.THICK=2
 !X.THICK=2
 !Y.THICK=2
 jdmin=1e22
 jdmax=-1e22
 ratiomax=-1e22
 names=['VE1','VE2','V','B','IRCUT']
 farver=['orange','red','blue','cyan','green']
 for inam=0,n_elements(names)-1,1 do begin
     wantname=names(inam)
     filename=strcompress(wantname+'.dat',/remove_all)
	ic=0
     openw,55,filename
     file='BBSO.results.dat'
     openr,1,file
     while not eof(1) do begin
         jd=0.0d0
         ratio=0.0
         err=0.0
         name=''
         readf,1,jd,ratio,err,name
         if (jd lt jdmin) then jdmin=jd
         if (jd gt jdmax) then jdmax=jd
         if (ratio gt ratiomax) then ratiomax=ratio
         name=strcompress(name,/remove_all)
         if (name eq wantname) then begin
             printf,55,format='(f17.7,2(1x,f9.3))',jd,ratio,err
             print,format='(f17.7,2(1x,f9.3),1x,a)',jd,ratio,err,name
	ic=ic+1
             endif
         endwhile
     close,55
	if (ic ne 0) then begin
     data=get_data(filename)
     jd=reform(data(0,*))
     ratio=reform(data(1,*))
     err=reform(data(2,*))
     if (inam eq 0) then begin
         if (dev ne 'ps') then plot,/nodata,jd-jdmin,ratio,xrange=[0,jdmax-jdmin],psym=7,yrange=[0,ratiomax],xstyle=3,ystyle=3,xtitle='Days',ytitle='BS/DS',color=fsc_color('white'),title=string(long(jdmin))
         if (dev eq 'ps') then plot,/nodata,jd-jdmin,ratio,xrange=[0,jdmax-jdmin],psym=7,yrange=[0,ratiomax],xstyle=3,ystyle=3,xtitle='Days',ytitle='BS/DS',color=fsc_color('black'),title=string(long(jdmin))
         oplot,jd-jdmin,ratio,color=fsc_color(farver(inam)),psym=7
         ;oploterr,jd-jdmin,ratio,err*ratio/100.
         endif else begin
         oplot,jd-jdmin,ratio,color=fsc_color(farver(inam)),psym=7
         ;oploterr,jd-jdmin,ratio,err*ratio/100.
         endelse
	endif
     close,1
     endfor
 end
