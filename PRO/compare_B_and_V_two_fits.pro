FUNCTION mhm,x_in
x=x_in
x=x(sort(x))
n=n_elements(x)
value=mean(x(n*0.25:n*0.75),/double)
return,value
end


fil1='CLEM.DMI.profiles_fitted_results_SELECTED_5_multipatch_contrFIX_stacks_17May2014_2456017.txt'
fil2='CLEM.profiles_fitted_results_multipatch_stacks_29May2014_ZODI_STARL_V_2456017.txt'
fil3='CLEM.profiles_fitted_results_multipatch_stacks_29May2014_ZODI_STARL_2456017_B.txt'
;
spawn,"grep _B_ "+fil1+" | awk '{print $2}' > data_B_noZLSL.dat"
spawn,"grep _V_ "+fil1+" | awk '{print $2}' > data_V_noZLSL.dat"
;
spawn,"grep _V_ "+fil2+" | awk '{print $2}' > data_V_ZLSL.dat"
spawn,"grep _B_ "+fil3+" | awk '{print $2}' > data_B_ZLSL.dat"
;
B_noZLSL=reform(get_data('data_B_noZLSL.dat'))
V_noZLSL=reform(get_data('data_V_noZLSL.dat'))

B_ZLSL=reform(get_data('data_B_ZLSL.dat'))
V_ZLSL=reform(get_data('data_V_ZLSL.dat'))
!P.MULTI=[0,1,2]
phere=!P.COLOR
histo,[B_noZLSL,V_noZLSL],0.3,0.5,0.00586547654
oplot,[median(B_noZLSL),median(B_noZLSL)],[!Y.crange],linestyle=2
oplot,[median(V_noZLSL),median(V_noZLSL)],[!Y.crange],linestyle=2
!P.COLOR=fsc_color('red')
histo,/overplot,[B_ZLSL,V_ZLSL],0.3,0.5,0.0059878765
oplot,[median(B_ZLSL),median(B_ZLSL)],[!Y.crange],linestyle=2
oplot,[median(V_ZLSL),median(V_ZLSL)],[!Y.crange],linestyle=2
!P.COLOR=phere
;
;print,'Without ZL and SL corrections B-V = ',mean(B_noZLSL)-mean(V_noZLSL)
;print,'Wit     ZL and SL corrections B-V = ',mean(B_ZLSL)-mean(V_ZLSL)
print,'Without ZL and SL corrections B-V = ',mhm(B_noZLSL)-mhm(V_noZLSL)
print,'Wit     ZL and SL corrections B-V = ',mhm(B_ZLSL)-mhm(V_ZLSL)
s1=stddev(B_noZLSL)/sqrt(n_elements(B_noZLSL)-1)
s2=stddev(V_noZLSL)/sqrt(n_elements(V_noZLSL)-1)
s3=stddev(B_ZLSL)/sqrt(n_elements(B_ZLSL)-1)
s4=stddev(V_ZLSL)/sqrt(n_elements(V_ZLSL)-1)
print,'S.D: of mean on B and V without ZL and SL : ',s1,s2
print,'S.D: of mean on B and V wit     ZL and SL : ',s3,s4
print,'error on difference in B-V : ',sqrt(s1^2+s2^2+s3^2+s4^2)
print,'SNR : ',(mhm(B_noZLSL)-mhm(V_noZLSL)-(mhm(B_ZLSL)-mhm(V_ZLSL)))/sqrt(s1^2+s2^2+s3^2+s4^2),' S.D.'
end
