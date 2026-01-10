file='DMI_and_ROLFSVEJ_JDs.txt'
openr,1,file
print,"--------------------------------"
while not eof(1) do begin
str=''
readf,1,str
spawn,'touch  DMI.dat'
spawn,'rm DMI.dat'
spawn,'touch  ROLF.dat'
spawn,'rm ROLF.dat'
spawn,"grep "+str+" CLEM.DMI.profiles_fitted_results_SELECTED_5_multipatch_contrFIX_stacks_17May2014.txt  > DMI.dat"
spawn,"grep "+str+" CLEM.profiles_fitted_results_SELECTED_5_multipatch_contrFIX_stacks_17May2014.txt > ROLF.dat"
stop
print,"--------------------------------"
endwhile
close,1
end
