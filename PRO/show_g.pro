PRO show_g,g
common sizes,l
common iternews,iter
	window,2,title='G',xsize=l(0),ysize=l(1)
	idx=where(g eq max(g))
	if (idx(0) ne -1) then begin
		maxat=array_indices(g,idx(0))
		gshifted=shift(g,l(0)/2.-maxat(0),l(1)/2.-maxat(1))
		tvscl,gshifted
	endif
return
end
