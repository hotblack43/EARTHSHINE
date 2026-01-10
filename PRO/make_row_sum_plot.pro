PRO make_row_sum_plot,image,x00,y00,radius
common facts,probableradius,probablex00,probabley00
l=size(image,/dimensions)
icol=indgen(l(0))
rowsum=total(image,2)
plot,rowsum,xtitle='Column no.',ytitle='Sum along rows'
idx=where(rowsum gt max(rowsum)/12.)
print,'The detected edges of the moon are at columns:',icol(idx(0)),icol(idx(n_elements(idx)-1))
;radius=(icol(idx(n_elements(idx)-1))-icol(idx(0)))/2.
radius=probableradius
x00=mean([icol(idx(0)),icol(idx(n_elements(idx)-1))])
y00=l(1)/2.
return
end

