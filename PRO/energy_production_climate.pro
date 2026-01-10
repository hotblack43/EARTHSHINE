; first build a time series for rate of global energy use
; base it on one number for a given year and then
; update by some percentage from year to year
E0=1.5e13	; Watt.	 source is http://en.wikipedia.org/wiki/World_energy_resources_and_consumption
		; this is for 2005
nyears=100
years=findgen(nyears)+2005
energy_rate=findgen(nyears)
factor=1.02	; i.e. 2 percent more per year
energy_rate(0)=E0
for i=1,nyears-1,1 do energy_rate(i)=energy_rate(i-1)*factor 
radius_earth=6371.0*1e3	; radius in meters
area=4.*!pi*radius_earth^2	; area of Earth in square meters
forcing=energy_rate/area
;
plot,years,forcing,xtitle='Year',ytitle='Forcing (W/m!u2!n)',charsize=1.9,title='Forcing due to energy use at 2% annual growth'
end	
