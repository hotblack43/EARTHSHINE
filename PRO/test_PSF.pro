      c3 =  -0.9203336    ; +/-  1.3536011E-04
      c4 =   -1.601890    ; +/-  6.9708112E-05

r=findgen(511)+0.00001
rl=alog10(r)

	fac=c3+c4*rl
	psf=10^fac

plot_oo,r,psf
end

