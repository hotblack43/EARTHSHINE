flat=read_png('flat_minus_dark.png')
dark=read_png('mean_darkframe.png')
im0=read_png('img0.png')
im=(im0-dark)/flat
end
