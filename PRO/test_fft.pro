n=100
matrix=randomn(seed,n,n)
fft_2d=fft(matrix,-1)
for irow=0,n-1,1 do begin
row=matrix(*,irow)
if(irow eq 0) then row_1d_fft=fft(row,-1) else row_1d_fft=[[[row_1d_fft]],[fft(row,-1)]]
endfor
for icol=0,n-1,1 do begin
col=row_1d_fft(icol,*)
if(icol eq 0) then row_2d_fft=transpose(fft(col,-1)) else row_2d_fft=[[transpose(fft(col,-1))],[[row_2d_fft]]]
endfor
ratio=fft_2d/row_2d_fft
end
