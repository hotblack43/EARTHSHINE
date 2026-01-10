PRO two_shooter_budget
common stuff,I_bright,I_low,n_pix,n_ims
; give magnitude of random error per pixel due to various sources:
; delta_IB	= Poisson error on bright side pixel
delta_IB=sqrt(I_bright)
; delta_ID	= Poisson error on dark side pixel
delta_ID=sqrt(I_low)
; Dark Frame error
delta_DF= 2.	; the SD on one pixel after DF removal
; Flat_Field error
delta_FF= 0.005	; guesstimate!
; ND filter error
delta_ND=0.003	; the one-shooter does not rely on knowing the ND transmission
; Scattered light removal error
delta_SL=0.29	; per pixel in one image
; DIfferential extinction removal
delta_DE_fractional=0.001 ; notet hat this is the fractional error - not the aboslute
;
; now combine to get the total fractional error per pixel
;
fmt_str='(11(1x,f12.7),2(1x,i4),1x,a)'
header='Tot_per_pix    Poisson_D   Poisson_B    DF_D           DF_B           FF_D           FF_B            SL_D            SL_B           DE               Tot_np_ni   np     ni     type'
openw,1,'two_shooter_random_error_budget.dat'
print,'ERROR BUDGET FOR TWO-SHOOTER DESIGN'
print,header

f_tot_squared=(delta_ID/I_low)^2+(delta_IB/I_bright)^2+(delta_DF/I_low)^2+ $
(delta_DF/I_bright)^2+(delta_FF/I_low)^2+(delta_FF/I_bright)^2+ $
(delta_SL/I_low)^2+(delta_SL/I_bright)^2+delta_DE_fractional^2

; allow for averaging over independent pixels and images
f_tot_squared_mean=f_tot_squared/n_pix/n_ims

print,format=fmt_str,sqrt(f_tot_squared),delta_ID/I_low,delta_IB/I_bright,delta_DF/I_low,$
delta_DF/I_bright,delta_FF/I_low,delta_FF/I_bright,delta_SL/I_low,$
delta_SL/I_bright,delta_DE_fractional,sqrt(f_tot_squared_mean),n_pix,n_ims,'     random error'

printf,1,format=fmt_str,sqrt(f_tot_squared),delta_ID/I_low,delta_IB/I_bright,delta_DF/I_low,$
delta_DF/I_bright,delta_FF/I_low,delta_FF/I_bright,delta_SL/I_low,$
delta_SL/I_bright,delta_DE_fractional,sqrt(f_tot_squared_mean),n_pix,n_ims

close,1
;                            BIAS
; give magnitude of bias due to various sources:
; delta_IB	= bias error on bright side pixel
delta_IB=0.0
; delta_ID	= bias error on dark side pixel
delta_ID=0.0
; Dark Frame error
delta_DF= 2.	; the bias on one pixel after DF removal
; Flat_Field error
delta_FF= 0.005	; guesstimate!
; ND filter error
delta_ND=0.0	; the one-shooter does not rely on knowing the ND transmission
; Scattered light removal error
delta_SL=0.0	; bias per pixel in one image - zero for now
; Differential extinction removal
delta_DE_fractional=0.0 ; notet hat this is the fractional bias - not the aboslute
;
; now combine to get the total bias error per pixel
;
fmt_str='(11(1x,f12.7),2(1x,i4),1x,a)'
openw,1,'two_shooter_bias_error_budget.dat'
bias_tot=(delta_ID/I_low)+(delta_IB/I_bright)+(delta_DF/I_low)+ $
(delta_DF/I_bright)+(delta_FF/I_low)+(delta_FF/I_bright)+ $
(delta_SL/I_low)+(delta_SL/I_bright)+delta_DE_fractional
print,format=fmt_str,bias_tot,delta_ID/I_low,delta_IB/I_bright,delta_DF/I_low,$
delta_DF/I_bright,delta_FF/I_low,delta_FF/I_bright,delta_SL/I_low,$
delta_SL/I_bright,delta_DE_fractional,bias_tot,1,1,'      bias'
printf,1,format=fmt_str,bias_tot,delta_ID/I_low,delta_IB/I_bright,delta_DF/I_low,$
delta_DF/I_bright,delta_FF/I_low,delta_FF/I_bright,delta_SL/I_low,$
delta_SL/I_bright,delta_DE_fractional,bias_tot,1,1
close,1
return
end

PRO one_shooter_budget
common stuff,I_bright,I_low,n_pix,n_ims
; give magnitude of random error per pixel due to various sources:
; delta_IB	= Poisson error on bright side pixel
delta_IB=sqrt(I_bright)
; delta_ID	= Poisson error on dark side pixel
delta_ID=sqrt(I_low)
; Dark Frame error
delta_DF= 2.	; the SD on one pixel after DF removal
; Flat_Field error
delta_FF= 0.005	; guesstimate!
; ND filter error
delta_ND=0.0	; the one-shooter does not rely on knowing the ND transmission
; Scattered light removal error
delta_SL=0.29	; per pixel in one image
; DIfferential extinction removal
delta_DE_fractional=0.001 ; notet hat this is the fractional error - not the aboslute
;
; now combine to get the total fractional error per pixel
;
fmt_str='(11(1x,f12.7),2(1x,i4),1x,a)'
header='Tot_per_pix    Poisson_D   Poisson_B    DF_D           DF_B           FF_D           FF_B            SL_D            SL_B           DE               Tot_np_ni   np     ni     type'
openw,1,'one_shooter_random_error_budget.dat'
print,'ERROR BUDGET FOR ONE-SHOOTER DESIGN'
print,header

