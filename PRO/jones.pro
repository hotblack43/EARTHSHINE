x1=randomn(seed,11)
x2=randomn(seed,11)
delta_jones=total(x2-x1)/n_elements(x2)
delta_other=total(x2)/n_elements(x2)-total(x1)/n_elements(x2)
print,delta_jones-delta_other
end

