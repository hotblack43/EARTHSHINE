data=get_data('data_for_paper_from_realimages.txt')
tot1=reform(data(0,*))/512.0d0/512.0d0
tot2=reform(data(1,*))/512.0d0/512.0d0
DS23=reform(data(2,*))
DS45=reform(data(3,*))
ds_bs=ds23/tot2
for i=0,4,1 do print,format='(f6.4)',ds_bs(i)
end
