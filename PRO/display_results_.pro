; set the experiment string
 str='Cols40to80'
 str='WholeDisk'
 str='SkyOnly'
 str='Cols0to200'
 tstr=str+'_'
 path=str+'/'
 ; read the test area limits:
 openr,2,strcompress(path+tstr+'limits.dat',/remove_all)
 readf,2,llim,rrlim,dlim,ulim
 close,2
 ;
 cleaned=readfits(strcompress(path+tstr+'cleaned.fit',/remove_all))
 imout=readfits(strcompress(path+tstr+'imout.fit',/remove_all))
 kernel=readfits(strcompress(path+tstr+'kernel.fit',/remove_all))
 scattered=readfits(strcompress(path+tstr+'scattered.fit',/remove_all))
 ideal=readfits(strcompress(path+tstr+'ideal.fit',/remove_all))
 imin=readfits(strcompress(path+tstr+'imin.fit',/remove_all))
 !p.MULTI=[0,1,2]
 !P.CHARSIZE=2
 !P.THICK=2
 !X.THICK=2
 !Y.THICK=2
 ;surface,imin,title='Observed image',/zlog
 ;surface,ideal,title='Assumed in-space look',/zlog
 ;surface,scattered,title='derived scattered light'
 ;surface,kernel,title='PSF'
 ;surface,imout,title='Simulated obserevd image',/zlog
 ;surface,cleaned,title='Cleeaned image',/zlog
 ;----------------------------------
 contour,imin,title='Observed image',xstyle=1,ystyle=1,/isotropic
 contour,ideal,title='Assumed in-space look',xstyle=1,ystyle=1,/isotropic
 contour,scattered,title='Derived scattered light',xstyle=1,ystyle=1,/isotropic
 ;contour,kernel,title='PSF',xstyle=1,ystyle=1,/isotropic
 contour,imout,title='Simulated observed image',xstyle=1,ystyle=1,/isotropic
 contour,cleaned,title='Cleaned image',xstyle=1,ystyle=1,/isotropic
 plots,[llim,llim],[dlim,ulim]
 plots,[llim,rrlim],[ulim,ulim]
 plots,[rrlim,rrlim],[ulim,dlim]
 plots,[rrlim,llim],[dlim,dlim]
 ; plot numerical results
 !p.MULTI=[0,1,2]
 !P.CHARSIZE=1.1
 plot,cleaned(*,512/2.),xtitle='Column',ytitle='Counts',title='Cleaned image slice (dashed), Observed (solid)',xstyle=1,ystyle=1,linestyle=2
 oplot,imin(*,512/2.)
 plots,[!X.crange],[0,0],thick=1
 openr,1,strcompress(path+tstr+'results.dat',/remove_all)
 i=0
 xyouts,/normal,0.1,0.3+0.05,strcompress('Dir: '+path+tstr)
 while not eof(1) do begin
     str=''
     readf,1,str
     xyouts,/normal,0.1,0.3-i*0.05,str
     i=i+1
     endwhile
 close,1
 end
