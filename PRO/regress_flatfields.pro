PRO gosavethem,ijd,gain,gain_sig,bias,bias_sig,filter_str
 if (median(bias) ne 0) then begin
     print,'Wrote files.'
     name=strcompress('bias_gain_'+filter_str+'_'+string(ijd,format='(f15.7)')+'.fits',/remove_all)
     writefits,name,[[[gain]],[[gain_sig]],[[bias]],[[bias_sig]]]
     endif
 return
 end

 PRO godoregression,names,exptime,gain,gain_sig,bias,bias_sig
 n=n_elements(names)
 stack=[]
 t=[]
 bias=dblarr(512,512)
 gain=dblarr(512,512)
 bias_sig=dblarr(512,512)
 gain_sig=dblarr(512,512)
 for i=0,n-1,1 do begin
     im=readfits(names(i),/silent)
     l=size(im)
     if (l(0) eq 3) then im=avg(im,2)
     l=size(im)
     if (l(0) ne 2) then stop
     if (max(im) lt 50000. and min(im) gt 1000) then begin
         tvscl,hist_equal(im)
         stack=[[[stack]],[[im]]]
         t=[t,exptime(i)]
         endif
     endfor
 nstack=size(stack,/dimensions)
 n_t=n_elements(t)
 if (n_t ne nstack(2)) then stop
 if (nstack(2) gt 10 and n_t eq nstack(2)) then begin
 for icol=0,511,1 do begin
     for irow=0,511,1 do begin
         y=reform(stack(icol,irow,*))
         r=correlate(t,y)
         gain(icol,irow)=!VALUES.F_NaN
         bias(icol,irow)=!VALUES.F_NaN
         gain_sig(icol,irow)=!VALUES.F_NaN
         bias_sig(icol,irow)=!VALUES.F_NaN
         if (r gt 0.25) then begin
             res=robust_linefit(t,y,yhat,dummy,sig)
	    ;plot,t,y,psym=7
            ;oplot,t,yhat,color=fsc_color('red')
             bias(icol,irow)=res(0)
             bias_sig(icol,irow)=sig(0)
             gain(icol,irow)=res(1)
             gain_sig(icol,irow)=sig(1)
             endif
         endfor
     endfor
     endif
 end
 
 PRO jusgetalldata,JD,exptime,names
 file='flatsinfo.txt'
 openr,1,file
 jd=[]
 exptime=[]
 names=[]
 while not eof(1) do begin
     str=''
     readf,1,str
     bits=strsplit(str,' ',/extract)
     jd=[jd,double(bits(0))]
     exptime=[exptime,double(bits(2))]
     names=[names,(bits(3))]
     endwhile
 close,1
 return
 end
 
 PRO getJDs,filnam,intJDs
 file='flatsinfo.txt'
 str="grep "+filnam+" "+file+" | awk '{print $1}' > allJDs"
 spawn,str
 intJDs=reform(long(get_data('allJDs')))
 intJDs=intJDs(sort(intJDs))
 intJDs=intJDs(uniq(intJDS))
 return
 end
 
 filternames=['_B_','_V_','_IRCUT_','_VE1_','_VE2_']
 jusgetalldata,JD,exptime,names
 for ifilter=0,4,1 do begin
     getJDs,filternames(ifilter),intJDs
     nJDs=n_elements(intJDs)
     for iJD=min(intJDs)-0.5,max(intJDs)+0.5,1.0 do begin
         idx=where(jd gt ijd and jd le ijd+1.)
         if (idx(0) ne -1 and max(exptime(idx)) gt 10.* min(exptime(idx))) then begin
             autohist,jd(idx)
             if (n_elements(idx) gt 20) then begin
                 print,format='(a10,i5,2(1x,f9.4),1x,f15.7)',filternames(ifilter),n_elements(idx),min(exptime(idx)),max(exptime(idx)),ijd
                 godoregression,names(idx),exptime(idx),gain,gain_sig,bias,bias_sig
                 gosavethem,ijd,gain,gain_sig,bias,bias_sig,filternames(ifilter)
                 endif
             endif
         endfor
     endfor
 end
