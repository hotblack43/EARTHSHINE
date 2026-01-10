PRO shift_g_to_center,g
	idx=where(g eq max(g))
	l=size(g,/dimensions)
	if (idx(0) ne -1) then begin
			maxat=array_indices(g,idx(0))
			gshifted=shift(g,l(0)/2.-maxat(0),l(1)/2.-maxat(1))
			g=shift(gshifted,l(0)/2.,l(1)/2.)
	endif
	return
	end