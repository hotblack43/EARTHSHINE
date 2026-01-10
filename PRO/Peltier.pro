txt='Peltier element TEC1-12706, room T and 0'
!P.MULTI=[0,1,3]
file='Peltier.dat'
data=get_data(file)
volts=reform(data(0,*))
resist=reform(data(1,*))

idx=sort(resist)
volts=volts(idx)
resist=resist(idx)
current=volts/resist
power=volts*current
plot,resist,current*1000.,xtitle='Resistance (Ohm)',ytitle='Current (mA)',charsize=1.8,psym=7,title=txt
tension=.035
oplot,resist,tension/resist*1000.
plot,resist,volts,xtitle='Resistance (Ohm)',ytitle='Voltage (V)',charsize=1.8,psym=7
oplot,[!x.crange],[tension,tension]
plot,resist,power*1000.,xtitle='Resistance (Ohm)',ytitle='Power (mW)',charsize=1.8,psym=7

end