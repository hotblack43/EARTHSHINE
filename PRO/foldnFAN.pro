 FUNCTION foldnFAN, X, P
 ; must return an array from the model 
 common stuff117,name,use1,use2,im1,im2,raw,RMSE,x0,y0,radius,nbands,w1,w2,w3,w4
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl,paramname
 common headerstuff,mixedimageheader,header
 common Y, Yobs
 common fanstuff,rad_raw,line_raw,rad_folded,line_folded
 common erry,erry
 common filterstuff,filter,if_want_replacedBS
 common vizualisation,ifviz
 print,format='(a,10(1x,f9.3))','In foldnFAN, p=',p
;a=get_kbrd()
 lll=size(raw,/dimensions)
 rawncols=lll(0)
 rawnrows=lll(1)
 alfa1=p(0)
 bwpr=p(1)
 pedestal=p(2)
 albedo=p(3)
 xshift=p(4)
 acoeff=p(5)
 lamda0=p(6)
 print,'lamda0: ',lamda0
  get_lun,hgjfrte & openw,hgjfrte,'LAMDA0.txt'
  	printf,hgjfrte,lamda0
  close,hgjfrte & free_lun,hgjfrte
 yshift=p(7)
 zodi=p(8)
 SLcounts=p(9)
 print,'zodi and SLcounts: ',zodi,SLcounts
 mixedimage=im1*(1.0-albedo)+im2*albedo
 ; identify the pixel that should have added Zodial light corrections
 idx=where(mixedimage eq 0.0)
 ; fold 
 writefits,'mixed117.fits',mixedimage,mixedimageheader
 str='./justconvolve_spPFS mixed117.fits trialout117.fits '+string(alfa1)+' '+string(acoeff)+' '+string(bwpr)
 spawn,str;,/NOSHELL
 folded=readfits('trialout117.fits',/silent)
; as a trial, smooth the model image alittle bit ...
;folded=smooth(folded,7,/edge_truncate)
 folded=shift_sub(folded,xshift,yshift)+pedestal
 folded=folded/total(folded,/double)*total(raw,/double)
 ; now add the ZL+SL correction to the sky-only pixels
 folded(idx)=folded(idx)+zodi+SLcounts
; build a new header based on the old one along with
 header_synth=header
 for klg=0,n_elements(p)-1,1 do begin
 sxaddpar,header_synth , strcompress('parm_'+string(klg),/remove_all), p(klg), paramname(klg)
 endfor
 writefits,strcompress('OUTPUT/IDEAL/synth_folded_scaled_shifted_JD'+string(JD,format='(f15.7)')+'_'+filter+'.fits',/remove_all),folded,header_synth
 ;==================folded image now ready for use=============================
 imethod=3
 ; get the 'fan' for the folded image
 actioninidcator=314
 use_cusp_angle_fan_DS_BS,actioninidcator,folded,x0,y0,radius,rad_folded,line_folded,dummy,imethod,w1,w2,w3,w4
 if (if_smoo eq 1) then line_folded=smooth(line_folded,11,/edge_truncate)
 value=line_folded
 x=rad_folded
 rad_folded=x
 ;=============================================PLOT AFTER THIS===================
 if (ifviz eq 1) then set_plot,'X'
 !P.MULTI=[0,1,1]
 if (ifviz eq 1) then ladder_plot,x,Yobs,value,'Columns','Observed and fitted counts',labelstr+name
 line=Yobs
 resids=(line-value)
 w=1./erry
 RMSE=sqrt(total(resids^2)/n_elements(resids))
 ;---------legend
 ystart=!Y.crange(1)
 ystep=(!Y.crange(1)-!Y.crange(0))/20.
 q=!x.crange(0)+(!x.crange(1)-!x.crange(0))/10.
 if (ifviz eq 1) then begin
 xyouts,q,ystart-1.*ystep,'!7a!d1!n!3 = '+string(alfa1,format='(f7.4)')
 xyouts,q,ystart-2.*ystep,'!7b!3      = '+string(bwpr,format='(f7.4)')
 xyouts,q,ystart-3.*ystep,'pedestal   = '+string(pedestal,format='(f8.3)')
 xyouts,q,ystart-4.*ystep,'!7D!3x     = '+string(xshift,format='(f7.4)')
 xyouts,q,ystart-5.*ystep,'!7D!3y     = '+string(yshift,format='(f7.4)')
 xyouts,q,ystart-6.*ystep,'a          = '+string(acoeff,format='(f7.4)')
 xyouts,q,ystart-7.*ystep,'lamda0     = '+string(lamda0,format='(f7.2)')
 xyouts,q,ystart-8.*ystep,'RMSE = '+string(RMSE,format='(f7.4)')
 xyouts,q,ystart-9.*ystep,'A* = '+string(albedo,format='(f7.4)')
 xyouts,q,ystart-10.*ystep,'ZL = '+string(zodi,format='(f7.4)')
 xyouts,q,ystart-11.*ystep,'SL = '+string(SLcounts,format='(f7.4)')
 endif
 ;---------------------
 return,value
 END