f_tot_squared=(delta_ID/I_low)^2+(delta_IB/I_bright)^2+(delta_DF/I_low)^2+ $
(delta_DF/I_bright)^2+(delta_FF/I_low)^2+(delta_FF/I_bright)^2+ $
(delta_SL/I_low)^2+(delta_SL/I_bright)^2+delta_DE_fractional^2

; allow for averaging over independent pixels and images
f_tot_squared_mean=f_tot_squared/n_pix/n_ims

print,format=fmt_str,sqrt(f_tot_squared),delta_ID/I_low,delta_IB/I_bright,delta_DF/I_low,$
delta_DF/I_bright,delta_FF/I_low,delta_FF/I_bright,delta_SL/I_low,$
delta_SL/I_bright,delta_DE_fractional,sqrt(f_tot_squared_mean),n_pix,n_ims,'     random error'

printf,1,format=fmt_str,sqrt(f_tot_squared),delta_ID/I_low,delta_IB/I_bright,delta_DF/I_low,$
delta_DF/I_bright,delta_FF/I_low,delta_FF/I_bright,delta_SL/I_low,$
delta_SL/I_bright,delta_DE_fractional,sqrt(f_tot_squared_mean),n_pix,n_ims

close,1
;                            BIAS
; give magnitude of bias due to various sources:
; delta_IB	= bias error on bright side pixel
delta_IB=0.0
; delta_ID	= bias error on dark side pixel
delta_ID=0.0
; Dark Frame error
delta_DF= 2.	; the bias on one pixel after DF removal
; Flat_Field error
delta_FF= 0.005	; guesstimate!
; ND filter error
delta_ND=0.0	; the one-shooter does not rely on knowing the ND transmission
; Scattered light removal error
delta_SL=0.0	; bias per pixel in one image - zero for now
; Differential extinction removal
delta_DE_fractional=0.0 ; notet hat this is the fractional bias - not the aboslute
;
; now combine to get the total bias error per pixel
;
fmt_str='(11(1x,f12.7),2(1x,i4),1x,a)'
openw,1,'one_shooter_bias_error_budget.dat'
bias_tot=(delta_ID/I_low)+(delta_IB/I_bright)+(delta_DF/I_low)+ $
(delta_DF/I_bright)+(delta_FF/I_low)+(delta_FF/I_bright)+ $
(delta_SL/I_low)+(delta_SL/I_bright)+delta_DE_fractional
print,format=fmt_str,bias_tot,delta_ID/I_low,delta_IB/I_bright,delta_DF/I_low,$
delta_DF/I_bright,delta_FF/I_low,delta_FF/I_bright,delta_SL/I_low,$
delta_SL/I_bright,delta_DE_fractional,bias_tot,1,1,'        bias'
printf,1,format=fmt_str,bias_tot,delta_ID/I_low,delta_IB/I_bright,delta_DF/I_low,$
delta_DF/I_bright,delta_FF/I_low,delta_FF/I_bright,delta_SL/I_low,$
delta_SL/I_bright,delta_DE_fractional,bias_tot,1,1
close,1
return
end

PRO plotter
; ------- First one shooter, random error
openr,1,'one_shooter_random_error_budget.dat'
x=fltarr(13)
readf,1,x
close,1
sqrtf_tot_squared=x(0)
f_ID=x(1)
f_IB=x(2)
f_DF_D=x(3)
f_DF_B=x(4)
f_FF_D=x(5)
f_FF_B=x(6)
f_SL_B=x(7)
f_SL_D=x(8)
f_DE=x(9)
sqrt_f_tot_sq_average=x(10)
n_pix=X(11)
n_ims=X(12)
array=indgen(10)
y=x(1:9)/sqrtf_tot_squared*100.
plot,array,y,psym=7,ytitle='Relative contribution of term (%)',title='Random error budget One-shooter', $
xtickv=array,xtickname=['Poi-D','Poi-B','DF-D','DF-B','FF-D','FF-B','SL-B','SL-D','DE'],xticks=8,xminor=1,xrange=[-1,9], $
/ylog,charsize=1.3,yrange=[min(y(where(y ne 0))),100]
; abs errors
plot,array,x(1:9),psym=7,ytitle='Term (pixels)',title='Absolute random error budget One-shooter', $
xtickv=array,xtickname=['Poi-D','Poi-B','DF-D','DF-B','FF-D','FF-B','SL-B','SL-D','DE'],xticks=8,xminor=1,xrange=[-1,9], $
/ylog,charsize=1.3,yrange=[min(y(where(y ne 0))),100]
stop
return
end

; code to evaluate error budget for eshine telescope an ddata-reduction system
; version 1
common stuff,I_bright,I_low,n_pix,n_ims
I_bright=45000L	; per pixel intensity in bright side
I_low=I_bright/1000L ; per pixel intensity in dark side
n_pix=100.0	; number of independent 'pixels' we will average over in one image
n_ims=10.0 ; number of images we will average over
one_shooter_budget

I_bright=45000L	; per pixel intensity in bright side
I_low=I_bright ; ideally!
n_pix=10.0	; number of independent 'pixels' we will average over in one image
n_ims=1.0 ; number of images we will average over
two_shooter_budget
!P.MULTI=[0,1,3]
plotter

end