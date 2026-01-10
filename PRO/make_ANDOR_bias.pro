ims=readfits('./ANDOR/Flatfield_2010_10_11/Bias.fits')
l=size(ims,/dimensions)
for order=1,5,1 do begin
print,'Surface poly order:',order
; 1 median
median_bias=median(ims,dimension=3)
sfit_median_bias=sfit(median_bias,order)
; 2 mean
mean_bias=total(ims,3)/float(l(2))
sfit_mean_bias=sfit(mean_bias,order)
; 3 half_median
get_meanhalfmedianval,ims,halfmedian_bias
sfit_halfmedian_bias=sfit(halfmedian_bias,order)
;
surface,[median_bias,mean_bias,halfmedian_bias]
surface,[sfit_median_bias,sfit_mean_bias,sfit_halfmedian_bias]
pctdelta_1_2=(sfit_median_bias-sfit_mean_bias)/sfit_mean_bias*100.0
pctdelta_1_3=(sfit_median_bias-sfit_halfmedian_bias)/sfit_halfmedian_bias*100.0
pctdelta_2_3=(sfit_halfmedian_bias-sfit_mean_bias)/sfit_mean_bias*100.0
sd_residuals_median=stddev(median_bias-sfit_median_bias)
sd_residuals_mean=stddev(mean_bias-sfit_mean_bias)
sd_residuals_half_median=stddev(halfmedian_bias-sfit_halfmedian_bias)
print,'Max diff in pct median vs mean     : ',max(abs(pctdelta_1_2))
print,'Max diff in pct half_median vs median: ',max(abs(pctdelta_1_3))
print,'Max diff in pct half_median vs mean: ',max(abs(pctdelta_2_3))
print,'S.D: HI-PASS median      :',sd_residuals_median
print,'S.D: HI-PASS mean        :',sd_residuals_mean
print,'S.D: HI-PASS half-median :',sd_residuals_half_median
; save
writefits,strcompress('bias_median_sfit_order_'+string(order)+'.fits',/remove_all),sfit_median_bias
writefits,strcompress('bias_mean_sfit_order_'+string(order)+'.fits'   ,/remove_all),sfit_mean_bias
writefits,strcompress('bias_half_median_sfit_order_'+string(order)+'.fits'   ,/remove_all),sfit_halfmedian_bias
endfor
end
