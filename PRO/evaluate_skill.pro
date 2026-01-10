PRO evaluate_skill,y,x,skills,ab_estimated,ab_actual,nskills
 ; y is the target
 ; x is the reconstruction
 ; evaluates 6 skills
 nskills=6
 skills=fltarr(nskills)
; plain correlation
 skills(0)=correlate(y,x)
; smoothed correlation 
 nsmoo=10
 skills(1)=correlate(smooth(y,nsmoo,/edge_truncate),smooth(x,nsmoo,/edge_truncate))
; bias between mean values of y
 skills(2)=(mean(x)-mean(y))/mean(y)
; bias between variance 
 sig_rec=stddev(smooth(x,nsmoo,/edge_truncate))
 sig_tar=stddev(smooth(y,nsmoo,/edge_truncate))
 skills(3)=(sig_rec-sig_tar)/sig_tar
; bias between linear slopes 
 dum=linfit(indgen(n_elements(y)),y,/double)
 tau_tar=dum(1)
 dum=linfit(indgen(n_elements(x)),x,/double)
 tau_rec=dum(1)
 skills(4)=(tau_rec-tau_tar)/tau_tar
; bias between regression coefficients 
  stuff=((ab_estimated-ab_actual)/ab_actual)^2
  skills(5)=sqrt(total(stuff))/float(n_elements(stuff))
 return
 end
