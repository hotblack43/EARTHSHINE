 n=20
 nstrplus1=string(n*n);+1)
 data=get_data('/data/OUTPUT/TABLE_TOTRAIN.DAT')
 print,'Description of data: '
 help,data
 openw,2,'test_scaled_array.dat'
 fmtstr='('+nstrplus1+'(f12.6,","),f12.6)'
 print,fmtstr
 printf,2,format=fmtstr,data
 close,2
 end

