PRO generate_interesting_problem,problem
; will put some numbers into the field 'problem' to make it interesting for the analysis
l=size(problem,/dimensions)
problem=randomn(seed,l(0),l(1),poisson=5)
return
end
