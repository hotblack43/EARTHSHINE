function imagefocusnumber,im
;value=total(sobel(im)/total(im))
value=total(abs(laplacian(im))/total(im))
return,value
end

PRO get_JD_from_filename,name,JD
ip=strpos(name,'24')
JD=double(strmid(name,ip,15))
return
end

close,/all
path='/media/HITACHI/BOOTSTRAPPEDOBSERVATINS/'
openw,55,'slopes_filters.dat'
 str=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
 JDstrs=['2456074','2456015','2456016','2456017','2456045','2456046','2456047','2456073','2456075','2456076']
 for istr=0,n_elements(JDstrs)-1,1 do begin
     !P.MULTI=[0,3,3]
     JDstr=JDstrs(istr)
     for k=0,n_elements(str)-1,1 do begin
         filter=str(k)
         files=file_search(path+JDstr+'*'+filter+'*fits*',count=n)
         if (n ne 0) then begin
             openw,33,'stats.dat'
             for i=0,n-1,1 do begin
                 im=readfits(files(i),/silent,header)
			get_info_from_header,header,'EXPOSURE',exptime
			texp=exptime(0)
			im=im/texp
                 idx=where(im gt median(im))
;                print,mean(im(idx)),stddev(im(idx))
                 printf,33,mean(im(idx)),stddev(im(idx)),mean(im(idx))/stddev(im(idx))
		get_JD_from_filename,files(i),JD
                 print,format='(1(a,1x),f15.7,2(1x,f9.5))',filter,JD,stddev(im(idx))/mean(im(idx)),imagefocusnumber(im)
                 endfor
             close,33
             data=get_data('stats.dat')
             !P.CHARSIZE=1.3
             x=data(0,*)
             y=data(1,*)
             z=data(2,*)
             idx=sort(x)
             x=x(idx)
             y=y(idx)
             plot,xstyle=3,ystyle=3,title=JDstr+' '+filter,x,y,psym=7,xtitle='Mean flux',ytitle='S.D. of flux'
             res=robust_linefit(x,y)
             res=ladfit(x,y)
		yfit=res(0)+res(1)*x
;            print,filter,' slope ',res(1)
		printf,55,res(1),' ',filter
             oplot,x,yfit,color=fsc_color('red')
		residuals=y-yfit
		sd=stddev(residuals)
		histo,xtitle='Residuals [1/S.D.]',residuals/sd,-4,4,0.25
		histo,xtitle='mean/S.D.',z,min(z),max(z),(max(z)-min(z))/11.
             endif
         endfor
     signature,'SCI/EARTHSHINE/test_focus.pro'
     endfor
	close,55
 end
