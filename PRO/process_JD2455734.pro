bias=readfits('Fitted_Surface_BIAS.fits')
;
path='/media/LaCie/ASTRO/ANDOR/JD2455734/'
files=file_search(strcompress(path+'*.fits',/remove_all),count=n)
print,files
Bfiles=['/media/LaCie/ASTRO/ANDOR/JD2455734/2455734.0240196M7-B-60SECONDS.fits']
Vfiles=['/media/LaCie/ASTRO/ANDOR/JD2455734/2455734.0247458M7-V-60SECONDS.fits','/media/LaCie/ASTRO/ANDOR/JD2455734/2455734.0254776M7-V-60SECONDS.fits']
VE1files=['/media/LaCie/ASTRO/ANDOR/JD2455734/2455734.0290296M7-VE1-60SECONDS.fits','/media/LaCie/ASTRO/ANDOR/JD2455734/2455734.0297527M7-VE1-60SECONDS.fits','/media/LaCie/ASTRO/ANDOR/JD2455734/2455734.0304749M7-VE1-60SECONDS.fits','/media/LaCie/ASTRO/ANDOR/JD2455734/2455734.0311970M7-VE1-60SECONDS.fits','/media/LaCie/ASTRO/ANDOR/JD2455734/2455734.0319199M7-VE1-60SECONDS.fits']
Bim=readfits(Bfiles(0))
for i=0,n_elements(Vfiles)-1,1 do begin
if (i eq 0) then Vim=readfits(Vfiles(0))
if (i gt 0) then Vim=Vim+readfits(Vfiles(0))
endfor
Vim=Vim/n_elements(Vfiles)
for i=0,n_elements(VE1files)-1,1 do begin
if (i eq 0) then VE1im=readfits(VE1files(0))
if (i gt 0) then VE1im=VE1im+readfits(VE1files(0))
endfor
VE1im=VE1im/n_elements(VE1files)
;
Bim=Bim-bias
Vim=Vim-bias
VE1im=VE1im-bias
writefits,'Bim.fits',Bim
writefits,'Vim.fits',Vim
writefits,'VE1im.fits',VE1im
end

