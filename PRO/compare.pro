openr,1,'justthefilename.txt'
s=''
readf,1,s
close,1
set_plot,'ps'
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
device,filename='bestfit.ps',/color
bestdifference=readfits('bestdifference.fits')
model=readfits('bestmodel.fits')
observed=readfits('presentinput.fits')
plot,observed(*,256),/ylog,title='Forward method on '+s
oplot,model(*,256),color=fsc_color('red')
device,/close
data=get_data('coords.dat')
x0=reform(data(0,*))
y0=reform(data(1,*))
radius=reform(data(2,*))
data=get_data('photometry_boxes.relcoords')
DSoffsetL=reform(data(0,0))	; offset from x0 to left side of DS box
DSoffsetR=reform(data(1,0))
DSoffsetD=reform(data(2,0))	; offset from x0 to bottom of DS box
DSoffsetU=reform(data(3,0))
BSoffsetL=reform(data(0,1))	; offset from x0 to left side of BS box
BSoffsetR=reform(data(1,1))
BSoffsetD=reform(data(2,1))	; offset from x0 to bottom of BS box
BSoffsetU=reform(data(3,1))
print,x0+DSoffsetL,x0+DSoffsetR,y0+DSoffsetD,y0+DSoffsetU
print,x0+BSoffsetL,x0+BSoffsetR,y0+BSoffsetD,y0+BSoffsetU
; extract DS
DS=bestdifference(x0+DSoffsetL:x0+DSoffsetR,y0+DSoffsetD:y0+DSoffsetU)
; extract BS
         BS=model(x0+BSoffsetL:x0+BSoffsetR,y0+BSoffsetD:y0+BSoffsetU)
relerr=sqrt((stddev(BS)/sqrt(n_elements(BS))/mean(BS))^2+(stddev(DS)/sqrt(n_elements(DS))/mean(DS))^2)
print,'BS/DS: ',mean(BS)/mean(DS),relerr*100.,' %'
openw,56,'ratio_and_relerr.dat' & printf,56,mean(BS)/mean(DS),relerr*100. & close,56
end

