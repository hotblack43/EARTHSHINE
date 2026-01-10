data=get_data('QE_Andor_897.txt')
x=reform(data(0,*))
y=reform(data(1,*))
area=int_tabulated(x,y,/double)
print,'Area=',area
xspan=max(x)-min(x)
print,'X span:',xspan
print,'mean QE = ',area/xspan
end
