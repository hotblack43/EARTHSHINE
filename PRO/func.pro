function func, P1, P2

;  This is a two-dimensional version of the multimodal function with
;  decreasing peaks used by Goldberg and Richardson (1987, see ReadMe
;  file for complete reference).  In two dimensions, this function has
;  25 peaks, but only one global maximum.  It is a reasonably tough
;  problem for the GA.  The uniform crossover micro-GA does well, the
;  single-point crossover micro-GA is slower, more conventional GA
;  techniques require reasonably large population sizes.


  pi=4.0*atan(1.d0)

  f11=(sin(5.1*pi*P1 + 0.5))^6.0
  f12=exp(-4.0*alog(2.0)*((P1-0.0667)^2.0)/0.64)

  f21=(sin(5.1*pi*P2 + 0.5))^6.0
  f22=exp(-4.0*alog(2.0)*((P2-0.0667)^2.0)/0.64)

  funcval=f11*f12*f21*f22
  return, funcval

end
