obs=readfits('obs.fits')
obs_line=avg(obs,1)
model=readfits('mod.fits')
model=shift(model,26)
mod_line=avg(model,1)
plot,obs_line,yrange=[-1,2]
oplot,mod_line*0.5*max(obs)/max(model)+0.4,color=fsc_color('red')
end
