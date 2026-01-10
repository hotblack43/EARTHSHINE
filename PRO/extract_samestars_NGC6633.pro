
data=get_data('plate.JDs')
n=n_elements(data)
for iplate=0,n-1,1 do begin
spawn,"grep "+string(data(iplate),format='(f15.7)')+" colated_NGC6633_filternums.dat > data.dat"
list=get_data('data.dat')
help,list
print,'--------------------------------'
endfor
end
