data=get_data('histograminput.dat')
print,'Median: ',median(data)
set_plot,'ps'
device,filename='PTHhisto_out.ps'
histo,data,min(data),max(data),(max(data)-min(data))/37.,/abs
device,/close
end
