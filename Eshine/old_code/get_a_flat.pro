FUNCTION get_a_flat,ncols,nrows,slope
flat=dindgen(ncols,nrows)
flat=flat/float(nrows*ncols)*slope+1.
flat=1.0d0+flat-mean(flat)
return, flat
end
