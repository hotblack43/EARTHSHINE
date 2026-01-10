;################################################################################
;
; This procedure defines a simple interface to run the IDL GA. The input 
; parameters are defined in 'ga.inp'.
;
;################################################################################

pro runga

@ga.inp
avgfit_ar=dblarr(maxgen)
maxfit_ar=dblarr(maxgen)

pop1=obj_new('population',nselect=nselect, pop_size=pop_size, p_creep=p_creep, $
    p_mutate=p_mutate, p_crossover=p_crossover, npar=npar, parmin=parmin, $
		parmax=parmax, parbits=parbits, seed=seed, microga=microga, outfile=outfile)
r=obj_valid(pop1)

if (r eq 1) then begin
	for gen=1, maxgen do begin
		pop1->new_generation, params=params, avgfitness=avgfitness, $
    	maxfitness=maxfitness, gen=gen
		avgfit_ar[gen-1]=avgfitness
  	maxfit_ar[gen-1]=maxfitness
	endfor

	plot, maxfit_ar, psym=-1, yrange=[0,1]
	oplot, avgfit_ar, psym=-2, linestyle=2
	print, "Best solution: ", params, " with fitness: ", maxfit_ar[maxgen-1]

	obj_destroy, pop1
endif else begin
	print, "Population failed to initialise. See console for details!"
endelse

end
