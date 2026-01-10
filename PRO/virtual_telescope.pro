;-----------------------------------------------------------------------------------
;
; virtual_telescope.pro
;
; Virtual Telescope
;
; Eric Steinbring
; Department of Astronomy and Astrophysics
; University of California at Santa Cruz
; Santa Cruz, CA, 95064
; Office: (831) 459-5804
; Fax: (831) 459-5717
; E-mail: steinb@ucolick.org
; WWW: www.ucolick.org/~steinb
;
; Documentation is available in 'virtual_telescope.doc'. The logbook is available in 'virtual_telescope.log'.
; 
;-----------------------------------------------------------------------------------	

;-----------------------------------------------------------------------------------
pro virtual_telescope

common  variables, $
        galaxy_bulge_radius, galaxy_disk_radius, galaxy_bulge_to_total_1, galaxy_bulge_to_total_2, galaxy_bulge_to_total_3, $
        galaxy_bulge_to_total_4, galaxy_cutoff, galaxy_faint, galaxy_multiple, galaxy_shift, galaxy_shrink, galaxy_correlation, $
        galaxy_line_width, $
        star_cutoff, star_faint, star_multiple, star_correlation, star_white_bright, star_white_fraction, star_surface_brightness, $
        star_distance_modulus, $
        telescope_temperature, telescope_primary, telescope_diameter, telescope_roughness, telescope_surfaces, telescope_error, $
        telescope_target, $
        optical_imager_filter, optical_imager_comparison, optical_imager_surfaces, optical_imager_detector, optical_imager_pixel, $
        optical_imager_readout, optical_imager_dark, optical_imager_gain, optical_imager_well, optical_imager_flag, optical_imager_exposure, $
        optical_imager_exposure_unit, $
        spectrograph_flag, spectrograph_resolution, spectrograph_slices, spectrograph_slits, spectrograph_length, spectrograph_width, $
        spectrograph_exposure, spectrograph_exposure_unit, spectrograph_position, spectrograph_extract, spectrograph_filter, $
        spectrograph_comparison, spectrograph_surfaces, spectrograph_detector, spectrograph_pixel, spectrograph_readout, spectrograph_dark, $
        spectrograph_gain, spectrograph_well, $
        target_flag, $
        pupil, aperture_hst, aperture_scaling, $
        mirror_coating_aluminum, mirror_coating_silver, mirror_coating_gold, grating_efficiency, filters, filter_bandpasses, $
        detector_efficiency_1, detector_efficiency_2, detector_efficiency_3, spectrum_1, spectrum_2, spectrum_3, spectrum_4, $
        colour_magnitude_1, colour_magnitude_2, $
        star_colour_shift_1, star_colour_shift_2, star_colour_shift_3, star_colour_shift_4, $
        background_total, atmospheric_transmission, $
        galaxy, galaxy_fake, galaxy_disk, galaxy_redshift, galaxy_magnitude, galaxy_classification, galaxy_radius, $
        galaxies, galaxies_redshift, galaxies_weight, galaxies_magnitude, galaxies_classification, galaxies_radius, galaxies_hst, $
        galaxies_telescope, galaxies_1, galaxies_2, galaxies_3, galaxies_4, galaxies_5, galaxies_list_x_pos, galaxies_list_y_pos, $
        galaxies_list_magnitude, galaxies_list_redshift, galaxies_list_classification, galaxies_list_radius, galaxies_list_rotate, $
        galaxies_list_ellipticity, galaxies_total_number, galaxies_total_number_hst, galaxies_number_counts, galaxies_number_counts_hst, $
        galaxies_number_counts_label, galaxies_distribution_magnitude, galaxies_distribution_redshift, galaxies_distribution_magnitude_hst, $
        galaxies_distribution_redshift_hst, galaxies_distribution_radius, galaxies_distribution_radius_hst, $
        star, star_fwhm, star_strehl, $
        stars, stars_hst, stars_telescope, stars_background, stars_list_magnitude, stars_list_x_pos, stars_list_y_pos, $
        stars_list_classification, stars_total_number, stars_total_number_hst, stars_number_counts, stars_number_counts_hst, $
        stars_number_counts_label, $
        spectrum, spectrum_extract, spectrum_true_extract, $
        x, y, $
        photometry, ratio, galaxy_radius_output, $
        statistics_magnitude, statistics_ratio, $
        colour_table, size_print, screen_output, $
        www, www_background, $
        initialize_field_done, initialize_telescope_done, optical_imager_done, infrared_camera_done,  $
        select_done, spectrum_integral_field_unit_done, spectrum_single_done, spectrum_multiplex_done, $
        field_running, telescope_running, oi_running, mos_running, $
        window_id

;Set the machine dependent values.

;For XWindows on PC. 
size_print=1.25

;For XWindows on Sun.
;size_print=0.75

;Shut off arithmetic error messages.
!except=-1

;Set the background colour to white.
!p.background=255

;Set the initialization toggles. Note, these parameters are set to 0 for the public version and 1 for the master version. They provide for error
;messages if the program is run in the incorrect order.
initialize_field_done=1
initialize_telescope_done=1
select_done=0
spectrum_integral_field_unit_done=0
spectrum_single_done=0
spectrum_multiplex_done=0
optical_imager_done=0
infrared_camera_done=0

;Set the control panel toggles.
field_running=0
telescope_running=0
oi_running=0
mos_running=0
analysis_running=0

;Generate the HTML code for a WWW interface. This is done in the following manner. Start up the program. Initialize the simulation. Set the
;parameters for the galaxy survey. Run the program with www_background=1 and www=0.  Set the target selection in the MOS simulation to 35 so that
;you do not see any redshift tags on the display and press 'Select Target'. Now, select a blank region in the field and take a  spectrum of the
;background. Stop the program. Now, set the same survey parameters again, set www_background=0 and www=1, and run a survey of all the galaxies in
;the field. When completed, copy all the files to the Virtual Telescope WWW directory called 'virtual_telescope_www'. Note that the file
;'virtual_telescope_www_interface.html' will need to be edited and moved the 'pubhtml' directory. The images of the display are all saved as
;full colour GIF files. The complete HTML code is generated.
www_background=0 ;This is set to 1 for yes and 0 for no.
www=0 ;This is set to 1 for yes and 0 for no.
if (www_background eq 1) then begin
 get_lun, unit
 openw, unit, './virtual_telescope_www/virtual_telescope_www_interface.html', /append
 printf, unit, '<html>'
 printf, unit, ' '
 printf, unit, '<head>'
 printf, unit, '<title>Virtual Telescope WWW Interface</title>'
 printf, unit, '</head>'
 printf, unit, ' '
 printf, unit, '<body bgcolor="#ffffff" link="#0000ff" vlink="#0000ff">'
 printf, unit, ' '
 printf, unit, '<map name="field">
 printf, unit, '</map>
 printf, unit, ' '
 printf, unit, '<img src="/~steinb/virtual_telescope_www/virtual_telescope_www_field.gif" align="left" vspace="0" hspace="0"'
 printf, unit, 'alt="Image of the Virtual Telescope deep field" border="0" usemap="#field">'
 printf, unit, ' '
 printf, unit, '</body>'
 printf, unit, ' '
 printf, unit, '</html>'  
 close, unit
 free_lun, unit
endif

;Reset the widget display.
widget_control, /reset

;Set up a display window.

;Build the base.
base=widget_base(/column, title='Virtual Telescope')

;The simulation control.
simulation_control=widget_base(base, /row)
button=widget_button(simulation_control, value='Field', uvalue='field', /align_center, xsize=75)
button=widget_button(simulation_control, value='Telescope', uvalue='telescope', /align_center, xsize=100)
button=widget_button(simulation_control, value='Optical Imager', uvalue='oi', /align_center, xsize=125)
button=widget_button(simulation_control, value='Multi-Object Spectrograph', uvalue='mos', /align_center, xsize=175)
label=widget_label(simulation_control, value='', xsize=200)
button=widget_button(simulation_control, value='Help', /help, uvalue='help', /align_center, xsize=50)
button=widget_button(simulation_control, value='Info', uvalue='information', /align_center, xsize=50)
button=widget_button(simulation_control, value='Zoom', /help, uvalue='zoom', /align_center, xsize=50)
button=widget_button(simulation_control, value='Quit', uvalue='quit', /align_center, xsize=50)

;The display base.
draw_base=widget_base(base,/row)
draw=widget_draw(draw_base, xsize=900, ysize=700)

;Realize the bases.
widget_control, /realize, draw
widget_control, draw, get_value=window_id
widget_control, /realize, base
wset, window_id
erase, 255

;Set the default simulation parameters.
galaxy_cutoff=23.5
galaxy_faint=4.4
galaxy_multiple=6
galaxy_shift=2.
galaxy_shrink=2.
galaxy_correlation=3.
galaxy_bulge_radius=1.5
galaxy_disk_radius=1.5
galaxy_bulge_to_total_1=0.8
galaxy_bulge_to_total_2=0.1
galaxy_bulge_to_total_3=0.01
galaxy_bulge_to_total_4=0.001
galaxy_line_width=5
star_cutoff=22.
star_faint=6.
star_multiple=18
star_correlation=3.
star_white_bright=22.
star_white_fraction=0.1
star_distance_modulus=8.
star_colour_shift_1=0.75
star_colour_shift_2=1.25
star_colour_shift_3=1.50
star_colour_shift_4=1.75
star_surface_brightness=25.
telescope_primary=3
telescope_temperature=273.
telescope_roughness=5.
telescope_surfaces=5
telescope_error=0.05
telescope_target=0
optical_imager_filter=5
optical_imager_comparison=4
optical_imager_surfaces=3
optical_imager_detector=0
optical_imager_pixel=0.01
optical_imager_readout=5.
optical_imager_dark=0.03
optical_imager_gain=2.
optical_imager_well=16
optical_imager_flag=26.
optical_imager_exposure_unit=300.
optical_imager_exposure=12
spectrograph_filter=7
spectrograph_comparison=6
spectrograph_surfaces=3
spectrograph_resolution=2000.
spectrograph_lower=1.
spectrograph_uppper=3.
spectrograph_slices=10
spectrograph_slits=25
spectrograph_length=4.
spectrograph_width=0.2
spectrograph_detector=2
spectrograph_pixel=0.1
spectrograph_readout=5.
spectrograph_dark=0.03
spectrograph_gain=2.
spectrograph_well=16
spectrograph_flag=26.
spectrograph_exposure_unit=300.
spectrograph_exposure=12
spectrograph_position=2.
spectrograph_extract=1.

;Set up a file for the survey data.
get_lun, unit
openw, unit, './virtual_telescope_results/survey_logfile.dat', /append
printf, unit, '  #Slit (arcsec) / z / H(AB) / Radius (arcsec) / R (delivered) / S/N'
number_statistics=0
close, unit
free_lun, unit

;Read in the images.
read_jpeg, './virtual_telescope_parameters/pupils.jpg',tmp , colour_table_tmp, colors=!d.n_colors-1

;Make a display.
tvlct, colour_table_tmp
tv, tmp, 0, 400

;Print information to the screen.
xyouts, 310, 355, 'Virtual Telescope', charsize=2*size_print, color=0, /device
xyouts, 310, 340, 'Eric Steinbring', charsize=size_print, color=0, /device
xyouts, 310, 325, 'Department of Astronomy and Astrophysics', charsize=size_print, color=0, /device
xyouts, 310, 310, 'University of California at Santa Cruz', charsize=size_print, color=0, /device
xyouts, 310, 295, 'Santa Cruz, CA, 95060', charsize=size_print, color=0, /device
xyouts, 310, 280, 'steinb@ucolick.org', charsize=size_print, color=0, /device
xyouts, 310, 265, 'www.ucolick.org/~steinb/', charsize=size_print, color=0, /device
xyouts, 310, 250, '10 October 2000', charsize=size_print, color=0, /device

;Submit the widgets to the xmanager.
xmanager, 'virtual_telescope', base

end

;-----------------------------------------------------------------------------------
pro virtual_telescope_event, event

common  variables, $
        galaxy_bulge_radius, galaxy_disk_radius, galaxy_bulge_to_total_1, galaxy_bulge_to_total_2, galaxy_bulge_to_total_3, $
        galaxy_bulge_to_total_4, galaxy_cutoff, galaxy_faint, galaxy_multiple, galaxy_shift, galaxy_shrink, galaxy_correlation, $
        galaxy_line_width, $
        star_cutoff, star_faint, star_multiple, star_correlation, star_white_bright, star_white_fraction, star_surface_brightness, $
        star_distance_modulus, $
        telescope_temperature, telescope_primary, telescope_diameter, telescope_roughness, telescope_surfaces, telescope_error, $
        telescope_target, $
        optical_imager_filter, optical_imager_comparison, optical_imager_surfaces, optical_imager_detector, optical_imager_pixel, $
        optical_imager_readout, optical_imager_dark, optical_imager_gain, optical_imager_well, optical_imager_flag, optical_imager_exposure, $
        optical_imager_exposure_unit, $
        spectrograph_flag, spectrograph_resolution, spectrograph_slices, spectrograph_slits, spectrograph_length, spectrograph_width, $
        spectrograph_exposure, spectrograph_exposure_unit, spectrograph_position, spectrograph_extract, spectrograph_filter, $
        spectrograph_comparison, spectrograph_surfaces, spectrograph_detector, spectrograph_pixel, spectrograph_readout, spectrograph_dark, $
        spectrograph_gain, spectrograph_well, $
        target_flag, $
        pupil, aperture_hst, aperture_scaling, $
        mirror_coating_aluminum, mirror_coating_silver, mirror_coating_gold, grating_efficiency, filters, filter_bandpasses, $
        detector_efficiency_1, detector_efficiency_2, detector_efficiency_3, spectrum_1, spectrum_2, spectrum_3, spectrum_4, $
        colour_magnitude_1, colour_magnitude_2, $
        star_colour_shift_1, star_colour_shift_2, star_colour_shift_3, star_colour_shift_4, $
        background_total, atmospheric_transmission, $
        galaxy, galaxy_fake, galaxy_disk, galaxy_redshift, galaxy_magnitude, galaxy_classification, galaxy_radius, $
        galaxies, galaxies_redshift, galaxies_weight, galaxies_magnitude, galaxies_classification, galaxies_radius, galaxies_hst, $
        galaxies_telescope, galaxies_1, galaxies_2, galaxies_3, galaxies_4, galaxies_5, galaxies_list_x_pos, galaxies_list_y_pos, $
        galaxies_list_magnitude, galaxies_list_redshift, galaxies_list_classification, galaxies_list_radius, galaxies_list_rotate, $
        galaxies_list_ellipticity, galaxies_total_number, galaxies_total_number_hst, galaxies_number_counts, galaxies_number_counts_hst, $
        galaxies_number_counts_label, galaxies_distribution_magnitude, galaxies_distribution_redshift, galaxies_distribution_magnitude_hst, $
        galaxies_distribution_redshift_hst, galaxies_distribution_radius, galaxies_distribution_radius_hst, $
        star, star_fwhm, star_strehl, $
        stars, stars_hst, stars_telescope, stars_background, stars_list_magnitude, stars_list_x_pos, stars_list_y_pos, $
        stars_list_classification, stars_total_number, stars_total_number_hst, stars_number_counts, stars_number_counts_hst, $
        stars_number_counts_label, $
        spectrum, spectrum_extract, spectrum_true_extract, $
        x, y, $
        photometry, ratio, galaxy_radius_output, $
        statistics_magnitude, statistics_ratio, $
        colour_table, size_print, screen_output, $
        www, www_background, $
        initialize_field_done, initialize_telescope_done, optical_imager_done, infrared_camera_done,  $
        select_done, spectrum_integral_field_unit_done, spectrum_single_done, spectrum_multiplex_done, $
        field_running, telescope_running, oi_running, mos_running, $
        window_id

;Find out what is going on.
widget_control, get_uvalue=uvalue, event.id

;The field control panel.
if (uvalue eq 'field') then begin

 ;Find out if there is one running.
 if (field_running eq 0) then begin

  ;Build the base.
  base_field=widget_base(/column, title='Field')
  base_top=widget_base(base_field, /column)
  base_bottom=widget_base(base_field, /column)

  ;The top setup panel.
  setup_top=widget_base(base_top, /row)

  ;The galaxy field cloning setup.
  field=widget_base(setup_top, /frame, /column)
  label=widget_label(field, value='Galaxy Field', xsize=150) 
  label=widget_label(field, value='Cloning', xsize=150)
  slider=cw_fslider(field, maximum=28., minimum=20., uvalue='galaxy_cutoff', $
   title='Faint cutoff (H(AB))', value=23.5, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=10., minimum=0., uvalue='galaxy_faint', $
   title='Added depth (H(AB))', value=4.5, xsize=150, drag=1)
  slider=widget_slider(field, maximum=20, minimum=0, uvalue='galaxy_multiple', $
   title='Number of clones', value=6, xsize=150) 
  slider=cw_fslider(field, maximum=3., minimum=1., uvalue='galaxy_shift', $
   title='Redshift factor', value=2., xsize=150, drag=1)
  slider=cw_fslider(field, maximum=5., minimum=1., uvalue='galaxy_shrink', $
   title='Shrinkage factor', value=2., xsize=150, drag=1)
  slider=cw_fslider(field, maximum=20., minimum=0.5, uvalue='galaxy_correlation', $
   title='Correlation (arcsec)', value=3., xsize=150, drag=1)

  ;The artificial galaxies.
  field=widget_base(setup_top, /frame, /column)
  label=widget_label(field, value='Artificial Galaxies', xsize=150)
  slider=cw_fslider(field, maximum=3.0, minimum=0.5, uvalue='galaxy_bulge_radius', $
   title='Bulge radius (arcsec)', value=1.5, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=3.0, minimum=0.5, uvalue='galaxy_disk_radius', $
   title='Disk radius (arcsec)', value=1.5, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=1., minimum=0.001, uvalue='galaxy_bulge_to_total_1', $
   title='E/S0 bulge-to-total', value=0.8, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=1., minimum=0.001, uvalue='galaxy_bulge_to_total_2', $
   title='Sbc bulge-to-total', value=0.1, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=1., minimum=0.001, uvalue='galaxy_bulge_to_total_3', $
   title='Scd bulge-to-total', value=0.01, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=1., minimum=0.001, uvalue='galaxy_bulge_to_total_4', $
   title='Irr bulge-to-total', value=0.001, xsize=150, drag=1)
  slider=widget_slider(field, maximum=50, minimum=2, uvalue='galaxy_line_width', $
  title='Line width (Angstroms)', value=5, xsize=150)

  ;The star field setup.
  field=widget_base(setup_top, /frame, /column)
  label=widget_label(field, value='Star Field', xsize=150)
  label=widget_label(field, value='Cloning', xsize=150)
  slider=cw_fslider(field, maximum=28., minimum=20., uvalue='star_cutoff', $
   title='Faint cutoff (I(AB))', value=22., xsize=150, drag=1)
  slider=cw_fslider(field, maximum=10., minimum=0., uvalue='star_faint', $
   title='Added depth (I(AB))', value=6., xsize=150, drag=1)
  slider=widget_slider(field, maximum=20, minimum=0, uvalue='star_multiple', $
   title='Number of clones', value=18, xsize=150)
  slider=cw_fslider(field, maximum=20., minimum=0.5, uvalue='star_correlation', $
   title='Correlation (arcsec)', value=3., xsize=150, drag=1)
  label=widget_label(field, value='White Dwarfs', xsize=150)
  slider=cw_fslider(field, maximum=30., minimum=10., uvalue='star_white_bright', $
   title='Bright cutoff (I(AB))', value=22., xsize=150, drag=1)
  slider=cw_fslider(field, maximum=0.5, minimum=0.01, uvalue='star_white_fraction', $
   title='Fraction', value=0.1, xsize=150, drag=1)

  ;The artificial star setup.
  field=widget_base(setup_top, /frame, /column)
  label=widget_label(field, value='Artificial Stars', xsize=150)
  slider=cw_fslider(field, maximum=15., minimum=0., uvalue='star_distance_modulus', $
   title='Distance modulus', value=8., xsize=150, drag=1)
  slider=cw_fslider(field, maximum=1.0, minimum=0.25, uvalue='star_colour_shift_1', $
   title='V-I colour shift', value=0.75, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=2.0, minimum=1.0, uvalue='star_colour_shift_2', $
   title='I-J colour shift', value=1.25, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=2.0, minimum=1.0, uvalue='star_colour_shift_3', $
   title='I-H colour shift', value=1.50, xsize=150, drag=1)
  slider=cw_fslider(field, maximum=2.0, minimum=1.0, uvalue='star_colour_shift_4', $
   title='I-K colour shift', value=1.75, xsize=150, drag=1)
  label=widget_label(field, value='Star Background', xsize=150)
  slider=cw_fslider(field, maximum=35., minimum=20., uvalue='star_surface_brightness', $
   title='Brightness (I(AB))', value=25., xsize=150, drag=1)

  ;The bottom setup panel.
  setup_bottom=widget_base(base_top, /column)

  ;The setup control.
  label=widget_label(setup_bottom, value='Setup', xsize=150)
  button=widget_button(setup_bottom, value='Initialize', uvalue='initialize_field', /align_left, xsize=75)
  button=widget_button(setup_bottom, value='Show Field Setup', uvalue='field_setup', /align_left, xsize=125)
  button=widget_button(setup_bottom, value='Show Galaxy Field', uvalue='galaxy_field', /align_left, xsize=125)
  button=widget_button(setup_bottom, value='Show Star Field', uvalue='star_field', /align_left, xsize=125)
 
  ;The base control.
  button=widget_button(base_bottom, value='Done', uvalue='done', /align_center, xsize=50)

  ;Realize the base.
  widget_control, /realize, base_field

  ;Submit the widgets to the xmanager.
  xmanager, 'virtual_telescope', base_field

  ;Set the running toggle.
  field_running=1
 endif

endif

;The control panel.
if (uvalue eq 'telescope') then begin

 ;Find out if there is one running.
 if (telescope_running eq 0) then begin

  ;Build the base.
  base_telescope=widget_base(/column, title='Telescope')
  base_top=widget_base(base_telescope, /column)
  base_bottom=widget_base(base_telescope, /row)

  ;The top setup panel.
  setup_top=widget_base(base_top, /row)

  ;The telescope setup.
  telescope=widget_base(setup_top, /frame, /column)
  label=widget_label(telescope, value='Telescope', xsize=150)
  tmp=strarr(4)
  tmp(0)='Hubble'
  tmp(1)='Next-Generation Space'
  tmp(2)='Canada-France-Hawaii'
  tmp(3)='Gemini'
  buttons=cw_bgroup(telescope, tmp, set_value=3, /exclusive, uvalue='telescope_primary')
  slider=cw_fslider(telescope, maximum=293., minimum=40., uvalue='telescope_temperature', $
   title='Temperature (K)', value=273., xsize=150)
  slider=cw_fslider(telescope, maximum=30., minimum=1., uvalue='telescope_roughness', $
   title='Mirror roughness (nm RMS)', value=5., xsize=150, drag=1)
  slider=widget_slider(telescope, maximum=10, minimum=2, uvalue='telescope_surfaces', $
   title='Number of surfaces', value=5, xsize=150)
  slider=cw_fslider(telescope, maximum=0.5, minimum=0.01, uvalue='telescope_error', $
   title='Optics error (arcsec)', value=0.05, xsize=150)

  ;Target.
  telescope_pointing=widget_base(setup_top, /frame, /column)
  label=widget_label(telescope_pointing, value='Target Field', xsize=150)
  label=widget_label(telescope_pointing, value='Angular Area', xsize=150)
  label=widget_label(telescope_pointing, value='58.4 arcsec X 55.7 arcsec', xsize=150)
  label=widget_label(telescope_pointing, value='Selection', xsize=150)
  tmp=strarr(2)
  tmp(0)='Galaxy field'
  tmp(1)='Star field'
  buttons=cw_bgroup(telescope_pointing, tmp, set_value=0, /exclusive, uvalue='telescope_target')

  ;The bottom setup panel.
  setup_bottom=widget_base(base_top, /column)

  ;The setup control.
  label=widget_label(setup_bottom, value='Setup', xsize=125)
  button=widget_button(setup_bottom, value='Initialize', uvalue='initialize_telescope', /align_left, xsize=75)
  button=widget_button(setup_bottom, value='Show Telescope Setup', uvalue='telescope_setup', /align_left, xsize=150)
 
  ;The base control.
  button=widget_button(base_bottom, value='Done', uvalue='done', /align_center, xsize=50)

  ;Realize the base.
  widget_control, /realize, base_telescope
  wset, window_id

  ;Submit the widgets to the xmanager.
  xmanager, 'virtual_telescope', base_telescope

  ;Set the running toggle.
  telescope_running=1
 endif
 
endif

;The OI control panel.
if (uvalue eq 'oi') then begin

 ;Find out if there is one running.
 if (oi_running eq 0) then begin

  ;Build the base.
  base_vi=widget_base(/column, title='Optical Imager')
  base_top=widget_base(base_vi, /column)
  base_bottom=widget_base(base_vi, /row)

  ;The top setup panel.
  setup_top=widget_base(base_top, /row)
 
  ;The filter setup.
  filter=widget_base(setup_top, /frame, /column)
  label=widget_label(filter, value='Filters', xsize=150)
  label=widget_label(filter, value='Comparison-Primary', xsize=150)
  filter_top=widget_base(filter, /row)
  comparison=widget_base(filter_top, /column)
  tmp=strarr(6)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  buttons=cw_bgroup(comparison, tmp, set_value=4, /exclusive, uvalue='optical_imager_comparison')
  primary=widget_base(filter_top, /column)
   tmp=strarr(6)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  buttons=cw_bgroup(primary, tmp, set_value=5, /exclusive, uvalue='optical_imager_filter')
  label=widget_label(filter, value='Reflective Surfaces', xsize=150)
  slider=widget_slider(filter, maximum=10, minimum=2, uvalue='optical_imager_surfaces', $
  title='Number of surfaces', value=3, xsize=150)

  ;The imager setup.
  imager=widget_base(setup_top, /frame, /column)
  label=widget_label(imager, value='Detector', xsize=150)
  label=widget_label(imager, value='Field of View', xsize=150)
  label=widget_label(imager, value='58.4 arcsec X 55.7 arcsec', xsize=150)
  label=widget_label(imager, value='Type', xsize=150)
  tmp=strarr(2)
  tmp(0)='HyViSi'
  tmp(1)='HgCdTe'
  buttons=cw_bgroup(imager, tmp, set_value=0, /exclusive, uvalue='optical_imager_detector')  
  slider=cw_fslider(imager, maximum=0.1, minimum=0.01, uvalue='optical_imager_pixel', $
   title='Pixel (arcsec/pixel)', value=0.01, xsize=150, drag=1)
  slider=cw_fslider(imager, maximum=30., minimum=1., uvalue='optical_imager_readout', $
   title='Readout (e-)', value=5., xsize=150, drag=1)
  slider=cw_fslider(imager, maximum=0.1, minimum=0.01, uvalue='optical_imager_dark', $
   title='Dark (e-/s)', value=0.03, xsize=150, drag=1)
  slider=widget_slider(imager, maximum=10, minimum=1, uvalue='optical_imager_gain', $
  title='Gain (e-/DU)', value=2, xsize=150)
  slider=widget_slider(imager, maximum=32, minimum=8, uvalue='optical_imager_well', $
  title='Well depth (bits)', value=16, xsize=150)

  ;Imager control.
  control=widget_base(setup_top, /frame, /column)
  label=widget_label(control, value='Target Selection', xsize=150)
  slider=cw_fslider(control, maximum=35., minimum=20., uvalue='optical_imager_flag', $
   title='Magnitude (H(AB))', value=26., xsize=150, drag=1)
  label=widget_label(control, value='Exposure', xsize=150)
  slider=cw_fslider(control, maximum=1.e5, minimum=1., uvalue='optical_imager_exposure_unit', $
   title='Unit exposure time (s)', value=300., xsize=150, drag=1)
  slider=widget_slider(control, maximum=1000, minimum=1, uvalue='optical_imager_exposure', $
   title='Number of exposures', value=12, xsize=150)

  ;The bottom setup panel.
  setup_bottom=widget_base(base_top, /row)
 
  ;The setup control.
  setup=widget_base(setup_bottom, /column)
  label=widget_label(setup, value='Setup', xsize=100)
  button=widget_button(setup, value='Show OI Setup', uvalue='optical_imager_setup', /align_left, xsize=100)
  button=widget_button(setup, value='Select Target', uvalue='optical_imager_select_target', /align_left, xsize=100)
 
  ;The exposure control.
  control_expose=widget_base(setup_bottom, /column)
  label=widget_label(control_expose, value='Imaging', xsize=100)
  button=widget_button(control_expose, value='Expose', uvalue='optical_imager_expose', /align_left, xsize=50)
  button=widget_button(control_expose, value='Show Results', uvalue='optical_imager_results', /align_left, xsize=100)
  button=widget_button(control_expose, value='Take Survey', uvalue='optical_imager_survey', /align_left, xsize=100)
  button=widget_button(control_expose, value='Reset Photometry', uvalue='reset_photometry', /align_left, xsize=125)
 
  ;The base control.
  button=widget_button(base_bottom, value='Done', uvalue='done', /align_center, xsize=50)

  ;Realize the base.
  widget_control, /realize, base_vi
  wset, window_id

  ;Submit the widgets to the xmanager.
  xmanager, 'virtual_telescope', base_vi

  ;Set the running toggle.
  oi_running=1
 endif

endif

;The MOS control panel.
if (uvalue eq 'mos') then begin

 ;Find out if there is one running.
 if (mos_running eq 0) then begin

  ;Build the base.
  base_mos=widget_base(/column, title='Multi-Object Spectrograph')
  base_top=widget_base(base_mos, /column)
  base_bottom=widget_base(base_mos, /row)

  ;The top setup panel.
  setup_top=widget_base(base_top, /row)
 
  ;The focal plane setup.
  focal_plane=widget_base(setup_top, /frame, /column)
  label=widget_label(focal_plane, value='Focal Plane', xsize=150)
  label=widget_label(focal_plane, value='Field of View', xsize=150)
  label=widget_label(focal_plane, value='58.4 arcsec X 55.7 arcsec', xsize=150)
  label=widget_label(focal_plane, value='Slits', xsize=150)
  slider=widget_slider(focal_plane, maximum=400, minimum=2, uvalue='spectrograph_slits', $
   title='Maximum number of slits', value=25, xsize=150)
  slider=cw_fslider(focal_plane, maximum=4., minimum=1., uvalue='spectrograph_length', $
   title='Slit length (arcsec)', value=4., xsize=150, drag=1)
  slider=cw_fslider(focal_plane, maximum=0.5, minimum=0.1, uvalue='spectrograph_width', $
   title='Slit width (arcsec)', value=0.2, xsize=150, drag=1)
  label=widget_label(focal_plane, value='Integral Field Unit', xsize=150)
  label=widget_label(focal_plane, value='2.0 arcsec X 4.0 arcsec', xsize=150)
  slider=widget_slider(focal_plane, maximum=20, minimum=10, uvalue='spectrograph_slices', $
   title='Number of slices', value=10, xsize=150)
 
  ;The filter setup.
  filter=widget_base(setup_top, /frame, /column)
  label=widget_label(filter, value='Filters', xsize=150)
  label=widget_label(filter, value='Comparison-Primary', xsize=150)
  filter_top=widget_base(filter, /row)
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  buttons=cw_bgroup(filter_top, tmp, set_value=6, /exclusive, uvalue='spectrograph_comparison')
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  buttons=cw_bgroup(filter_top, tmp, set_value=7, /exclusive, uvalue='spectrograph_filter')  
  label=widget_label(filter, value='Reflective Surfaces', xsize=150)
  slider=widget_slider(filter, maximum=10, minimum=0, uvalue='spectrograph_surfaces', $
  title='Number of surfaces', value=3, xsize=150)

  ;The spectrograph setup.
  spectrograph=widget_base(setup_top, /frame, /column)
  label=widget_label(spectrograph, value='Spectrograph', xsize=150)
  label=widget_label(spectrograph, value='Field of View', xsize=150)
  label=widget_label(spectrograph, value='58.4 arcsec X 55.7 arcsec', xsize=150)
  label=widget_label(spectrograph, value='Grating', xsize=125)
  slider=cw_fslider(spectrograph, maximum=5000., minimum=200., uvalue='spectrograph_resolution', $
   title='Resolution (1/pixel)', value=2000., xsize=150, drag=1)

  ;The infrared camera setup.
  infrared_camera=widget_base(setup_top, /frame, /column)
  label=widget_label(infrared_camera, value='Detector', xsize=150)
  label=widget_label(infrared_camera, value='Type', xsize=150)
  tmp=strarr(2)
  tmp(0)='HgCdTe'
  tmp(1)='InSb'
  buttons=cw_bgroup(infrared_camera, tmp, set_value=1, /exclusive, uvalue='spectrograph_detector') 
  label=widget_label(infrared_camera, value='Size', xsize=150)
  label=widget_label(infrared_camera, value='5200 pixels X 55.7 arcsec', xsize=150)
  slider=cw_fslider(infrared_camera, maximum=0.1, minimum=0.01, uvalue='spectrograph_pixel', $
  title='Pixel (arcsec/pixel)', value=0.1, xsize=150, drag=1)
  slider=cw_fslider(infrared_camera, maximum=30., minimum=1., uvalue='spectrograph_readout', $
  title='Readout (e-)', value=5., xsize=150, drag=1)
  slider=cw_fslider(infrared_camera, maximum=0.1, minimum=0.01, uvalue='spectrograph_dark', $
   title='Dark (e-/s)', value=0.03, xsize=150, drag=1)
  slider=widget_slider(infrared_camera, maximum=10, minimum=1, uvalue='spectrograph_gain', $
  title='Gain (e-/DU)', value=2, xsize=150)
  slider=widget_slider(infrared_camera, maximum=32, minimum=8, uvalue='spectrograph_well', $
  title='Well depth (bits)', value=16, xsize=150)

  ;The control setup.
  control=widget_base(setup_top, /frame, /column)
  label=widget_label(control, value='Target Selection', xsize=150)
  slider=cw_fslider(control, maximum=35., minimum=20., uvalue='spectrograph_flag', $
   title='Magnitude (H(AB))', value=26., xsize=150, drag=1)
  label=widget_label(control, value='Exposure', xsize=150)
  slider=cw_fslider(control, maximum=1.e5, minimum=1., uvalue='spectrograph_exposure_unit', $
   title='Unit exposure time (s)', value=300., xsize=150, drag=1)
  slider=widget_slider(control, maximum=1000, minimum=1, uvalue='spectrograph_exposure', $
   title='Number of exposures', value=12, xsize=150)
 
  label=widget_label(control, value='Spectral Extraction', xsize=150)
  slider=cw_fslider(control, maximum=4., minimum=0., uvalue='spectrograph_position', $
   title='Position (arcsec)', value=2., xsize=150, drag=1)
  slider=cw_fslider(control, maximum=2., minimum=0.5, uvalue='spectrograph_extract', $
   title='Width (arcsec)', value=1., xsize=150, drag=1)
 
  ;The bottom setup panel.
  setup_bottom=widget_base(base_top, /row)

  ;The setup control.
  setup=widget_base(setup_bottom, /column)
  label=widget_label(setup, value='Setup', xsize=125)
  button=widget_button(setup, value='Show MOS Setup', uvalue='spectrograph_setup', /align_left, xsize=100)
  button=widget_button(setup, value='Select Target', uvalue='spectrograph_select_target', /align_left, xsize=100)
 
  ;The imaging mode control.
  control_imaging=widget_base(setup_bottom, /column)
  label=widget_label(control_imaging, value='Imaging Mode', xsize=125)
  button=widget_button(control_imaging, value='Expose', uvalue='infrared_camera_expose', /align_left, xsize=50)
  button=widget_button(control_imaging, value='Show Results', uvalue='infrared_camera_results', /align_left, xsize=100)
  button=widget_button(control_imaging, value='Take Survey', uvalue='infrared_camera_survey', /align_left, xsize=100)
  button=widget_button(control_imaging, value='Reset Photometry', uvalue='reset_photometry', /align_left, xsize=125)

  ;The single slit mode control.
  control_single=widget_base(setup_bottom, /column)
  label=widget_label(control_single, value='Single Slit Mode', xsize=150)
  button=widget_button(control_single, value='Expose', uvalue='spectrograph_single_slit', /align_left, xsize=50)
  button=widget_button(control_single, value='Show Spectrum', uvalue='spectrograph_single_slit_spectrum', /align_left, xsize=100)

  ;The integral field unit mode control.
  control_slicer=widget_base(setup_bottom, /column)
  label=widget_label(control_slicer, value='Integral Field Unit Mode', xsize=150)
  button=widget_button(control_slicer, value='Expose', uvalue='spectrograph_integral_field_unit', /align_left, xsize=50)
  button=widget_button(control_slicer, value='Show Spectrum', uvalue='spectrograph_integral_field_unit_spectrum', /align_left, xsize=100)
 
  ;The multiplex mode control.
  control_multiplex=widget_base(setup_bottom, /column)
  label=widget_label(control_multiplex, value='Multiplex Mode', xsize=150)
  button=widget_button(control_multiplex, value='Expose', uvalue='spectrograph_survey', /align_left, xsize=50)
  button=widget_button(control_multiplex, value='Show Spectra', uvalue='spectrograph_spectra', /align_left, xsize=100)
  button=widget_button(control_multiplex, value='Show Results', uvalue='spectrograph_results', /align_left, xsize=100)

  ;The base control.
  button=widget_button(base_bottom, value='Done', uvalue='done', /align_center, xsize=50)

  ;Realize the base.
  widget_control, /realize, base_mos
  wset, window_id

  ;Submit the widgets to the xmanager.
  xmanager, 'virtual_telescope', base_mos

  ;Set the running toggle.
  mos_running=1
 endif

endif

;-----------------------------------------------------------------------------
;Give the help display.
if (uvalue eq 'help') then begin
 xdisplayfile, 'virtual_telescope.doc', title='Virtual Telescope Help', group=event.top, height=40, width=60
endif
   
;-----------------------------------------------------------------------------
;Give the contact information.
if (uvalue eq 'information') then begin

 ;Show a startup display.
 erase, 255
 wshow, window_id

 ;Read in the images.
 read_jpeg, './virtual_telescope_parameters/pupils.jpg', tmp, colour_table_tmp, colors=!d.n_colors-1

 ;Make a display.
 tvlct, colour_table_tmp
 tv, tmp, 0, 400

 ;Print information to the screen.
 xyouts, 310, 355, 'Virtual Telescope', charsize=2*size_print, color=0, /device
 xyouts, 310, 340, 'Eric Steinbring', charsize=size_print, color=0, /device
 xyouts, 310, 325, 'Department of Astronomy and Astrophysics', charsize=size_print, color=0, /device
 xyouts, 310, 310, 'University of California at Santa Cruz', charsize=size_print, color=0, /device
 xyouts, 310, 295, 'Santa Cruz, CA, 95060', charsize=size_print, color=0, /device
 xyouts, 310, 280, 'steinb@ucolick.org', charsize=size_print, color=0, /device
 xyouts, 310, 265, 'www.ucolick.org/~steinb/', charsize=size_print, color=0, /device
 xyouts, 310, 250, '10 October 2000', charsize=size_print, color=0, /device

endif

;-----------------------------------------------------------------------------
;Use the zoom function.
if (uvalue eq 'zoom') then begin
 zoom
endif
 
;-------------------------------------------------------------------------------
;Done with a control panel.
if (uvalue eq 'done') then begin
 widget_control, iconify=1, event.top
endif

;--------------------------------------------------------------------------------
;Kill the display.
if (uvalue eq 'quit') then begin
 widget_control, /reset
endif

;--------------------------------------------------------------------------------
;Set the parameters.
if (uvalue eq 'galaxy_cutoff') then begin
 galaxy_cutoff=event.value
endif
if (uvalue eq 'galaxy_faint') then begin
 galaxy_faint=event.value
endif
if (uvalue eq 'galaxy_multiple') then begin
 galaxy_multiple=event.value
endif
if (uvalue eq 'galaxy_shift') then begin
 galaxy_shift=event.value
endif
if (uvalue eq 'galaxy_shrink') then begin
 galaxy_shrink=event.value
endif
if (uvalue eq 'galaxy_correlation') then begin
 galaxy_correlation=event.value
endif
if (uvalue eq 'galaxy_bulge_radius') then begin
 galaxy_bulge_radius=event.value
endif
if (uvalue eq 'galaxy_disk_radius') then begin
 galaxy_disk_radius=event.value
endif
if (uvalue eq 'galaxy_bulge_to_total_1') then begin
 galaxy_bulge_to_total_1=event.value
endif
if (uvalue eq 'galaxy_bulge_to_total_2') then begin
 galaxy_bulge_to_total_2=event.value
endif
if (uvalue eq 'galaxy_bulge_to_total_3') then begin
 galaxy_bulge_to_total_3=event.value
endif
if (uvalue eq 'galaxy_bulge_to_total_4') then begin
 galaxy_bulge_to_total_4=event.value
endif
if (uvalue eq 'galaxy_line_width') then begin
 galaxy_line_width=event.value
endif
if (uvalue eq 'star_faint') then begin
 star_faint=event.value
endif
if (uvalue eq 'star_multiple') then begin
 star_multiple=event.value
endif
if (uvalue eq 'star_correlation') then begin
 star_correlation=event.value
endif
if (uvalue eq 'star_white_bright') then begin
 star_white_bright=event.value
endif
if (uvalue eq 'star_white_fraction') then begin
 star_white_fraction=event.value
endif
if (uvalue eq 'star_colour_shift_1') then begin
 star_colour_shift_1=event.value
endif
if (uvalue eq 'star_colour_shift_2') then begin
 star_colour_shift_2=event.value
endif
if (uvalue eq 'star_colour_shift_3') then begin
 star_colour_shift_3=event.value
endif
if (uvalue eq 'star_colour_shift_4') then begin
 star_colour_shift_4=event.value
endif
if (uvalue eq 'star_distance_modulus') then begin
 star_distance_modulus=event.value
endif
if (uvalue eq 'star_surface_brightness') then begin
 star_surface_brightness=event.value
endif
if (uvalue eq 'telescope_primary') then begin
 case (event.value) of
  0: telescope_primary=0
  1: telescope_primary=1
  2: telescope_primary=2
  3: telescope_primary=3
 endcase
endif
if (uvalue eq 'telescope_roughness') then begin
 telescope_roughness=event.value
endif
if (uvalue eq 'telescope_surfaces') then begin
 telescope_surfaces=event.value
endif
if (uvalue eq 'telescope_error') then begin
 telescope_error=event.value
endif
if (uvalue eq 'telescope_temperature') then begin
 telescope_temperature=event.value
endif
if (uvalue eq 'telescope_target') then begin
 case (event.value) of
  0: telescope_target=0
  1: telescope_target=1
 endcase
endif
if (uvalue eq 'optical_imager_filter') then begin
 case (event.value) of
  0: optical_imager_filter=0
  1: optical_imager_filter=1
  2: optical_imager_filter=2
  3: optical_imager_filter=3
  4: optical_imager_filter=4
  5: optical_imager_filter=5
 endcase
endif
if (uvalue eq 'optical_imager_comparison') then begin
 case (event.value) of
  0: optical_imager_comparison=0
  1: optical_imager_comparison=1
  2: optical_imager_comparison=2
  3: optical_imager_comparison=3
  4: optical_imager_comparison=4
  5: optical_imager_comparison=5
 endcase
endif
if (uvalue eq 'optical_imager_surfaces') then begin
 optical_imager_surfaces=event.value
endif
if (uvalue eq 'optical_imager_detector') then begin
 case (event.value) of
  0: optical_imager_detector=0
  1: optical_imager_detector=1
 endcase
endif
if (uvalue eq 'optical_imager_pixel') then begin
 optical_imager_pixel=event.value
endif
if (uvalue eq 'optical_imager_readout') then begin
 optical_imager_readout=event.value
endif
if (uvalue eq 'optical_imager_dark') then begin
 optical_imager_dark=event.value
endif
if (uvalue eq 'optical_imager_gain') then begin
 optical_imager_gain=float(event.value)
endif
if (uvalue eq 'optical_imager_well') then begin
 optical_imager_well=event.value
endif
if (uvalue eq 'optical_imager_flag') then begin
 optical_imager_flag=event.value
endif
if (uvalue eq 'optical_imager_exposure') then begin
 optical_imager_exposure=float(floor(event.value))
endif
if (uvalue eq 'optical_imager_exposure_unit') then begin
 optical_imager_exposure_unit=float(floor(event.value))
endif
if (uvalue eq 'spectrograph_filter') then begin
 case (event.value) of
  0: spectrograph_filter=0
  1: spectrograph_filter=1
  2: spectrograph_filter=2
  3: spectrograph_filter=3
  4: spectrograph_filter=4
  5: spectrograph_filter=5
  6: spectrograph_filter=6
  7: spectrograph_filter=7
  8: spectrograph_filter=8
 endcase
endif
if (uvalue eq 'spectrograph_comparison') then begin
 case (event.value) of
  0: spectrograph_comparison=0
  1: spectrograph_comparison=1
  2: spectrograph_comparison=2
  3: spectrograph_comparison=3
  4: spectrograph_comparison=4
  5: spectrograph_comparison=5
  6: spectrograph_comparison=6
  7: spectrograph_comparison=7
  8: spectrograph_comparison=8
 endcase
endif
if (uvalue eq 'spectrograph_surfaces') then begin
 spectrograph_surfaces=event.value
endif
if (uvalue eq 'spectrograph_detector') then begin
 case (event.value) of
  0: spectrograph_detector=1
  1: spectrograph_detector=2
 endcase
endif
if (uvalue eq 'spectrograph_pixel') then begin
 spectrograph_pixel=event.value
endif
if (uvalue eq 'spectrograph_readout') then begin
 spectrograph_readout=event.value
endif
if (uvalue eq 'spectrograph_dark') then begin
 spectrograph_dark=event.value
endif
if (uvalue eq 'spectrograph_gain') then begin
 spectrograph_gain=float(event.value)
endif
if (uvalue eq 'spectrograph_well') then begin
 spectrograph_well=event.value
endif
if (uvalue eq 'spectrograph_flag') then begin
 spectrograph_flag=event.value
endif
if (uvalue eq 'spectrograph_resolution') then begin
 spectrograph_resolution=event.value
endif
if (uvalue eq 'spectrograph_slices') then begin
 spectrograph_slices=event.value
endif
if (uvalue eq 'spectrograph_slits') then begin
 spectrograph_slits=event.value
endif
if (uvalue eq 'spectrograph_length') then begin
 spectrograph_length=event.value
endif
if (uvalue eq 'spectrograph_width') then begin
 spectrograph_width=event.value
endif
if (uvalue eq 'spectrograph_exposure') then begin
 spectrograph_exposure=float(floor(event.value))
endif
if (uvalue eq 'spectrograph_exposure_unit') then begin
 spectrograph_exposure_unit=float(floor(event.value))
endif
if (uvalue eq 'spectrograph_position') then begin
 spectrograph_position=event.value
endif
if (uvalue eq 'spectrograph_extract') then begin
 spectrograph_extract=event.value
endif

;-----------------------------------------------------------------------------------
;Initialize the field. 
if (uvalue eq 'initialize_field') then begin

 ;Set the status bar.
 status=0

 ;Initialize the photometry files.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Configuring the photometry files ...', charsize=size_print, color=0, /device

 ;Determine filter label.
 filter_tmp=strarr(9)
 filter_tmp(0)='open'
 filter_tmp(1)='u'
 filter_tmp(2)='b'
 filter_tmp(3)='v'
 filter_tmp(4)='r'
 filter_tmp(5)='i'
 filter_tmp(6)='j'
 filter_tmp(7)='h'
 filter_tmp(8)='k'

 ;Initialize the optical imager files.
 for i=0,8 do begin
  get_lun, unit
  openw, unit, './virtual_telescope_results/photometry_optical_imager_'+filter_tmp(i)+'.dat'
  for j=0,9999 do begin
   printf, unit, j, 0., 0., 0., 0., 0., 0., 0.
  endfor
  close, unit
  free_lun, unit
 endfor

 ;And the infrared camera files.
 for i=0,8 do begin
  get_lun, unit
  openw, unit, './virtual_telescope_results/photometry_spectrograph_'+filter_tmp(i)+'.dat'
  for j=0,9999 do begin
   printf, unit, j, 0., 0., 0., 0., 0., 0., 0.
  endfor
  close, unit
  free_lun, unit
 endfor

 ;-------------------------------------------------------------------------------
 ;The galaxies.

 ;Read in the spectra. These are spectra provided by Steve Gwyn of typical E/S0/S/Irr galaxies. They have 50000 data points from 0.0 to 5.0
 ;microns. The flux is in units of W/m^2/Angstrom for E/S0, Sbc, Scd, and Irr. Note, we normalize the spectra to have a total flux of 1.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the template galaxy spectra ...', charsize=size_print, color=0, /device

 ;Load colours for the display.
 loadct, 3, /silent

 ;Read in the E/S0, Sbc, Scd, and Irr spectra.
 tmp_1=fltarr(50000)
 tmp_2=tmp_1
 tmp_3=tmp_1
 tmp_4=tmp_1

 ;E/S0.
 file='./virtual_telescope_parameters/spectrum_1.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b 
  tmp_1(floor(a))=b
 endwhile
 close, unit
 free_lun, unit
 
 ;Sbc.
 file='./virtual_telescope_parameters/spectrum_2.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  tmp_2(floor(a))=b
 endwhile 
 close, unit
 free_lun, unit
 
 ;Scd.
 file='./virtual_telescope_parameters/spectrum_3.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  tmp_3(floor(a))=b
 endwhile
 close, unit
 free_lun, unit
 
 ;Irr.
 file='./virtual_telescope_parameters/spectrum_4.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  tmp_4(floor(a))=b
 endwhile
 close, unit
 free_lun, unit
 
 ;Read in the spectral lines.
 tmp_5=fltarr(61)
 tmp_6=fltarr(61)
 file='./virtual_telescope_parameters/spectrum_lines.dat'
 openr, unit, file, /get_lun
 for i=0,60 do begin
  readf, unit, a, b
  tmp_5(i)=a
  tmp_6(i)=b
 endfor
 close, unit
 free_lun, unit
 
 ;Add the spectral lines.
 for i=0,60 do begin
  if (tmp_1(floor(tmp_5(i))) lt tmp_6(i)) then begin
   tmp_1(floor(tmp_5(i)))=tmp_6(i)
  endif
  if (tmp_2(floor(tmp_5(i))) lt tmp_6(i)) then begin
   tmp_2(floor(tmp_5(i)))=tmp_6(i)
  endif
  if (tmp_3(floor(tmp_5(i))) lt tmp_6(i)) then begin
   tmp_3(floor(tmp_5(i)))=tmp_6(i)
  endif
  if (tmp_4(floor(tmp_5(i))) lt tmp_6(i)) then begin
   tmp_4(floor(tmp_5(i)))=tmp_6(i)
  endif
 endfor

 ;Now, we only want from 0.0 to 3.0 microns.
 spectrum_1=tmp_1(0:29999)
 spectrum_2=tmp_2(0:29999)
 spectrum_3=tmp_3(0:29999)
 spectrum_4=tmp_4(0:29999)

 ;Smooth them to produce artificial line-widths.
 spectrum_1=smooth(spectrum_1,galaxy_line_width)
 spectrum_2=smooth(spectrum_2,galaxy_line_width)
 spectrum_3=smooth(spectrum_3,galaxy_line_width)
 spectrum_4=smooth(spectrum_4,galaxy_line_width)

 ;Normalization of the spectra.
 spectrum_1=spectrum_1/total(spectrum_1)
 spectrum_2=spectrum_2/total(spectrum_2)
 spectrum_3=spectrum_3/total(spectrum_3)
 spectrum_4=spectrum_4/total(spectrum_4)

 ;Read in the galaxy image. This is a 1 second 1100 X 1300 pixel H image from the HST NICMOS HDF-S.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the galaxy images ...', charsize=size_print, color=0, /device

; ;Read in the colour image.
; read_jpeg, './virtual_telescope_parameters/hdfs_nicmos.jpg', tmp, colour_table, colors=!d.n_colors-1
; galaxies_hst=fltarr(1100,1300)
; galaxies_hst(157:935,283:1024)=congrid(tmp,779,742)

 ;Read in the H image.
 image_h=readfits('./virtual_telescope_parameters/hdfs_nicmos.fits', /silent)

 ;Extract the bright star from this image.
 psf_hst=fltarr(40,40)
 psf_hst=image_h(278-2-20:278-2+19,599-1-20:599-1+19)
 
 ;And normalize to a total flux of 1.
 psf_hst=psf_hst/total(psf_hst)

 ;Also, extract the bright spiral galaxy. 
 galaxy_spiral=fltarr(100,100)
 galaxy_spiral=image_h(760-50:760+49,831-50:831+49)

 ;Make sure there are no bad pixels.
 for i=0,99 do begin
  for j=0,99 do begin
   if (galaxy_spiral(i,j) lt 0.) then begin
    galaxy_spiral(i,j)=0.
   endif
  endfor
 endfor

 ;Make a copy of the image.
 tmp_1=galaxy_spiral
 tmp_2=tmp_1

 ;And deconvolve.
 for n=1,5 do begin
  max_likelihood, tmp_1, psf_hst, tmp_2
  tmp_1=tmp_2
 endfor

 ;Normalize.
 galaxy_spiral=tmp_1/total(tmp_1)

 ;Now, continuing to deconvolve will generate knots. Make a copy of the image.
 tmp_1=galaxy_spiral
 tmp_2=tmp_1

 ;And deconvolve.
 for n=1,15 do begin
  max_likelihood, tmp_1, psf_hst, tmp_2
  tmp_1=tmp_2
 endfor

 ;Normalize.
 galaxy_knots=tmp_1/total(tmp_1)
 
 ;We generate the fake galaxies. These are 3.0 arcsec X 3.0 arcsec or 300 X 300 pixels or 0.01 arcsec/pixel. This is the same sampling as the
 ;telescope PSFs.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Generating artificial galaxies ...', charsize=size_print, color=0, /device

 ;Make a circular cutoff.
 tmp_cut=shift((dist(300)*2./300. lt 1. and dist(300)*2./300. ge 0.),150.,150.)

 ;Make the bulge component.
 tmp=fltarr(300,300)
 tmp_1=galaxy_bulge_radius/0.01
 bulge=tmp
 for i=0,299 do begin
  for j=0,299 do begin
   tmp(i,j)=sqrt((i-150.)^2+(j-150.)^2)
  endfor
 endfor
 bulge=tmp_cut*exp(-7.67*(tmp/tmp_1)^0.25)

 ;And normalize to a flux of 1.
 bulge=bulge/total(bulge)

 ;Make the exponential disk component.
 tmp=fltarr(300,300)
 tmp_1=galaxy_disk_radius/0.01
 disk=tmp
 for i=0,299 do begin
  for j=0,299 do begin
   tmp(i,j)=sqrt((i-150.)^2+(j-150.)^2)
  endfor
 endfor
 disk=tmp_cut*exp(-tmp/tmp_1)

 ;Normalize.
 disk=disk/total(disk)

 ;And the spiral. Now, this was a 100 X 100 pixel area at 0.075 arcsec/pixel or 7.5 arcsec X 7.5 arcsec. We will rebin this to be 300 X 300 
 ;pixels at 0.01 arcsec/pixel. This gives a factor of 7.5 X improvement of spatial resolution. That is, the smallest structures are now 0.01
 ;arcsec across. 
 spiral=tmp_cut*congrid(galaxy_spiral,300,300)

 ;Normalize.
 spiral=spiral/total(spiral)

 ;And knots.
 knots=tmp_cut*congrid(galaxy_knots,300,300)

 ;Add some random knots.
 
 ;Make a knot.
 knot=psf_gaussian(npixel=20,fwhm=2.,/normal)
 knot=max(knots)*knot

 ;And add them.
 for i=0,100 do begin
  tmp_x=291*randomu(seed)
  tmp_y=291*randomu(seed)
  knots(tmp_x:tmp_x+8,tmp_y:tmp_y+8)=randomu(seed)*knot(0:8,0:8)
 endfor

 ;Normalize.
 knots=knots/total(knots)

 ;Apply the cutter.
 knots=tmp_cut*knots

 ;Thus, the total disk becomes.
 disk=disk+10.*spiral+knots

 ;And normalize to a flux of 1.
 disk=disk/total(disk)

 ;Compose four galaxies with different disk and bulge components. The fifth object is stellar.
 galaxy_fake=fltarr(5,300,300)
 galaxy_disk=galaxy_fake
 for i=0,3 do begin

  ;Find the bulge_to_total ratio.
  if (i eq 0) then begin
   galaxy_bulge_to_total=galaxy_bulge_to_total_1
  endif
  if (i eq 1) then begin
   galaxy_bulge_to_total=galaxy_bulge_to_total_2
  endif
  if (i eq 2) then begin
   galaxy_bulge_to_total=galaxy_bulge_to_total_3
  endif
  if (i eq 3) then begin
   galaxy_bulge_to_total=galaxy_bulge_to_total_4
  endif

  ;The bulge and disk galaxy.
  galaxy_fake(i,0:299,0:299)=(galaxy_bulge_to_total*bulge+(1.-galaxy_bulge_to_total)*disk)

  ;Now, with only the disk component.
  galaxy_disk(i,0:299,0:299)=(1.-galaxy_bulge_to_total)*bulge

  ;Normalize this.
  galaxy_disk(i,0:299,0:299)=galaxy_disk(i,0:299,0:299)/total(galaxy_fake(i,0:299,0:299))

  ;Also, the full image has a total flux of 1.
  galaxy_fake(i,0:299,0:299)=galaxy_fake(i,0:299,0:299)/total(galaxy_fake(i,0:299,0:299))

 endfor

 ;Finally, the fifth classification, or stellar is a spike.
 galaxy_fake(4,150,150)=1.

 ;Read in the galaxy data. This data is from the Stony Brook photometric redshift survey of the HDFS field. It contains the galaxy position in
 ;pixels, its H(AB) magnitude, redshift, and spectral classification. There are 327 objects. The classifications are E/S0, Sbc, Scd, Irr, and
 ;stellar, which are labeled 1 through 5.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the galaxy survey data ...', charsize=size_print, color=0, /device

 ;The total number of galaxies in the original image.
 galaxies_total_number_hst=0

 ;The galaxy data.
 file='./virtual_telescope_parameters/hdfs_nicmos.dat'
 x_pos=fltarr(2000)
 y_pos=x_pos
 magnitude=x_pos
 redshift=x_pos
 classification=intarr(2000)
 radius=x_pos
 openr, unit, file, /get_lun

 ;For all galaxies in the list.
 for i=0,327-1 do begin
  readf, unit, a, b, c, d, e
  
  ;Take those within the field.
  if ((a gt 157.) and (b gt 283.)) then begin
   if ((a lt 936.) and (b lt 1025.)) then begin 

    ;Update the list.
    x_pos(galaxies_total_number_hst)=a
    y_pos(galaxies_total_number_hst)=b
    magnitude(galaxies_total_number_hst)=c
    redshift(galaxies_total_number_hst)=d
    classification(galaxies_total_number_hst)=e
    galaxies_total_number_hst=galaxies_total_number_hst+1
  
   endif
  endif
 endfor
 close, unit
 free_lun, unit
 
 ;We will have overcounted by one galaxy.
 galaxies_total_number_hst=galaxies_total_number_hst-1

 ;Calculate the number counts for this data.
 galaxies_number_counts_hst=intarr(50)
 galaxies_number_counts=intarr(50)
 galaxies_number_counts_label=fltarr(16)

 ;For all of the original galaxies.
 for i=0,galaxies_total_number_hst-1 do begin 

  ;And within the magnitude bin.
  for j=20,35 do begin
   galaxies_number_counts_label(j-20)=j
     
   ;Count this if it is within the magnitude bin.
   if (magnitude(i) gt float(j)-0.5) then begin
    if (magnitude(i) le float(j)+0.5) then begin
     galaxies_number_counts_hst(j)=galaxies_number_counts_hst(j)+1
    endif
   endif

  endfor
 endfor

 ;Find out the redshift and magnitude distrubution of galaxies.
 galaxies_distribution_redshift_hst=redshift
 galaxies_distribution_magnitude_hst=magnitude

 ;Generate masks for the galaxies. The pixel sampling is 0.075 arcsec/pixel in the masks and we use 40 X 40 sections giving 3.0 arcsec X 3.0
 ;arcsec sections. However, the image that we generate will have pixel sampling of 0.0375 arcsec/pixel and is therefore 2200 X 2600 pixels.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Generating the galaxy field ...', charsize=size_print, color=0, /device

 ;Set the image sizes.
 galaxies=fltarr(2200,2600)
 galaxies_tmp=fltarr(120,120)
 galaxies_hst=fltarr(1100,1300)
 galaxies_telescope=galaxies_hst
 galaxies_redshift=galaxies_hst
 galaxies_magnitude=galaxies_hst
 galaxies_weight=galaxies_hst
 galaxies_classification=galaxies_hst
 galaxies_radius=galaxies_hst
 galaxies_1=galaxies_hst
 galaxies_2=galaxies_hst
 galaxies_3=galaxies_hst
 galaxies_4=galaxies_hst
 galaxies_5=galaxies_hst

 ;And the catalog.
 galaxies_total_number=0
 galaxies_list_x_pos=fltarr(20000)
 galaxies_list_y_pos=galaxies_list_x_pos
 galaxies_list_magnitude=galaxies_list_x_pos
 galaxies_list_redshift=galaxies_list_x_pos
 galaxies_list_classification=galaxies_list_x_pos
 galaxies_list_radius=galaxies_list_x_pos
 galaxies_list_rotate=galaxies_list_x_pos
 galaxies_list_ellipticity=galaxies_list_x_pos

 ;The number of galaxies in the artificial image.
 galaxies_total_number=galaxies_total_number_hst
 
 ;Make an aperture.
 tmp_aperture=shift((dist(40)*2./40. lt 1. and dist(40)*2./40. ge 0.),20.,20.)

 ;And the fake galaxies. The maximum size is 3.0 arcsec across. For pixel sampling of 0.0375 arcsec/pixel this is 80 pixels.
 galaxy_fake_tmp=fltarr(5,80,80)

 ;For all five classifications.
 for i=0,4 do begin

  ;Galaxy.
  tmp=fltarr(300,300)
  tmp(0:299,0:299)=galaxy_fake(i,0:299,0:299)
  galaxy_fake_tmp(i,0:79,0:79)=congrid(tmp,80,80)

  ;And normalize.
  galaxy_fake_tmp=galaxy_fake_tmp*total(tmp)/total(galaxy_fake_tmp)

 endfor

 ;Add up the total flux of the simulation.
 flux_tmp=0.

 ;Go through all the original objects in the list.
 for i=0,galaxies_total_number_hst-1 do begin

  ;Status bar.
  status=floor(99.*float(i)/float(galaxies_total_number_hst))
  blank=fltarr(100,15)
  blank=blank+255
  blank(0:status,0:14)=0
  tv, congrid(blank,250,15), 350, 320
  xyouts, 350, 305, '0                                 100%', charsize=size_print, color=0, /device

  ;Set the cutter size.
  aperture=8.+0.01*(2.51^(30.-magnitude(i)))
  aperture=aperture/20.

  ;Ensure that a mask cannot be bigger than 40 pixels across.
  tmp_cut=tmp_aperture*shift((dist(40)*2./40. lt aperture and dist(40)*2./40. ge 0.),20.,20.)

  ;Extract the real galaxy.
  image_h_tmp=fltarr(40,40)
  image_h_tmp=tmp_cut*image_h(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)

  ;Estimate the radius of this object.
  tmp_1=image_h_tmp
  tmp=max(tmp_1)
  if (tmp le 0.) then begin
   tmp=1.
  endif
  tmp_1=tmp_1/tmp

  ;Count the number of pixels at half-light.
  tmp_2=0
  for l=0,39 do begin
   for m=0,39 do begin
    if (tmp_1(l,m) gt 0.5) then begin
     tmp_2=tmp_2+1
    endif
   endfor
  endfor

  ;Now this is an area. Assume it is circular and find the radius in arcsec.
  radius_tmp=0.075*sqrt(tmp_2/!dpi)

  ;Also, update the HST catalog of radii.
  radius(i)=radius_tmp

  ;Now, what factor smaller than the maximum radius of the HST galaxies is this. Remember, the biggest possible galaxy is 3.0 arcsec across or
  ;a radius of 1.5 arcsec. The maximum radius measured this way corresponds to 0.461594 arcsec.
  factor_tmp=radius_tmp/0.461594

  ;This can't be more than 1.
  if (factor_tmp gt 1.) then begin
   factor_tmp=1.
  endif

  ;This corresponds to a scale size. We also assign a random ellipticity.
  ellipticity_tmp=randomu(seed)

  ;Now determine a rotation.
  rotate_tmp=randomu(seed)*360.

  ;In x.
  x_f=floor(ellipticity_tmp*factor_tmp*40.)
  if (x_f lt 2) then begin
   x_f=2
  endif

  ;In y.
  y_f=floor(factor_tmp*40.)
  if (y_f lt 2) then begin
   y_f=2
  endif
  x_s=x_f-1
  y_s=y_f-1

  ;Now if this is a star then the image is full size.
  if (classification(i) eq 5) then begin
   rotate_tmp=0.
   factor_tmp=1.
   radius_tmp=0.461594
   ellipticity_tmp=1.
   x_f=factor_tmp*40
   y_f=factor_tmp*40
   x_s=x_f-1
   y_s=y_f-1
  endif

  ;Also, if this is the bright galaxy we force the parameters.
  if (i eq 232) then begin
   rotate_tmp=0.
   factor_tmp=1.
   radius_tmp=0.461594
   ellipticity_tmp=1.
   x_f=factor_tmp*40
   y_f=factor_tmp*40
   x_s=x_f-1
   y_s=y_f-1
  endif
  
  ;Generate a fake galaxy. This is scaled and rotated.
 
  ;First, take the fake galaxy image.
  tmp=fltarr(80,80)
  tmp(0:79,0:79)=galaxy_fake_tmp(classification(i)-1,0:79,0:79)

  ;Scale it.
  galaxies_fake_tmp=congrid(tmp,2*x_f,2*y_f)

  ;Insert back into a full image.
  tmp=galaxies_fake_tmp
  galaxies_fake_tmp=fltarr(80,80)
  galaxies_fake_tmp(40-x_f:40+x_s,40-y_f:40+y_s)=tmp(0:x_f+x_s,0:y_f+y_s)

  ;And rotate.
  galaxies_fake_tmp=rot(galaxies_fake_tmp,rotate_tmp)

  ;Ensure flux is 1.
  galaxies_fake_tmp=galaxies_fake_tmp/total(galaxies_fake_tmp)

  ;We multiply by the catalog flux for this galaxy. This is in H.
  lambda=16000.
  dlambda=3500.
  c=299792458. ;m/s
  h=6.6260755e-34 ;Joule/s
  nu=c/(lambda*1.e-10) ;Hz
  dnu=c/(dlambda*1.e-10) ;Hz
  flux=40012.*dnu/(nu*h*1e7)*10.^((magnitude(i)+48.60)/(-2.5))

  ;And multiply by the real flux.
  galaxies_fake_tmp=galaxies_fake_tmp*flux
  flux_tmp=flux_tmp+flux
 
  ;Put the galaxy into the original field. This has pixel sampling of 0.075 arcsec/pixel.

  ;Build the HST galaxy.
  tmp=congrid(galaxies_fake_tmp,40,40)

  ;Ensure flux is 1.
  tmp=tmp/total(tmp)

  ;And multiply by the real flux.
  tmp=flux*tmp

;  ;Now if this is a star then replace it with a Gaussian.
;  if (classification(i) eq 5) then begin
;   psf_tmp=fltarr(40,40)
;   psf_tmp=psf_gaussian(npixel=40,fwhm=2.,/normal)
;   tmp=flux*tmp_cut*psf_tmp
;  endif

  ;Now if this is a star then replace it with a blank image.
  if (classification(i) eq 5) then begin
   tmp=fltarr(40,40)
  endif

  ;Add it to the display images.
  galaxies_hst(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_hst(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+tmp
  galaxies_telescope(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_telescope(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+tmp
 
  ;And also the new field. This has sampling of 0.0375 arcsec/pixel.
  galaxies(2.*x_pos(i)-40:2.*x_pos(i)+39,2.*y_pos(i)-40:2.*y_pos(i)+39)=galaxies(2.*x_pos(i)-40:2.*x_pos(i)+39,2.*y_pos(i)-40:2.*y_pos(i)+39)+galaxies_fake_tmp

;  ;And the display.
;  display_tmp=fltarr(40,40)
;  display_tmp=tmp_cut*galaxies_hst(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)

  ;Make a complete list of the objects.
  galaxies_total_number=galaxies_total_number+1
  galaxies_list_x_pos(galaxies_total_number)=x_pos(i)
  galaxies_list_y_pos(galaxies_total_number)=y_pos(i)
  galaxies_list_magnitude(galaxies_total_number)=magnitude(i)
  galaxies_list_redshift(galaxies_total_number)=redshift(i)
  galaxies_list_classification(galaxies_total_number)=classification(i)
  galaxies_list_radius(galaxies_total_number)=radius_tmp
  galaxies_list_rotate(galaxies_total_number)=rotate_tmp
  galaxies_list_ellipticity(galaxies_total_number)=ellipticity_tmp

  ;Make the masks.
  galaxies_redshift(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_redshift(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+redshift(i)*tmp_cut
  galaxies_weight(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_weight(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+tmp_cut  
  galaxies_magnitude(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_magnitude(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+magnitude(i)*tmp_cut
  galaxies_classification(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_classification(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+float(classification(i))*tmp_cut
  galaxies_radius(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_radius(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+radius_tmp*tmp_cut
  if (floor(classification(i)) eq 1) then begin
   galaxies_1(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_1(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+redshift(i)*tmp_cut
  endif
  if (floor(classification(i)) eq 2) then begin
   galaxies_2(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_2(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+redshift(i)*tmp_cut
  endif
  if (floor(classification(i)) eq 3) then begin
   galaxies_3(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_3(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+redshift(i)*tmp_cut
  endif
  if (floor(classification(i)) eq 4) then begin
   galaxies_4(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_4(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+redshift(i)*tmp_cut
  endif
  if (floor(classification(i)) eq 5) then begin
   galaxies_5(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=galaxies_5(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+redshift(i)*tmp_cut
  endif

  ;If the galaxy is faint.
  if (magnitude(i) gt galaxy_cutoff) then begin

   ;Now, generate multiple clones (faint magnitudes fainter) in random locations in the field. Note that the new galaxies should be fainter,
   ;smaller, and at higher redshifts. They should also have a specified correlation length.
   scale=1./((2.51)^galaxy_faint)

   ;Add the galaxies.
   for k=0,galaxy_multiple-1 do begin

    ;The correlation length. We restrict it to be a few arcsec. This is highly clumpy and thus conservative. Note, correlation is in
    ;arcsec so we turn it into pixels.
    correlation_length=galaxy_correlation/0.075

    ;Note, there are more galaxies to choose from to put the new clones by, so you actually have to put them within this distance of all the new
    ;galaxies. The problem is that the galaxies can then 'stray' out of the simulation bounds. The simulation is only 1100 X 1300 pixels in size.
    ;The answer is to put them within a randomized distribution length of the original galaxies. This is also conservative.
    x_new=x_pos(abs(randomu(seed)*(galaxies_total_number_hst)))+floor(randomn(seed)*correlation_length)
    y_new=y_pos(abs(randomu(seed)*(galaxies_total_number_hst)))+floor(randomn(seed)*correlation_length)

    ;And if the galaxy has not strayed outside the simulation keep it.
    if ((x_new gt 157) and (y_new gt 283)) then begin
     if ((x_new lt 936) and (y_new lt 1025)) then begin 
 
      ;Give it a new rotation.
      rotate_tmp=randomu(seed)*360. 

      ;The shrinkage is applied to the galaxy radius.  

      ;Add the object to the list.
      galaxies_total_number=galaxies_total_number+1 
      galaxies_total_number=galaxies_total_number+1
      galaxies_list_x_pos(galaxies_total_number)=x_new
      galaxies_list_y_pos(galaxies_total_number)=y_new
      galaxies_list_magnitude(galaxies_total_number)=magnitude(i)+galaxy_faint
      galaxies_list_redshift(galaxies_total_number)=galaxy_shift*redshift(i)
      galaxies_list_classification(galaxies_total_number)=classification(i)
      galaxies_list_rotate(galaxies_total_number)=rotate_tmp
      galaxies_list_radius(galaxies_total_number)=(1./galaxy_shrink)*radius_tmp 
      galaxies_list_ellipticity(galaxies_total_number)=ellipticity_tmp

      ;Alter the masks.    
      galaxies_redshift(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_redshift(x_new-20:x_new+19,y_new-20:y_new+19)+galaxy_shift*redshift(i)*tmp_cut
      galaxies_weight(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_weight(x_new-20:x_new+19,y_new-20:y_new+19)+tmp_cut 
      galaxies_magnitude(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_magnitude(x_new-20:x_new+19,y_new-20:y_new+19)+(magnitude(i)+galaxy_faint)*tmp_cut
      galaxies_classification(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_classification(x_new-20:x_new+19,y_new-20:y_new+19)+float(classification(i))*tmp_cut
      galaxies_radius(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_radius(x_new-20:x_new+19,y_new-20:y_new+19)+(1./galaxy_shrink)*radius_tmp*tmp_cut
      if (floor(classification(i)) eq 1) then begin
       galaxies_1(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_1(x_new-20:x_new+19,y_new-20:y_new+19)+redshift(i)*tmp_cut
      endif
      if (floor(classification(i)) eq 2) then begin
       galaxies_2(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_2(x_new-20:x_new+19,y_new-20:y_new+19)+redshift(i)*tmp_cut
      endif
      if (floor(classification(i)) eq 3) then begin
       galaxies_3(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_3(x_new-20:x_new+19,y_new-20:y_new+19)+redshift(i)*tmp_cut
      endif
      if (floor(classification(i)) eq 4) then begin
       galaxies_4(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_4(x_new-20:x_new+19,y_new-20:y_new+19)+redshift(i)*tmp_cut
      endif
      if (floor(classification(i)) eq 5) then begin
       galaxies_5(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_5(x_new-20:x_new+19,y_new-20:y_new+19)+redshift(i)*tmp_cut
      endif

      ;Generate the new image. We will rotate and shrink the previous image.
      x_f=floor((1./galaxy_shrink)*40)
      y_f=floor((1./galaxy_shrink)*40)
      if (x_f lt 2) then begin
       x_f=2
      endif
      if (y_f lt 2) then begin
       y_f=2
      endif
      x_s=x_f-1
      y_s=y_f-1

      ;First, rotate it.
      tmp=fltarr(80,80)
      tmp(0:79,0:79)=rot(galaxies_fake_tmp,rotate_tmp)

      ;Shrink.
      tmp_1=congrid(tmp,2.*x_f,2.*y_f)
 
      ;Normalize to a flux of 1.
      tmp_1=tmp_1/total(tmp_1)

      ;And multiply by the real flux.
      tmp_1=scale*flux*tmp_1
      flux_tmp=flux_tmp+scale*flux

      ;Insert back into a full image.
      tmp=fltarr(80,80)
      tmp(40-x_f:40+x_s,40-y_f:40+y_s)=tmp_1(0:x_f+x_s,0:y_f+y_s)

      ;The new galaxy is added to the blank image.
      galaxies(2.*x_new-40:2.*x_new+39,2.*y_new-40:2.*y_new+39)=galaxies(2.*x_new-40:2.*x_new+39,2.*y_new-40:2.*y_new+39)+tmp

      ;And the display image. This is not scaled, which make the galaxies appear brighter in the display.
      display_tmp=congrid(tmp/scale,40,40)
      galaxies_telescope(x_new-20:x_new+19,y_new-20:y_new+19)=galaxies_telescope(x_new-20:x_new+19,y_new-20:y_new+19)+display_tmp
   
;      ;Find the messed up pixels in the colour image and reset them to white.
;      for l=x_new-20,x_new+19 do begin
;       for m=y_new-20,y_new+19 do begin
;        if (galaxies_telescope(l,m) gt 255) then begin
;         galaxies_telescope(l,m)=255
;        endif
;       endfor
;      endfor
      
     endif
    endif
   endfor
  endif
 endfor

 ;Now, fix the classifications, magnitudes, and radii of galaxies in the images.
 tmp=galaxies_weight
 for i=0,1099 do begin
  for j=0,1299 do begin
   if (tmp(i,j) eq 0.) then begin
    tmp(i,j)=1.
   endif
  endfor
 endfor
 galaxies_classification=galaxies_classification/tmp
 galaxies_magnitude=galaxies_magnitude/tmp
 galaxies_radius=galaxies_radius/tmp

 ;Reset the scale levels.
 galaxies_hst=galaxies_hst/max(galaxies_hst)
 galaxies_telescope=galaxies_telescope/max(galaxies_telescope)
 for i=0,1099 do begin
  for j=0,1299 do begin
   if (galaxies_hst(i,j) gt 0.01) then begin
    galaxies_hst(i,j)=0.01
   endif
  endfor
 endfor
 for i=0,1099 do begin
  for j=0,1299 do begin
   if (galaxies_telescope(i,j) gt 0.01) then begin
    galaxies_telescope(i,j)=0.01
   endif
  endfor
 endfor

 ;Also, mask off anything falling outside the original image.
 tmp=fltarr(1100,1300)
 tmp(157:935,283:1024)=1.
 galaxies_hst=galaxies_hst*tmp
 galaxies_telescope=galaxies_telescope*tmp

 ;Ensure the same scaling.
 tmp_1=max(galaxies_hst)
 tmp_2=max(galaxies_telescope)
 galaxies_hst(0,0)=tmp_2
 galaxies_telescope(0,0)=tmp_1
 
 ;Rescale.
 galaxies_hst=bytscl((galaxies_hst-min(galaxies_hst))^0.1, min=0.)
 galaxies_telescope=bytscl((galaxies_telescope-min(galaxies_telescope))^0.1, min=0.)

 ;Finally, fix the display images to be white in the margins.
 galaxies_hst(0:1099,0:283)=255
 galaxies_hst(0:1099,1020:1299)=255
 galaxies_hst(0:157,283:1025)=255
 galaxies_hst(936:1099,283:1025)=255
 galaxies_telescope(0:1099,0:283)=255
 galaxies_telescope(0:1099,1020:1299)=255
 galaxies_telescope(0:157,283:1025)=255
 galaxies_telescope(936:1099,283:1025)=255

 ;Generate the number counts. For each magnitude bin find out how many galaxies there are.
 
 ;For each galaxy.
 for i=0,galaxies_total_number-1 do begin 

  ;And within the magnitude bin.
  for j=20,35 do begin
   
   ;Count this if it is within the magnitude bin.
   if (galaxies_list_magnitude(i) gt float(j)-0.5) then begin
    if (galaxies_list_magnitude(i) le float(j)+0.5) then begin
     galaxies_number_counts(j)=galaxies_number_counts(j)+1
    endif
   endif

  endfor
 endfor

 ;Find out the new redshift distrubution of galaxies. Note, this list has been appended to when each new galaxy was added to the mask. Therefore,
 ;we only need to read off the last version of the list of redshifts and magnitudes.
 galaxies_distribution_redshift=galaxies_list_redshift
 galaxies_distribution_magnitude=galaxies_list_magnitude

 ;Find out the new radius distribution of objects.
 galaxies_distribution_radius=galaxies_list_radius
 galaxies_distribution_radius_hst=radius

 ;---------------------------------------------------------------------------------
 ;The stars.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the colour-magnitude diagrams ...', charsize=size_print, color=0, /device

 ;Load colours for the display.
 loadct, 1, /silent

 ;Read in the colour-magnitude diagrams.
 colour_magnitude_1=fltarr(2000)
 colour_magnitude_2=colour_magnitude_1

 ;R-I for ZAMS.
 file='./virtual_telescope_parameters/colour_magnitude_1.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*40.) lt 2000) then begin
   colour_magnitude_1(floor(a*40.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;R-I for white dwarfs.
 file='./virtual_telescope_parameters/colour_magnitude_2.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*40.) lt 2000) then begin
   colour_magnitude_2(floor(a*40.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;Shift these fainter by some factor.
 shift=floor(2000.*star_distance_modulus/40.)

 ;ZAMS.
 tmp=colour_magnitude_1
 colour_magnitude_1=shift(tmp,shift)
 colour_magnitude_1(0:shift)=colour_magnitude_1(shift)

 ;White dwarfs.
 tmp=colour_magnitude_2
 colour_magnitude_2=shift(tmp,shift)
 colour_magnitude_2(0:shift)=colour_magnitude_2(shift)

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the star field images ...', charsize=size_print, color=0, /device

; ;Read in the globular cluster image. This is a 1 second HST WFPC2 image of M15. The pixel sampling is 0.09 arcsec/pixel and so the image is 
; ;917 X 1083 pixels. We will rebin it to the same scaling as the galaxy image. That is we multiply the scaling by 1.2.

; ;Read in the image.
; stars_hst=readfits('./virtual_telescope_parameters/m15_wfpc2.fits', /silent)

; ;Rebin this to the correct size.
; tmp=stars_hst
; tmp_1=total(stars_hst)
; stars_hst=congrid(stars_hst,1100,1300)

; ;And normalize.
; stars_hst=stars_hst*tmp_1/total(stars_hst)

 ;Read in the galaxy background image.

 ;Read in the image.
 stars_background=fltarr(830,821)
 stars_background=readfits('./virtual_telescope_parameters/ngc5457_wfpc2.fits', /silent)

 ;Now, trim off the edges.
 tmp=fltarr(750,750)
 tmp=stars_background(60:809,70:819)

 ;And normalize to a total flux of 1.
 stars_background=fltarr(750,750)
 stars_background=tmp/total(tmp)

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the star field photometry ...', charsize=size_print, color=0, /device

 ;The total number of stars in the original image.
 stars_total_number_hst=0

 ;Set the counter.
 count=0

 ;The star data.
 file='./virtual_telescope_parameters/m15_wfpc2.dat'
 x_pos=fltarr(20000)
 y_pos=x_pos
 magnitude=x_pos
 classification=intarr(20000)
 openr, unit, file, /get_lun

 ;For all stars in the list.
 for i=0,3379-1 do begin
  readf, unit, a, b, c
  
  ;Take those within the field. Note the image had smaller dimensions when the photometry was taken. The area on the sky is the same. We
  ;only need the imager fields of 300 X 300 pixels.
  if ((a gt 157./1.2) and (b gt 283./1.2)) then begin
   if ((a lt (157.+300.)/1.2) and (b lt (283.+300)/1.2)) then begin

    ;Update the list.
    x_pos(stars_total_number_hst)=1.2*a
    y_pos(stars_total_number_hst)=1.2*b
    magnitude(stars_total_number_hst)=c

    ;Type 0 corresponds to ZAMS stars.
    classification(stars_total_number_hst)=0
    count=count+1

    ;Let some fraction be white dwarfs.
    if ((magnitude(stars_total_number_hst) gt star_white_bright) and (count eq floor(1./star_white_fraction))) then begin
     classification(stars_total_number_hst)=1
    endif

    ;Reset the counter.
    if (count eq floor(1./star_white_fraction)+1) then begin
     count=0
    endif

    ;Update the number of stars.
    stars_total_number_hst=stars_total_number_hst+1
  
   endif
  endif
 endfor
 close, unit
 free_lun, unit
 
 ;We will have overcounted by one star.
 stars_total_number_hst=stars_total_number_hst-1

 ;Calculate the number counts for this data.
 stars_number_counts_hst=intarr(50)
 stars_number_counts=intarr(50)
 stars_number_counts_label=fltarr(16)

 ;For all of the original stars.
 for i=0,stars_total_number_hst-1 do begin 

  ;And within the magnitude bin.
  for j=20,35 do begin
   stars_number_counts_label(j-20)=j
     
   ;Count this if it is within the magnitude bin.
   if (magnitude(i) gt float(j)-0.5) then begin
    if (magnitude(i) le float(j)+0.5) then begin
     stars_number_counts_hst(j)=stars_number_counts_hst(j)+1
    endif
   endif

  endfor
 endfor

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Generating the star field ...', charsize=size_print, color=0, /device

 ;Set image sizes.
 stars_hst=fltarr(1100,1300)
 stars_telescope=stars_hst

 ;And the catalogue.
 stars_total_number=0
 stars_list_x_pos=fltarr(20000)
 stars_list_y_pos=stars_list_x_pos
 stars_list_magnitude=stars_list_x_pos
 stars_list_classification=intarr(20000)

 ;Generate a star image to put in the images.
 psf=fltarr(40,40)
 psf=psf_gaussian(npixel=40,fwhm=2.,/normal)

 ;Set the correlation length.
 correlation_length=star_correlation/0.075

 ;For each star in the original list.
 for i=0,stars_total_number_hst-1 do begin

  ;Status bar.
  status=floor(99.*float(i)/float(stars_total_number_hst))
  blank=fltarr(100,15)
  blank=blank+255
  blank(0:status,0:14)=0
  tv, congrid(blank,250,15), 350, 320
  xyouts, 350, 305, '0                                 100%', charsize=size_print, color=0, /device

  ;Find the flux for the star.
  c=299792458. ;m/s
  h=6.6260755e-34 ;Joule/s
  lambda=8140. ;Angstrom
  dlambda=1000. ;Angstrom
  nu=c/(lambda*1.e-10) ;Hz
  dnu=c/(dlambda*1.e-10) ;Hz
  flux=40012.*dnu/(nu*h*1e7)*10.^((magnitude(i)+48.60)/(-2.5))

  ;Add the star to the original field.
  stars_hst(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=stars_hst(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+flux*psf
  
  ;And the new field.
  stars_telescope(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)=stars_telescope(x_pos(i)-20:x_pos(i)+19,y_pos(i)-20:y_pos(i)+19)+flux*psf
 
  ;Now, generate fainter copies in random locations in the field.
  scale=1./((2.51)^star_faint)

  ;Update the catalogue.
  stars_list_x_pos(i)=x_pos(i)
  stars_list_y_pos(i)=y_pos(i)
  stars_list_magnitude(i)=magnitude(i)
  stars_list_classification(i)=classification(i)

  ;Add the stars.
  for k=0,star_multiple-1 do begin

   ;Find a random position.
   x_new=x_pos(abs(randomu(seed)*(stars_total_number_hst)))+floor(randomn(seed)*correlation_length)
   y_new=y_pos(abs(randomu(seed)*(stars_total_number_hst)))+floor(randomn(seed)*correlation_length)

   ;If the star has not strayed outside the simulation keep it.
   if ((x_new gt 157) and (y_new gt 283)) then begin
    if ((x_new lt 157+300) and (y_new lt 283+300)) then begin 

    ;And update the catalogue.
    stars_total_number=stars_total_number+1
    stars_list_x_pos(stars_total_number)=x_new
    stars_list_y_pos(stars_total_number)=y_new
    stars_list_magnitude(stars_total_number)=magnitude(i)+star_faint
    stars_list_classification(stars_total_number)=classification(i)

    ;And add it to the field.
    stars_telescope(x_new-20:x_new+19,y_new-20:y_new+19)=stars_telescope(x_new-20:x_new+19,y_new-20:y_new+19)+scale*flux*psf

    endif
   endif

  endfor
 endfor

 ;Calculate the surface brightness of the background. The HST aperture is 40012 cm^2.
 c=299792458. ;m/s
 h=6.6260755e-34 ;Joule/s
 lambda=8140. ;Angstrom
 dlambda=1000. ;Angstrom
 nu=c/(lambda*1.e-10) ;Hz
 dnu=c/(dlambda*1.e-10) ;Hz
 flux=40012.*dnu/(nu*h*1e7)*10.^((star_surface_brightness+48.60)/(-2.5))
 
 ;Now, this is the flux in 1.0 arcsec X 1.0 arcsec or 13 X 13 pixels. We need to know the flux in 300 X 300 pixels which will be 532.5 X this
 ;amount.

 ;Add the background. Note that it is normalized to a flux of 1.
 tmp=congrid(stars_background,300,300)
 stars_hst(157:456,283:582)=stars_hst(157:456,283:582)+532.5*flux*tmp
 stars_telescope(157:456,283:582)=stars_telescope(157:456,283:582)+532.5*flux*tmp

 ;Also, mask off the objects falling outside the original image.
 tmp=fltarr(1100,1300)
 tmp(157:457,283:583)=1.
 stars_hst=stars_hst*tmp
 stars_telescope=stars_telescope*tmp
 
 ;Scale the images.
 stars_hst=bytscl((stars_hst-min(stars_hst))^0.1, min=0.)
 stars_telescope=bytscl((stars_telescope-min(stars_telescope))^0.1, min=0.)

 ;Finally, fix the display images to be white in the margins.
 stars_hst(0:1099,0:283)=255
 stars_hst(0:1099,583:1299)=255
 stars_hst(0:157,283:584)=255
 stars_hst(457:1099,283:584)=255
 stars_telescope(0:1099,0:283)=255
 stars_telescope(0:1099,583:1299)=255
 stars_telescope(0:157,283:584)=255
 stars_telescope(457:1099,283:584)=255

 ;Generate the number counts. For each magnitude bin find out how many stars there are.
 
 ;For each star.
 for i=0,stars_total_number-1 do begin 

  ;And within the magnitude bin.
  for j=20,35 do begin
   
   ;Count this if it is within the magnitude bin.
   if (stars_list_magnitude(i) gt float(j)-0.5) then begin
    if (stars_list_magnitude(i) le float(j)+0.5) then begin
     stars_number_counts(j)=stars_number_counts(j)+1
    endif
   endif

  endfor
 endfor

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Initialization of the field is complete.', charsize=size_print, color=0, /device

 ;Set the display toggle to 1.
 initialize_field_done=1
 
endif

;-----------------------------------------------------------------------------------
;Initialize the telescope. 
if (uvalue eq 'initialize_telescope') then begin

 ;Check for initialization.
 if (initialize_field_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the field first.', charsize=size_print, color=0, /device
 endif
 if (initialize_field_done eq 1) then begin

 ;Status bar.
 status=0

 ;Read in the solar spectrum. These data are from the NSO/Kitt Peak FTS. They cover 1.0 to 5.0 microns in 20000 data points.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the solar spectrum ...', charsize=size_print, color=0, /device

 ;Read in the spectrum.
 spectrum_solar=fltarr(20000)
 file='./virtual_telescope_parameters/spectrum_solar.dat'
 openr, unit, file, /get_lun
 for i=0,19999 do begin 
  readf, unit, a, b
  spectrum_solar(i)=b

  ;Find places where the spectrum is blank and set it to 1.
  if (spectrum_solar(i) le 0.) then begin
   spectrum_solar(i)=1.
  endif

 endfor
 close, unit
 free_lun, unit

 ;This covers 1.0 to 5.0 microns in 20000 data points. We want it to cover 0.0 to 3.0 microns in 30000 data points.
 tmp=congrid(spectrum_solar(0:9999),20000)
 spectrum_solar=fltarr(30000)
 spectrum_solar(0:9999)=1.
 spectrum_solar(10000:29999)=tmp

 ;Background calculated along the dispersion axis. Note that the resolution is set to 30000. It is in units of photons/s/arcsec^2.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Calculating the zodiacal background light ...', charsize=size_print, color=0, /device

 ;General constants.
 t_solar=5770. ;K
 c=299792458. ;m/s
 h=6.6260755e-34 ;Joule/s
 k_b=1.380658e-23 ;Joule/K

 ;Parameters.
 solar_distance=1. ;AU
 sky_area=((1./648000.)*!dpi)^2 ;steradians

 ;Background light parameters.
 t_thermal=266.*solar_distance^(-0.36) ;K
 albedo=0.102
 tau_thermal=5.61e-8*solar_distance^0.8          
 tau_scattered=tau_thermal*(albedo/(1-albedo))*(t_thermal/t_solar)^4
 background_zodiacal=fltarr(30000)

 ;Go along the dispersion axis.
 for i=1,29999 do begin

  ;Calculate the wavelength in meters.
  lambda=(3.*i/30000.)*1.e-6
  blackbody_solar=2*h*c/lambda^3*(exp(h*c/(lambda*k_b*t_solar))-1.)^(-1)
  spectrum_solar_true=blackbody_solar

  ;Multiply by the spectrum of the sun.
  spectrum_solar_true=blackbody_solar*spectrum_solar(i)

  ;And the thermal component.
  blackbody_thermal=2*h*c/lambda^3*(exp(h*c/(lambda*k_b*t_thermal))-1.)^(-1)
 
  ;Thus, the total is.
  background_zodiacal(i)=(tau_scattered*spectrum_solar_true+tau_thermal*blackbody_thermal)*sky_area/lambda/h/1.e6
 
 endfor

 ;Clean up.
 spectrum_solar=0

 ;Read in the sky spectrum. These data are from Keck NIRSPEC and are provided by Nicolas Cardiel. It covers 1.0 to 3.0 microns in 20000 data
 ;points.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the sky spectrum ...', charsize=size_print, color=0, /device

 ;Read in the spectrum.
 spectrum_sky=fltarr(30000)
 file='./virtual_telescope_parameters/spectrum_sky.dat'
 openr, unit, file, /get_lun
 for i=0,19999 do begin 
  readf, unit, a, b
  spectrum_sky(9999+i)=b

  ;Find places where the spectrum is negative and set it to 1.
  if (spectrum_sky(i) le 0.) then begin
   spectrum_sky(i)=1.
  endif

 endfor
 close, unit
 free_lun, unit

 ;Find the sky background in units of photons/s/m^2/arcsec^2/micron. We divide by the calibration to get photons/s/m^2/arcsec/micron and 
 ;multiply by the wavelength. Note the telescope pixel was 0.18 arcsec by 0.76 arcsec.
 background_sky=fltarr(30000)
 for i=0,29999 do begin
  background_sky(i)=10000.*(float(i)*1e-7*1.e-10)/(1.5e17*(0.01^2)*0.1368*h*c)*spectrum_sky(i)
 endfor

 ;Clean up.
 spectrum_sky=0

 ;Read in the atmospheric transmission. It covers 0.0 to 3.0 microns in 30000 data points.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in the atmospheric transmission ...', charsize=size_print, color=0, /device

 ;Read in the spectrum.
 atmospheric_transmission=fltarr(30000)
 file='./virtual_telescope_parameters/atmospheric_transmission.dat'
 openr, unit, file, /get_lun
 for i=0,29999 do begin 
  readf, unit, a, b
  atmospheric_transmission(i)=b

  ;Find places where the spectrum is negative and set it to 0.
  if (atmospheric_transmission(i) lt 0.) then begin
   atmospheric_transmission(i)=0.
  endif

  ;Also set data points greater than 1 to 1.
  if (atmospheric_transmission(i) gt 1.) then begin
   atmospheric_transmission(i)=1.
  endif

 endfor
 close, unit
 free_lun, unit

 ;If this is from space it is set to 1.
 if (telescope_primary eq 0) or (telescope_primary eq 1) then begin
  atmospheric_transmission=fltarr(30000)
  atmospheric_transmission=atmospheric_transmission+1.
 endif

 ;Generate the telescope pupil mask.

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Generating the telescope pupil mask ...', charsize=size_print, color=0, /device

 ;The HST pupil.
 if (telescope_primary eq 0) then begin

  ;Generate a circular pupil.
  pupil=shift((dist(1000)*2./1000. lt 0.24 and dist(1000)*2./1000. ge 0.07), 500., 500.)

  ;Finally, the spider.
  pupil(0:999,498:501)=0.
  pupil(498:501,0:999)=0.
 
 endif

 ;For NGST we emulate the GSFC design.
 if (telescope_primary eq 1) then begin

  ;Make a circular aperture.
  pupil=shift((dist(1000)*2./1000. lt 1. and dist(1000)*2./1000. ge 0.), 500., 500.)
  
  ;Now, the jagged edges of the mirror.
  pupil_obstruction=fltarr(500,500)
  pupil_obstruction=pupil_obstruction+1
  pupil_obstruction(260:499,260:499)=0
 
  ;The corners of the quadrant.
  for i=0,133 do begin
   pupil_obstruction(floor(i*0.55),366+i:499)=0
   pupil_obstruction(366+i:499,floor(i*0.55))=0
  endfor
  
  ;The notch.
  for i=0,239 do begin
   pupil_obstruction(260+i,260:260+floor(i*0.204))=1
  endfor
  for i=0,48 do begin
   pupil_obstruction(260+i,260+floor(i*4.906):499)=1
  endfor
  
  ;The central obstruction.
  for i=0,152 do begin
   pupil_obstruction(i,0:367-floor(2.414*i))=0
  endfor
  for i=0,152 do begin
   pupil_obstruction(i,152-floor(i/2.414):367)=1
  endfor
  pupil(500:999,500:999)=pupil(500:999,500:999)*pupil_obstruction
  pupil_obstruction=rotate(pupil_obstruction,1)
  pupil(0:499,500:999)=pupil(0:499,500:999)*pupil_obstruction
  pupil_obstruction=rotate(pupil_obstruction,-1)
  pupil(0:499,0:499)=pupil(0:499,0:499)*pupil_obstruction
  pupil_obstruction=rotate(pupil_obstruction,5)
  pupil(500:999,0:499)=pupil(500:999,0:499)*pupil_obstruction 

  ;Also, the spider.
  ;The vertical strut.
  pupil(498:501,500:999)=0.

  ;The other two struts.
  for i=0,499 do begin
   pupil(i+498:i+500,500-floor(0.58*i):500-floor(0.58*i)+2)=0
   pupil(i:i+2,210+floor(0.58*i):211+floor(0.58*i)+2)=0
  endfor
 
  ;Now this is larger than needed so we rescale it to be 8.0 metres across.
  tmp=congrid(pupil,800,800)
  pupil=fltarr(1000,1000)
  pupil(100:899,100:899)=tmp

  ;Clean up.
  pupil_obstruction=0

 endif

 ;The CFHT.
 if (telescope_primary eq 2) then begin

  ;Make a circular aperture.
  pupil=shift((dist(1000)*2./1000. lt 0.36 and dist(1000)*2./1000. ge 0.16), 500., 500.)

  ;Also, the spider.
  pupil(0:999,498:501)=0.
  pupil(498:501,0:999)=0.

 endif

 ;Finally, Gemini.
 if (telescope_primary eq 3) then begin

  ;Make a circular aperture.
  pupil=shift((dist(1000)*2./1000. lt 0.79 and dist(1000)*2./1000. ge 0.12), 500., 500.)

  ;Also, the spider.
  pupil(0:999,499:500)=0.
  pupil(499:500,0:999)=0.

 endif

 ;Calculate the area of the HST pupil.

 ;Generate the HST pupil.
 pupil_hst=shift((dist(1000)*2./1000. lt 0.24 and dist(1000)*2./1000. ge 0.07), 500., 500.)

 ;Finally, the spider.
 pupil_hst(0:999,498:501)=0.
 pupil_hst(498:501,0:999)=0.

 ;The image has resolution of 1 cm/pixel.
 aperture_hst=0.0001*total(pupil_hst)

 ;Find out how much bigger the telescope pupil is than the HST.
 aperture_scaling=total(pupil)/total(pupil_hst)

 ;We can now scale the background to the aperture of the telescope.
 background_zodiacal=aperture_scaling*aperture_hst*background_zodiacal
 background_sky=aperture_scaling*aperture_hst*background_sky

 ;Put the pupil mask into a bigger image for the purposes of FFT.
 pupil_tmp=fltarr(2000,2000)
 pupil_tmp(500:1499,500:1499)=pupil

 ;Take the Fourier transform of the pupil in order to generate the diffraction pattern at the focal plane.
 diffraction_tmp=abs(fft(pupil_tmp))^2.
 diffraction_tmp=shift(diffraction_tmp,499.,499.)/total(diffraction_tmp)

 ;And normalize.
 diffraction_tmp=diffraction_tmp/total(diffraction_tmp)

 ;Make an aperture.
 tmp_cut=shift((dist(200)*2./200. lt 1. and dist(200)*2./200. ge 0.),100.,100.)

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Generating the telescope diffraction pattern ...', charsize=size_print, color=0, /device

 ;This is the diffraction pattern for 0.1 microns. We need the changing diffraction pattern from 0.1 to 3 microns. The idea is to rescale this
 ;diffraction pattern to represent the increased diffraction limit towards longer wavelengths.
 star=fltarr(30,200,200)

 ;Do 0.1 to 3.0 microns.
 for i=0,29 do begin

  ;Status bar.
  status=floor(99.*(float(i)/float(30)))
  blank=fltarr(100,15)
  blank=blank+255
  blank(0:status,0:14)=0
  tv, congrid(blank,250,15), 350, 320
  xyouts, 350, 305, '0                                 100%', charsize=size_print, color=0, /device

  ;Scale down the initial image. There should be an extra factor of how much smaller the diffraction pattern needs to be for an 8 metre telescope
  ;to have an 0.03 arcsec FWHM diffraction spike in J.
  tmp_1=floor(500/(i+1))
  if (tmp_1 gt 500) then begin
   tmp_1=500
  endif
  tmp=diffraction_tmp(500-tmp_1:500+tmp_1-1,500-tmp_1:500+tmp_1-1)

  ;That is, if the wavelength is 2 X as long the diffraction pattern is 2 X as big.
  diffraction=congrid(tmp,200,200,/minus_one)
 
  ;We will assume that the PSF is diffraction limited.
  star(i,0:199,0:199)=tmp_cut*diffraction(0:199,0:199)

  ;And normalize.
  star(i,0:199,0:199)=star(i,0:199,0:199)/total(star(i,0:199,0:199)) 

 endfor

 ;Clean up
 diffraction_tmp=0

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Generating the telescope point-spread function ...', charsize=size_print, color=0, /device

 ;Set up the wavelengths in nm of the PSFs.
 tmp_3=fltarr(30)
 for i=0,29 do begin
  tmp_3(i)=100.*i
 endfor

 ;We have now generated 30 images from 0.0 to 3.0 microns. Check the FWHM and Strehl-ratios for each of these PSFs.
 star_fwhm=fltarr(30)
 star_strehl=star_fwhm
 for i=0,29 do begin

  ;Status bar.
  status=floor(99.*(float(i)/float(30)))
  blank=fltarr(100,15)
  blank=blank+255
  blank(0:status,0:14)=0
  tv, congrid(blank,250,15), 350, 320
  xyouts, 350, 305, '0                                 100%', charsize=size_print, color=0, /device
 
  ;Extract the PSF.
  tmp_1=fltarr(200,200)
  tmp_1(0:199,0:199)=star(i,0:199,0:199)

  ;Find the normalization.
  tmp=max(tmp_1)
  if (tmp le 0.) then begin
   tmp=1.
  endif
  tmp_1=tmp_1/tmp

  ;And the scatter.
  scatter=1.-exp(-(4.*!dpi*telescope_roughness/tmp_3(i))^2)
  tmp=fltarr(200,200)
  tmp=tmp+scatter*total(tmp_1)

  ;Thus, the PSF is the perfect PSF with scattering.
  tmp_1=(1.-scatter)*tmp_1+tmp

  ;And subtract the background.
  star(i,0:199,0:199)=tmp_1-min(tmp_1)

  ;Now, assume imperfect correction of the adaptive optics is well modeled by a Gaussian filter.
  tmp_1(0:199,0:199)=star(i,0:199,0:199)
  tmp_2=psf_gaussian(npixel=20,fwhm=telescope_error/0.01,/normal)
  star(i,0:199,0:199)=convolve(tmp_1,tmp_2)
    
  ;Count the number of pixels at half-light.
  tmp_2=0
  for j=0,199 do begin
   for k=0,199 do begin
    if (tmp_1(j,k) gt 0.5) then begin
     tmp_2=tmp_2+1
    endif
   endfor
  endfor

  ;Assume it is circular and find the diameter. Thus the FWHM in arcsec is given by.
  star_fwhm(i)=0.01*2.*sqrt(tmp_2/!dpi)

  ;Calculate the delivered Strehl-ratio.
  star_strehl(i)=max(star(i,0:199,0:199))
  
  ;Normalize this to have a total flux of 1.
  star(i,0:199,0:199)=star(i,0:199,0:199)/total(star(i,0:199,0:199))
  
 endfor

 ;Let the 0.0 micron PSF be the same as for 0.1 microns.
 star(0,0:199,0:199)=star(1,0:199,0:199)

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 loadct, 0, /silent
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Reading in efficiency curves ...', charsize=size_print, color=0, /device

 ;First, the coating efficiency of the mirrors.

 ;Aluminum.
 mirror_coating_aluminum=fltarr(2000)
 file='./virtual_telescope_parameters/mirror_coating_aluminum.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*400.) lt 2000) then begin
   mirror_coating_aluminum(floor(a*400.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=mirror_coating_aluminum(0:1200)
 mirror_coating_aluminum=congrid(tmp,3000)

 ;Silver.
 mirror_coating_silver=fltarr(2000)
 file='./virtual_telescope_parameters/mirror_coating_silver.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*400.) lt 2000) then begin
   mirror_coating_silver(floor(a*400.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=mirror_coating_silver(0:1200)
 mirror_coating_silver=congrid(tmp,3000)

 ;Gold.
 mirror_coating_gold=fltarr(2000)
 file='./virtual_telescope_parameters/mirror_coating_gold.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*400.) lt 2000) then begin
   mirror_coating_gold(floor(a*400.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=mirror_coating_gold(0:1200)
 mirror_coating_gold=congrid(tmp,3000)

 ;And the grating efficiency.
 grating_efficiency=fltarr(2000)
 file='./virtual_telescope_parameters/grating_efficiency.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*400.) lt 2000) then begin
   grating_efficiency(floor(a*400.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=grating_efficiency(0:1200)
 grating_efficiency=congrid(tmp,3000)

 ;Now, generate the filter set.
 filters=fltarr(9,3000)
 filter_bandpasses=fltarr(9,2)

 ;Filter bandpasses.
 file='./virtual_telescope_parameters/filter_bandpasses.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, a, b, c
  filter_bandpasses(a,0)=b
  filter_bandpasses(a,1)=c
 endwhile
 close, unit
 free_lun, unit

 ;Blank filter.
 filters(0,0:2999)=1.

 ;U.
 file='./virtual_telescope_parameters/filter_f300w.dat'
 openr, unit, file, /get_lun
 tmp=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b
  tmp_1=floor(a/25.)
  if ((tmp_1-5 gt 0) and (tmp_1+5 lt 1999)) then begin
   ;The peak throughput should be 80%. It has been normalized to 1.
   tmp(tmp_1-5:tmp_1+5)=b*0.8
  endif
 endwhile
 close, unit
 free_lun, unit
 filters(1,0:1999)=smooth(tmp(0:1999),5)

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=fltarr(1200)
 tmp(0:1199)=filters(1,0:1199)
 tmp_1=congrid(tmp,3000)
 filters(1,0:2999)=tmp_1(0:2999)

 ;B.
 file='./virtual_telescope_parameters/filter_f450w.dat'
 openr, unit, file, /get_lun
 tmp=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b 
  tmp_1=floor(a/25.)
  if ((tmp_1-5 gt 0) and (tmp_1+5 lt 1999)) then begin
   ;the peak is 80%.
   tmp(tmp_1-5:tmp_1+5)=b*0.8
  endif
 endwhile
 close, unit
 free_lun, unit
 filters(2,0:1999)=smooth(tmp(0:1999),5)

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=fltarr(1200)
 tmp(0:1199)=filters(2,0:1199)
 tmp_1=congrid(tmp,3000)
 filters(2,0:2999)=tmp_1(0:2999)

 ;V.
 file='./virtual_telescope_parameters/filter_f606w.dat'
 openr, unit, file, /get_lun
 tmp=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b
  tmp_1=floor(a/25.)
  if ((tmp_1-5 gt 0) and (tmp_1+5 lt 1999)) then begin
   ;The peak is 90%.
   tmp(tmp_1-5:tmp_1+5)=b*0.9
  endif
 endwhile
 close, unit
 free_lun, unit
 filters(3,0:1999)=smooth(tmp(0:1999),5)

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=fltarr(1200)
 tmp(0:1199)=filters(3,0:1199)
 tmp_1=congrid(tmp,3000)
 filters(3,0:2999)=tmp_1(0:2999)
  
 ;R. 
 file='./virtual_telescope_parameters/filter_f702w.dat'
 openr, unit, file, /get_lun
 tmp=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b 
  tmp_1=floor(a/25.)
  if ((tmp_1-5 gt 0) and (tmp_1+5 lt 1999)) then begin
   ;The peak is 90%.
   tmp(tmp_1-5:tmp_1+5)=b*0.9
  endif
 endwhile
 close, unit
 free_lun, unit
 filters(4,0:1999)=smooth(tmp(0:1999),5)

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=fltarr(1200)
 tmp(0:1199)=filters(4,0:1199)
 tmp_1=congrid(tmp,3000)
 filters(4,0:2999)=tmp_1(0:2999)

 ;I.
 file='./virtual_telescope_parameters/filter_f814w.dat'
 openr, unit, file, /get_lun
 tmp=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b 
  tmp_1=floor(a/25.)
  if ((tmp_1-5 gt 0) and (tmp_1+5 lt 1999)) then begin
   ;The peak is 80%.
   tmp(tmp_1-5:tmp_1+5)=b*0.8
  endif
 endwhile
 close, unit
 free_lun, unit
 filters(5,0:1999)=smooth(tmp(0:1999),5)

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=fltarr(1200)
 tmp(0:1199)=filters(5,0:1199)
 tmp_1=congrid(tmp,3000)
 filters(5,0:2999)=tmp_1(0:2999)

 ;J.
 file='./virtual_telescope_parameters/filter_f1100w.dat'
 openr, unit, file, /get_lun
 tmp=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b
  tmp_1=floor(a*400.)
  if ((tmp_1-25 gt 0) and (tmp_1+25 lt 1999)) then begin
   ;The infrared filters are properly normalized.
   tmp(tmp_1-25:tmp_1+25)=b
  endif
 endwhile
 close, unit
 free_lun, unit
 filters(6,0:1999)=smooth(tmp(0:1999),50)

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=fltarr(1200)
 tmp(0:1199)=filters(6,0:1199)
 tmp_1=congrid(tmp,3000)
 filters(6,0:2999)=tmp_1(0:2999)

 ;H.
 file='./virtual_telescope_parameters/filter_f1600w.dat'
 openr, unit, file, /get_lun
 tmp=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b
  tmp_1=floor(a*400.)
  if ((tmp_1-25 gt 0) and (tmp_1+25 lt 1999)) then begin
   tmp(tmp_1-25:tmp_1+25)=b
  endif
 endwhile
 close, unit
 free_lun, unit
 filters(7,0:1999)=smooth(tmp(0:1999),50)

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=fltarr(1200)
 tmp(0:1199)=filters(7,0:1199)
 tmp_1=congrid(tmp,3000)
 filters(7,0:2999)=tmp_1(0:2999)

 ;K.
 file='./virtual_telescope_parameters/filter_f2200w.dat'
 openr, unit, file, /get_lun
 tmp=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b
  tmp_1=floor(a*400.)
  if ((tmp_1-25 gt 0) and (tmp_1+25 lt 1999)) then begin
   tmp(tmp_1-25:tmp_1+25)=b
  endif
 endwhile
 close, unit
 free_lun, unit
 filters(8,0:1999)=smooth(tmp(0:1999),50)

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=fltarr(1200)
 tmp(0:1199)=filters(8,0:1199)
 tmp_1=congrid(tmp,3000)
 filters(8,0:2999)=tmp_1(0:2999)

 ;And the detector efficiencies.
 detector_efficiency_1=fltarr(2000)
 detector_efficiency_2=detector_efficiency_1
 detector_efficiency_3=detector_efficiency_1

 ;HyViSi.
 file='./virtual_telescope_parameters/detector_efficiency_HyViSi.dat'
 openr, unit, file, /get_lun
 detector_efficiency_1=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*400.) lt 2000) then begin
   detector_efficiency_1(floor(a*400.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=detector_efficiency_1(0:1200)
 detector_efficiency_1=congrid(tmp,3000)

 ;HgCdTe.
 file='./virtual_telescope_parameters/detector_efficiency_HgCdTe.dat'
 openr, unit, file, /get_lun
 detector_efficiency_2=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*400.) lt 2000) then begin
   detector_efficiency_2(floor(a*400.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=detector_efficiency_2(0:1200)
 detector_efficiency_2=congrid(tmp,3000)

 ;InSb.
 file='./virtual_telescope_parameters/detector_efficiency_InSb.dat'
 openr, unit, file, /get_lun
 detector_efficiency_3=fltarr(2000)
 while not eof(unit) do begin 
  readf, unit, a, b
  if (floor(a*400.) lt 2000) then begin
   detector_efficiency_3(floor(a*400.))=b
  endif
 endwhile
 close, unit
 free_lun, unit

 ;This is from 0.0 to 5.0 microns in 2000 pixels. We only want 0.0 to 3.0 microns.
 tmp=detector_efficiency_3(0:1200)
 detector_efficiency_3=congrid(tmp,3000)

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Calculating the telescope background ...', charsize=size_print, color=0, /device

 ;General constants.
 c=299792458. ;m/s
 h=6.6260755e-34 ;Joule/s
 k_b=1.380658e-23 ;Joule/K

 ;Parameters.
 sky_area=((1./648000.)*!dpi)^2 ;steradians
 t=telescope_temperature ;K
 background_telescope=fltarr(30000)
 tmp=fltarr(30000)
 if ((telescope_primary eq 0) or (telescope_primary eq 2) or (telescope_primary eq 3)) then begin
  tmp=congrid(mirror_coating_aluminum,30000)
 endif
 if (telescope_primary eq 1) then begin
  tmp=congrid(mirror_coating_gold,30000)
 endif
 
 ;Go along the dispersion axis.
 for i=1,29999 do begin

  ;Calculate the wavelength in meters.
  lambda=(3.*i/30000.)*1.e-6

  ;And the thermal component.
  blackbody_thermal=2*h*c/lambda^3*(exp(h*c/(lambda*k_b*t))-1.)^(-1) 
 
  ;Thus, the total is.
  background_telescope(i)=telescope_surfaces*(1.-tmp(i))*blackbody_thermal*sky_area/lambda/h/1.e6
 
 endfor

 ;And the total background is.

 ;For space.
 if (telescope_primary eq 0) or (telescope_primary eq 1) then begin
  background_total=background_zodiacal+background_telescope
 endif
 
 ;For the ground.
 if (telescope_primary eq 2) or (telescope_primary eq 3) then begin
  background_total=background_sky+background_telescope
 endif

 ;Clean up.
 background_zodiacal=0
 background_sky=0
 background_thermal=0

 ;Write out the spectrum to a file.
 tmp=string('./virtual_telescope_parameters/spectrum_background.dat')
 get_lun, unit
 openw, unit, tmp, /append
 xlabel=fltarr(30000)
 for i=0,29999 do begin
  xlabel(i)=(i/30000.)*3.
  printf, unit, xlabel(i), background_total(i)
 endfor
 close, unit
 free_lun, unit

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Initializing:', charsize=size_print, color=0, /device
 xyouts, 350, 350, 'Initialization of the telescope is complete.', charsize=size_print, color=0, /device

 ;Set the display toggle to 1.
 initialize_telescope_done=1

 endif
endif

;-----------------------------------------------------------------------------------
;Show the field setup.
if (uvalue eq 'field_setup') then begin

 ;Check for initialization.
 if (initialize_field_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the field first.', charsize=size_print, color=0, /device
 endif
 if (initialize_field_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 0, /silent
 !p.multi = [0,3,2]
 character_size=size_print*1.5

 ;Top row.

 ;Plot of the template galaxy spectra.

 ;Generate an axis label.
 xlabel=fltarr(30000)
 for i=0,29999 do begin
  xlabel(i)=(i/30000.)*3.
 endfor

 ;The template galaxy spectra.
 plot, xlabel, spectrum_1/max(spectrum_4), /ylog, ystyle=1, yrange=[0.0001,1], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Intensity', title='Template Galaxy Spectra', background=255, color=0
 oplot, xlabel, spectrum_2/max(spectrum_4), linestyle=2, color=0
 oplot, xlabel, spectrum_3/max(spectrum_4), linestyle=3, color=0
 oplot, xlabel, spectrum_4/max(spectrum_4), linestyle=4, color=0

 ;Display the galaxy number counts. Note that the size of the observed field for NICMOS 
 ;is 58.4 X 55.7 arcsec^2, which is 0.0002509938 square degrees. 
 plot, galaxies_number_counts_label, 3894.1617*galaxies_number_counts(20:35), psym=-4, /ylog, min_value=1.e4, charsize=character_size, thick=1, xtitle='H(AB)', ytitle='Galaxy counts (galaxies/degree/magnitude)', title='Galaxy Counts', color=0
 oplot, galaxies_number_counts_label, 3894.1617*galaxies_number_counts_hst(20:35), psym=-2, symsize=0.75, linestyle=2, color=0

 ;Plot the distribution of redshifts versus magnitude for both HST and NGST.
 plot, galaxies_distribution_magnitude, galaxies_distribution_redshift, psym=4, xrange=[20,35], min_value=0, charsize=character_size, thick=1, xtitle='H(AB)', ytitle='Redshift', title='Redshift Distribution', color=0
 oplot, galaxies_distribution_magnitude_hst, galaxies_distribution_redshift_hst, psym=2, symsize=0.75, color=0 

 ;Bottom row.

 ;Plot the distribution of galaxy sizes.
 plot, galaxies_distribution_magnitude, galaxies_distribution_radius, psym=4, xrange=[20,35], min_value=0., charsize=character_size, thick=1, xtitle='H(AB)', ytitle='FWHM (arcsec)', title='Galaxy FWHM', color=0
 oplot, galaxies_distribution_magnitude_hst, galaxies_distribution_radius_hst, psym=2, symsize=0.75, color=0

 ;Generate an axis label.
 xlabel=fltarr(2000)
 for i=0,1999 do begin
  xlabel(i)=i/40.
 endfor

 ;The template colour-magnitude diagrams.

 ;R-I.
 plot, xlabel, colour_magnitude_1, linestyle=0, xrange=[20,35], yrange=[-2,6], ystyle=1, charsize=character_size, thick=1, xtitle='I(AB)', ytitle='Magnitude(AB)', title='Template Colour-Magnitude Relations', color=0 
 oplot, xlabel, colour_magnitude_2, linestyle=2, color=0

 ;V-I.
 oplot, xlabel, colour_magnitude_1*star_colour_shift_1, linestyle=0, color=0
 oplot, xlabel, colour_magnitude_2*star_colour_shift_1, linestyle=2, color=0

 ;I-J.
 oplot, xlabel, colour_magnitude_1*star_colour_shift_2, linestyle=0, color=0
 oplot, xlabel, colour_magnitude_2*star_colour_shift_2, linestyle=2, color=0

 ;J-H.
 oplot, xlabel, colour_magnitude_1*star_colour_shift_3, linestyle=0, color=0
 oplot, xlabel, colour_magnitude_2*star_colour_shift_3, linestyle=2, color=0

 ;H-K.
 oplot, xlabel, colour_magnitude_1*star_colour_shift_4, linestyle=0, color=0
 oplot, xlabel, colour_magnitude_2*star_colour_shift_4, linestyle=2, color=0

 ;Display the star number counts. Note that the size of the observed field for NICMOS is 58.4 X 55.7 arcsec^2, which is 0.0002509938
 ;square degrees. 
 plot, stars_number_counts_label, 3894.1617*stars_number_counts(20:35), psym=-4, /ylog, min_value=1.e4, charsize=character_size, thick=1, xtitle='I(AB)', ytitle='Star counts (stars/degree/magnitude)', title='Star Counts', color=0
 oplot, stars_number_counts_label, 3894.1617*stars_number_counts_hst(20:35), psym=-2, symsize=0.75, linestyle=2, color=0

 endif
endif

;-----------------------------------------------------------------------------------
;Show the galaxy field.
if (uvalue eq 'galaxy_field') then begin

 ;Check for initialization.
 if (initialize_field_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the field first.', charsize=size_print, color=0, /device
 endif
 if (initialize_field_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 3, /silent

 ;Display the images.
 tmp=fltarr(741,778)
 tmp=galaxies_hst(157:934,283:1023)
 tmp_1=congrid(tmp,420,400)
 tmp=galaxies_telescope(157:934,283:1023)
 tmp_2=congrid(tmp,420,400)
 tv, tmp_1, 20, 130
 tv, tmp_2, 460, 130

 ;Labels.
 xyouts, 20, 560, 'HST H Galaxy Field', charsize=size_print, color=0, /device
 xyouts, 20, 545, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device
 xyouts, 460, 560, 'H Galaxy Field', charsize=size_print, color=0, /device
 xyouts, 460, 545, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device
 
 endif
endif

;-----------------------------------------------------------------------------------
;Show the star field.
if (uvalue eq 'star_field') then begin

 ;Check for initialization.
 if (initialize_field_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the field first.', charsize=size_print, color=0, /device
 endif
 if (initialize_field_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 1, /silent

 ;Display the images.
 tmp=fltarr(741,778)
 tmp=stars_hst(157:934,283:1023)
 tmp_1=congrid(tmp,420,400)
 tmp=stars_telescope(157:934,283:1023)
 tmp_2=congrid(tmp,420,400)
 tv, tmp_1, 20, 130
 tv, tmp_2, 460, 130

 ;Labels.
 xyouts, 20, 560, 'HST I Star Field', charsize=size_print, color=0, /device
 xyouts, 20, 545, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device
 xyouts, 460, 560, 'I Star Field', charsize=size_print, color=0, /device
 xyouts, 460, 545, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

 ;Put a border around the image.

 ;HST.
 arrow, 20, 130, 440, 130, /solid, hsize=0, color=0
 arrow, 440, 130, 440, 530, /solid, hsize=0, color=0
 arrow, 440, 530, 20, 530, /solid, hsize=0, color=0
 arrow, 20, 530, 20, 130, /solid, hsize=0, color=0

 ;Telescope.
 arrow, 460, 130, 880, 130, /solid, hsize=0, color=0
 arrow, 880, 130, 880, 530, /solid, hsize=0, color=0
 arrow, 880, 530, 460, 530, /solid, hsize=0, color=0
 arrow, 460, 530, 460, 130, /solid, hsize=0, color=0
 
 endif
endif

;-----------------------------------------------------------------------------------
;Show the telescope setup.
if (uvalue eq 'telescope_setup') then begin

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the telescope first.', charsize=size_print, color=0, /device
 endif
 if (initialize_telescope_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 0, /silent
 !p.multi = [0,3,2]
 character_size=size_print*1.5

 ;Plot of the background spectrum. Display this in photons/s/m^2/arcsec^2/micron.
  
 ;Generate an axis label.
 xlabel=fltarr(30000)
 for i=0,29999 do begin
  xlabel(i)=(i/30000.)*3.
 endfor
 plot, xlabel, (1./(aperture_scaling*aperture_hst))*background_total, min_value=0.1, /ylog, charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Intensity (photons/s/m^2/arcsec^2/micron)', title='Background Light', background=255, color=0

 ;In the case of the ground display the atmospheric transmission.
 if (telescope_primary eq 2) or (telescope_primary eq 3) then begin

  ;Generate an axis label.
  xlabel=fltarr(30000)
  for i=0,29999 do begin
   xlabel(i)=(i/30000.)*3.
  endfor
  plot, xlabel, 100.*atmospheric_transmission, yrange=[0,100], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Transmittance (%)', title='Atmospheric Transmission', background=255, color=0

 endif

 ;Plot of the mirror coating efficiency.

 ;Generate an axis label.
 xlabel=fltarr(3000)
 for i=0,2999 do begin
  xlabel(i)=(i/3000.)*3.
 endfor
 if (telescope_primary eq 1) then begin
 plot, xlabel, 100.*mirror_coating_gold, yrange=[0,100], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='Mirror Coatings', color=0
 endif
 if ((telescope_primary eq 0) or (telescope_primary eq 2) or (telescope_primary eq 3)) then begin
 plot, xlabel, 100.*mirror_coating_aluminum, yrange=[0,100], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='Mirror Coatings', color=0
 endif

 ;Plot of the PSFs at different wavelengths.

 ;Generate an axis label.
 xlabel=fltarr(200)
 for i=0,199 do begin
  xlabel(i)=-1.+(i/200.)*2.
 endfor

 ;The PSFs.
 plot, xlabel, star(1,0:199,100)/max(star(1,0:199,0:100)), yrange=[1.e-6,1], /ylog, charsize=character_size, thick=1, xtitle='Position (arcsec)', ytitle='Intensity', title='Point-Spread Function', color=0
 oplot, xlabel, star(3,0:199,100)/max(star(3,0:199,0:100)), color=0
 oplot, xlabel, star(5,0:199,100)/max(star(5,0:199,0:100)), color=0
 oplot, xlabel, star(7,0:199,100)/max(star(7,0:199,0:100)), color=0
 oplot, xlabel, star(9,0:199,100)/max(star(9,0:199,0:100)), color=0
 oplot, xlabel, star(19,0:199,100)/max(star(19,0:199,0:100)), color=0
 oplot, xlabel, star(29,0:199,100)/max(star(29,0:199,0:100)), color=0

 ;Plot of PSF FWHM as a function of wavelength.
 
 ;Generate an axis label.
 xlabel=fltarr(30)
 for i=0,29 do begin
  xlabel(i)=0.1*i
 endfor
 plot, xlabel, star_fwhm(0:29), min_value=0., psym=-4, charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='FWHM (arcsec)', title='Point-Spread Function', color=0

 ;Plot of PSF FWHM as a function of wavelength.
 plot, xlabel, 100.*star_strehl(0:29), yrange=[0,100], psym=-4, charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Strehl-ratio (%)', title='Point-Spread Function', color=0

 endif
endif

;-----------------------------------------------------------------------------------
;Show the optical imager setup.
if (uvalue eq 'optical_imager_setup') then begin

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the telescope first.', charsize=size_print, color=0, /device
 endif
 if (initialize_telescope_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 0, /silent
 !p.multi = [0,3,2]
 character_size=size_print*1.5

 ;Plot of the optical imager filter-bandpasses. Display this as a percentage.
 ;Generate an axis label.
 xlabel=fltarr(3000)
 for i=0,2999 do begin
  xlabel(i)=(i/3000.)*3.
 endfor
 plot, xlabel, 100.*filters(1,0:2999), ystyle=1, yrange=[0,100], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Throughput (%)', title='OI Filter Bandpasses', background=255, color=0
 oplot, xlabel, 100.*filters(2,0:2999), color=0
 oplot, xlabel, 100.*filters(3,0:2999), color=0
 oplot, xlabel, 100.*filters(4,0:2999), color=0
 oplot, xlabel, 100.*filters(5,0:2999), color=0

 ;Plot of the mirror coating efficiency.

 ;Generate an axis label.
 xlabel=fltarr(3000)
 for i=0,2999 do begin
  xlabel(i)=(i/3000.)*3.
 endfor
 plot, xlabel, 100.*mirror_coating_silver, min_value=0., charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='OI Mirror Coatings', color=0

 ;Plot of the detector efficiency. Display this as a percentage.
 if (optical_imager_detector eq 0) then begin
  plot, xlabel, 100.*detector_efficiency_1, ystyle=1, yrange=[0,100], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='OI Detector Quantum Efficiency', color=0
 endif
 if (optical_imager_detector eq 1) then begin
  plot, xlabel, 100.*detector_efficiency_2, ystyle=1, yrange=[0,100], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='OI Detector Quantum Efficiency', color=0
 endif
 if (optical_imager_detector eq 2) then begin
  plot, xlabel, 100.*detector_efficiency_3, ystyle=1, yrange=[0,100], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='OI Detector Quantum Efficiency', color=0
 endif

 ;Calculate the throughputs.

 ;Initialize.
 if ((telescope_primary eq 0) or (telescope_primary eq 2) or (telescope_primary eq 3)) then begin
  telescope_mirror=mirror_coating_aluminum
 endif
 if (telescope_primary eq 1) then begin
  telescope_mirror=mirror_coating_gold
 endif
 optical_imager_mirror=mirror_coating_aluminum
 optical_imager_throughput=fltarr(9,3000)

 ;Run through all the filters.
 for i=0,8 do begin
  filter=fltarr(3000)
  filter=filters(i,0:2999)
  
  ;The imager.
  if (optical_imager_detector eq 0) then begin
   detector=detector_efficiency_1(0:2999)
   optical_imager_throughput(i,0:2999)=(telescope_mirror^telescope_surfaces)*(optical_imager_mirror^optical_imager_surfaces)*filter*detector
  endif
  if (optical_imager_detector eq 1) then begin
   detector=detector_efficiency_2(0:2999)
   optical_imager_throughput(i,0:2999)=(telescope_mirror^telescope_surfaces)*(optical_imager_mirror^optical_imager_surfaces)*filter*detector
  endif
  if (optical_imager_detector eq 2) then begin
   detector=detector_efficiency_3(0:2999)
   optical_imager_throughput(i,0:2999)=(telescope_mirror^telescope_surfaces)*(optical_imager_mirror^optical_imager_surfaces)*filter*detector
  endif

 endfor

 ;Plot of the throughputs. Display this as a percentage.
 ;Generate an axis label.
 xlabel=fltarr(3000)
 for i=0,2999 do begin
  xlabel(i)=(i/3000.)*3.
 endfor
 plot, xlabel, 100.*optical_imager_throughput(1,0:2999), yrange=[0,100], charsize=character_size, thick=1,  xtitle='Wavelength (micron)', ytitle='Throughput (%)', title='OI Throughput', color=0
 oplot, xlabel, 100.*optical_imager_throughput(2,0:2999), color=0
 oplot, xlabel, 100.*optical_imager_throughput(3,0:2999), color=0
 oplot, xlabel, 100.*optical_imager_throughput(4,0:2999), color=0
 oplot, xlabel, 100.*optical_imager_throughput(5,0:2999), color=0

 endif
endif

;-----------------------------------------------------------------------------------
;Show the spectrograph setup.
if (uvalue eq 'spectrograph_setup') then begin

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the telescope first.', charsize=size_print, /device, color=0
 endif
 if (initialize_telescope_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 0, /silent
 !p.multi = [0,3,2]
 character_size=size_print*1.5

 ;Plot of the grating efficiency. Display this as a percentage.
 ;Generate an axis label.
 xlabel=fltarr(3000)
 for i=0,2999 do begin
  xlabel(i)=(i/3000.)*3.
 endfor
 plot, xlabel, 100.*grating_efficiency, yrange=[0,100], ystyle=1, charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='MOS Grating Efficiency', background=255, color=0

 ;Plot of the filter bandpasses. Display this as a percentage.
 plot, xlabel, 100.*filters(1,0:2999), yrange=[0,100], ystyle=1, charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Throughput (%)', title='MOS Filter Bandpasses', color=0
 oplot, xlabel, 100.*filters(2,0:2999), color=0
 oplot, xlabel, 100.*filters(3,0:2999), color=0
 oplot, xlabel, 100.*filters(4,0:2999), color=0
 oplot, xlabel, 100.*filters(5,0:2999), color=0
 oplot, xlabel, 100.*filters(6,0:2999), color=0
 oplot, xlabel, 100.*filters(7,0:2999), color=0
 oplot, xlabel, 100.*filters(8,0:2999), color=0

 ;Plot of the mirror coating efficiency.

 ;Generate an axis label.
 xlabel=fltarr(3000)
 for i=0,2999 do begin
  xlabel(i)=(i/3000.)*3.
 endfor
 plot, xlabel, 100.*mirror_coating_gold, yrange=[0,100], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='MOS Mirror Coatings', color=0

 ;Plot of the detector efficiency. Display this as a percentage.
 if (spectrograph_detector eq 0) then begin
  plot, xlabel, 100.*detector_efficiency_1, yrange=[0,100], ystyle=1, charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='MOS Detector Quantum Efficiency', color=0
 endif
 if (spectrograph_detector eq 1) then begin
  plot, xlabel, 100.*detector_efficiency_2, yrange=[0,100], ystyle=1, charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='MOS Detector Quantum Efficiency', color=0
 endif
 if (spectrograph_detector eq 2) then begin
  plot, xlabel, 100.*detector_efficiency_3, yrange=[0,100], ystyle=1, charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Efficiency (%)', title='MOS Detector Quantum Efficiency', color=0
 endif

 ;Calculate the throughputs.

 ;Initialize.
 if ((telescope_primary eq 0) or (telescope_primary eq 2) or (telescope_primary eq 3)) then begin
  telescope_mirror=mirror_coating_aluminum
 endif
 if (telescope_primary eq 1) then begin
  telescope_mirror=mirror_coating_gold
 endif
 spectrograph_mirror=mirror_coating_gold
 spectrograph_throughput=fltarr(9,3000)

 ;Run through all the filters.
 for i=0,8 do begin
  filter=fltarr(3000)
  filter=filters(i,0:2999)
  
  ;The spectrograph.
  if (spectrograph_detector eq 0) then begin
   detector=detector_efficiency_1(0:2999)
   spectrograph_throughput(0,0:2999)=(telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*grating_efficiency*detector
   spectrograph_throughput(i,0:2999)=(telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*filter*detector
  endif
  if (spectrograph_detector eq 1) then begin
   detector=detector_efficiency_2(0:2999)
   spectrograph_throughput(0,0:2999)=(telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*grating_efficiency*detector
   spectrograph_throughput(i,0:2999)=(telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*filter*detector
  endif
  if (spectrograph_detector eq 2) then begin
   detector=detector_efficiency_3(0:2999)
   spectrograph_throughput(0,0:2999)=(telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*grating_efficiency*detector
   spectrograph_throughput(i,0:2999)=(telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*filter*detector
  endif

 endfor

 ;Plot of the throughputs. Display this as a percentage.
 ;Generate an axis label.
 xlabel=fltarr(3000)
 for i=0,2999 do begin
  xlabel(i)=(i/3000.)*3.
 endfor
 plot, xlabel, 100.*spectrograph_throughput(1,0:2999), yrange=[0,100], charsize=character_size, thick=1,  xtitle='Wavelength (micron)', ytitle='Throughput (%)', title='MOS Imaging Throughput', color=0
 oplot, xlabel, 100.*spectrograph_throughput(2,0:2999), color=0
 oplot, xlabel, 100.*spectrograph_throughput(3,0:2999), color=0
 oplot, xlabel, 100.*spectrograph_throughput(4,0:2999), color=0
 oplot, xlabel, 100.*spectrograph_throughput(5,0:2999), color=0
 oplot, xlabel, 100.*spectrograph_throughput(6,0:2999), color=0
 oplot, xlabel, 100.*spectrograph_throughput(7,0:2999), color=0
 oplot, xlabel, 100.*spectrograph_throughput(8,0:2999), color=0

 ;And for the spectrograph.
 plot, xlabel, 100.*spectrograph_throughput(0,0:2999), yrange=[0,100], charsize=character_size, thick=1,  xtitle='Wavelength (micron)', ytitle='Throughput (%)', title='MOS Spectroscopy Throughput', color=0

 endif
endif

;-----------------------------------------------------------------------------------
;Select a target for the optical imager.
if (uvalue eq 'optical_imager_select_target') then begin
 target_flag=optical_imager_flag
 select_target
endif

;-----------------------------------------------------------------------------------
;Select a target for the spectrograph.
if (uvalue eq 'spectrograph_select_target') then begin
 target_flag=spectrograph_flag
 select_target
endif

;-----------------------------------------------------------------------------------
;Take an exposure with the optical imager.
if (uvalue eq 'optical_imager_expose') then begin
 optical_imager_simulation
endif

;----------------------------------------------------------------------------------
;Take an imaging survey with the optical imager.
if (uvalue eq 'optical_imager_survey') then begin

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the telescope first.', charsize=size_print, color=0, /device
 endif
 if (initialize_telescope_done eq 1) then begin

 ;Take several exposures.
 for m=1,3 do begin

  print, m

  ;Galaxies.
  if (telescope_target eq 0) then begin
   x_range=724
   y_range=688
  endif

  ;Stars.
  if (telescope_target eq 1) then begin
   x_range=247
   y_range=247
  endif

  ;Pick a position at random.
  x=157+27+floor(randomu(seed)*x_range)
  y=283+27+floor(randomu(seed)*y_range)

  ;Perform imaging in the primary filter.
  optical_imager_simulation
 
  ;Save the filter wheel location.
  optical_imager_filter_tmp=optical_imager_filter

  ;Now, perform imaging in the comparison filter.
  optical_imager_filter=optical_imager_comparison
  optical_imager_simulation

  ;And return the filter wheel to the original position.
  optical_imager_filter=optical_imager_filter_tmp
  
 endfor

 endif
endif

;-----------------------------------------------------------------------------
;Show the optical imager results.
if (uvalue eq 'optical_imager_results') then begin

 ;Check for initialization.
 if (optical_imager_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must take an exposure first.', charsize=size_print, color=0, /device
 endif
 if (optical_imager_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 0, /silent
 character_size=size_print*1.5

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Reading in the photometry...', charsize=size_print, color=0, /device

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Determine filter label.
  filter_tmp=strarr(9)
  filter_tmp(0)='open'
  filter_tmp(1)='u'
  filter_tmp(2)='b'
  filter_tmp(3)='v'
  filter_tmp(4)='r'
  filter_tmp(5)='i'
  filter_tmp(6)='j'
  filter_tmp(7)='h'
  filter_tmp(8)='k' 

  ;Read the photometry from the file.
  surface_brightness=fltarr(10000)
  surface_brightness_true=surface_brightness
  signal_to_noise=surface_brightness
  bulge_to_total=surface_brightness
  bulge_to_total_true=surface_brightness
  file='./virtual_telescope_results/photometry_optical_imager_'+filter_tmp(optical_imager_filter)+'.dat'
  openr, unit, file, /get_lun
  tmp_1=0
  while not eof(unit) do begin 
   readf, unit, a, b, c, d, e, f, g, h 
   surface_brightness(a)=b
   surface_brightness_true(a)=c
   signal_to_noise(a)=d
   bulge_to_total(a)=e
   bulge_to_total_true(a)=f
   if (surface_brightness(a) ne 0.) then begin
    tmp_1=tmp_1+1
   endif
  endwhile
  close, unit
  free_lun, unit

  ;Display the results.
  !p.multi = [0,3,2]
  erase, 255

  ;Plots.

  ;Dummy plot.
  plot, surface_brightness_true, surface_brightness, color=255

  ;Determine filter label.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'

  ;Generate an axis label.
  xlabel=fltarr(2000)
  for i=0,1999 do begin
   xlabel(i)=20.+15.*(i/2000.)
  endfor 

  ;Galaxies.
  title='OI Galaxies '+tmp(optical_imager_filter)+' Surface Brightness'
  xtitle=tmp(optical_imager_filter)+'(AB) SB true'
  ytitle=tmp(optical_imager_filter)+'(AB) SB observed'
  plot, surface_brightness_true, surface_brightness, psym=4, symsize=1.0, xrange=[20,35], yrange=[20,35], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, surface_brightness_true, surface_brightness_true, psym=4, symsize=0.25, color=0
  oplot, xlabel, xlabel, linestyle=0, color=0

  ;Bulge-to-total ratio.
  title='OI Galaxies '+tmp(optical_imager_filter)+' Bulge-to-Total Ratio'
  xtitle=tmp(optical_imager_filter)+'(AB) SB true'
  ytitle=tmp(optical_imager_filter)+'(AB) B/T observed'
  plot, surface_brightness_true, bulge_to_total, psym=4, symsize=1.0, xrange=[20,35], yrange=[0,1.5], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, surface_brightness_true, bulge_to_total_true, psym=4, symsize=0.25, color=0

  ;Dummy plot.
  plot, surface_brightness_true, surface_brightness, color=255

  ;Signal-to-noise ratio.
  title='OI Galaxies '+tmp(optical_imager_filter)+' Signal-to-Noise Ratio'
  xtitle=tmp(optical_imager_filter)+'(AB) SB true'
  ytitle=tmp(optical_imager_filter)+'(AB) S/N observed (1/pixel)'
  plot, surface_brightness_true, signal_to_noise, psym=4, symsize=1.0, xrange=[20,35], yrange=[1,10000], /ylog, charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0

  ;Print information to the screen.
  xyouts, 30, 657, 'OI Imaging Survey', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device  
  xyouts, 30, 612, 'Galaxy Field', charsize=size_print, color=0, /device 
  xyouts, 30, 597, 'Faint cutoff (H(AB)) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_cutoff)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 597, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 582, 'Added depth (H(AB)) = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_faint)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)
  xyouts, 240, 582, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 567, 'Number of clones = ', charsize=size_print, color=0, /device 
  xyouts, 240, 567, galaxy_multiple, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 552, 'Redshift factor = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_shift)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)
  xyouts, 240, 552, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 537, 'Shrinkage factor = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_shrink)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 537, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 522, 'Correlation (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_correlation)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 522, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 507, 'Bulge radius (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_bulge_radius)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 507, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 492, 'Disk radius (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_disk_radius)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 492, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 477, 'E/S0 bulge-to-total = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_bulge_to_total_1)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 477, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 462, 'Sbc bulge-to-total = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_bulge_to_total_2)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 462, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 447, 'Scd bulge-to-total = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_bulge_to_total_3)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 447, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 432, 'Irr bulge-to-total = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_bulge_to_total_4)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 432, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 417, 'Line width (Angstroms) = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_line_width)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 417, tmp, alignment=1.0, charsize=size_print, color=0, /device

  xyouts, 30, 387, 'Telescope', charsize=size_print, color=0, /device 
  ;Determine the configuration of the telescope.
  tmp=strarr(5)
  tmp(0)='Canada-France-Hawaii'
  tmp(1)='Gemini'
  tmp(2)='Keck'
  tmp(3)='Hubble'
  tmp(4)='Next-Generation Space'
  xyouts, 30, 372, 'Primary = ', charsize=size_print, color=0, /device 
  xyouts, 240, 372, tmp(telescope_primary), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 357, 'Temperature (K) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_temperature)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 357, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 342, 'Mirror roughness (nm RMS) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_roughness)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)  
  xyouts, 240, 342, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 327, 'Number of surfaces = ', charsize=size_print, color=0, /device 
  xyouts, 240, 327, telescope_surfaces, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 312, 'Optics error (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_error)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 312, tmp, alignment=1.0, charsize=size_print, color=0, /device
      
  xyouts, 30, 282, 'Optical Imager', charsize=size_print, color=0, /device
  ;Determine the filters.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  xyouts, 30, 267, 'Filter = ', charsize=size_print, color=0, /device
  xyouts, 240, 267, tmp(optical_imager_filter), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 252, 'Number of surfaces = ', charsize=size_print, color=0, /device 
  xyouts, 240, 252, optical_imager_surfaces, alignment=1.0, charsize=size_print, color=0, /device
  ;Determine properties of the detector.
  tmp=strarr(3)
  tmp(0)='HyViSi'
  tmp(1)='HgCdTe'
  tmp(2)='InSb'
  xyouts, 30, 237, 'Detector type = ', charsize=size_print, color=0, /device 
  xyouts, 240, 237, tmp(optical_imager_detector), alignment=1.0, charsize=size_print, color=0, /device   
  xyouts, 30, 222, 'Pixel (arcsec/pixel) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_pixel)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)   
  xyouts, 240, 222, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 207, 'Readout (e-) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_readout)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)    
  xyouts, 240, 207, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 192, 'Dark (e-/s) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_dark)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)    
  xyouts, 240, 192, tmp, alignment=1.0, charsize=size_print, color=0, /device   
  xyouts, 30, 177, 'Gain (e-/DU) = ', charsize=size_print, color=0, /device 
  tmp=string(optical_imager_gain)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)   
  xyouts, 240, 177, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 162, 'Well depth (bits) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_well)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,2)    
  xyouts, 240, 162, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 147, 'Unit exposure (s) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_exposure_unit)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,8)    
  xyouts, 240, 147, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 132, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 132, floor(optical_imager_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 117, 'Number of galaxies = ', charsize=size_print, color=0, /device
  tmp=string(tmp_1)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)    
  xyouts, 240, 117, tmp, alignment=1.0, charsize=size_print, color=0, /device
 
 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;Determine filter label.
  filter_tmp=strarr(9)
  filter_tmp(0)='open'
  filter_tmp(1)='u'
  filter_tmp(2)='b'
  filter_tmp(3)='v'
  filter_tmp(4)='r'
  filter_tmp(5)='i'
  filter_tmp(6)='j'
  filter_tmp(7)='h'
  filter_tmp(8)='k'

  ;Determine the CMD.

  ;ZAMS.
  colour_magnitude_1_tmp=fltarr(9,2000)
  colour_magnitude_1_tmp(3,0:1999)=colour_magnitude_1(0:1999)*star_colour_shift_1
  colour_magnitude_1_tmp(4,0:1999)=colour_magnitude_1(0:1999)
  colour_magnitude_1_tmp(5,0:1999)=0.
  colour_magnitude_1_tmp(6,0:1999)=-1.*(colour_magnitude_1(0:1999)*star_colour_shift_2)
  colour_magnitude_1_tmp(7,0:1999)=-1.*(colour_magnitude_1(0:1999)*star_colour_shift_3)
  colour_magnitude_1_tmp(8,0:1999)=-1.*(colour_magnitude_1(0:1999)*star_colour_shift_4) 

  ;White dwarfs.
  colour_magnitude_2_tmp=fltarr(9,2000)
  colour_magnitude_2_tmp(3,0:1999)=colour_magnitude_2(0:1999)*star_colour_shift_1
  colour_magnitude_2_tmp(4,0:1999)=colour_magnitude_2(0:1999)
  colour_magnitude_2_tmp(5,0:1999)=0.
  colour_magnitude_2_tmp(6,0:1999)=-1.*(colour_magnitude_2(0:1999)*star_colour_shift_2)
  colour_magnitude_2_tmp(7,0:1999)=-1.*(colour_magnitude_2(0:1999)*star_colour_shift_3)
  colour_magnitude_2_tmp(8,0:1999)=-1.*(colour_magnitude_2(0:1999)*star_colour_shift_4)   
 
  ;Read the photometry from the files.

  ;Comparison filter.
  photometry_comparison=fltarr(20000)
  photometry_true_comparison=photometry_comparison
  file='./virtual_telescope_results/photometry_optical_imager_'+filter_tmp(optical_imager_comparison)+'.dat'
  openr, unit, file, /get_lun
  tmp_1=0
  while not eof(unit) do begin 
   readf, unit, a, b, c, d, e, f, g, h 
   photometry_comparison(a)=g
   photometry_true_comparison(a)=h
   if (photometry_comparison(a) ne 0.) then begin
    tmp_1=tmp_1+1
   endif
  endwhile
  close, unit
  free_lun, unit 

  ;Primary filter.
  photometry_primary=fltarr(20000)
  photometry_true_primary=photometry_primary
  file='./virtual_telescope_results/photometry_optical_imager_'+filter_tmp(optical_imager_filter)+'.dat'
  openr, unit, file, /get_lun
  while not eof(unit) do begin 
   readf, unit, a, b, c, d, e, f, g, h 
   photometry_primary(a)=g
   photometry_true_primary(a)=h
  endwhile
  close, unit
  free_lun, unit

  ;Display the results.
  !p.multi = [0,3,2]
  erase, 255

  ;Plots.

  ;Dummy plot.
  plot, photometry_true_comparison, photometry_comparison, color=255

  ;Determine the filter.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'

  ;Generate an axis label.
  xlabel=fltarr(2000)
  for i=0,1999 do begin
   xlabel(i)=20.+20.*(i/2000.)
  endfor

  ;Comparison.
  title='OI Stars '+tmp(optical_imager_comparison)+' Comparison Photometry'
  xtitle=tmp(optical_imager_comparison)+'(AB) true'
  ytitle=tmp(optical_imager_comparison)+'(AB) observed'
  plot, photometry_true_comparison, photometry_comparison, psym=4, symsize=1.0, xrange=[20,35], yrange=[20,35], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, photometry_true_comparison, photometry_true_comparison, psym=4, symsize=0.25, color=0
  oplot, xlabel, xlabel, linestyle=0, color=0

  ;Primary.
  title='OI Stars '+tmp(optical_imager_filter)+' Primary Photometry'
  xtitle=tmp(optical_imager_filter)+'(AB) true'
  ytitle=tmp(optical_imager_filter)+'(AB) observed'
  plot, photometry_true_primary, photometry_primary, psym=4, symsize=1.0, xrange=[20,35], yrange=[20,35], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, photometry_true_primary, photometry_true_primary, psym=4, symsize=0.25, color=0
  oplot, xlabel, xlabel, linestyle=0, color=0

  ;Dummy plot.
  plot, photometry_true_comparison, photometry_comparison, color=255

  ;Generate an axis label.
  xlabel=fltarr(2000)
  for i=0,1999 do begin
   xlabel(i)=i/40.
  endfor

  ;Comparison-Primary.
  title='OI Stars ('+tmp(optical_imager_comparison)+'-'+tmp(optical_imager_filter)+')(AB) Colours'
  xtitle=tmp(optical_imager_filter)+'(AB)'
  ytitle='('+tmp(optical_imager_comparison)+'-'+tmp(optical_imager_filter)+')(AB)'
  plot, photometry_true_primary, photometry_comparison-photometry_primary, psym=4, symsize=1.0, xrange=[20,35], yrange=[-2,6], ystyle=1, charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, photometry_true_primary, photometry_true_comparison-photometry_true_primary, psym=4, symsize=0.25, color=0
  oplot, xlabel, colour_magnitude_1_tmp(optical_imager_comparison,0:1999)-colour_magnitude_1_tmp(optical_imager_filter,0:1999), linestyle=0, color=0
  oplot, xlabel, colour_magnitude_2_tmp(optical_imager_comparison,0:1999)-colour_magnitude_2_tmp(optical_imager_filter,0:1999), linestyle=2, color=0

  ;Print information to the screen.
  xyouts, 30, 657, 'OI Imaging Survey', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device  
  xyouts, 30, 612, 'Star Field', charsize=size_print, color=0, /device 
  xyouts, 30, 597, 'Faint cutoff (I(AB)) = ', charsize=size_print, color=0, /device
  tmp=string(star_cutoff)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 597, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 582, 'Added depth (I(AB)) = ', charsize=size_print, color=0, /device 
  tmp=string(star_faint)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)
  xyouts, 240, 582, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 567, 'Number of clones = ', charsize=size_print, color=0, /device 
  xyouts, 240, 567, star_multiple, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 552, 'Correlation (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(star_correlation)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 552, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 537, 'Bright cutoff (I(AB)) = ', charsize=size_print, color=0, /device
  tmp=string(star_white_bright)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4) 
  xyouts, 240, 537, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 522, 'Fraction = ', charsize=size_print, color=0, /device
  tmp=string(star_white_fraction)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 522, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 507, 'Distance modulus = ', charsize=size_print, color=0, /device
  tmp=string(star_distance_modulus)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4) 
  xyouts, 240, 507, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 492, 'V-I colour shift = ', charsize=size_print, color=0, /device
  tmp=string(star_colour_shift_1)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 492, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 477, 'I-J colour shift = ', charsize=size_print, color=0, /device 
  tmp=string(star_colour_shift_2)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 477, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 462, 'I-H colour shift = ', charsize=size_print, color=0, /device
  tmp=string(star_colour_shift_3)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)  
  xyouts, 240, 462, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 447, 'I-K colour shift = ', charsize=size_print, color=0, /device
  tmp=string(star_colour_shift_4)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 447, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 432, 'Brightness (I(AB)) = ', charsize=size_print, color=0, /device 
  tmp=string(star_surface_brightness)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4) 
  xyouts, 240, 432, tmp, alignment=1.0, charsize=size_print, color=0, /device

  xyouts, 30, 402, 'Telescope', charsize=size_print, color=0, /device 
  ;Determine the configuration of the telescope.
  tmp=strarr(5)
  tmp(0)='Canada-France-Hawaii'
  tmp(1)='Gemini'
  tmp(2)='Keck'
  tmp(3)='Hubble'
  tmp(4)='Next-Generation Space'
  xyouts, 30, 387, 'Primary = ', charsize=size_print, color=0, /device 
  xyouts, 240, 387, tmp(telescope_primary), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 372, 'Temperature (K) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_temperature)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 372, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 357, 'Mirror roughness (nm RMS) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_roughness)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)  
  xyouts, 240, 357, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 342, 'Number of surfaces = ', charsize=size_print, color=0, /device 
  xyouts, 240, 342, telescope_surfaces, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 327, 'Optics error (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_error)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 327, tmp, alignment=1.0, charsize=size_print, color=0, /device
      
  xyouts, 30, 297, 'Optical Imager', charsize=size_print, color=0, /device
  ;Determine the filters.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  xyouts, 30, 282, 'Primary filter = ', charsize=size_print, color=0, /device
  xyouts, 240, 282, tmp(optical_imager_filter), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 267, 'Comparison filter = ', charsize=size_print, color=0, /device 
  xyouts, 240, 267, tmp(optical_imager_comparison), alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 252, 'Number of surfaces = ', charsize=size_print, color=0, /device 
  xyouts, 240, 252, optical_imager_surfaces, alignment=1.0, charsize=size_print, color=0, /device
  ;Determine properties of the detector.
  tmp=strarr(3)
  tmp(0)='HyViSi'
  tmp(1)='HgCdTe'
  tmp(2)='InSb'
  xyouts, 30, 237, 'Detector type = ', charsize=size_print, color=0, /device 
  xyouts, 240, 237, tmp(optical_imager_detector), alignment=1.0, charsize=size_print, color=0, /device   
  xyouts, 30, 222, 'Pixel (arcsec/pixel) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_pixel)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)   
  xyouts, 240, 222, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 207, 'Readout (e-) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_readout)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)    
  xyouts, 240, 207, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 192, 'Dark (e-/s) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_dark)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)    
  xyouts, 240, 192, tmp, alignment=1.0, charsize=size_print, color=0, /device   
  xyouts, 30, 177, 'Gain (e-/DU) = ', charsize=size_print, color=0, /device 
  tmp=string(optical_imager_gain)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)   
  xyouts, 240, 177, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 162, 'Well depth (bits) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_well)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,2)    
  xyouts, 240, 162, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 147, 'Unit exposure (s) = ', charsize=size_print, color=0, /device
  tmp=string(optical_imager_exposure_unit)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,8)    
  xyouts, 240, 147, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 132, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 132, floor(optical_imager_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 117, 'Number of stars = ', charsize=size_print, color=0, /device
  tmp=string(tmp_1)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)    
  xyouts, 240, 117, tmp, alignment=1.0, charsize=size_print, color=0, /device

 endif

 endif
endif

;-----------------------------------------------------------------------------------
;Take an exposure with the infrared camera.
if (uvalue eq 'infrared_camera_expose') then begin
 infrared_camera_simulation
endif

;----------------------------------------------------------------------------------
;Take an imaging survey with the infrared camera.
if (uvalue eq 'infrared_camera_survey') then begin

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the telescope first.', charsize=size_print, color=0, /device
 endif
 if (initialize_telescope_done eq 1) then begin

 ;Take several exposures.
 for m=1,3 do begin

  print, m

  ;Galaxies.
  if (telescope_target eq 0) then begin
   x_range=724
   y_range=688
  endif

  ;Stars.
  if (telescope_target eq 1) then begin
   x_range=247
   y_range=247
  endif

  ;Pick a position at random.
  x=157+27+floor(randomu(seed)*x_range)
  y=283+27+floor(randomu(seed)*y_range)

  ;Perform imaging in the primary filter.
  infrared_camera_simulation
 
  ;Save the filter wheel location.
  spectrograph_filter_tmp=spectrograph_filter

  ;Now, perform imaging in the comparison filter.
  spectrograph_filter=spectrograph_comparison
  infrared_camera_simulation

  ;And return the filter wheel to the original position.
  spectrograph_filter=spectrograph_filter_tmp

 endfor

 endif
endif

;-----------------------------------------------------------------------------
;Show the infrared camera results.
if (uvalue eq 'infrared_camera_results') then begin

 ;Check for initialization.
 if (infrared_camera_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must take an exposure first.', charsize=size_print, color=0, /device
 endif
 if (infrared_camera_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 0, /silent
 character_size=size_print*1.5

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Reading in the photometry ...', charsize=size_print, color=0, /device

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Determine filter label.
  filter_tmp=strarr(9)
  filter_tmp(0)='open'
  filter_tmp(1)='u'
  filter_tmp(2)='b'
  filter_tmp(3)='v'
  filter_tmp(4)='r'
  filter_tmp(5)='i'
  filter_tmp(6)='j'
  filter_tmp(7)='h'
  filter_tmp(8)='k' 

  ;Read the photometry from the file.
  surface_brightness=fltarr(20000)
  surface_brightness_true=surface_brightness
  signal_to_noise=surface_brightness
  bulge_to_total=surface_brightness
  bulge_to_total_true=surface_brightness
  file='./virtual_telescope_results/photometry_spectrograph_'+filter_tmp(spectrograph_filter)+'.dat'
  openr, unit, file, /get_lun
  tmp_1=0
  while not eof(unit) do begin 
   readf, unit, a, b, c, d, e, f, g, h 
   surface_brightness(a)=b
   surface_brightness_true(a)=c
   signal_to_noise(a)=d
   bulge_to_total(a)=e
   bulge_to_total_true(a)=f
   if (surface_brightness(a) ne 0.) then begin
    tmp_1=tmp_1+1
   endif
  endwhile
  close, unit
  free_lun, unit

  ;Display the results.
  !p.multi = [0,3,2]
  erase, 255

  ;Plots.

  ;Dummy plot.
  plot, surface_brightness_true, surface_brightness, color=255

  ;Determine the filter.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'

  ;Generate an axis label.
  xlabel=fltarr(2000)
  for i=0,1999 do begin
   xlabel(i)=20.+20.*(i/2000.)
  endfor 

  ;Galaxies.
  title='MOS Galaxies '+tmp(spectrograph_filter)+' Surface Brightness'
  xtitle=tmp(spectrograph_filter)+'(AB) SB true'
  ytitle=tmp(spectrograph_filter)+'(AB) SB observed'
  plot, surface_brightness_true, surface_brightness, psym=4, symsize=1.0, xrange=[20,35], yrange=[20,35], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, surface_brightness_true, surface_brightness_true, psym=4, symsize=0.25, color=0
  oplot, xlabel, xlabel, linestyle=0, color=0

  ;Bulge-to-total ratio.
  title='MOS Galaxies '+tmp(spectrograph_filter)+' Bulge-to-Total Ratio'
  xtitle=tmp(spectrograph_filter)+'(AB) SB true'
  ytitle=tmp(spectrograph_filter)+'(AB) B/T observed'
  plot, surface_brightness_true, bulge_to_total, psym=4, symsize=1.0, xrange=[20,35], yrange=[0,1.5], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, surface_brightness_true, bulge_to_total_true, psym=4, symsize=0.25, color=0

  ;Dummy plot.
  plot, surface_brightness_true, surface_brightness, color=255

  ;Signal-to-noise ratio.
  title='MOS Galaxies '+tmp(spectrograph_filter)+' Signal-to-Noise Ratio'
  xtitle=tmp(spectrograph_filter)+'(AB) SB true'
  ytitle=tmp(spectrograph_filter)+'(AB) S/N observed (1/pixel)'
  plot, surface_brightness_true, signal_to_noise, psym=4, symsize=1.0, xrange=[20,35], yrange=[1,10000], /ylog, charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0

  ;Print information to the screen.
  xyouts, 30, 657, 'MOS Imaging Survey', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device  
  xyouts, 30, 612, 'Galaxy Field', charsize=size_print, color=0, /device 
  xyouts, 30, 597, 'Faint cutoff (H(AB)) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_cutoff)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 597, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 582, 'Added depth (H(AB)) = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_faint)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)
  xyouts, 240, 582, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 567, 'Number of clones = ', charsize=size_print, color=0, /device 
  xyouts, 240, 567, galaxy_multiple, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 552, 'Redshift factor = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_shift)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)
  xyouts, 240, 552, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 537, 'Shrinkage factor = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_shrink)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 537, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 522, 'Correlation (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_correlation)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 522, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 507, 'Bulge radius (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_bulge_radius)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 507, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 492, 'Disk radius (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_disk_radius)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 492, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 477, 'E/S0 bulge-to-total = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_bulge_to_total_1)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 477, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 462, 'Sbc bulge-to-total = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_bulge_to_total_2)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 462, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 447, 'Scd bulge-to-total = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_bulge_to_total_3)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 447, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 432, 'Irr bulge-to-total = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_bulge_to_total_4)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 432, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 417, 'Line width (Angstroms) = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_line_width)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 417, tmp, alignment=1.0, charsize=size_print, color=0, /device

  xyouts, 30, 387, 'Telescope', charsize=size_print, color=0, /device 
  ;Determine the configuration of the telescope.
  tmp=strarr(5)
  tmp(0)='Canada-France-Hawaii'
  tmp(1)='Gemini'
  tmp(2)='Keck'
  tmp(3)='Hubble'
  tmp(4)='Next-Generation Space'
  xyouts, 30, 372, 'Primary = ', charsize=size_print, color=0, /device 
  xyouts, 240, 372, tmp(telescope_primary), alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 357, 'Temperature (K) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_temperature)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 357, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 342, 'Mirror roughness (nm RMS) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_roughness)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)  
  xyouts, 240, 342, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 327, 'Number of surfaces = ', charsize=size_print, color=0, /device 
  xyouts, 240, 327, telescope_surfaces, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 312, 'Optics error (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_error)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 312, tmp, alignment=1.0, charsize=size_print, color=0, /device
      
  xyouts, 30, 282, 'Multi-Object Spectrograph', charsize=size_print, color=0, /device
  ;Determine the filters.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  xyouts, 30, 267, 'Filter = ', charsize=size_print, color=0, /device
  xyouts, 240, 267, tmp(spectrograph_filter), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 252, 'Number of surfaces = ', charsize=size_print, color=0, /device 
  xyouts, 240, 252, spectrograph_surfaces, alignment=1.0, charsize=size_print, color=0, /device
  ;Determine properties of the detector.
  tmp=strarr(3)
  tmp(0)='HyViSi'
  tmp(1)='HgCdTe'
  tmp(2)='InSb'
  xyouts, 30, 237, 'Detector type = ', charsize=size_print, color=0, /device 
  xyouts, 240, 237, tmp(spectrograph_detector), alignment=1.0, charsize=size_print, color=0, /device   
  xyouts, 30, 222, 'Pixel (arcsec/pixel) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_pixel)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)   
  xyouts, 240, 222, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 207, 'Readout (e-) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_readout)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)    
  xyouts, 240, 207, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 192, 'Dark (e-/s) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_dark)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)    
  xyouts, 240, 192, tmp, alignment=1.0, charsize=size_print, color=0, /device   
  xyouts, 30, 177, 'Gain (e-/DU) = ', charsize=size_print, color=0, /device 
  tmp=string(spectrograph_gain)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)   
  xyouts, 240, 177, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 162, 'Well depth (bits) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_well)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,2)    
  xyouts, 240, 162, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 147, 'Unit exposure (s) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_exposure_unit)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,8)    
  xyouts, 240, 147, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 132, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 132, floor(optical_imager_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 117, 'Number of galaxies = ', charsize=size_print, color=0, /device
  tmp=string(tmp_1)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)    
  xyouts, 240, 117, tmp, alignment=1.0, charsize=size_print, color=0, /device

 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;Determine filter label.
  filter_tmp=strarr(9)
  filter_tmp(0)='open'
  filter_tmp(1)='u'
  filter_tmp(2)='b'
  filter_tmp(3)='v'
  filter_tmp(4)='r'
  filter_tmp(5)='i'
  filter_tmp(6)='j'
  filter_tmp(7)='h'
  filter_tmp(8)='k'

  ;Determine the CMD.

  ;ZAMS.
  colour_magnitude_1_tmp=fltarr(9,2000)
  colour_magnitude_1_tmp(3,0:1999)=colour_magnitude_1(0:1999)*star_colour_shift_1
  colour_magnitude_1_tmp(4,0:1999)=colour_magnitude_1(0:1999)
  colour_magnitude_1_tmp(5,0:1999)=0.
  colour_magnitude_1_tmp(6,0:1999)=-1.*(colour_magnitude_1(0:1999)*star_colour_shift_2)
  colour_magnitude_1_tmp(7,0:1999)=-1.*(colour_magnitude_1(0:1999)*star_colour_shift_3)
  colour_magnitude_1_tmp(8,0:1999)=-1.*(colour_magnitude_1(0:1999)*star_colour_shift_4)  

  ;White dwarfs.
  colour_magnitude_2_tmp=fltarr(9,2000)
  colour_magnitude_2_tmp(3,0:1999)=colour_magnitude_2(0:1999)*star_colour_shift_1
  colour_magnitude_2_tmp(4,0:1999)=colour_magnitude_2(0:1999)
  colour_magnitude_2_tmp(5,0:1999)=0.
  colour_magnitude_2_tmp(6,0:1999)=-1.*(colour_magnitude_2(0:1999)*star_colour_shift_2)
  colour_magnitude_2_tmp(7,0:1999)=-1.*(colour_magnitude_2(0:1999)*star_colour_shift_3)
  colour_magnitude_2_tmp(8,0:1999)=-1.*(colour_magnitude_2(0:1999)*star_colour_shift_4)  
 
  ;Read the photometry from the files.

  ;Comparison filter.
  photometry_comparison=fltarr(20000)
  photometry_true_comparison=photometry_comparison
  file='./virtual_telescope_results/photometry_spectrograph_'+filter_tmp(spectrograph_comparison)+'.dat'
  openr, unit, file, /get_lun
  tmp_1=0
  while not eof(unit) do begin 
   readf, unit, a, b, c, d, e, f, g, h 
   photometry_comparison(a)=g
   photometry_true_comparison(a)=h
   if (photometry_comparison(a) ne 0.) then begin
    tmp_1=tmp_1+1
   endif
  endwhile
  close, unit
  free_lun, unit 

  ;Primary filter.
  photometry_primary=fltarr(20000)
  photometry_true_primary=photometry_primary
  file='./virtual_telescope_results/photometry_spectrograph_'+filter_tmp(spectrograph_filter)+'.dat'
  openr, unit, file, /get_lun
  while not eof(unit) do begin 
   readf, unit, a, b, c, d, e, f, g, h 
   photometry_primary(a)=g
   photometry_true_primary(a)=h
  endwhile
  close, unit
  free_lun, unit

  ;Display the results.
  !p.multi = [0,3,2]
  erase, 255

  ;Plots.

  ;Dummy plot.
  plot, photometry_true_comparison, photometry_comparison, color=255

  ;Determine the filter.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'

  ;Generate an axis label.
  xlabel=fltarr(2000)
  for i=0,1999 do begin
   xlabel(i)=20.+20.*(i/2000.)
  endfor

  ;Comparison.
  title='MOS Stars '+tmp(spectrograph_comparison)+' Comparison Photometry'
  xtitle=tmp(spectrograph_comparison)+'(AB) true'
  ytitle=tmp(spectrograph_comparison)+'(AB) observed'
  plot, photometry_true_comparison, photometry_comparison, psym=4, symsize=1.0, xrange=[20,35], yrange=[20,35], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, photometry_true_comparison, photometry_true_comparison, psym=4, symsize=0.25, color=0
  oplot, xlabel, xlabel, linestyle=0, color=0

  ;Primary.
  title='MOS Stars '+tmp(spectrograph_filter)+' Primary Photometry'
  xtitle=tmp(spectrograph_filter)+'(AB) true'
  ytitle=tmp(spectrograph_filter)+'(AB) observed'
  plot, photometry_true_primary, photometry_primary, psym=4, symsize=1.0, xrange=[20,35], yrange=[20,35], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, photometry_true_primary, photometry_true_primary, psym=4, symsize=0.25, color=0
  oplot, xlabel, xlabel, linestyle=0, color=0

  ;Dummy plot.
  plot, photometry_true_comparison, photometry_comparison, color=255

  ;Generate an axis label.
  xlabel=fltarr(2000)
  for i=0,1999 do begin
   xlabel(i)=i/40.
  endfor

  ;Residuals.  
  title='MOS Stars '+tmp(spectrograph_filter)+' Residuals'
  xtitle=tmp(spectrograph_filter)+'(AB) true'
  ytitle=tmp(spectrograph_filter)+'(AB) residual'
  plot, photometry_true_primary, photometry_primary-photometry_true_primary, psym=4, symsize=1.0, xrange=[20,35], yrange=[-1,1], charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  
  ;Comparison-Primary.
  title='MOS Stars ('+tmp(spectrograph_comparison)+'-'+tmp(spectrograph_filter)+')(AB) Colours'
  xtitle=tmp(spectrograph_filter)+'(AB)'
  ytitle='('+tmp(spectrograph_comparison)+'-'+tmp(spectrograph_filter)+')(AB)'
  plot, photometry_true_primary, photometry_comparison-photometry_primary, psym=4, symsize=1.0, xrange=[20,35], yrange=[-2,6], ystyle=1, charsize=character_size, thick=1, xtitle=xtitle, ytitle=ytitle, title=title, color=0
  ;oplot, photometry_true_primary, photometry_true_comparison-photometry_true_primary, psym=4, symsize=0.25, color=0
  oplot, xlabel, colour_magnitude_1_tmp(spectrograph_comparison,0:1999)-colour_magnitude_1_tmp(spectrograph_filter,0:1999), linestyle=0, color=0
  oplot, xlabel, colour_magnitude_2_tmp(spectrograph_comparison,0:1999)-colour_magnitude_2_tmp(spectrograph_filter,0:1999), linestyle=2, color=0

  ;Print information to the screen.
  xyouts, 30, 657, 'MOS Imaging Survey', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device  
  xyouts, 30, 612, 'Star Field', charsize=size_print, color=0, /device 
  xyouts, 30, 597, 'Faint cutoff (I(AB)) = ', charsize=size_print, color=0, /device
  tmp=string(star_cutoff)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 597, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 582, 'Added depth (I(AB)) = ', charsize=size_print, color=0, /device 
  tmp=string(star_faint)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)
  xyouts, 240, 582, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 567, 'Number of clones = ', charsize=size_print, color=0, /device 
  xyouts, 240, 567, star_multiple, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 552, 'Correlation (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(star_correlation)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 552, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 537, 'Bright cutoff (I(AB)) = ', charsize=size_print, color=0, /device
  tmp=string(star_white_bright)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4) 
  xyouts, 240, 537, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 522, 'Fraction = ', charsize=size_print, color=0, /device
  tmp=string(star_white_fraction)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 522, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 507, 'Distance modulus = ', charsize=size_print, color=0, /device
  tmp=string(star_distance_modulus)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4) 
  xyouts, 240, 507, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 492, 'V-I colour shift = ', charsize=size_print, color=0, /device
  tmp=string(star_colour_shift_1)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 492, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 477, 'I-J colour shift = ', charsize=size_print, color=0, /device 
  tmp=string(star_colour_shift_2)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 477, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 462, 'I-H colour shift = ', charsize=size_print, color=0, /device
  tmp=string(star_colour_shift_3)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)  
  xyouts, 240, 462, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 447, 'I-K colour shift = ', charsize=size_print, color=0, /device
  tmp=string(star_colour_shift_4)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3) 
  xyouts, 240, 447, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 432, 'Brightness (I(AB)) = ', charsize=size_print, color=0, /device 
  tmp=string(star_surface_brightness)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4) 
  xyouts, 240, 432, tmp, alignment=1.0, charsize=size_print, color=0, /device

  xyouts, 30, 402, 'Telescope', charsize=size_print, color=0, /device 
  ;Determine the configuration of the telescope.
  tmp=strarr(5)
  tmp(0)='Canada-France-Hawaii'
  tmp(1)='Gemini'
  tmp(2)='Keck'
  tmp(3)='Hubble'
  tmp(4)='Next-Generation Space'
  xyouts, 30, 387, 'Primary = ', charsize=size_print, color=0, /device 
  xyouts, 240, 387, tmp(telescope_primary), alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 372, 'Temperature (K) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_temperature)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 372, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 357, 'Mirror roughness (nm RMS) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_roughness)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)  
  xyouts, 240, 357, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 342, 'Number of surfaces = ', charsize=size_print, color=0, /device 
  xyouts, 240, 342, telescope_surfaces, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 327, 'Optics error (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(telescope_error)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)  
  xyouts, 240, 327, tmp, alignment=1.0, charsize=size_print, color=0, /device
      
  xyouts, 30, 297, 'Multi-Object Spectrograph', charsize=size_print, color=0, /device
  ;Determine the filters.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  xyouts, 30, 282, 'Primary filter = ', charsize=size_print, color=0, /device
  xyouts, 240, 282, tmp(spectrograph_filter), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 267, 'Comparison filter = ', charsize=size_print, color=0, /device 
  xyouts, 240, 267, tmp(spectrograph_comparison), alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 252, 'Number of surfaces = ', charsize=size_print, color=0, /device 
  xyouts, 240, 252, spectrograph_surfaces, alignment=1.0, charsize=size_print, color=0, /device
  ;Determine properties of the detector.
  tmp=strarr(3)
  tmp(0)='HyViSi'
  tmp(1)='HgCdTe'
  tmp(2)='InSb'
  xyouts, 30, 237, 'Detector type = ', charsize=size_print, color=0, /device 
  xyouts, 240, 237, tmp(spectrograph_detector), alignment=1.0, charsize=size_print, color=0, /device   
  xyouts, 30, 222, 'Pixel (arcsec/pixel) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_pixel)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)   
  xyouts, 240, 222, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 207, 'Readout (e-) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_readout)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)    
  xyouts, 240, 207, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 192, 'Dark (e-/s) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_dark)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)    
  xyouts, 240, 192, tmp, alignment=1.0, charsize=size_print, color=0, /device   
  xyouts, 30, 177, 'Gain (e-/DU) = ', charsize=size_print, color=0, /device 
  tmp=string(spectrograph_gain)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,3)   
  xyouts, 240, 177, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 162, 'Well depth (bits) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_well)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,2)    
  xyouts, 240, 162, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 147, 'Unit exposure (s) = ', charsize=size_print, color=0, /device
  tmp=string(spectrograph_exposure_unit)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,8)    
  xyouts, 240, 147, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 132, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 132, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 117, 'Number of stars = ', charsize=size_print, color=0, /device
  tmp=string(tmp_1)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)    
  xyouts, 240, 117, tmp, alignment=1.0, charsize=size_print, color=0, /device

 endif

 endif
endif

;-----------------------------------------------------------------------------------
;Run the spectrograph simulation.
if (uvalue eq 'spectrograph_single_slit') then begin
 spectrograph_simulation
endif

;-----------------------------------------------------------------------------------
;Run the integral field unit simulation.
if (uvalue eq 'spectrograph_integral_field_unit') then begin
 spectrograph_integral_field_unit_simulation
endif

;-----------------------------------------------------------------------------------
;Select targets for study in a spectrographic survey.
if (uvalue eq 'spectrograph_survey') then begin
 spectrograph_survey
endif

;------------------------------------------------------------------------------------
;Reset the photometry files.
if (uvalue eq 'reset_photometry') then begin

 ;Determine filter label.
 filter_tmp=strarr(9)
 filter_tmp(0)='open'
 filter_tmp(1)='u'
 filter_tmp(2)='b'
 filter_tmp(3)='v'
 filter_tmp(4)='r'
 filter_tmp(5)='i'
 filter_tmp(6)='j'
 filter_tmp(7)='h'
 filter_tmp(8)='k'

 ;Initialize the Optical Imager files.
 for i=0,8 do begin
  get_lun, unit
  openw, unit, './virtual_telescope_results/photometry_optical_imager_'+filter_tmp(i)+'.dat'
  for j=0,9999 do begin
   printf, unit, j, 0., 0., 0., 0., 0., 0., 0.
  endfor
  close, unit
  free_lun, unit
 endfor

 ;And the infrared camera files.
 for i=0,8 do begin
  get_lun, unit
  openw, unit, './virtual_telescope_results/photometry_spectrograph_'+filter_tmp(i)+'.dat'
  for j=0,9999 do begin
   printf, unit, j, 0., 0., 0., 0., 0., 0., 0.
  endfor
  close, unit
  free_lun, unit
 endfor

endif

;----------------------------------------------------------------------------------
;Show an expanded version of the spectrum.
if (uvalue eq 'spectrograph_single_slit_spectrum') then begin

 ;Check for initialization.
 if ((spectrum_single_done eq 0) or (spectrum_multiplex_done eq 0)) then begin
  wshow, window_id
  erase, 255
  xyouts, 375, 365, 'You must take a spectrum first.', charsize=size_print, color=0, /device
 endif
 if ((spectrum_single_done eq 1) or (spectrum_multiplex_done eq 1)) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 !p.multi = [0,3,2]
 character_size=size_print*1.5

 ;Generate an axis label.
 r=floor(spectrograph_resolution)
 xlabel=fltarr(r)
 for i=0,r-1 do begin
  xlabel(i)=0.+(i/float(r))*3.
 endfor

 ;Determine the normalization.
 tmp=max(spectrum_true_extract)
 if (tmp le 0.) then begin
  tmp=1.
 endif

 ;Plot.
 plot, xlabel, spectrum_extract/tmp, xmargin=[15,-100], yrange=[0,1], charsize=character_size, thick=1, xtitle='Wavelength (micron)', ytitle='Intensity',title='Extracted Spectrum', color=0
 oplot, xlabel, spectrum_true_extract/tmp, linestyle=2, color=0

 endif
endif

;-----------------------------------------------------------------------------------
;Show the output spectrum from the integral field unit.
if (uvalue eq 'spectrograph_integral_field_unit_spectrum') then begin

 ;Check for initialization.
 if (spectrum_integral_field_unit_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must take a spectrum first.', charsize=size_print, color=0, /device
 endif
 if (spectrum_integral_field_unit_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 3, /silent

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Reading in the spectrum ...', charsize=size_print, color=0, /device

 ;Read in the spectrum and footprint.
 tmp_1=fltarr(5200,4000)
 tmp_1=readfits('./virtual_telescope_results/spectrum_slicer.fits', /silent)
 tmp_2=fltarr(1040,500)
 tmp_2=readfits('./virtual_telescope_results/footprint_slicer.fits', /silent)

 ;Now, normalize the spectrum and footprint to have a peak of 255.

 ;Spectrum.
 tmp_1=(tmp_1-min(tmp_1))^0.1
 tmp=max(tmp_1)
 if (tmp eq 0.) then begin
  tmp=1.
 endif

 ;Footprint.
 tmp_1=255.*tmp_1/tmp
 tmp=max(tmp_2)
 if (tmp eq 0.) then begin
  tmp=1.
 endif
 tmp_2=255.*tmp_2/tmp

 ;Display the images. Note the length of the display is 900.
 erase, 255
 tmp=congrid(tmp_2,floor(1040/2.6),floor(800/2.6))
 tv, tmp, 33, 174
 tmp=congrid(tmp_1,floor(5200/13),floor(4000/13))
 tv, tmp, 466, 174

 ;Label the screen.
 xyouts, 33, 512, 'MOS Integral Field Unit Footprint', charsize=size_print, color=0, /device
 xyouts, 33, 497, '(5200 pixels X 4000 pixels)', charsize=size_print, color=0,  /device
 xyouts, 466, 512, 'MOS Integral Field Unit Spectrum', charsize=size_print, color=0, /device
 xyouts, 466, 497, '(5200 pixels X 4000 pixels)', charsize=size_print, color=0,  /device

 endif
endif

;-----------------------------------------------------------------------------------
;Show the output spectra from the different spectrograph configurations.
if (uvalue eq 'spectrograph_spectra') then begin

 ;Check for initialization.
 if (spectrum_multiplex_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must take multiplexed spectra first.', charsize=size_print, color=0, /device
 endif
 if (spectrum_multiplex_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 3, /silent

 ;Print a message to the screen.
 wshow, window_id
 erase, 255
 xyouts, 350, 365, 'Reading in the spectra ...', charsize=size_print, color=0, /device

 ;Read in the input focal plane masks.
 focal_mask_slits=fltarr(1100,1300)
 focal_mask_slits=readfits('./virtual_telescope_results/focal_mask_slits.fits', /silent)
 focal_mask_fibers=fltarr(1100,1300)
 focal_mask_fibers=readfits('./virtual_telescope_results/focal_mask_fibers.fits', /silent)

 ;Read in the output focal plane masks.
 focal_mask_slits_out=fltarr(1100,1300)
 focal_mask_slits_out=readfits('./virtual_telescope_results/focal_mask_slits_out.fits', /silent)
 focal_mask_fibers_out=fltarr(1100,1300)
 focal_mask_fibers_out=readfits('./virtual_telescope_results/focal_mask_fibers_out.fits', /silent)
  
 ;Read in the footprints.
 footprint_slits=fltarr(1100,1300)
 footprint_slits=readfits('./virtual_telescope_results/footprint_slits.fits', /silent)
 footprint_fibers=fltarr(1100,1300)
 footprint_fibers=readfits('./virtual_telescope_results/footprint_fibers.fits', /silent)
 
 ;Calculate the coverage of the focal plane. There are  779 X 742 = 578018  pixels available.
 coverage_focal_slits=total(focal_mask_slits(157:935,283:1024))/578018
 coverage_focal_fibers=total(focal_mask_fibers(157:935,283:1024))/578018

 ;Calculate the coverage of the detector. There are 5000 X 742 = 3710000 pixels available. 
 coverage_detector_slits=total(footprint_slits(0:5199,284:1024))/(3710000*255)
 coverage_detector_fibers=total(footprint_fibers(0:5199,284:1024))/(3710000*255)

 ;Mask off the margins.
 footprint_slits(0:5199,0:283)=255
 footprint_slits(0:5199,1025:1299)=255 
 footprint_fibers(0:5199,0:283)=255
 footprint_fibers(0:5199,1025:1299)=255 

 ;Read in the spectra.
 tmp_1=fltarr(5200,1300)
 tmp_1=readfits('./virtual_telescope_results/spectrum_slits.fits', /silent)
 tmp_2=fltarr(5200,1300)
 tmp_2=readfits('./virtual_telescope_results/spectrum_fibers.fits', /silent)

 ;Find the maximum.
 tmp=max(tmp_1)
 if (max(tmp_2) gt tmp) then begin
  tmp=max(tmp_2)
 endif
 if (tmp eq 0.) then begin
  tmp=1.
 endif

 ;Now, normalize the spectra to have a peak of 255.
 tmp_1=(tmp_1-min(tmp_1))
 tmp_1=255.*tmp_1/tmp
 tmp_2=(tmp_2-min(tmp_2))
 tmp_2=255.*tmp_2/tmp

 ;We set the margins to be white for the spectra and footprints.
 tmp_1(0:5199,0:283)=255
 tmp_1(0:5199,1025:1299)=255 
 tmp_2(0:5199,0:283)=255
 tmp_2(0:5199,1025:1299)=255 


 ;Display the images. Note the length of the display is 900. The spectra are 5200 pixels long. The height is only 700. We scale the image (which
 ;is originally 1300 pixels) to be 1/8 of that. Thus, each spectrum will be 163 pixels high.

 ;First, show the input image.
 erase, 255
 tmp=congrid(galaxies_telescope,1100/8,1300/8)
 tv, tmp, 10, 489
 tv, tmp, 10, 326

 ;Next, the focal plane masks.
 tmp=congrid(focal_mask_slits,1100/8,1300/8)+255
 tv, tmp, 155, 489
 tmp=congrid(focal_mask_fibers,1100/8,1300/8)+255
 tv, tmp, 155, 326

 ;Now, the output focal plane masks.
 tmp=congrid(focal_mask_slits_out,1100/8,1300/8)+255
 tv, tmp, 300, 489
 tmp=congrid(focal_mask_fibers_out,1100/8,1300/8)+255
 tv, tmp, 300, 326

 ;Now, the footprint of each of those configurations.
 tmp=congrid(footprint_slits,400,1300/8)
 tv, tmp, 470, 489
 tmp=congrid(footprint_fibers,400,1300/8)
 tv, tmp, 470, 326

 ;Label the screen.
 xyouts, 30, 657, 'MOS Slit Spectrograph', charsize=size_print, color=0, /device
 xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec X 5200 pixels)', charsize=size_print, color=0, /device
 xyouts, 30, 494, 'MOS Fiber Spectrograph', charsize=size_print, color=0, /device
 xyouts, 30, 479, '(58.4 arcsec X 55.7 arcsec X 5200 pixels)', charsize=size_print, color=0, /device
 xyouts, 155+20, 552-40, 'Focal Plane Coverage =', charsize=size_print, color=0, /device
 xyouts, 155+20, 389-40, 'Focal Plane Coverage =', charsize=size_print, color=0, /device
 xyouts, 470-52, 552-40, coverage_focal_slits, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 470-52, 389-40, coverage_focal_fibers, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 490-20, 552-40, 'Detector Coverage = ', charsize=size_print, color=0, /device
 xyouts, 490-20, 389-40, 'Detector Coverage = ', charsize=size_print, color=0, /device
 xyouts, 880-7, 552-40, coverage_detector_slits, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 880-7, 389-40, coverage_detector_fibers, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 652-30, 'Field', charsize=size_print, color=0, /device
 xyouts, 30, 489-30, 'Field', charsize=size_print, color=0, /device
 xyouts, 175, 652-30, 'Mask', charsize=size_print, color=0, /device
 xyouts, 175, 489-30, 'Mask', charsize=size_print, color=0, /device
 xyouts, 320, 652-30, 'Mask Used', charsize=size_print, color=0, /device
 xyouts, 320, 489-30, 'Mask Used', charsize=size_print, color=0, /device
 xyouts, 470, 652-30, 'Detector', charsize=size_print, color=0, /device
 xyouts, 470, 489-30, 'Detector', charsize=size_print, color=0, /device

 ;Display the images. Note the length of the display is 900. We let the spectrum be 900 pixels long. The height is only 700. We scale the image
 ;(which is originally 1300 pixels) to be 1/8 of that. Thus, each spectrum will be 163 pixels high by 700 pixels long.

 ;Now, the spectrum of each of those configurations.
 tmp=congrid(tmp_1,860,1300/8)
 tv, tmp, 20, 163
 tmp=congrid(tmp_2,860,1300/8)
 tv, tmp, 20, 0

 ;Label the screen.
 xyouts, 20, 326, 'MOS Slit Spectrograph', charsize=size_print, color=0, /device
 xyouts, 20, 311, '(5200 pixels X 55.7 arcsec)', charsize=size_print, color=0,  /device
 xyouts, 20, 163, 'MOS Fiber Spectrograph', charsize=size_print, color=0,  /device
 xyouts, 20, 148, '(5200 pixels X 55.7 arcsec)', charsize=size_print, color=0,  /device

 endif
endif

;----------------------------------------------------------------------------------
;Show the spectrographic survey results.
if (uvalue eq 'spectrograph_results') then begin

 ;Check for initialization.
 if (spectrum_multiplex_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must take a multiplexed spectrum first.', charsize=size_print, color=0, /device
 endif
 if (spectrum_multiplex_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 !p.multi = [0,3,2]
 character_size=size_print*1.5

 ;Dummy plot.
 plot, statistics_magnitude, color=255

 ;Show the plot.
 plot, statistics_magnitude, statistics_ratio, /ylog, xrange=[20,35], min_value=1, psym=4, charsize=character_size, thick=1, xtitle='H(AB)', ytitle='S/N',title='MOS Survey Statistics', color=0

 ;Print information to the screen.
 xyouts, 30, 657, 'MOS Spectrographic Survey', charsize=size_print, color=0, /device
 xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device  
 xyouts, 30, 612, 'Galaxy Field', charsize=size_print, color=0, /device 
 xyouts, 30, 597, 'Faint cutoff (H(AB)) = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_cutoff)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)
 xyouts, 240, 597, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 582, 'Added depth (H(AB)) = ', charsize=size_print, color=0, /device 
 tmp=string(galaxy_faint)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3)
 xyouts, 240, 582, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 567, 'Number of clones = ', charsize=size_print, color=0, /device 
 xyouts, 240, 567, galaxy_multiple, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 552, 'Redshift factor = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_shift)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3)
 xyouts, 240, 552, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 537, 'Shrinkage factor = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_shrink)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3) 
 xyouts, 240, 537, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 522, 'Correlation (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_correlation)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)
 xyouts, 240, 522, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 507, 'Bulge radius (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_bulge_radius)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3) 
 xyouts, 240, 507, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 492, 'Disk radius (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_disk_radius)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3) 
 xyouts, 240, 492, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 477, 'E/S0 bulge-to-total = ', charsize=size_print, color=0, /device 
 tmp=string(galaxy_bulge_to_total_1)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5) 
 xyouts, 240, 477, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 462, 'Sbc bulge-to-total = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_bulge_to_total_2)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5)  
 xyouts, 240, 462, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 447, 'Scd bulge-to-total = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_bulge_to_total_3)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5) 
 xyouts, 240, 447, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 432, 'Irr bulge-to-total = ', charsize=size_print, color=0, /device 
 tmp=string(galaxy_bulge_to_total_4)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5) 
 xyouts, 240, 432, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 417, 'Line width (Angstroms) = ', charsize=size_print, color=0, /device 
 tmp=string(galaxy_line_width)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5) 
 xyouts, 240, 417, tmp, alignment=1.0, charsize=size_print, color=0, /device

 xyouts, 30, 387, 'Telescope', charsize=size_print, color=0, /device 
 ;Determine the configuration of the telescope.
 tmp=strarr(5)
 tmp(0)='Canada-France-Hawaii'
 tmp(1)='Gemini'
 tmp(2)='Keck'
 tmp(3)='Hubble'
 tmp(4)='Next-Generation Space'
 xyouts, 30, 372, 'Primary = ', charsize=size_print, color=0, /device 
 xyouts, 240, 372, tmp(telescope_primary), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 357, 'Temperature (K) = ', charsize=size_print, color=0, /device
 tmp=string(telescope_temperature)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5)  
 xyouts, 240, 357, tmp, alignment=1.0, charsize=size_print, color=0, /device  
 xyouts, 30, 342, 'Mirror roughness (nm RMS) = ', charsize=size_print, color=0, /device
 tmp=string(telescope_roughness)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3)  
 xyouts, 240, 342, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 327, 'Number of surfaces = ', charsize=size_print, color=0, /device 
 xyouts, 240, 327, telescope_surfaces, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 312, 'Optics error (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(telescope_error)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5)  
 xyouts, 240, 312, tmp, alignment=1.0, charsize=size_print, color=0, /device
      
 xyouts, 30, 282, 'Multi-Object Spectrograph', charsize=size_print, color=0, /device
 xyouts, 30, 267, 'Maximum number of slits = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_slits)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3)   
 xyouts, 240, 267, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 252, 'Slit length (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_length)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3)   
 xyouts, 240, 252, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 237, 'Slit width (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_width)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)   
 xyouts, 240, 237, tmp, alignment=1.0, charsize=size_print, color=0, /device
 ;Determine the filters.
 tmp=strarr(9)
 tmp(0)='open'
 tmp(1)='U'
 tmp(2)='B'
 tmp(3)='V'
 tmp(4)='R'
 tmp(5)='I'
 tmp(6)='J'
 tmp(7)='H'
 tmp(8)='K'
 xyouts, 30, 222, 'Filter = ', charsize=size_print, color=0, /device
 xyouts, 240, 222, tmp(0), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 207, 'Number of surfaces = ', charsize=size_print, color=0, /device 
 xyouts, 240, 207, spectrograph_surfaces, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 192, 'Resolution (1/pixel) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_resolution)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5)   
 xyouts, 240, 192, tmp, alignment=1.0, charsize=size_print, color=0, /device
 ;Determine properties of the detector.
 tmp=strarr(3)
 tmp(0)='HyViSi'
 tmp(1)='HgCdTe'
 tmp(2)='InSb'
 xyouts, 30, 177, 'Detector type = ', charsize=size_print, color=0, /device 
 xyouts, 240, 177, tmp(spectrograph_detector), alignment=1.0, charsize=size_print, color=0, /device   
 xyouts, 30, 162, 'Pixel (arcsec/pixel) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_pixel)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5)   
 xyouts, 240, 162, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 147, 'Readout (e-) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_readout)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)    
 xyouts, 240, 147, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 132, 'Dark (e-/s) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_dark)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)    
 xyouts, 240, 132, tmp, alignment=1.0, charsize=size_print, color=0, /device   
 xyouts, 30, 117, 'Gain (e-/DU) = ', charsize=size_print, color=0, /device 
 tmp=string(spectrograph_gain)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3)   
 xyouts, 240, 117, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 102, 'Well depth (bits) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_well)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,2)    
 xyouts, 240, 102, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 87, 'Selection (H(AB)) = ', charsize=size_print, color=0, /device 
 tmp=string(spectrograph_flag)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)   
 xyouts, 240, 87, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 72, 'Unit exposure (s) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_exposure_unit)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,8)    
 xyouts, 240, 72, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 57, 'Number of exposures = ', charsize=size_print, color=0, /device 
 xyouts, 240, 57, floor(optical_imager_exposure), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 42, 'Extraction position (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_position)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3)   
 xyouts, 240, 42, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 27, 'Extraction width (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(spectrograph_extract)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,3)   
 xyouts, 240, 27, tmp, alignment=1.0, charsize=size_print, color=0, /device

 endif
endif

end
;-----------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
;Select a target.
pro select_target

common  variables, $
        galaxy_bulge_radius, galaxy_disk_radius, galaxy_bulge_to_total_1, galaxy_bulge_to_total_2, galaxy_bulge_to_total_3, $
        galaxy_bulge_to_total_4, galaxy_cutoff, galaxy_faint, galaxy_multiple, galaxy_shift, galaxy_shrink, galaxy_correlation, $
        galaxy_line_width, $
        star_cutoff, star_faint, star_multiple, star_correlation, star_white_bright, star_white_fraction, star_surface_brightness, $
        star_distance_modulus, $
        telescope_temperature, telescope_primary, telescope_diameter, telescope_roughness, telescope_surfaces, telescope_error, $
        telescope_target, $
        optical_imager_filter, optical_imager_comparison, optical_imager_surfaces, optical_imager_detector, optical_imager_pixel, $
        optical_imager_readout, optical_imager_dark, optical_imager_gain, optical_imager_well, optical_imager_flag, optical_imager_exposure, $
        optical_imager_exposure_unit, $
        spectrograph_flag, spectrograph_resolution, spectrograph_slices, spectrograph_slits, spectrograph_length, spectrograph_width, $
        spectrograph_exposure, spectrograph_exposure_unit, spectrograph_position, spectrograph_extract, spectrograph_filter, $
        spectrograph_comparison, spectrograph_surfaces, spectrograph_detector, spectrograph_pixel, spectrograph_readout, spectrograph_dark, $
        spectrograph_gain, spectrograph_well, $
        target_flag, $
        pupil, aperture_hst, aperture_scaling, $
        mirror_coating_aluminum, mirror_coating_silver, mirror_coating_gold, grating_efficiency, filters, filter_bandpasses, $
        detector_efficiency_1, detector_efficiency_2, detector_efficiency_3, spectrum_1, spectrum_2, spectrum_3, spectrum_4, $
        colour_magnitude_1, colour_magnitude_2, $
        star_colour_shift_1, star_colour_shift_2, star_colour_shift_3, star_colour_shift_4, $
        background_total, atmospheric_transmission, $
        galaxy, galaxy_fake, galaxy_disk, galaxy_redshift, galaxy_magnitude, galaxy_classification, galaxy_radius, $
        galaxies, galaxies_redshift, galaxies_weight, galaxies_magnitude, galaxies_classification, galaxies_radius, galaxies_hst, $
        galaxies_telescope, galaxies_1, galaxies_2, galaxies_3, galaxies_4, galaxies_5, galaxies_list_x_pos, galaxies_list_y_pos, $
        galaxies_list_magnitude, galaxies_list_redshift, galaxies_list_classification, galaxies_list_radius, galaxies_list_rotate, $
        galaxies_list_ellipticity, galaxies_total_number, galaxies_total_number_hst, galaxies_number_counts, galaxies_number_counts_hst, $
        galaxies_number_counts_label, galaxies_distribution_magnitude, galaxies_distribution_redshift, galaxies_distribution_magnitude_hst, $
        galaxies_distribution_redshift_hst, galaxies_distribution_radius, galaxies_distribution_radius_hst, $
        star, star_fwhm, star_strehl, $
        stars, stars_hst, stars_telescope, stars_background, stars_list_magnitude, stars_list_x_pos, stars_list_y_pos, $
        stars_list_classification, stars_total_number, stars_total_number_hst, stars_number_counts, stars_number_counts_hst, $
        stars_number_counts_label, $
        spectrum, spectrum_extract, spectrum_true_extract, $
        x, y, $
        photometry, ratio, galaxy_radius_output, $
        statistics_magnitude, statistics_ratio, $
        colour_table, size_print, screen_output, $
        www, www_background, $
        initialize_field_done, initialize_telescope_done, optical_imager_done, infrared_camera_done,  $
        select_done, spectrum_integral_field_unit_done, spectrum_single_done, spectrum_multiplex_done, $
        field_running, telescope_running, oi_running, mos_running, $
        window_id

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the telescope first.', charsize=size_print, color=0, /device
 endif
 if (initialize_telescope_done eq 1) then begin

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Set up the display.
  wshow, window_id
  erase, 255
  loadct, 3, /silent

  ;Display the image.
  tmp=fltarr(778,741)
  tmp=galaxies_telescope(157:936,283:1023)
  tmp_1=congrid(tmp,630,600)
  tv, tmp_1, 23, 27
 
  ;Labels.
  xyouts, 23, 657, 'Galaxy Field', charsize=size_print, color=0, /device
  xyouts, 23, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

  ;If the program is generating WWW output copy the field to a file.
  if (www_background eq 1) then begin
   screen_output=tvrd()
   write_gif, './virtual_telescope_www/virtual_telescope_www_field.gif', screen_output
  endif

  ;Put tick-marks where all the list galaxies are. Select those galaxies with H(AB) equal
  ;to the target flag value.
  for i=0,galaxies_total_number do begin
   if (galaxies_list_magnitude(i) ge target_flag) then begin
    if (galaxies_list_magnitude(i) lt target_flag+1.) then begin
     ;Make sure it is within the display size.
     if ((galaxies_list_x_pos(i) lt 936) and (galaxies_list_x_pos(i) gt 157)) then begin
      if ((galaxies_list_y_pos(i) lt 1024) and (galaxies_list_y_pos(i) gt 283)) then begin
       tmp=string(galaxies_list_redshift(i))
       tmp=strtrim(tmp,2)
       tmp=strmid(tmp,0,4)
       xyouts, 23+(630./779.)*(galaxies_list_x_pos(i)-157.), 27+(630./779.)*(galaxies_list_y_pos(i)-283.), '_ _', alignment=0.5, charsize=size_print, /device 
       xyouts, 23+(630./779.)*(galaxies_list_x_pos(i)-157.)-12, 27+(630./779.)*(galaxies_list_y_pos(i)-283.)-3, tmp, alignment=1.0, charsize=size_print, /device      
      endif
     endif
    endif
   endif
  endfor

  ;Pick a target galaxy field for study.
  cursor, x, y, /device, wait=0

  ;If the cursor is not on the image.
  if ((x le 23+22) or (x ge 23+630-22) or (y le 27+22) or (y ge 27+600-22)) then begin

    ;Print a message to the screen.
    erase, 255
    xyouts, 350, 365, 'You must select from the galaxy field.', charsize=size_print, color=0, /device
  
  endif

  ;The cursor must be in the image.
  if ((x gt 23+22) and (x lt 23+630-22)) then begin
   if ((y gt 27+22) and (y lt 27+600-22)) then begin

    ;Selected area. This is a 4.0 arcsec X 4.0 arcsec box.
    arrow, x-22, y-22, x+22, y-22, /solid, hsize=0, color=255
    arrow, x+22, y-22, x+22, y+22, /solid, hsize=0, color=255
    arrow, x+22, y+22, x-22, y+22, /solid, hsize=0, color=255
    arrow, x-22, y+22, x-22, y-22, /solid, hsize=0, color=255

    ;Set the coordinates.
    x_tmp=floor(((x-23.)/630.)*779.+157.)
    y_tmp=floor(((y-27.)/600.)*742.+283.)

    ;Display the chosen image section. Select a 4.0 arcsec X 4.0 arcsec section of image. For scaling
    ;of 0.075 arcsec/pixel we would require an image of size 53.3 X 53.3 pixels. We select 53 X 53
    ;pixels.

    ;Draw an arrow to the galaxy.

    ;Black.
    arrow, 676, 625, x+22, y+22, /solid, hsize=0, color=0
    ;arrow, 676, 426, x+22, y-22, /solid, hsize=0, color=0
 
    ;White.
    arrow, 676, 624, x+22, y+21, /solid, hsize=0, color=255
    ;arrow, 676, 427, x+22, y-21, /solid, hsize=0, color=255

    ;And display the section.
    tv, congrid(galaxies_telescope(x_tmp-27:x_tmp+27,y_tmp-27:y_tmp+27), 200, 200), 676, 426
    xyouts, 691, 442, 'Imaging', orientation=90., charsize=size_print, color=255, /device
 
    ;Put a cross-hairs in the displayed image.
    arrow, 776-15, 527, 776+15, 527, /solid, hsize=0, color=255
    arrow, 776, 527-15, 776, 527+15, /solid, hsize=0, color=255

    ;And draw the outline of the integral field unit field.
    arrow, 726, 427+1, 726, 627-3, /solid, hsize=0, color=255
    arrow, 826, 427+1, 826, 627-3, /solid, hsize=0, color=255
    arrow, 726, 427+1, 826, 427+1, /solid, hsize=0, color=255
    arrow, 726, 627-3, 826, 627-3, /solid, hsize=0, color=255
    xyouts, 741, 442, 'Integral Field Unit', orientation=90., charsize=size_print, color=255, /device

    ;And draw the outline of the slit area. Note the image here is 200 pixels across and
    ;is 4.0 arcsec X 4.0 arcsec. 
    tmp_1=floor((1./0.02)*spectrograph_width/2.)-2
    tmp_2=floor((1./0.02)*spectrograph_length/2.)-2
    arrow, 776-tmp_1, 526-tmp_2, 776+tmp_1, 526-tmp_2, /solid, hsize=0, color=255
    arrow, 776+tmp_1, 526-tmp_2, 776+tmp_1, 526+tmp_2, /solid, hsize=0, color=255
    arrow, 776+tmp_1, 526+tmp_2, 776-tmp_1, 526+tmp_2, /solid, hsize=0, color=255
    arrow, 776-tmp_1, 526+tmp_2, 776-tmp_1, 526-tmp_2, /solid, hsize=0, color=255
    xyouts, 776-tmp_1-5, 442, 'Slit', orientation=90., charsize=size_print, color=255, /device
 
    ;Determine properties of the galaxy.
    galaxy_magnitude=galaxies_magnitude(x_tmp,y_tmp)
    galaxy_redshift=galaxies_redshift(x_tmp,y_tmp)
    galaxy_classification=galaxies_classification(x_tmp,y_tmp)
    galaxy_radius=galaxies_radius(x_tmp,y_tmp)
    tmp_1=strarr(6)
    tmp_1(0)='background'
    tmp_1(1)='E/S0'
    tmp_1(2)='Sbc'
    tmp_1(3)='Scd'
    tmp_1(4)='Irr'
    tmp_1(5)='stellar'
    if (floor(galaxy_classification) eq 0) then begin
     galaxy_radius=0. 
    endif

    ;Print information on the screen.
    xyouts, 676, 657, 'Selected Region', charsize=size_print, color=0, /device
    xyouts, 676, 642, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device
    xyouts, 676, 397, 'Centre of Selected Region', charsize=size_print, color=0, /device
    xyouts, 676, 382, 'z = ', charsize=size_print, color=0, /device
    tmp=string(galaxy_redshift)
    tmp=strtrim(tmp,2)
    tmp=strmid(tmp,0,4)
    xyouts, 877, 382, tmp, alignment=1.0, charsize=size_print, color=0, /device 
    xyouts, 676, 367, 'H(AB) = ', charsize=size_print, color=0, /device
    tmp=string(galaxy_magnitude)
    tmp=strtrim(tmp,2)
    tmp=strmid(tmp,0,6)
    xyouts, 877, 367, tmp, alignment=1.0,charsize=size_print, color=0, /device
    xyouts, 676, 352, 'Object type = ', charsize=size_print, color=0, /device 
    xyouts, 877, 352, tmp_1(floor(galaxy_classification)), alignment=1.0, charsize=size_print, color=0, /device
    xyouts, 676, 337, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device
    tmp=string(galaxy_radius)
    tmp=strtrim(tmp,2)
    tmp=strmid(tmp,0,5)
    xyouts, 877, 337, tmp, alignment=1.0, charsize=size_print, color=0, /device

    ;Set the positions in the mask.
    x=x_tmp
    y=y_tmp

   endif
  endif
 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;Set up the display.
  wshow, window_id
  erase, 255
  loadct, 1, /silent

  ;Display the image.
  tmp=fltarr(778,741)
  tmp=stars_telescope(157:936,283:1023)
  tmp_1=congrid(tmp,630,600)
  tv, tmp_1, 23, 27

  ;Put a border around the image.
  arrow, 23, 27, 653, 27, /solid, hsize=0, color=0
  arrow, 653, 27, 653, 625, /solid, hsize=0, color=0
  arrow, 653, 625, 23, 625, /solid, hsize=0, color=0
  arrow, 23, 625, 23, 27, /solid, hsize=0, color=0
 
  ;Labels.
  xyouts, 23, 657, 'Star Field', charsize=size_print, color=0, /device
  xyouts, 23, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

  ;Pick a target star field.
  cursor, x, y, /device, wait=0

  ;If the cursor is not on the image.
  if ((x le 23+22) or (x ge 23+243-22) or (y le 27+22) or (y ge 27+231-22)) then begin

    ;Print a message to the screen.
    erase, 255
    xyouts, 350, 365, 'You must select from the star field.', charsize=size_print, color=0, /device

  endif

  ;The cursor must be in the image.
  if ((x gt 23+22) and (x lt 23+243-22)) then begin
   if ((y gt 27+22) and (y lt 27+231-22)) then begin

    ;Selected area. This is a 4.0 arcsec X 4.0 arcsec box.
    arrow, x-22, y-22, x+22, y-22, /solid, hsize=0, color=255
    arrow, x+22, y-22, x+22, y+22, /solid, hsize=0, color=255
    arrow, x+22, y+22, x-22, y+22, /solid, hsize=0, color=255
    arrow, x-22, y+22, x-22, y-22, /solid, hsize=0, color=255

    ;Set the coordinates.
    x_tmp=floor(((x-23.)/630.)*779.+157.)
    y_tmp=floor(((y-27.)/600.)*742.+283.)

    ;Display the chosen image section. Select a 4.0 arcsec X 4.0 arcsec section of image. For scaling
    ;of 0.075 arcsec/pixel we would require an image of size 53.3 X 53.3 pixels. We select 53 X 53
    ;pixels.

    ;Draw an arrow to the galaxy.

    ;Black.
    arrow, 676, 625, x+22, y+22, /solid, hsize=0, color=0
    ;arrow, 676, 426, x+22, y-22, /solid, hsize=0, color=0
 
    ;White.
    arrow, 676, 624, x+22, y+21, /solid, hsize=0, color=255
    ;arrow, 676, 427, x+22, y-21, /solid, hsize=0, color=255

    ;And display the section.
    tv, congrid(stars_telescope(x_tmp-27:x_tmp+27,y_tmp-27:y_tmp+27), 200, 200), 676, 426
 
    ;Put a cross-hairs in the displayed image.
    arrow, 776-15, 527, 776+15, 527, /solid, hsize=0, color=255
    arrow, 776, 527-15, 776, 527+15, /solid, hsize=0, color=255

    ;Print information on the screen.
    xyouts, 676, 657, 'Selected Region', charsize=size_print, color=0, /device
    xyouts, 676, 642, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device

    ;Set the positions in the mask.
    x=x_tmp
    y=y_tmp

   endif
  endif

 endif

 ;Set the toggle to 1.
 select_done=1

 endif
end

;--------------------------------------------------------------------------------
;Run the optical imager simulation.
pro optical_imager_simulation

common  variables, $
        galaxy_bulge_radius, galaxy_disk_radius, galaxy_bulge_to_total_1, galaxy_bulge_to_total_2, galaxy_bulge_to_total_3, $
        galaxy_bulge_to_total_4, galaxy_cutoff, galaxy_faint, galaxy_multiple, galaxy_shift, galaxy_shrink, galaxy_correlation, $
        galaxy_line_width, $
        star_cutoff, star_faint, star_multiple, star_correlation, star_white_bright, star_white_fraction, star_surface_brightness, $
        star_distance_modulus, $
        telescope_temperature, telescope_primary, telescope_diameter, telescope_roughness, telescope_surfaces, telescope_error, $
        telescope_target, $
        optical_imager_filter, optical_imager_comparison, optical_imager_surfaces, optical_imager_detector, optical_imager_pixel, $
        optical_imager_readout, optical_imager_dark, optical_imager_gain, optical_imager_well, optical_imager_flag, optical_imager_exposure, $
        optical_imager_exposure_unit, $
        spectrograph_flag, spectrograph_resolution, spectrograph_slices, spectrograph_slits, spectrograph_length, spectrograph_width, $
        spectrograph_exposure, spectrograph_exposure_unit, spectrograph_position, spectrograph_extract, spectrograph_filter, $
        spectrograph_comparison, spectrograph_surfaces, spectrograph_detector, spectrograph_pixel, spectrograph_readout, spectrograph_dark, $
        spectrograph_gain, spectrograph_well, $
        target_flag, $
        pupil, aperture_hst, aperture_scaling, $
        mirror_coating_aluminum, mirror_coating_silver, mirror_coating_gold, grating_efficiency, filters, filter_bandpasses, $
        detector_efficiency_1, detector_efficiency_2, detector_efficiency_3, spectrum_1, spectrum_2, spectrum_3, spectrum_4, $
        colour_magnitude_1, colour_magnitude_2, $
        star_colour_shift_1, star_colour_shift_2, star_colour_shift_3, star_colour_shift_4, $
        background_total, atmospheric_transmission, $
        galaxy, galaxy_fake, galaxy_disk, galaxy_redshift, galaxy_magnitude, galaxy_classification, galaxy_radius, $
        galaxies, galaxies_redshift, galaxies_weight, galaxies_magnitude, galaxies_classification, galaxies_radius, galaxies_hst, $
        galaxies_telescope, galaxies_1, galaxies_2, galaxies_3, galaxies_4, galaxies_5, galaxies_list_x_pos, galaxies_list_y_pos, $
        galaxies_list_magnitude, galaxies_list_redshift, galaxies_list_classification, galaxies_list_radius, galaxies_list_rotate, $
        galaxies_list_ellipticity, galaxies_total_number, galaxies_total_number_hst, galaxies_number_counts, galaxies_number_counts_hst, $
        galaxies_number_counts_label, galaxies_distribution_magnitude, galaxies_distribution_redshift, galaxies_distribution_magnitude_hst, $
        galaxies_distribution_redshift_hst, galaxies_distribution_radius, galaxies_distribution_radius_hst, $
        star, star_fwhm, star_strehl, $
        stars, stars_hst, stars_telescope, stars_background, stars_list_magnitude, stars_list_x_pos, stars_list_y_pos, $
        stars_list_classification, stars_total_number, stars_total_number_hst, stars_number_counts, stars_number_counts_hst, $
        stars_number_counts_label, $
        spectrum, spectrum_extract, spectrum_true_extract, $
        x, y, $
        photometry, ratio, galaxy_radius_output, $
        statistics_magnitude, statistics_ratio, $
        colour_table, size_print, screen_output, $
        www, www_background, $
        initialize_field_done, initialize_telescope_done, optical_imager_done, infrared_camera_done,  $
        select_done, spectrum_integral_field_unit_done, spectrum_single_done, spectrum_multiplex_done, $
        field_running, telescope_running, oi_running, mos_running, $
        window_id

 ;Check for initialization.
 if (select_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must select a target first.', charsize=size_print, color=0, /device
 endif
 if (select_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255

 ;Optical.
 if (optical_imager_filter le 5) then begin
  loadct, 1, /silent
 endif

 ;Infrared.
 if (optical_imager_filter gt 5) then begin
  loadct, 3, /silent
 endif
 
 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Display the field.
  tmp=fltarr(778,741)
  tmp=galaxies_telescope(157:934,283:1023)
  tmp_1=congrid(tmp,210,200)
  tv, tmp_1, 30, 427
 
  ;Labels.
  xyouts, 30, 657, 'Galaxy Field', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

  ;Selected area.
  x_i=(x-157)*(210./778.)+30-7
  x_f=x_i+14
  y_i=(y-283)*(200./741.)+427-7
  y_f=y_i+14
  arrow, x_i, y_i, x_f, y_i, /solid, hsize=0, color=255
  arrow, x_f, y_i, x_f, y_f, /solid, hsize=0, color=255
  arrow, x_f, y_f, x_i, y_f, /solid, hsize=0, color=255
  arrow, x_i, y_f, x_i, y_i, /solid, hsize=0, color=255

  ;Determine properties of the galaxy.
  galaxy_magnitude=galaxies_magnitude(x,y)
  galaxy_redshift=galaxies_redshift(x,y)
  galaxy_classification=galaxies_classification(x,y)
  galaxy_radius=galaxies_radius(x,y)
  tmp_1=strarr(6)
  tmp_1(0)='background'
  tmp_1(1)='E/S0'
  tmp_1(2)='Sbc'
  tmp_1(3)='Scd'
  tmp_1(4)='Irr'
  tmp_1(5)='stellar'
  if (floor(galaxy_classification) eq 0) then begin
   galaxy_radius=0. 
  endif

  ;Print information to the screen.
  xyouts, 30, 397, 'OI Imaging', charsize=size_print, color=0, /device
  xyouts, 30, 382, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device  
  xyouts, 30, 352, 'Centre of Target Field', charsize=size_print, color=0, /device 
  tmp=string(galaxy_redshift)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 30, 337, 'z = ', charsize=size_print, color=0, /device 
  xyouts, 240, 337, tmp, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 322, 'H(AB) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_magnitude)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6)
  xyouts, 240, 322, tmp, alignment=1.0,charsize=size_print, color=0, /device
  xyouts, 30, 307, 'Object type = ', charsize=size_print, color=0, /device 
  xyouts, 240, 307, tmp_1(galaxy_classification), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 292, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_radius)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)
  xyouts, 240, 292, tmp, alignment=1.0, charsize=size_print, color=0, /device

  ;Determine properties of the exposure.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  completed_tmp=0

  ;Print information to the screen.
  xyouts, 30, 262, 'Exposure', charsize=size_print, color=0, /device 
  xyouts, 30, 247, 'Filter = ', charsize=size_print, color=0, /device 
  xyouts, 240, 247, tmp(optical_imager_filter), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 232, 'Unit exposure (s) = ', charsize=size_print, color=0, /device 
  xyouts, 240, 232, optical_imager_exposure_unit, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 217, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 217, floor(optical_imager_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
  xyouts, 240, 202, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
  wait, 1

 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;Display the image.
  tmp=fltarr(778,741)
  tmp=stars_telescope(157:934,283:1023)
  tmp_1=congrid(tmp,210,200)
  tv, tmp_1, 30, 427

  ;Put a border around the image.
  arrow, 30, 427, 240, 427, /solid, hsize=0, color=0
  arrow, 240, 427, 240, 625, /solid, hsize=0, color=0
  arrow, 240, 625, 30, 625, /solid, hsize=0, color=0
  arrow, 30, 625, 30, 427, /solid, hsize=0, color=0
 
  ;Labels.
  xyouts, 30, 657, 'Star Field', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

  ;Selected area.
  x_i=(x-157)*(210./778.)+30-7
  x_f=x_i+14
  y_i=(y-283)*(200./741.)+427-7
  y_f=y_i+14
  arrow, x_i, y_i, x_f, y_i, /solid, hsize=0, color=255
  arrow, x_f, y_i, x_f, y_f, /solid, hsize=0, color=255
  arrow, x_f, y_f, x_i, y_f, /solid, hsize=0, color=255
  arrow, x_i, y_f, x_i, y_i, /solid, hsize=0, color=255

  ;Determine properties of the exposure.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  completed_tmp=0

  ;Print information to the screen.
  xyouts, 30, 397, 'OI Imaging', charsize=size_print, color=0, /device
  xyouts, 30, 382, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device  
  xyouts, 30, 352, 'Exposure', charsize=size_print, color=0, /device 
  xyouts, 30, 337, 'Filter = ', charsize=size_print, color=0, /device 
  xyouts, 240, 337, tmp(optical_imager_filter), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 322, 'Unit exposure (s) = ', charsize=size_print, color=0, /device 
  xyouts, 240, 322, optical_imager_exposure_unit, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 307, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 307, floor(optical_imager_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 292, 'Number completed = ', charsize=size_print, color=0, /device 
  xyouts, 240, 292, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
  wait, 1

 endif

 ;Print a message to the screen.
 xyouts, 525, 365, 'Initializing ...', charsize=size_print, color=0, /device

 ;Initialize.
 r=100
 if ((telescope_primary eq 0) or (telescope_primary eq 2) or (telescope_primary eq 3)) then begin
  telescope_mirror=congrid(mirror_coating_aluminum(0:2999),r)
 endif
 if (telescope_primary eq 1) then begin
  telescope_mirror=congrid(mirror_coating_gold(0:2999),r)
 endif
 transmission=congrid(atmospheric_transmission(0:29999),r)
 optical_imager_mirror=congrid(mirror_coating_aluminum(0:2999),r)
 tmp=fltarr(3000)
 tmp=filters(optical_imager_filter,0:2999)
 filter=fltarr(r)
 filter(0:r-1)=congrid(tmp(0:2999),r)
 tmp=fltarr(3000)
 tmp=filters(7,0:2999)
 filter_h=fltarr(r)
 filter_h(0:r-1)=congrid(tmp(0:2999),r)
 if (optical_imager_detector eq 0) then begin
  detector=congrid(detector_efficiency_1(0:2999),r)
 endif
 if (optical_imager_detector eq 1) then begin
  detector=congrid(detector_efficiency_2(0:2999),r)
 endif
 if (optical_imager_detector eq 2) then begin
  detector=congrid(detector_efficiency_3(0:2999),r)
 endif
 spectrum_1_tmp=congrid(spectrum_1(0:29999),3000)
 spectrum_2_tmp=congrid(spectrum_2(0:29999),3000)
 spectrum_3_tmp=congrid(spectrum_3(0:29999),3000)
 spectrum_4_tmp=congrid(spectrum_4(0:29999),3000)

 ;Determine the filter central wavelength.
 if (optical_imager_filter eq 1) then begin
  lambda=2500. ;A
  dlambda=500. ;A
 endif
 if (optical_imager_filter eq 2) then begin
  lambda=3000. ;A
  dlambda=500. ;A
 endif
 if (optical_imager_filter eq 3) then begin
  lambda=4500. ;A
  dlambda=500. ;A
 endif
 if (optical_imager_filter eq 4) then begin
  lambda=6060. ;A
  dlambda=1000. ;A
 endif
 if (optical_imager_filter eq 5) then begin
  lambda=8140. ;A
  dlambda=1000. ;A
 endif
 if (optical_imager_filter eq 6) then begin
  lambda=11000. ;A
  dlambda=3500. ;A
 endif
 if (optical_imager_filter eq 7) then begin
  lambda=16000. ;A
  dlambda=3500. ;A
 endif
 if (optical_imager_filter eq 8) then begin
  lambda=22000. ;A
  dlambda=3500. ;A
 endif

 ;Calculate the throughput. This is in photons/e-.
 tmp=fltarr(r)
 tmp=tmp+1.
 throughput_atmosphere=total(transmission*filter*tmp)/total(filter*tmp)
 throughput_instrument=total((telescope_mirror^telescope_surfaces)*(optical_imager_mirror^optical_imager_surfaces)*filter*detector*tmp)/total(filter*tmp)

 ;Calculate the PSF for the given filter. Remember that the original sampling is 0.01 arcsec/pixel and that the input PSFs are 2 arcsec X 2 
 ;arcsec or 200 X 200 pixels.

 ;Now, construct the PSF for the given filter.
 psf=fltarr(200,200)
 for i=0,r-1 do begin
  psf(0:199,0:199)=psf(0:199,0:199)+filter(i)*star(floor((30./float(r)*i)),0:199,0:199)
 endfor

 ;Normalize to have a total flux of 1.
 psf=psf/total(psf)

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;The full images.
  galaxies_tmp=fltarr(1000,1000)
  galaxies_disk_tmp=galaxies_tmp

  ;Run through all the galaxies in the list.
  for i=0,galaxies_total_number do begin

   ;Find out if the galaxy is in the larger field. Note, these coordinates are in units of 0.075 arcsec/pixel. That is, 875 pixels at 0.004
   ;arcsec/pixel corresponds to 47 for 0.075 arcsec/pixel.
   if ((galaxies_list_x_pos(i) gt x-46) and (galaxies_list_x_pos(i) lt x+46)) then begin
    if ((galaxies_list_y_pos(i) gt y-46) and (galaxies_list_y_pos(i) lt y+46)) then begin

     print, i

     ;We know the catalog flux for this galaxy. This is in H and is in photons.
     lambda_tmp=16000.
     dlambda_tmp=3500.
     c=299792458. ;m/s
     h=6.6260755e-34 ;Joule/s
     nu=c/(lambda_tmp*1.e-10) ;Hz
     dnu=c/(dlambda_tmp*1.e-10) ;Hz
     flux=aperture_scaling*aperture_hst*10000.*dnu/(nu*h*1e7)*10.^((galaxies_list_magnitude(i)+48.60)/(-2.5))

     ;Now, we need to find what fraction fainter or brighter the galaxy is in the new filter. This is done by finding how much light will pass
     ;through both the new filter and H filter in the redshifted galaxy spectrum.
     if (floor(galaxies_list_classification(i)) eq 1) then begin
      blue=0
      red=floor(3000./(1.+galaxies_list_redshift(i)))-1      
      tmp=congrid(spectrum_1_tmp(blue:red),r)
      fraction=total(filter*tmp)/total(filter_h*tmp)
     endif
     if (floor(galaxies_list_classification(i)) eq 2) then begin
      blue=0
      red=floor(3000./(1.+galaxies_list_redshift(i)))-1      
      tmp=congrid(spectrum_2_tmp(blue:red),r)
      fraction=total(filter*tmp)/total(filter_h*tmp)
     endif
     if (floor(galaxies_list_classification(i)) eq 3) then begin
      blue=0
      red=floor(3000./(1.+galaxies_list_redshift(i)))-1      
      tmp=congrid(spectrum_3_tmp(blue:red),r)
      fraction=total(filter*tmp)/total(filter_h*tmp)
     endif
     if (floor(galaxies_list_classification(i)) eq 4) then begin
      blue=0
      red=floor(3000./(1.+galaxies_list_redshift(i)))-1      
      tmp=congrid(spectrum_1_tmp(blue:red),r)
      fraction=total(filter*tmp)/total(filter_h*tmp)
     endif

     ;The positions of the images. Note, the simulation is 133.3 pixels at 0.075 arcsec/pixel. Half of this is 66.7 pixels.
     x_tmp=floor((0.075/0.01)*(galaxies_list_x_pos(i)-(x-66.7)))
     y_tmp=floor((0.075/0.01)*(galaxies_list_y_pos(i)-(y-66.7)))

     ;We assign the classification, ellipticity, rotation, and scale factor.
     classification_tmp=galaxies_list_classification(i)
     rotate_tmp=galaxies_list_rotate(i)
     factor_tmp=galaxies_list_radius(i)/0.461594
     ellipticity_tmp=galaxies_list_ellipticity(i)
     
     ;In x.
     x_f=floor(ellipticity_tmp*factor_tmp*150.)
     if (x_f lt 2) then begin
      x_f=2
     endif
     x_s=x_f-1

     ;In y.
     y_f=floor(factor_tmp*150.)
     if (y_f lt 2) then begin
      y_f=2
     endif
     y_s=y_f-1

     ;Now if this is a star then the image is full size.
     if (classification_tmp eq 5) then begin
      x_f=150
      y_f=150
      x_s=x_f-1
      y_s=y_f-1
     endif

     ;Generate a fake galaxy. This is scaled and rotated.
 
     ;First, take the fake galaxy image.
     tmp=fltarr(300,300)
     tmp(0:299,0:299)=galaxy_fake(classification_tmp-1,0:299,0:299)

     ;Scale it.
     galaxy_fake_tmp=congrid(tmp,2*x_f,2*y_f)

     ;Ensure flux is conserved.
     galaxy_fake_tmp=galaxy_fake_tmp*total(tmp)/total(galaxy_fake_tmp)

     ;Insert back into a full image.
     tmp=galaxy_fake_tmp
     galaxy_fake_tmp=fltarr(300,300)
     galaxy_fake_tmp(150-x_f:150+x_s,150-y_f:150+y_s)=tmp(0:x_f+x_s,0:y_f+y_s)

     ;And rotate.
     galaxy_fake_tmp=rot(galaxy_fake_tmp,rotate_tmp)

     ;Place the galaxy in the output image.
     galaxies_tmp(x_tmp-150:x_tmp+149,y_tmp-150:y_tmp+149)=galaxies_tmp(x_tmp-150:x_tmp+149,y_tmp-150:y_tmp+149)+fraction*flux*galaxy_fake_tmp

     ;Also, the disk.

     ;First, take the fake disk image.
     tmp=fltarr(300,300)
     tmp(0:299,0:299)=galaxy_disk(classification_tmp-1,0:299,0:299)

     ;Scale it.
     galaxy_disk_tmp=congrid(tmp,2*x_f,2*y_f)

     ;Ensure flux is conserved.
     galaxy_disk_tmp=galaxy_disk_tmp*total(tmp)/total(galaxy_disk_tmp)

     ;Insert back into a full image.
     tmp=galaxy_disk_tmp
     galaxy_disk_tmp=fltarr(300,300)
     galaxy_disk_tmp(150-x_f:150+x_s,150-y_f:150+y_s)=tmp(0:x_f+x_s,0:y_f+y_s)

     ;And rotate.
     galaxy_disk_tmp=rot(galaxy_disk_tmp,rotate_tmp)

     ;Place the galaxy in the output image.
     galaxies_disk_tmp(x_tmp-150:x_tmp+149,y_tmp-150:y_tmp+149)=galaxies_disk_tmp(x_tmp-150:x_tmp+149,y_tmp-150:y_tmp+149)+fraction*flux*galaxy_disk_tmp

     ;Set the counter to the last galaxy.
     galaxies_last=i

    endif
   endif
  endfor
 
 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;The full images.
  stars_tmp=fltarr(1000,1000)

  ;Run through all the stars in the list.
  for i=0,stars_total_number do begin

  ;Find out if the star is in the larger field. Note, these coordinates are in units of 0.075 arcsec/pixel. That is, 875 pixels at 0.004
  ;arcsec/pixel corresponds to 47 for 0.075 arcsec/pixel.
  if ((stars_list_x_pos(i) gt x-46) and (stars_list_x_pos(i) lt x+46)) then begin
   if ((stars_list_y_pos(i) gt y-46) and (stars_list_y_pos(i) lt y+46)) then begin

     print, i

     ;Put a star in the starfield. We need to know how much fainter the star will be if it is not in I.

     ;For I.
     magnitude_tmp=stars_list_magnitude(i)

     ;For R.
     if ((optical_imager_filter eq 3) or (optical_imager_filter eq 4) or (optical_imager_filter eq 6) or (optical_imager_filter eq 7) or (optical_imager_filter eq 7) or (optical_imager_filter eq 8)) then begin

      ;If the star is on the ZAMS.
      if (stars_list_classification(i) eq 0) then begin
       colour_tmp=colour_magnitude_1(floor(40.*stars_list_magnitude(i)))
       magnitude_tmp=stars_list_magnitude(i)+colour_tmp
      endif
     
      ;Now, if this is a white dwarf we need a different colour magnitude diagram.
      if (stars_list_classification(i) eq 1) then begin
       colour_tmp=colour_magnitude_2(floor(40.*stars_list_magnitude(i)))
       magnitude_tmp=stars_list_magnitude(i)+colour_tmp
      endif

     endif

     ;Now, for the remaining colours we simply shift a small amount blue or red.

     ;For V.
     if (optical_imager_filter eq 3) then begin
      magnitude_tmp=stars_list_magnitude(i)+colour_tmp*star_colour_shift_1
     endif

     ;For J.
     if (optical_imager_filter eq 6) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_2
     endif

     ;For H.
     if (optical_imager_filter eq 7) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_3
     endif

     ;For K.
     if (optical_imager_filter eq 8) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_4
     endif
 
     ;Find the flux for the star. This is in photons.
     c=299792458. ;m/s
     h=6.6260755e-34 ;Joule/s
     nu=c/(lambda*1.e-10) ;Hz
     dnu=c/(dlambda*1.e-10) ;Hz
     flux=aperture_scaling*aperture_hst*10000.*dnu/(nu*h*1e7)*10.^((magnitude_tmp+48.60)/(-2.5))

     ;The positions of the images. Note, the simulation is 133.3 pixels at 0.075 arcsec/pixel. Half of this is 66.7 pixels.
     x_tmp=floor((0.075/0.01)*(stars_list_x_pos(i)-(x-66.7)))
     y_tmp=floor((0.075/0.01)*(stars_list_y_pos(i)-(y-66.7)))

     ;Generate the star image and add it to the field.
     stars_tmp(x_tmp-100:x_tmp+99,y_tmp-100:y_tmp+99)=stars_tmp(x_tmp-100:x_tmp+99,y_tmp-100:y_tmp+99)+flux*psf
    
    endif
   endif
  endfor
 endif

 ;We now have 1 second images of stars or galaxies in units of photons for the chosen filter.

 ;We convolve with the PSF and then rebin the images to the pixel sampling of the camera. Note, this is the smaller inset region that we expand.
 ;This is only 4.0 arcsec X 4.0 arcsec.
 f=floor(4./optical_imager_pixel)
 s=f-1

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Galaxies.
  tmp=galaxies_tmp(300:699,300:699)

  ;And convolve with the PSF.
  tmp=convolve(tmp,psf)

  ;Photometry in the true image.
  photometry_galaxies=total(tmp)

  ;But this is for 4.0 arcsec X 4.0 arcsec. We divide by 16 to get the mean flux per arcsec^2.
  photometry=photometry_galaxies/16.

  ;And the true surface brightness is given by.
  flux=photometry*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
  surface_brightness_true=-2.5*alog10(flux)-48.6

  ;And rebin.
  galaxies_tmp=congrid(tmp,f,f)
  galaxies_tmp=galaxies_tmp*total(tmp)/total(galaxies_tmp)

  ;Galaxy disks.
  tmp=galaxies_disk_tmp(300:699,300:699)

  ;Photometry in the true image.
  photometry_galaxies_disk=total(tmp)

  ;Thus the true bulge-to-total is.
  bulge_to_total_true=(photometry_galaxies-photometry_galaxies_disk)/photometry_galaxies
  if (bulge_to_total_true lt 0.) then begin
   bulge_to_total_true=0.
  endif

  ;And convolve with the PSF.
  tmp=convolve(tmp,psf)

  ;And rebin.
  galaxies_disk_tmp=congrid(tmp,f,f)
  galaxies_disk_tmp=galaxies_disk_tmp*total(tmp)/total(galaxies_disk_tmp)

 endif

 ;Stars.
 if (telescope_target eq 1) then begin
  
  ;Rebin the stars image.
  tmp=stars_tmp(300:699,300:699)
  stars_tmp=congrid(tmp,f,f)
  stars_tmp=stars_tmp*total(tmp)/total(stars_tmp)

  ;Calculate the surface brightness of the background. This is in photons/arcsec.
  c=299792458. ;m/s
  h=6.6260755e-34 ;Joule/s
  nu=c/(lambda*1.e-10) ;Hz
  dnu=c/(dlambda*1.e-10) ;Hz
  flux=aperture_scaling*aperture_hst*10000.*dnu/(nu*h*1e7)*10.^((star_surface_brightness+48.60)/(-2.5))
 
  ;Now, this is the flux in 1.0 arcsec X 1.0 arcsec or 250 X 250 pixels. We need to know the flux in 400 X 400 pixels which will be 16 X this
  ;amount.

  ;The star background. Note that it is normalized to a flux of 1 before being multiplied by the total flux.
  stars_background_tmp=congrid(stars_background,400,400)
  stars_background_tmp=flux*stars_background_tmp/total(stars_background_tmp)

  ;Convolve with the PSF.
  stars_background_tmp=convolve(stars_background_tmp,psf)

  ;And rebin this to the pixel sampling of the camera.
  tmp=stars_background_tmp
  stars_background_tmp=congrid(tmp,f,f)
  stars_background_tmp=stars_background_tmp*total(tmp)/total(stars_background_tmp)

  ;And add it to the stars image.
  stars_tmp=stars_tmp+stars_background_tmp

 endif

 ;We now have the inset image of 4.0 arcsec X 4.0 arcsec with galaxy background in the case of the star field. It is in photons/pixel.

 ;Simulate the imager.
 image=fltarr(f,f)

 ;Multiply the images by the throughput and the unit exposure time. This results in e-/pixel.
 if (telescope_target eq 0) then begin
  image=image+throughput_atmosphere*throughput_instrument*optical_imager_exposure_unit*galaxies_tmp(0:s,0:s) 
 endif
 if (telescope_target eq 1) then begin
  image=image+throughput_atmosphere*throughput_instrument*optical_imager_exposure_unit*stars_tmp(0:s,0:s)
 endif

 ;First, calculate the background.
 background_tmp=congrid(background_total,r)
 background_tmp=(optical_imager_pixel^2)*background_tmp*(total(background_total))/total(background_tmp)/1000.

 ;Now integrate the light that is within the passband of the filter.
 background=0.
 for i=1,r-1 do begin
  tmp=(telescope_mirror(i)^telescope_surfaces)*(optical_imager_mirror(i)^optical_imager_surfaces)*filter(i)*detector(i)*background_tmp(i)
  if (tmp lt 0.) then begin
   tmp=0.
  endif
  background=background+tmp
 endfor

 ;Clean up
 background_tmp=0

 ;And add it to the images.
 image=image+optical_imager_exposure_unit*background

 ;Calculate and add the dark current.
 image=image+optical_imager_exposure_unit*optical_imager_dark

 ;Now, integrate the exposures.
 tmp_1=fltarr(f,f)
 tmp_2=tmp_1

 ;Make a copy of the unit exposure.
 tmp_1=image
 image=fltarr(f,f)

 ;Find the well depth in e-/pixel.
 optical_imager_well_depth=floor(optical_imager_gain*(2.^float(optical_imager_well)))

 ;Sum up the exposures.
 for i=1,optical_imager_exposure do begin

  ;For the first exposure.
  if (i eq 1) then begin

   ;Draw an arrow to the imaging display.

   ;Selected area.
   x_i=(x-157)*(210./778.)+30-7
   x_f=x_i+14
   y_i=(y-283)*(200./741.)+427-7
   y_f=y_i+14

   ;Black.
   arrow, 270, 626, x_f, y_f, /solid, hsize=0, color=0
   ;arrow, 270, 27, x_f, y_i, /solid, hsize=0, color=0
 
   ;White.
   arrow, 270, 625, x_f, y_f-1, /solid, hsize=0, color=255
   ;arrow, 270, 28, x_f, y_i+1, /solid, hsize=0, color=255

   ;And set up the imaging display.
   tmp=fltarr(600,600)
   tv, tmp, 270, 27

   ;Labels.
   xyouts, 270, 657, 'OI Target Field', charsize=size_print, color=0, /device
   xyouts, 270, 642, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device
 
  endif

  ;Expose the image.

  ;Add poisson noise.
  tmp=fltarr(f,f)
  tmp=sqrt(tmp_1)*randomn(seed,f,f)
  tmp_2=tmp_1+tmp

  ;Note, you can't have fractions of e-/pixel.
  tmp_2=round(tmp_2)

  ;Ensure that the exposure is not under or over the well-depth.
  for j=0,f-1 do begin
   for k=0,f-1 do begin
    if (tmp_2(j,k) lt 0.) then begin
     tmp_2(j,k)=0.
    endif
    if (tmp_2(j,k) gt optical_imager_well_depth) then begin
     tmp_2(j,k)=optical_imager_well_depth
    endif
   endfor
  endfor

  ;Read out the image. Add readout noise and apply the gain. The output is in DU/pixel.
  tmp=fltarr(f,f)
  tmp=optical_imager_readout*randomn(seed,f,f)
  image=image+(1./optical_imager_gain)*(tmp_2+tmp)

  ;Display the image.
  tmp=congrid(image-min(image),600,600)
  tvscl, tmp^0.1, 270, 27

  ;Number of completed exposures.
  if (telescope_target eq 0) then begin
   blank=fltarr(50,17)
   blank=blank+255
   tv, blank, 190, 200
   completed_tmp=completed_tmp+1
   xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
   xyouts, 240, 202, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
  endif
  if (telescope_target eq 1) then begin
   blank=fltarr(50,17)
   blank=blank+255
   tv, blank, 190, 290
   completed_tmp=completed_tmp+1
   xyouts, 30, 292, 'Number completed = ', charsize=size_print, color=0, /device 
   xyouts, 240, 292, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
  endif

 endfor

 ;We now have the output image from the imager with units of DU/pixel.

 ;Subtract the background and dark.
 image=image-optical_imager_exposure*optical_imager_exposure_unit*(1./optical_imager_gain)*(background+optical_imager_dark)

 ;Correct for throughput, gain, and exposure time. The result is in photons/pixel/s.
 tmp=(1./(optical_imager_exposure*optical_imager_exposure_unit))*(1./(throughput_atmosphere*throughput_instrument))*optical_imager_gain
 image=tmp*image

 ;Write out the images. Shut this off in the case of WWW code generation.
 if (www eq 0) then begin
  if (telescope_target eq 0) then begin
   writefits, './virtual_telescope_results/optical_imager_galaxies.fits', image
   writefits, './virtual_telescope_results/optical_imager_galaxies_true.fits', galaxies_tmp
   writefits, './virtual_telescope_results/optical_imager_galaxies_disk_true.fits', galaxies_disk_tmp
  endif
  if (telescope_target eq 1) then begin
   writefits, './virtual_telescope_results/optical_imager_stars.fits', image
   writefits, './virtual_telescope_results/optical_imager_stars_true.fits', stars_tmp
  endif
 endif

 ;Analysis.

 ;Determine filter label.
 filter_tmp=strarr(9)
 filter_tmp(0)='open'
 filter_tmp(1)='u'
 filter_tmp(2)='b'
 filter_tmp(3)='v'
 filter_tmp(4)='r'
 filter_tmp(5)='i'
 filter_tmp(6)='j'
 filter_tmp(7)='h'
 filter_tmp(8)='k' 

 ;Read the previous photometry from the file.
 tmp_2=fltarr(20000)
 tmp_3=tmp_2
 tmp_4=tmp_2
 tmp_5=tmp_2
 tmp_6=tmp_2
 tmp_7=tmp_2
 tmp_8=tmp_2
 file='./virtual_telescope_results/photometry_optical_imager_'+filter_tmp(optical_imager_filter)+'.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, aa, bb, cc, dd, ee, ff, gg, hh
  tmp_2(aa)=bb
  tmp_3(aa)=cc
  tmp_4(aa)=dd
  tmp_5(aa)=ee
  tmp_6(aa)=ff
  tmp_7(aa)=gg
  tmp_8(aa)=hh
 endwhile
 close, unit
 free_lun, unit

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Find the mean surface brightness in the image.
  photometry=total(image)

  ;But this is for 4.0 arcsec X 4.0 arcsec. We divide by 16 to get the mean flux per arcsec^2.
  photometry=photometry/16.

  ;And the surface brightness is given by.
  flux=photometry*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
  surface_brightness=-2.5*alog10(flux)-48.6

  ;Calculate the signal-to-noise ratio everywhere by using the true image and finding
  ;the RMS of the fluctuations.
  signal_to_noise=total(image)/total(sqrt((image-galaxies_tmp)^2))
  if (signal_to_noise lt 0.) then begin
   signal_to_noise=0.
  endif

  ;The bulge images.
  image_bulge=image-smooth(galaxies_disk_tmp,5)

  ;Thus the measured bulge-to-total is.
  bulge_to_total=total(image_bulge)/total(image)

  ;Print this to the screen.
  xyouts, 30, 172, 'Mean Values for Target Field', charsize=size_print, color=0, /device 
  xyouts, 30, 157, 'SB observed = ', charsize=size_print, color=0, /device
  tmp=string(surface_brightness)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6) 
  xyouts, 240, 157, tmp, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 142, 'SB true = ', charsize=size_print, color=0, /device
  tmp=string(surface_brightness_true)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6) 
  xyouts, 240, 142, tmp, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 127, 'S/N (1/pixel) = ', charsize=size_print, color=0, /device 
  xyouts, 240, 127, signal_to_noise, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 112, 'B/T observed = ', charsize=size_print, color=0, /device
  tmp=string(bulge_to_total)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 112, tmp, alignment=1.0,charsize=size_print, color=0, /device
  xyouts, 30, 97, 'B/T true = ', charsize=size_print, color=0, /device
  tmp=string(bulge_to_total_true)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 97, tmp, alignment=1.0,charsize=size_print, color=0, /device

  ;Save the values to the file variables.
  tmp_2(galaxies_last)=surface_brightness
  tmp_3(galaxies_last)=surface_brightness_true
  tmp_4(galaxies_last)=signal_to_noise
  tmp_5(galaxies_last)=bulge_to_total
  tmp_6(galaxies_last)=bulge_to_total_true

  ;Put a cross-hairs in the displayed image.
  arrow, 570-15, 327, 570+15, 327, /solid, hsize=0, color=255
  arrow, 570, 327-15, 570, 327+15, /solid, hsize=0, color=255

 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;The image sections. We select 0.4 arcsec X 0.4 arcsec sections which correspond to the 
  ;subsection of the PSF.
  x_w=floor(0.4/optical_imager_pixel)
  tmp_1=fltarr(x_w,x_w)

  ;Now, rebin the subsection PSF to the camera pixel sampling.
  tmp=psf(80:119,80:119)
  psf_tmp=congrid(tmp,x_w,x_w)

  ;Normalize to a flux of 1.
  psf_tmp=psf_tmp/total(psf_tmp)

  ;For all the stars in the list.
  for i=0,stars_total_number do begin

   ;Find out if the star is in the smaller field.
   if ((stars_list_x_pos(i) gt x-20) and (stars_list_x_pos(i) lt x+19)) then begin
    if ((stars_list_y_pos(i) gt y-20) and (stars_list_y_pos(i) lt y+19)) then begin

     ;We need to know the true flux of the star. First, how much fainter the star will be
     ;if it is not in I.

     ;For I.
     magnitude_tmp=stars_list_magnitude(i)

     ;For R.
     if ((optical_imager_filter eq 3) or (optical_imager_filter eq 4) or (optical_imager_filter eq 6) or (optical_imager_filter eq 7) or (optical_imager_filter eq 7) or (optical_imager_filter eq 8)) then begin

      ;If the star is on the ZAMS.
      if (stars_list_classification(i) eq 0) then begin
       colour_tmp=colour_magnitude_1(floor(40.*stars_list_magnitude(i)))
       magnitude_tmp=stars_list_magnitude(i)+colour_tmp
      endif
     
      ;Now, if this is a white dwarf we need a different colour magnitude diagram.
      if (stars_list_classification(i) eq 1) then begin
       colour_tmp=colour_magnitude_2(floor(40.*stars_list_magnitude(i)))
       magnitude_tmp=stars_list_magnitude(i)+colour_tmp
      endif

     endif

     ;Now, for the remaining colours we simply shift a small amount blue or red.

     ;For V.
     if (optical_imager_filter eq 3) then begin
      magnitude_tmp=stars_list_magnitude(i)+colour_tmp*star_colour_shift_1
     endif

     ;For J.
     if (optical_imager_filter eq 6) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_2
     endif

     ;For H.
     if (optical_imager_filter eq 7) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_3
     endif

     ;For K.
     if (optical_imager_filter eq 8) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_4
     endif
  
     ;Find the true flux for the star. This is in photons.
     c=299792458. ;m/s
     h=6.6260755e-34 ;Joule/s
     nu=c/(lambda*1.e-10) ;Hz
     dnu=c/(dlambda*1.e-10) ;Hz
     flux=aperture_scaling*aperture_hst*10000.*dnu/(nu*h*1e7)*10.^((magnitude_tmp+48.60)/(-2.5))

     ;Which corresponds to an AB-magnitude of.
     magnitude_true=magnitude_tmp

     ;Determine the section from the image.
     x_tmp=floor((0.075/optical_imager_pixel)*(stars_list_x_pos(i)-(x-26.7)))
     y_tmp=floor((0.075/optical_imager_pixel)*(stars_list_y_pos(i)-(y-26.7)))
     x_i=x_tmp-floor(x_w/2.)
     x_f=x_i+x_w-1
     y_i=y_tmp-floor(x_w/2.)
     y_f=y_i+x_w-1

     ;Label the screen.
     x_i_screen=270+600.*((x_tmp)/((0.004/optical_imager_pixel)*1000.))-5
     y_i_screen=27+600.*((y_tmp)/((0.004/optical_imager_pixel)*1000.))-5
     arrow, x_i_screen, y_i_screen+5, x_i_screen+10, y_i_screen+5, /solid, hsize=0, color=255
     arrow, x_i_screen+5, y_i_screen, x_i_screen+5, y_i_screen+10, /solid, hsize=0, color=255

     ;Now, generate the true image with the star of interest subtracted.
     tmp=fltarr(x_w,x_w)
     tmp=stars_tmp(x_i:x_f,y_i:y_f)
     tmp=tmp-flux*psf_tmp

     ;Star photometry.
     ;tmp_1=image(x_i:x_f,y_i:y_f)-smooth(tmp,5)
     tmp_1=image(x_i:x_f,y_i:y_f)-tmp
     photometry=total(tmp_1)
     flux=photometry*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
     magnitude=-2.5*alog10(flux)-48.6

     ;And save these to the file.
     if (magnitude_true lt 35.) then begin
      tmp_7(i)=magnitude
      tmp_8(i)=magnitude_true
     endif

    endif
   endif
  endfor
 endif

 ;Write the results to a file.
 get_lun, unit
 openw, unit, './virtual_telescope_results/photometry_optical_imager_'+filter_tmp(optical_imager_filter)+'.dat'
 for i=0,9999 do begin
  printf, unit, i, tmp_2(i), tmp_3(i), tmp_4(i), tmp_5(i), tmp_6(i), tmp_7(i), tmp_8(i)
 endfor
 close, unit
 free_lun, unit

 ;Save the screen to an image.
 if (www eq 1) then begin
 
  ;Save the screen output.
  screen_output=tvrd()
 
 endif

 ;Set the toggle to 1.
 optical_imager_done=1

 endif
end

;--------------------------------------------------------------------------------
;Run the infrared camera simulation.
pro infrared_camera_simulation

common  variables, $
        galaxy_bulge_radius, galaxy_disk_radius, galaxy_bulge_to_total_1, galaxy_bulge_to_total_2, galaxy_bulge_to_total_3, $
        galaxy_bulge_to_total_4, galaxy_cutoff, galaxy_faint, galaxy_multiple, galaxy_shift, galaxy_shrink, galaxy_correlation, $
        galaxy_line_width, $
        star_cutoff, star_faint, star_multiple, star_correlation, star_white_bright, star_white_fraction, star_surface_brightness, $
        star_distance_modulus, $
        telescope_temperature, telescope_primary, telescope_diameter, telescope_roughness, telescope_surfaces, telescope_error, $
        telescope_target, $
        optical_imager_filter, optical_imager_comparison, optical_imager_surfaces, optical_imager_detector, optical_imager_pixel, $
        optical_imager_readout, optical_imager_dark, optical_imager_gain, optical_imager_well, optical_imager_flag, optical_imager_exposure, $
        optical_imager_exposure_unit, $
        spectrograph_flag, spectrograph_resolution, spectrograph_slices, spectrograph_slits, spectrograph_length, spectrograph_width, $
        spectrograph_exposure, spectrograph_exposure_unit, spectrograph_position, spectrograph_extract, spectrograph_filter, $
        spectrograph_comparison, spectrograph_surfaces, spectrograph_detector, spectrograph_pixel, spectrograph_readout, spectrograph_dark, $
        spectrograph_gain, spectrograph_well, $
        target_flag, $
        pupil, aperture_hst, aperture_scaling, $
        mirror_coating_aluminum, mirror_coating_silver, mirror_coating_gold, grating_efficiency, filters, filter_bandpasses, $
        detector_efficiency_1, detector_efficiency_2, detector_efficiency_3, spectrum_1, spectrum_2, spectrum_3, spectrum_4, $
        colour_magnitude_1, colour_magnitude_2, $
        star_colour_shift_1, star_colour_shift_2, star_colour_shift_3, star_colour_shift_4, $
        background_total, atmospheric_transmission, $
        galaxy, galaxy_fake, galaxy_disk, galaxy_redshift, galaxy_magnitude, galaxy_classification, galaxy_radius, $
        galaxies, galaxies_redshift, galaxies_weight, galaxies_magnitude, galaxies_classification, galaxies_radius, galaxies_hst, $
        galaxies_telescope, galaxies_1, galaxies_2, galaxies_3, galaxies_4, galaxies_5, galaxies_list_x_pos, galaxies_list_y_pos, $
        galaxies_list_magnitude, galaxies_list_redshift, galaxies_list_classification, galaxies_list_radius, galaxies_list_rotate, $
        galaxies_list_ellipticity, galaxies_total_number, galaxies_total_number_hst, galaxies_number_counts, galaxies_number_counts_hst, $
        galaxies_number_counts_label, galaxies_distribution_magnitude, galaxies_distribution_redshift, galaxies_distribution_magnitude_hst, $
        galaxies_distribution_redshift_hst, galaxies_distribution_radius, galaxies_distribution_radius_hst, $
        star, star_fwhm, star_strehl, $
        stars, stars_hst, stars_telescope, stars_background, stars_list_magnitude, stars_list_x_pos, stars_list_y_pos, $
        stars_list_classification, stars_total_number, stars_total_number_hst, stars_number_counts, stars_number_counts_hst, $
        stars_number_counts_label, $
        spectrum, spectrum_extract, spectrum_true_extract, $
        x, y, $
        photometry, ratio, galaxy_radius_output, $
        statistics_magnitude, statistics_ratio, $
        colour_table, size_print, screen_output, $
        www, www_background, $
        initialize_field_done, initialize_telescope_done, optical_imager_done, infrared_camera_done,  $
        select_done, spectrum_integral_field_unit_done, spectrum_single_done, spectrum_multiplex_done, $
        field_running, telescope_running, oi_running, mos_running, $
        window_id

 ;Check for initialization.
 if (select_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must select a target first.', charsize=size_print, color=0, /device
 endif
 if (select_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255

 ;Optical.
 if (spectrograph_filter le 5) then begin
  loadct, 1, /silent
 endif

 ;Infrared.
 if (spectrograph_filter gt 5) then begin
  loadct, 3, /silent
 endif

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Show the field.
  tmp=fltarr(778,741)
  tmp=galaxies_telescope(157:934,283:1023)
  tmp_1=congrid(tmp,210,200)
  tv, tmp_1, 30, 427
 
  ;Labels.
  xyouts, 30, 657, 'Galaxy Field', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

  ;Selected area.
  x_i=(x-157)*(210./778.)+30-7
  x_f=x_i+14
  y_i=(y-283)*(200./741.)+427-7
  y_f=y_i+14
  arrow, x_i, y_i, x_f, y_i, /solid, hsize=0, color=255
  arrow, x_f, y_i, x_f, y_f, /solid, hsize=0, color=255
  arrow, x_f, y_f, x_i, y_f, /solid, hsize=0, color=255
  arrow, x_i, y_f, x_i, y_i, /solid, hsize=0, color=255

  ;Determine properties of the galaxy.
  galaxy_magnitude=galaxies_magnitude(x,y)
  galaxy_redshift=galaxies_redshift(x,y)
  galaxy_classification=galaxies_classification(x,y)
  galaxy_radius=galaxies_radius(x,y)
  tmp_1=strarr(6)
  tmp_1(0)='background'
  tmp_1(1)='E/S0'
  tmp_1(2)='Sbc'
  tmp_1(3)='Scd'
  tmp_1(4)='Irr'
  tmp_1(5)='stellar'
  if (floor(galaxy_classification) eq 0) then begin
   galaxy_radius=0. 
  endif

  ;Print information to the screen.
  xyouts, 30, 397, 'MOS Imaging', charsize=size_print, color=0, /device
  xyouts, 30, 382, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device 
  xyouts, 30, 352, 'Centre of Target Field', charsize=size_print, color=0, /device 
  xyouts, 30, 337, 'z = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_redshift)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 337, tmp, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 322, 'H(AB) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_magnitude)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6)
  xyouts, 240, 322, tmp, alignment=1.0,charsize=size_print, color=0, /device
  xyouts, 30, 307, 'Object type = ', charsize=size_print, color=0, /device 
  xyouts, 240, 307, tmp_1(galaxy_classification), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 292, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_radius)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 292, tmp, alignment=1.0, charsize=size_print, color=0, /device

  ;Determine properties of the exposure.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  completed_tmp=0

  ;Print information to the screen.
  xyouts, 30, 262, 'Exposure', charsize=size_print, color=0, /device 
  xyouts, 30, 247, 'Filter = ', charsize=size_print, color=0, /device 
  xyouts, 240, 247, tmp(spectrograph_filter), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 232, 'Unit exposure (s) = ', charsize=size_print, color=0, /device 
  xyouts, 240, 232, spectrograph_exposure_unit, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 217, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 217, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
  xyouts, 240, 202, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
  wait, 1

 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;Display the image.
  tmp=fltarr(778,741)
  tmp=stars_telescope(157:934,283:1023)
  tmp_1=congrid(tmp,210,200)
  tv, tmp_1, 30, 427

  ;Put a border around the image.
  arrow, 30, 427, 240, 427, /solid, hsize=0, color=0
  arrow, 240, 427, 240, 625, /solid, hsize=0, color=0
  arrow, 240, 625, 30, 625, /solid, hsize=0, color=0
  arrow, 30, 625, 30, 427, /solid, hsize=0, color=0
 
  ;Labels.
  xyouts, 30, 657, 'Star Field', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

  ;Selected area.
  x_i=(x-157)*(210./778.)+30-7
  x_f=x_i+14
  y_i=(y-283)*(200./741.)+427-7
  y_f=y_i+14
  arrow, x_i, y_i, x_f, y_i, /solid, hsize=0, color=255
  arrow, x_f, y_i, x_f, y_f, /solid, hsize=0, color=255
  arrow, x_f, y_f, x_i, y_f, /solid, hsize=0, color=255
  arrow, x_i, y_f, x_i, y_i, /solid, hsize=0, color=255

  ;Determine properties of the exposure.
  tmp=strarr(9)
  tmp(0)='open'
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  completed_tmp=0

  ;Print information to the screen.
  xyouts, 30, 397, 'MOS Imaging', charsize=size_print, color=0, /device
  xyouts, 30, 382, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device
  xyouts, 30, 352, 'Exposure', charsize=size_print, color=0, /device 
  xyouts, 30, 337, 'Filter = ', charsize=size_print, color=0, /device 
  xyouts, 240, 337, tmp(spectrograph_filter), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 322, 'Unit exposure (s) = ', charsize=size_print, color=0, /device 
  xyouts, 240, 322, spectrograph_exposure_unit, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 307, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 307, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 292, 'Number completed = ', charsize=size_print, color=0, /device 
  xyouts, 240, 292, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
  wait, 1

 endif

 ;Print a message to the screen.
 xyouts, 525, 365, 'Initializing ...', charsize=size_print, color=0, /device

 ;Initialize.
 r=100

 if ((telescope_primary eq 0) or (telescope_primary eq 2) or (telescope_primary eq 3)) then begin
  telescope_mirror=congrid(mirror_coating_aluminum(0:2999),r)
 endif
 if (telescope_primary eq 1) then begin
  telescope_mirror=congrid(mirror_coating_gold(0:2999),r)
 endif
 transmission=congrid(atmospheric_transmission(0:29999),r)
 spectrograph_mirror=congrid(mirror_coating_gold(0:2999),r)
 tmp=fltarr(3000)
 tmp=filters(spectrograph_filter,0:2999)
 filter=fltarr(r)
 filter(0:r-1)=congrid(tmp(0:2999),r)
 tmp=fltarr(3000)
 tmp=filters(7,0:2999)
 filter_h=fltarr(r)
 filter_h(0:r-1)=congrid(tmp(0:2999),r)
 if (spectrograph_detector eq 0) then begin
  detector=congrid(detector_efficiency_1(0:2999),r)
 endif
 if (spectrograph_detector eq 1) then begin
  detector=congrid(detector_efficiency_2(0:2999),r)
 endif
 if (spectrograph_detector eq 2) then begin
  detector=congrid(detector_efficiency_3(0:2999),r)
 endif
 spectrum_1_tmp=congrid(spectrum_1(0:29999),3000)
 spectrum_2_tmp=congrid(spectrum_2(0:29999),3000)
 spectrum_3_tmp=congrid(spectrum_3(0:29999),3000)
 spectrum_4_tmp=congrid(spectrum_4(0:29999),3000)

 ;Determine the filter central wavelength.
 if (spectrograph_filter eq 1) then begin
  lambda=2500. ;A
  dlambda=500. ;A
 endif
 if (spectrograph_filter eq 2) then begin
  lambda=3000. ;A
  dlambda=500. ;A
 endif
 if (spectrograph_filter eq 3) then begin
  lambda=4500. ;A
  dlambda=500. ;A
 endif
 if (spectrograph_filter eq 4) then begin
  lambda=6060. ;A
  dlambda=1000. ;A
 endif
 if (spectrograph_filter eq 5) then begin
  lambda=8140. ;A
  dlambda=1000. ;A
 endif
 if (spectrograph_filter eq 6) then begin
  lambda=11000. ;A
  dlambda=3500. ;A
 endif
 if (spectrograph_filter eq 7) then begin
  lambda=16000. ;A
  dlambda=3500. ;A
 endif
 if (spectrograph_filter eq 8) then begin
  lambda=22000. ;A
  dlambda=3500. ;A
 endif

 ;Calculate the throughput.
 tmp=fltarr(r)
 tmp=tmp+1.
 throughput_atmosphere=total(transmission*filter*tmp)/total(filter*tmp)
 throughput_instrument=total((telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*filter*detector*tmp)/total(filter*tmp)

 ;Calculate the PSF for the given filter. Remember that the original sampling is 0.01 arcsec/pixel and that the input PSFs are 2 arcsec X 2 
 ;arcsec or 200 X 200 pixels.

 ;Now, construct the PSF for the given filter.
 psf=fltarr(200,200)
 for i=0,r-1 do begin
  psf(0:199,0:199)=psf(0:199,0:199)+filter(i)*star(floor((30/r)*i),0:199,0:199)
 endfor

 ;Normalize to have a total flux of 1.
 psf=psf/total(psf)

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;The full images.
  galaxies_tmp=fltarr(1000,1000)
  galaxies_disk_tmp=galaxies_tmp

  ;Run through all the galaxies in the list.
  for i=0,galaxies_total_number do begin

   ;Find out if the galaxy is in the larger field. Note, these coordinates are in units of 0.075 arcsec/pixel. That is, 875 pixels at 0.004
   ;arcsec/pixel corresponds to 47 at 0.075 arcsec/pixel.
   if ((galaxies_list_x_pos(i) gt x-46) and (galaxies_list_x_pos(i) lt x+46)) then begin
    if ((galaxies_list_y_pos(i) gt y-46) and (galaxies_list_y_pos(i) lt y+46)) then begin

     print, i

     ;We know the catalog flux for this galaxy. This is in H.
     lambda_tmp=16000.
     dlambda_tmp=3500.
     c=299792458. ;m/s
     h=6.6260755e-34 ;Joule/s
     nu=c/(lambda_tmp*1.e-10) ;Hz
     dnu=c/(dlambda_tmp*1.e-10) ;Hz
     flux=aperture_scaling*aperture_hst*10000.*dnu/(nu*h*1e7)*10.^((galaxies_list_magnitude(i)+48.60)/(-2.5))

     ;Now, we need to find what fraction fainter or brighter the galaxy is in the new filter. This is done by finding how much light will pass
     ;through both the new filter and H filter in the redshifted galaxy spectrum.
     if (floor(galaxies_list_classification(i)) eq 1) then begin
      blue=0
      red=floor(2000./(1.+galaxies_list_redshift(i)))-1      
      tmp=congrid(spectrum_1_tmp(blue:red),r)
      fraction=total(filter*tmp)/total(filter_h*tmp)
     endif
     if (floor(galaxies_list_classification(i)) eq 2) then begin
      blue=0
      red=floor(2000./(1.+galaxies_list_redshift(i)))-1      
      tmp=congrid(spectrum_2_tmp(blue:red),r)
      fraction=total(filter*tmp)/total(filter_h*tmp)
     endif
     if (floor(galaxies_list_classification(i)) eq 3) then begin
      blue=0
      red=floor(2000./(1.+galaxies_list_redshift(i)))-1      
      tmp=congrid(spectrum_3_tmp(blue:red),r)
      fraction=total(filter*tmp)/total(filter_h*tmp)
     endif
     if (floor(galaxies_list_classification(i)) eq 4) then begin
      blue=0
      red=floor(2000./(1.+galaxies_list_redshift(i)))-1      
      tmp=congrid(spectrum_1_tmp(blue:red),r)
      fraction=total(filter*tmp)/total(filter_h*tmp)
     endif

     ;The positions of the images. Note, the simulation is 133.3 pixels at 0.075 arcsec/pixel. Half of this is 66.7 pixels.
     x_tmp=floor((0.075/0.01)*(galaxies_list_x_pos(i)-(x-66.7)))
     y_tmp=floor((0.075/0.01)*(galaxies_list_y_pos(i)-(y-66.7)))

     ;We assign the classification, ellipticity, rotation, and scale factor.
     classification_tmp=galaxies_list_classification(i)
     rotate_tmp=galaxies_list_rotate(i)
     factor_tmp=galaxies_list_radius(i)/0.461594
     ellipticity_tmp=galaxies_list_ellipticity(i)
     
     ;In x.
     x_f=floor(ellipticity_tmp*factor_tmp*150.)
     if (x_f lt 2) then begin
      x_f=2
     endif
     x_s=x_f-1

     ;In y.
     y_f=floor(factor_tmp*150.)
     if (y_f lt 2) then begin
      y_f=2
     endif
     y_s=y_f-1

     ;Now if this is a star then the image is full size.
     if (classification_tmp eq 5) then begin
      x_f=150
      y_f=150
      x_s=x_f-1
      y_s=y_f-1
     endif

     ;Generate a fake galaxy. This is scaled and rotated.
 
     ;First, take the fake galaxy image.
     tmp=fltarr(300,300)
     tmp(0:299,0:299)=galaxy_fake(classification_tmp-1,0:299,0:299)

     ;Scale it.
     galaxy_fake_tmp=congrid(tmp,2*x_f,2*y_f)

     ;Ensure flux is conserved.
     galaxy_fake_tmp=galaxy_fake_tmp*total(tmp)/total(galaxy_fake_tmp)

     ;Insert back into a full image.
     tmp=galaxy_fake_tmp
     galaxy_fake_tmp=fltarr(300,300)
     galaxy_fake_tmp(150-x_f:150+x_s,150-y_f:150+y_s)=tmp(0:x_f+x_s,0:y_f+y_s)

     ;And rotate.
     galaxy_fake_tmp=rot(galaxy_fake_tmp,rotate_tmp)

     ;Place the galaxy in the output image.
     galaxies_tmp(x_tmp-150:x_tmp+149,y_tmp-150:y_tmp+149)=galaxies_tmp(x_tmp-150:x_tmp+149,y_tmp-150:y_tmp+149)+fraction*flux*galaxy_fake_tmp

     ;Also, the disk.

     ;First, take the fake disk image.
     tmp=fltarr(300,300)
     tmp(0:299,0:299)=galaxy_disk(classification_tmp-1,0:299,0:299)

     ;Scale it.
     galaxy_disk_tmp=congrid(tmp,2*x_f,2*y_f)

     ;Ensure flux is conserved.
     galaxy_disk_tmp=galaxy_disk_tmp*total(tmp)/total(galaxy_disk_tmp)

     ;Insert back into a full image.
     tmp=galaxy_disk_tmp
     galaxy_disk_tmp=fltarr(300,300)
     galaxy_disk_tmp(150-x_f:150+x_s,150-y_f:150+y_s)=tmp(0:x_f+x_s,0:y_f+y_s)

     ;And rotate.
     galaxy_disk_tmp=rot(galaxy_disk_tmp,rotate_tmp)

     ;Place the galaxy in the output image.
     galaxies_disk_tmp(x_tmp-150:x_tmp+149,y_tmp-150:y_tmp+149)=galaxies_disk_tmp(x_tmp-150:x_tmp+149,y_tmp-150:y_tmp+149)+fraction*flux*galaxy_disk_tmp

     ;Set the counter to the last galaxy.
     galaxies_last=i

    endif
   endif
  endfor
 
 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;The full images.
  stars_tmp=fltarr(1000,1000)

  ;Run through all the stars in the list.
  for i=0,stars_total_number do begin

  ;Find out if the star is in the larger field. Note, these coordinates are in units of 0.075 arcsec/pixel. That is, 875 pixels at 0.004
  ;arcsec/pixel corresponds to 47 at 0.075 arcsec/pixel.
  if ((stars_list_x_pos(i) gt x-46) and (stars_list_x_pos(i) lt x+46)) then begin
   if ((stars_list_y_pos(i) gt y-46) and (stars_list_y_pos(i) lt y+46)) then begin

     print, i

     ;Put a star in the starfield. We need to know how much fainter the star will be
     ;if it is not in I.

     ;For I.
     magnitude_tmp=stars_list_magnitude(i)

     ;For R.
     if ((spectrograph_filter eq 3) or (spectrograph_filter eq 4) or (spectrograph_filter eq 6) or (spectrograph_filter eq 7) or (spectrograph_filter eq 7) or (spectrograph_filter eq 8)) then begin

      ;If the star is on the ZAMS.
      if (stars_list_classification(i) eq 0) then begin
       colour_tmp=colour_magnitude_1(floor(40.*stars_list_magnitude(i)))
       magnitude_tmp=stars_list_magnitude(i)+colour_tmp
      endif
     
      ;Now, if this is a white dwarf we need a different colour magnitude diagram.
      if (stars_list_classification(i) eq 1) then begin
       colour_tmp=colour_magnitude_2(floor(40.*stars_list_magnitude(i)))
       magnitude_tmp=stars_list_magnitude(i)+colour_tmp
      endif

     endif

     ;Now, for the remaining colours we simply shift a small amount blue or red.

     ;For V.
     if (spectrograph_filter eq 3) then begin
      magnitude_tmp=stars_list_magnitude(i)+colour_tmp*star_colour_shift_1
     endif

     ;For J.
     if (spectrograph_filter eq 6) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_2
     endif

     ;For H.
     if (spectrograph_filter eq 7) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_3
     endif

     ;For K.
     if (spectrograph_filter eq 8) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_4
     endif

     ;Find the flux for the star.
     c=299792458. ;m/s
     h=6.6260755e-34 ;Joule/s
     nu=c/(lambda*1.e-10) ;Hz
     dnu=c/(dlambda*1.e-10) ;Hz
     flux=aperture_scaling*aperture_hst*10000.*dnu/(nu*h*1e7)*10.^((magnitude_tmp+48.60)/(-2.5))

     ;The positions of the images. Note, the simulation is 133.3 pixels at 0.075 arcsec/pixel.
     ;Half of this is 66.7 pixels.
     x_tmp=floor((0.075/0.01)*(stars_list_x_pos(i)-(x-66.7)))
     y_tmp=floor((0.075/0.01)*(stars_list_y_pos(i)-(y-66.7)))

     ;Generate the star image and add it to the field.
     stars_tmp(x_tmp-100:x_tmp+99,y_tmp-100:y_tmp+99)=stars_tmp(x_tmp-100:x_tmp+99,y_tmp-100:y_tmp+99)+flux*psf

    endif
   endif
  endfor
 endif

 ;We now have 1 second images of stars or galaxies in units of photons for the chosen filter.

 ;We convolve with the PSF and then rebin the images to the pixel sampling of the camera. Note, this is the smaller inset region that we expand.
 ;This is only 4.0 arcsec X 4.0 arcsec.
 f=floor(4./spectrograph_pixel)
 s=f-1

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Galaxies.
  tmp=galaxies_tmp(300:699,300:699)

  ;And convolve with the PSF.
  tmp=convolve(tmp,psf)

  ;Photometry in the true image.
  photometry_galaxies=total(tmp)

  ;But this is for 4.0 arcsec X 4.0 arcsec. We divide by 16 to get the mean flux per arcsec^2.
  photometry=photometry_galaxies/16.

  ;And the true surface brightness is given by.
  flux=photometry*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
  surface_brightness_true=-2.5*alog10(flux)-48.6

  ;And rebin.
  galaxies_tmp=congrid(tmp,f,f)
  galaxies_tmp=galaxies_tmp*total(tmp)/total(galaxies_tmp)

  ;Galaxy disks.
  tmp=galaxies_disk_tmp(300:699,300:699)

  ;Photometry in the true image.
  photometry_galaxies_disk=total(tmp)

  ;Thus the true bulge-to-total is.
  bulge_to_total_true=(photometry_galaxies-photometry_galaxies_disk)/photometry_galaxies
  if (bulge_to_total_true lt 0.) then begin
   bulge_to_total_true=0.
  endif

  ;And convolve with the PSF.
  tmp=convolve(tmp,psf)

  ;And rebin.
  galaxies_disk_tmp=congrid(tmp,f,f)
  galaxies_disk_tmp=galaxies_disk_tmp*total(tmp)/total(galaxies_disk_tmp)

 endif

 ;Stars.
 if (telescope_target eq 1) then begin
  
  ;Rebin the stars image.
  tmp=stars_tmp(300:699,300:699)
  stars_tmp=congrid(tmp,f,f)
  stars_tmp=stars_tmp*total(tmp)/total(stars_tmp)

  ;Calculate the surface brightness of the background.
  c=299792458. ;m/s
  h=6.6260755e-34 ;Joule/s
  nu=c/(lambda*1.e-10) ;Hz
  dnu=c/(dlambda*1.e-10) ;Hz
  flux=aperture_scaling*aperture_hst*10000.*dnu/(nu*h*1e7)*10.^((star_surface_brightness+48.60)/(-2.5))
 
  ;Now, this is the flux in 1.0 arcsec X 1.0 arcsec or 250 X 250 pixels. We need to know the flux
  ;in 1000 X 1000 pixels which will be 16 X this amount.

  ;The star background. Note that it is normalized to a flux of 1 before being multiplied by the
  ;total flux.
  stars_background_tmp=congrid(stars_background,1000,1000)
  stars_background_tmp=flux*stars_background_tmp/total(stars_background_tmp)

  ;Convolve with the PSF.
  stars_background_tmp=convolve(stars_background_tmp,psf)

  ;And rebin this to the pixel sampling of the camera.
  tmp=stars_background_tmp
  stars_background_tmp=congrid(tmp,f,f)
  stars_background_tmp=stars_background_tmp*total(tmp)/total(stars_background_tmp)

  ;And add it to the stars image.
  stars_tmp=stars_tmp+stars_background_tmp

 endif

 ;Simulate the infrared camera.
 image=fltarr(f,f)

 ;Multiply the images by the throughput and the unit exposure time. This results in e-/pixel.
 if (telescope_target eq 0) then begin
  image=image+throughput_atmosphere*throughput_instrument*spectrograph_exposure_unit*galaxies_tmp(0:s,0:s) 
 endif
 if (telescope_target eq 1) then begin
  image=image+throughput_atmosphere*throughput_instrument*spectrograph_exposure_unit*stars_tmp(0:s,0:s)
 endif

 ;First, calculate the background.
 background_tmp=congrid(background_total,r)
 background_tmp=(spectrograph_pixel^2)*background_tmp*(total(background_total))/total(background_tmp)/1000.

 ;Now integrate the light that is within the passband of the filter.
 background=0.
 for i=1,r-1 do begin
  tmp=(telescope_mirror(i)^telescope_surfaces)*(spectrograph_mirror(i)^spectrograph_surfaces)*filter(i)*detector(i)*background_tmp(i)
  if (tmp lt 0.) then begin
   tmp=0.
  endif
  background=background+tmp
 endfor

 ;And add it to the images.
 image=image+spectrograph_exposure_unit*background

 ;Calculate and add the dark current.
 image=image+spectrograph_exposure_unit*spectrograph_dark

 ;Now, integrate the exposures.
 tmp_1=fltarr(f,f)
 tmp_2=tmp_1

 ;Make a copy of the unit exposures.
 tmp_1=image
 image=fltarr(f,f)

 ;Temporary images.
 tmp_2=fltarr(f,f)

 ;Find the well depth.
 spectrograph_well_depth=spectrograph_gain*(2.^float(spectrograph_well))
 
 ;Sum up the exposures.
 for i=1,spectrograph_exposure do begin

  ;For the first exposure.
  if (i eq 1) then begin

   ;Draw an arrow to the imaging display.

   ;Selected area.
   x_i=(x-157)*(210./778.)+30-7
   x_f=x_i+14
   y_i=(y-283)*(200./741.)+427-7
   y_f=y_i+14

   ;Black.
   arrow, 270, 626, x_f, y_f, /solid, hsize=0, color=0
   ;arrow, 270, 27, x_f, y_i, /solid, hsize=0, color=0
 
   ;White.
   arrow, 270, 625, x_f, y_f-1, /solid, hsize=0, color=255
   ;arrow, 270, 28, x_f, y_i+1, /solid, hsize=0, color=255

   ;And set up the imaging display.
   tmp=fltarr(600,600)
   tv, tmp, 270, 27

   ;Labels.
   xyouts, 270, 657, 'MOS Target Field', charsize=size_print, color=0, /device
   xyouts, 270, 642, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device
 
  endif

  ;Expose the image.

  ;Add poisson noise.
  tmp=fltarr(f,f)
  tmp=sqrt(tmp_1)*randomn(seed,f,f)
  tmp_2=tmp_1+tmp

  ;Note, you can't have fractions of e-/pixel.
  tmp_2=round(tmp_2)

  ;Ensure that the exposure is not under or over the well-depth.
  for j=0,f-1 do begin
   for k=0,f-1 do begin
    if (tmp_2(j,k) lt 0.) then begin
     tmp_2(j,k)=0.
    endif
    if (tmp_2(j,k) gt spectrograph_well_depth) then begin
     tmp_2(j,k)=spectrograph_well_depth
    endif
   endfor
  endfor

  ;Read out the image. Add readout noise and apply the gain. The output is in DU/pixel.
  tmp=fltarr(f,f)
  tmp=spectrograph_readout*randomn(seed,f,f)
  image=image+(1./spectrograph_gain)*(tmp_2+tmp)

  ;Display the image.
  tmp=congrid(image-min(image),600,600)
  tvscl, tmp^0.1, 270, 27

  ;Number of completed exposures.
  if (telescope_target eq 0) then begin
   blank=fltarr(50,17)
   blank=blank+255
   tv, blank, 190, 200
   completed_tmp=completed_tmp+1
   xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
   xyouts, 240, 202, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
  endif
  if (telescope_target eq 1) then begin
   blank=fltarr(50,17)
   blank=blank+255
   tv, blank, 190, 290
   completed_tmp=completed_tmp+1
   xyouts, 30, 292, 'Number completed = ', charsize=size_print, color=0, /device 
   xyouts, 240, 292, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
  endif

 endfor

 ;Subtract the background and dark.
 image=image-spectrograph_exposure*spectrograph_exposure_unit*(1./spectrograph_gain)*(background+spectrograph_dark)

 ;Correct for throughput, gain, and exposure time. The result is in photons/s.
 tmp=(1./(spectrograph_exposure*spectrograph_exposure_unit))*(1./(throughput_atmosphere*throughput_instrument))*spectrograph_gain
 image=tmp*image

 ;Write out the images. Shut this off in the case of WWW code generation.
 if (www eq 0) then begin
  if (telescope_target eq 0) then begin
   writefits, './virtual_telescope_results/spectrograph_galaxies.fits', image
   writefits, './virtual_telescope_results/spectrograph_galaxies_true.fits', galaxies_tmp
   writefits, './virtual_telescope_results/spectrograph_galaxies_disk_true.fits', galaxies_disk_tmp
  endif
  if (telescope_target eq 1) then begin
   writefits, './virtual_telescope_results/spectrograph_stars.fits', image
   writefits, './virtual_telescope_results/spectrograph_stars_true.fits', stars_tmp
  endif
 endif

 ;Analysis.

 ;Determine filter label.
 filter_tmp=strarr(9)
 filter_tmp(0)='open'
 filter_tmp(1)='u'
 filter_tmp(2)='b'
 filter_tmp(3)='v'
 filter_tmp(4)='r'
 filter_tmp(5)='i'
 filter_tmp(6)='j'
 filter_tmp(7)='h'
 filter_tmp(8)='k' 

 ;Read the previous photometry from the file.
 tmp_2=fltarr(20000)
 tmp_3=tmp_2
 tmp_4=tmp_2
 tmp_5=tmp_2
 tmp_6=tmp_2
 tmp_7=tmp_2
 tmp_8=tmp_2
 file='./virtual_telescope_results/photometry_spectrograph_'+filter_tmp(spectrograph_filter)+'.dat'
 openr, unit, file, /get_lun
 while not eof(unit) do begin 
  readf, unit, aa, bb, cc, dd, ee, ff, gg, hh
  tmp_2(aa)=bb
  tmp_3(aa)=cc
  tmp_4(aa)=dd
  tmp_5(aa)=ee
  tmp_6(aa)=ff
  tmp_7(aa)=gg
  tmp_8(aa)=hh
 endwhile
 close, unit
 free_lun, unit

 ;Galaxies.
 if (telescope_target eq 0) then begin

  ;Find the mean surface brightness in the image.
  photometry=total(image) 

  ;But this is for 4.0 arcsec X 4.0 arcsec. We divide by 16 to get the mean flux per arcsec^2.
  photometry=photometry/16.

  ;And the surface brightness is given by.
  flux=photometry*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
  surface_brightness=-2.5*alog10(flux)-48.6

  ;Calculate the signal-to-noise ratio everywhere by using the true image and finding
  ;the RMS of the fluctuations.
  signal_to_noise=total(image)/total(sqrt((image-galaxies_tmp)^2))
  if (signal_to_noise lt 0.) then begin
   signal_to_noise=0.
  endif

  ;The bulge images.
  image_bulge=image-smooth(galaxies_disk_tmp,5)

  ;Thus the measured bulge-to-total is.
  bulge_to_total=total(image_bulge)/total(image)

  ;Print this to the screen.
  xyouts, 30, 172, 'Mean Values for Target Field', charsize=size_print, color=0, /device 
  xyouts, 30, 157, 'SB observed = ', charsize=size_print, color=0, /device 
  tmp=string(surface_brightness)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6)
  xyouts, 240, 157, tmp, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 142, 'SB true = ', charsize=size_print, color=0, /device 
  tmp=string(surface_brightness_true)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6)
  xyouts, 240, 142, tmp, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 127, 'S/N (1/pixel) = ', charsize=size_print, color=0, /device 
  xyouts, 240, 127, signal_to_noise, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 112, 'B/T observed = ', charsize=size_print, color=0, /device
  tmp=string(bulge_to_total)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5) 
  xyouts, 240, 112, tmp, alignment=1.0,charsize=size_print, color=0, /device
  xyouts, 30, 97, 'B/T true = ', charsize=size_print, color=0, /device 
  tmp=string(bulge_to_total_true)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,5)
  xyouts, 240, 97, tmp, alignment=1.0,charsize=size_print, color=0, /device

  ;Save the values to the file variables.
  tmp_2(galaxies_last)=surface_brightness
  tmp_3(galaxies_last)=surface_brightness_true
  tmp_4(galaxies_last)=signal_to_noise
  tmp_5(galaxies_last)=bulge_to_total
  tmp_6(galaxies_last)=bulge_to_total_true

  ;Put a cross-hairs in the displayed image.
  arrow, 570-15, 327, 570+15, 327, /solid, hsize=0, color=255
  arrow, 570, 327-15, 570, 327+15, /solid, hsize=0, color=255

 endif

 ;Stars.
 if (telescope_target eq 1) then begin

  ;The image sections. We select 0.4 arcsec X 0.4 arcsec sections which correspond to the subsection of the PSF.
  x_w=floor(0.4/spectrograph_pixel)
  tmp_1=fltarr(x_w,x_w)

  ;Now, rebin the subsection PSF to the camera pixel sampling.
  tmp=psf(80:119,80:119)
  psf_tmp=congrid(tmp,x_w,x_w)

  ;Normalize to a flux of 1.
  psf_tmp=psf_tmp/total(psf_tmp)

  ;For all the stars in the list.
  for i=0,stars_total_number do begin

   ;Find out if the star is in the smaller field.
   if ((stars_list_x_pos(i) gt x-20) and (stars_list_x_pos(i) lt x+19)) then begin
    if ((stars_list_y_pos(i) gt y-20) and (stars_list_y_pos(i) lt y+19)) then begin

     ;Put a star in the starfield. We need to know how much fainter the star will be
     ;if it is not in I.

     ;For I.
     magnitude_tmp=stars_list_magnitude(i)

     ;For R.
     if ((spectrograph_filter eq 3) or (spectrograph_filter eq 4) or (spectrograph_filter eq 6) or (spectrograph_filter eq 7) or (spectrograph_filter eq 7) or (spectrograph_filter eq 8)) then begin

      ;If the star is on the ZAMS.
      if (stars_list_classification(i) eq 0) then begin
       colour_tmp=colour_magnitude_1(floor(40.*stars_list_magnitude(i)))
       magnitude_tmp=stars_list_magnitude(i)+colour_tmp
      endif
     
      ;Now, if this is a white dwarf we need a different colour magnitude diagram.
      if (stars_list_classification(i) eq 1) then begin
       colour_tmp=colour_magnitude_2(floor(40.*stars_list_magnitude(i)))
       magnitude_tmp=stars_list_magnitude(i)+colour_tmp
      endif

     endif

     ;Now, for the remaining colours we simply shift a small amount blue or red.

     ;For V.
     if (spectrograph_filter eq 3) then begin
      magnitude_tmp=stars_list_magnitude(i)+colour_tmp*star_colour_shift_1
     endif

     ;For J.
     if (spectrograph_filter eq 6) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_2
     endif

     ;For H.
     if (spectrograph_filter eq 7) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_3
     endif

     ;For K.
     if (spectrograph_filter eq 8) then begin
      magnitude_tmp=stars_list_magnitude(i)-colour_tmp*star_colour_shift_4
     endif
      
     ;Find the true flux for the star.
     c=299792458. ;m/s
     h=6.6260755e-34 ;Joule/s
     nu=c/(lambda*1.e-10) ;Hz
     dnu=c/(dlambda*1.e-10) ;Hz
     flux=aperture_scaling*aperture_hst*10000.*dnu/(nu*h*1e7)*10.^((magnitude_tmp+48.60)/(-2.5))

     ;Which corresponds to an AB-magnitude of.
     magnitude_true=magnitude_tmp

     ;Determine the section from the image.
     x_tmp=floor((0.075/spectrograph_pixel)*(stars_list_x_pos(i)-(x-26.7)))
     y_tmp=floor((0.075/spectrograph_pixel)*(stars_list_y_pos(i)-(y-26.7)))
     x_i=x_tmp-floor(x_w/2.)
     x_f=x_i+x_w-1
     y_i=y_tmp-floor(x_w/2.)
     y_f=y_i+x_w-1

     ;Label the screen.
     x_i_screen=270+600.*((x_tmp)/((0.004/spectrograph_pixel)*1000.))-5
     y_i_screen=27+600.*((y_tmp)/((0.004/spectrograph_pixel)*1000.))-5
     arrow, x_i_screen, y_i_screen+5, x_i_screen+10, y_i_screen+5, /solid, hsize=0, color=255
     arrow, x_i_screen+5, y_i_screen, x_i_screen+5, y_i_screen+10, /solid, hsize=0, color=255

     ;Now, generate the true image with the star of interest subtracted.
     tmp=fltarr(x_w,x_w)
     tmp=stars_tmp(x_i:x_f,y_i:y_f)
     tmp=tmp-flux*psf_tmp

     ;Star photometry.
     ;tmp_1=image(x_i:x_f,y_i:y_f)-smooth(tmp,5)
     tmp_1=image(x_i:x_f,y_i:y_f)-tmp
     photometry=total(tmp_1)
     flux=photometry*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
     magnitude=-2.5*alog10(flux)-48.6

     ;And save these to the file.
     if (magnitude lt 35.) then begin
      tmp_7(i)=magnitude
      tmp_8(i)=magnitude_true
     endif     

    endif
   endif
  endfor
 endif

 ;Write the results to a file.
 get_lun, unit
 openw, unit, './virtual_telescope_results/photometry_spectrograph_'+filter_tmp(spectrograph_filter)+'.dat'
 for i=0,9999 do begin
  printf, unit, i, tmp_2(i), tmp_3(i), tmp_4(i), tmp_5(i), tmp_6(i), tmp_7(i), tmp_8(i)
 endfor
 close, unit
 free_lun, unit

 ;Save the screen to an image.
 if (www eq 1) then begin
 
  ;Save the screen output.
  screen_output=tvrd()
 
 endif

 ;Set the toggle to 1.
 infrared_camera_done=1

 endif
end

;----------------------------------------------------------------------------
;Run the slit spectrograph simulation.
pro spectrograph_simulation

common  variables, $
        galaxy_bulge_radius, galaxy_disk_radius, galaxy_bulge_to_total_1, galaxy_bulge_to_total_2, galaxy_bulge_to_total_3, $
        galaxy_bulge_to_total_4, galaxy_cutoff, galaxy_faint, galaxy_multiple, galaxy_shift, galaxy_shrink, galaxy_correlation, $
        galaxy_line_width, $
        star_cutoff, star_faint, star_multiple, star_correlation, star_white_bright, star_white_fraction, star_surface_brightness, $
        star_distance_modulus, $
        telescope_temperature, telescope_primary, telescope_diameter, telescope_roughness, telescope_surfaces, telescope_error, $
        telescope_target, $
        optical_imager_filter, optical_imager_comparison, optical_imager_surfaces, optical_imager_detector, optical_imager_pixel, $
        optical_imager_readout, optical_imager_dark, optical_imager_gain, optical_imager_well, optical_imager_flag, optical_imager_exposure, $
        optical_imager_exposure_unit, $
        spectrograph_flag, spectrograph_resolution, spectrograph_slices, spectrograph_slits, spectrograph_length, spectrograph_width, $
        spectrograph_exposure, spectrograph_exposure_unit, spectrograph_position, spectrograph_extract, spectrograph_filter, $
        spectrograph_comparison, spectrograph_surfaces, spectrograph_detector, spectrograph_pixel, spectrograph_readout, spectrograph_dark, $
        spectrograph_gain, spectrograph_well, $
        target_flag, $
        pupil, aperture_hst, aperture_scaling, $
        mirror_coating_aluminum, mirror_coating_silver, mirror_coating_gold, grating_efficiency, filters, filter_bandpasses, $
        detector_efficiency_1, detector_efficiency_2, detector_efficiency_3, spectrum_1, spectrum_2, spectrum_3, spectrum_4, $
        colour_magnitude_1, colour_magnitude_2, $
        star_colour_shift_1, star_colour_shift_2, star_colour_shift_3, star_colour_shift_4, $
        background_total, atmospheric_transmission, $
        galaxy, galaxy_fake, galaxy_disk, galaxy_redshift, galaxy_magnitude, galaxy_classification, galaxy_radius, $
        galaxies, galaxies_redshift, galaxies_weight, galaxies_magnitude, galaxies_classification, galaxies_radius, galaxies_hst, $
        galaxies_telescope, galaxies_1, galaxies_2, galaxies_3, galaxies_4, galaxies_5, galaxies_list_x_pos, galaxies_list_y_pos, $
        galaxies_list_magnitude, galaxies_list_redshift, galaxies_list_classification, galaxies_list_radius, galaxies_list_rotate, $
        galaxies_list_ellipticity, galaxies_total_number, galaxies_total_number_hst, galaxies_number_counts, galaxies_number_counts_hst, $
        galaxies_number_counts_label, galaxies_distribution_magnitude, galaxies_distribution_redshift, galaxies_distribution_magnitude_hst, $
        galaxies_distribution_redshift_hst, galaxies_distribution_radius, galaxies_distribution_radius_hst, $
        star, star_fwhm, star_strehl, $
        stars, stars_hst, stars_telescope, stars_background, stars_list_magnitude, stars_list_x_pos, stars_list_y_pos, $
        stars_list_classification, stars_total_number, stars_total_number_hst, stars_number_counts, stars_number_counts_hst, $
        stars_number_counts_label, $
        spectrum, spectrum_extract, spectrum_true_extract, $
        x, y, $
        photometry, ratio, galaxy_radius_output, $
        statistics_magnitude, statistics_ratio, $
        colour_table, size_print, screen_output, $
        www, www_background, $
        initialize_field_done, initialize_telescope_done, optical_imager_done, infrared_camera_done,  $
        select_done, spectrum_integral_field_unit_done, spectrum_single_done, spectrum_multiplex_done, $
        field_running, telescope_running, oi_running, mos_running, $
        window_id

 ;Check that the telescope is pointing at the galaxy field.
 if (telescope_target eq 1) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must select the galaxy field.', charsize=size_print, color=0, /device
 endif
 if (telescope_target eq 0) then begin

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must select a target first.', charsize=size_print, color=0, /device
 endif
 if (select_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 3, /silent

 ;Display the field.
 tmp=fltarr(778,741)
 tmp=galaxies_telescope(157:934,283:1023)
 tmp_1=congrid(tmp,210,200)
 tv, tmp_1, 30, 427
 
 ;Labels.
 xyouts, 30, 657, 'Galaxy Field', charsize=size_print, color=0, /device
 xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

 ;Selected area. This is 0.5 arcsec X 4.0 arcsec. Any smaller would not display on the
 ;screen.
 x_i=(x-157)*(210./778.)+30-3
 x_f=x_i+7
 y_i=(y-283)*(200./741.)+427-7
 y_f=y_i+14
 arrow, x_i, y_i, x_f, y_i, /solid, hsize=0, color=255
 arrow, x_f, y_i, x_f, y_f, /solid, hsize=0, color=255
 arrow, x_f, y_f, x_i, y_f, /solid, hsize=0, color=255
 arrow, x_i, y_f, x_i, y_i, /solid, hsize=0, color=255

 ;Determine properties of the galaxy.
 galaxy_magnitude=galaxies_magnitude(x,y)
 galaxy_redshift=galaxies_redshift(x,y)
 galaxy_classification=galaxies_classification(x,y)
 galaxy_radius=galaxies_radius(x,y)
 tmp_4=strarr(6)
 tmp_4(0)='background'
 tmp_4(1)='E/S0'
 tmp_4(2)='Sbc'
 tmp_4(3)='Scd'
 tmp_4(4)='Irr'
 tmp_4(5)='stellar'
 if (floor(galaxy_classification) eq 0) then begin
  galaxy_radius=0. 
 endif

 ;Print information to the screen.
 xyouts, 30, 397, 'MOS Slit', charsize=size_print, color=0, /device
 tmp_1=string(spectrograph_width)
 tmp_1=strtrim(tmp_1,2)
 tmp_1=strmid(tmp_1,0,4)
 tmp_2=string(spectrograph_length)
 tmp_2=strtrim(tmp_2,2)
 tmp_2=strmid(tmp_2,0,4)
 tmp_3='('+tmp_1+' arcsec X '+tmp_2+' arcsec)'
 xyouts, 30, 382, tmp_3, charsize=size_print, color=0, /device 
 xyouts, 30, 352, 'Centre of Slit', charsize=size_print, color=0, /device 
 tmp=string(galaxy_redshift)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)
 xyouts, 30, 337, 'z = ', charsize=size_print, color=0, /device 
 xyouts, 240, 337, tmp, alignment=1.0, charsize=size_print, color=0, /device 
 xyouts, 30, 322, 'H(AB) = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_magnitude)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,6)
 xyouts, 240, 322, tmp, alignment=1.0,charsize=size_print, color=0, /device
 xyouts, 30, 307, 'Object type = ', charsize=size_print, color=0, /device 
 xyouts, 240, 307, tmp_4(galaxy_classification), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 292, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device 
 tmp=string(galaxy_radius)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)
 xyouts, 240, 292, tmp, alignment=1.0, charsize=size_print, color=0, /device

 ;Determine properties of the exposure.
 tmp=strarr(9)
 tmp(0)='open'
 tmp(1)='U'
 tmp(2)='B'
 tmp(3)='V'
 tmp(4)='R'
 tmp(5)='I'
 tmp(6)='J'
 tmp(7)='H'
 tmp(8)='K'
 completed_tmp=0

 ;Print information to the screen.
 xyouts, 30, 262, 'Exposure', charsize=size_print, color=0, /device 
 xyouts, 30, 247, 'Filter = ', charsize=size_print, color=0, /device 
 xyouts, 240, 247, tmp(0), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 232, 'Unit exposure (s) = ', charsize=size_print, color=0, /device 
 xyouts, 240, 232, spectrograph_exposure_unit, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 217, 'Number of exposures = ', charsize=size_print, color=0, /device 
 xyouts, 240, 217, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
 xyouts, 240, 202, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
 wait, 1

 ;Print a message to the screen.
 xyouts, 525, 365, 'Initializing ...', charsize=size_print, color=0, /device

 ;Initialize.
 f=floor(0.5/spectrograph_pixel)
 s=f-1
 r=floor(spectrograph_resolution) 
 exposure_time=spectrograph_exposure*spectrograph_exposure_unit
 if ((telescope_primary eq 0) or (telescope_primary eq 2) or (telescope_primary eq 3)) then begin
  telescope_mirror=congrid(mirror_coating_aluminum(0:2999),r)
 endif
 if (telescope_primary eq 1) then begin
  telescope_mirror=congrid(mirror_coating_gold(0:2999),r)
 endif
 transmission=congrid(atmospheric_transmission(0:29999),r)
 spectrograph_mirror=congrid(mirror_coating_gold(0:2999),r)
 grating=congrid(grating_efficiency(0:2999),r)
 tmp=fltarr(3000)
 tmp=filters(7,0:2999)
 filter_h=fltarr(r)
 filter_h(0:r-1)=congrid(tmp(0:2999),r)
 if (spectrograph_detector eq 0) then begin
  detector=congrid(detector_efficiency_1(0:2999),r)
 endif
 if (spectrograph_detector eq 1) then begin
  detector=congrid(detector_efficiency_2(0:2999),r)
 endif
 if (spectrograph_detector eq 2) then begin
  detector=congrid(detector_efficiency_3(0:2999),r)
 endif

 ;Calculate the throughput. This is in e-/photon.
 tmp=fltarr(r)
 tmp=tmp+1.
 throughput_atmosphere=total(transmission*filter_h*tmp)/total(filter_h*tmp)
throughput_instrument=total((telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*grating*filter_h*detector*tmp)/total(filter_h*tmp)

 ;Take the spectra.
 tmp_1=congrid(galaxies_1(x-3:x+3,y-26:y+26),f,8*f)
 tmp_2=congrid(galaxies_2(x-3:x+3,y-26:y+26),f,8*f)
 tmp_3=congrid(galaxies_3(x-3:x+3,y-26:y+26),f,8*f)
 tmp_4=congrid(galaxies_4(x-3:x+3,y-26:y+26),f,8*f)
 tmp_5=congrid(galaxies_5(x-3:x+3,y-26:y+26),f,8*f)

 ;The galaxy weights.
 galaxy_weight=congrid(galaxies_weight(x-3:x+3,y-26:y+26),f,8*f) 

 ;Shift the spectra according to the given redshifts of the galaxies. Note that the input spectrum covers a range of 0.0 to 3.0 microns with
 ;30000 data points. Also, we renormalize each output spectrum to have a flux of 1 over H.
 
 ;E/S0.
 spectrum_1_tmp=fltarr(r,f,8*f)
 for i=0,s do begin
  for j=0,7*f+s do begin
   if (tmp_1(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_1(i,j)))-1      
    spectrum_1_tmp(0:r-1,i,j)=congrid(spectrum_1(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_1_tmp(0:r-1,i,j))
    spectrum_1_tmp(0:r-1,i,j)=spectrum_1_tmp(0:r-1,i,j)/tmp
   endif
  endfor
 endfor

 ;Sbc.
 spectrum_2_tmp=fltarr(r,f,8*f)
 for i=0,s do begin
  for j=0,7*f+s do begin
   if (tmp_2(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_2(i,j)))-1
    spectrum_2_tmp(0:r-1,i,j)=congrid(spectrum_2(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_2_tmp(0:r-1,i,j))
    spectrum_2_tmp(0:r-1,i,j)=spectrum_2_tmp(0:r-1,i,j)/tmp
   endif
  endfor
 endfor

 ;Scd.
 spectrum_3_tmp=fltarr(r,f,8*f)
 for i=0,s do begin
  for j=0,7*f+s do begin
   if (tmp_3(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_3(i,j)))-1
    spectrum_3_tmp(0:r-1,i,j)=congrid(spectrum_3(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_3_tmp(0:r-1,i,j))
    spectrum_3_tmp(0:r-1,i,j)=spectrum_3_tmp(0:r-1,i,j)/tmp 
   endif
  endfor
 endfor

 ;Irr.
 spectrum_4_tmp=fltarr(r,f,8*f)
 for i=0,s do begin
  for j=0,7*f+s do begin
   if (tmp_4(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_4(i,j)))-1
    spectrum_4_tmp(0:r-1,i,j)=congrid(spectrum_4(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_4_tmp(0:r-1,i,j))
    spectrum_4_tmp(0:r-1,i,j)=spectrum_4_tmp(0:r-1,i,j)/tmp 
   endif
  endfor
 endfor

 ;Stellar.
 spectrum_5_tmp=fltarr(r,f,8*f)
 for i=0,s do begin
  for j=0,7*f+s do begin
   if (tmp_5(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_5(i,j)))-1
    spectrum_5_tmp(0:r-1,i,j)=congrid(spectrum_4(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_5_tmp(0:r-1,i,j))
    spectrum_5_tmp(0:r-1,i,j)=spectrum_5_tmp(0:r-1,i,j)/tmp 
   endif
  endfor
 endfor

 ;Combine them.
 spectrum=fltarr(r,f,8*f)
 for i=0,s do begin
  for j=0,7*f+s do begin
   spectrum(0:r-1,i,j)=spectrum_1_tmp(0:r-1,i,j)+spectrum_2_tmp(0:r-1,i,j)+spectrum_3_tmp(0:r-1,i,j)+spectrum_4_tmp(0:r-1,i,j)+spectrum_5_tmp(0:r-1,i,j)
  endfor
 endfor

 ;Now, if the galaxy weight is 0, that is, there is no galaxy, set it to 1. Now, you won't divide by 0 when you correct for overlapping galaxies.
 for i=0,s do begin
  for j=0,7*f+s do begin
   if (galaxy_weight(i,j) eq 0.) then begin
    galaxy_weight(i,j)=1.
   endif
  endfor
 endfor

 ;We divide by the galaxy weight in order to average the spectrum whenever two galaxies overlap.
 for i=0,r-1 do begin
  spectrum(i,0:s,0:7*f+s)=spectrum(i,0:s,0:7*f+s)/galaxy_weight(0:s,0:7*f+s)
 endfor

 ;We generate a spectrum as if all the light were in a single emission line at 1.0 micron.
 spectrum_line=fltarr(r,f,8*f)
 spectrum_line(floor(0.333*r),0:s,0:7*f+s)=1.
 
 ;Generate the ideal artificial images by going along the dispersion axis.
 galaxy=fltarr(r,f,8*f)
 psf=galaxy
 psf_function=fltarr(f,8*f)

 ;Extract the small field.
 galaxy_tmp=congrid(aperture_scaling*galaxies(2*x-6:2*x+6,2*y-52:2*y+52),f,8*f)

 ;Make sure that flux is conserved.
 tmp=total(galaxy_tmp)
 if (tmp eq 0.) then begin
  tmp=1.
 endif
 galaxy_tmp=galaxy_tmp*total(aperture_scaling*galaxies(2*x-6:2*x+6,2*y-52:2*y+52))/tmp

 ;If this is the background.
 if (floor(galaxy_classification) eq 0) then begin
  galaxy_tmp=fltarr(f,8*f)
  galaxy_tmp=galaxy_tmp+1.
 endif 

 ;Get the PSFs. Note, these are 200 by 200 pixels or 2.0 arcsec X 2.0 arcsec. We want a 0.5 arcsec X 2.0 arcsec section.
 psf_function=fltarr(30,f,8*f)
 for i=0,29 do begin

  ;Extract the section.
  tmp=fltarr(50,400)
  tmp(0:49,100:299)=star(i,75:124,0:199)

  ;We rebin this to have the same pixel sampling as selected for the detector.
  psf_function(i,0:s,0:7*f+s)=congrid(tmp(0:49,0:399),f,8*f)

  ;Make sure this has a total flux of 1.
  psf_function(i,0:s,0:7*f+s)=psf_function(i,0:s,0:7*f+s)/total(psf_function(i,0:s,0:7*f+s))

 endfor

 ;Now, apply the PSF to the images.
 for i=0,r-1 do begin

  ;Convolve the images with the PSF.
  tmp=fltarr(f,8*f)

  ;Find what range in wavelength we are in and select the PSF.
  for j=0,28 do begin
   if ((i gt floor((float(j)/29.)*r)) and (i le floor(float(j+1)/29.*r))) then begin
     
    ;The PSF.
    tmp_1=tmp
    distance_from=(i-floor(0.0333333*j*r))/(0.0333333*r)
    if (distance_from gt 1.) then begin
     distance_from=1.
    endif
    distance_to=1.-distance_from
    tmp_1(0:s,0:7*f+s)=distance_to*psf_function(j,0:s,0:7*f+s)+distance_from*psf_function(j+1,0:s,0:7*f+s)
    tmp_1=tmp_1/total(tmp_1)

   endif
  endfor

  ;The galaxy image.
  tmp(0:s,0:7*f+s)=spectrum(i,0:s,0:7*f+s)*galaxy_tmp(0:s,0:7*f+s)
  galaxy(i,0:s,0:7*f+s)=convolve(tmp(0:s,0:7*f+s),tmp_1(0:s,0:7*f+s))
 
  ;The spectral line image.
  tmp(0:s,0:7*f+s)=spectrum_line(i,0:s,0:7*f+s)*galaxy_tmp(0:s,0:7*f+s)
  psf(i,0:s,0:7*f+s)=convolve(tmp(0:s,0:7*f+s),tmp_1(0:s,0:7*f+s))

 endfor

 ;Set image size.
 image=fltarr(r,f,8*f)
 image_true=image
 image_background=image
 image_white=image+1.
 image_total=fltarr(f,8*f)

 ;Make a perfect image. This is in e-/pixel.
 for i=0,r-1 do begin
image_true(i,0:s,0:7*f+s)=exposure_time*(telescope_mirror(i)^telescope_surfaces)*(spectrograph_mirror(i)^spectrograph_surfaces)*grating(i)*detector(i)*galaxy(i,0:s,0:7*f+s)
 endfor

 ;Make an image that does not have any background or noise added.  
 for i=0,r-1 do begin
  image(i,0:s,0:7*f+s)=transmission(i)*image_true(i,0:s,0:7*f+s)
 endfor
 
 ;Now, add background and noise. The noise is Poisson noise due to object signal, background and dark current. The background is scaled by the
 ;pixel size. Note, image and image_true are in units of e-/pixel. Also, the background is in units of photons/arcsec/second. We want
 ;units of e-/pixel/second. We multiply by the quantum efficiency as well.

 ;First, calculate the background.
 background=congrid(background_total,r)
 background=(spectrograph_pixel^2)*background*(total(background_total))/total(background)/1000.

 ;Send the background light through the spectrograph. Take into account
 ;the efficiency of the grating.
 for i=1,r-1 do begin
  background(i)=(telescope_mirror(i)^telescope_surfaces)*(spectrograph_mirror(i)^spectrograph_surfaces)*grating(i)*detector(i)*background(i)
 endfor

 ;Add the dark current, background, and Poisson noise.
 for i=0,r-1 do begin 

  ;The spectrograph stream.
  image(i,0:s,0:7*f+s)=image(i,0:s,0:7*f+s)+exposure_time*(background(i)+spectrograph_dark)
  image_background(i,0:s,0:7*f+s)=image_background(i,0:s,0:7*f+s)+exposure_time*(background(i)+spectrograph_dark)
  
  ;Calculate and add the Poisson noise.
  image(i,0:s,0:7*f+s)=image(i,0:s,0:7*f+s)+randomn(seed,f,8*f)*sqrt(image(i,0:s,0:7*f+s))
  image_background(i,0:s,0:7*f+s)=image_background(i,0:s,0:7*f+s)+randomn(seed,f,8*f)*sqrt(image_background(i,0:s,0:7*f+s))

 endfor
 
 ;Generate readout noise. Note, this is in units of e-. Consider only the spectrograph stream. Note, the exposures are taken in sub-exposures.
 readout_noise=fltarr(f,8*f)
 for i=1,spectrograph_exposure do begin
  readout_noise(0:s,0:7*f+s)=readout_noise(0:s,0:7*f+s)+spectrograph_readout*randomn(seed,f,8*f)
 endfor

 ;Add readout noise.
 for i=0,r-1 do begin
  image(i,0:s,0:7*f+s)=image(i,0:s,0:7*f+s)+readout_noise(0:s,0:7*f+s)*randomn(seed)
  image_background(i,0:s,0:7*f+s)=image_background(i,0:s,0:7*f+s)+readout_noise(0:s,0:7*f+s)*randomn(seed)
 endfor

 ;Now, set the number of completed exposures in the display.
 blank=fltarr(50,15)
 blank=blank+255
 tv, blank, 190, 202
 completed_tmp=floor(spectrograph_exposure)
 xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
 xyouts, 240, 202, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
 wait, 1

 ;Generate an image of the total light through the spectrograph that is registered by the detector if the aperture is wide open.
 for i=0,s do begin
  for j=0,7*f+s do begin
   image_total(i,j)=image_total(i,j)+total(image(0:r-1,i,j))
  endfor
 endfor

 ;Make the slit-mask.
 size_width=floor((1./spectrograph_pixel)*(spectrograph_width)/2)
 size_length=floor((1./spectrograph_pixel)*(spectrograph_length)/2)
 mask=fltarr(r,f,8*f)
 tmp_1=float(f/2)
 tmp_2=float(4*f)
 tmp_3=tmp_1-size_width
 tmp_4=tmp_1+size_width
 tmp_5=tmp_2-size_length
 tmp_6=tmp_2+size_length
 if (tmp_3 lt 0) then begin
  tmp_3=0
 endif 
 if (tmp_4 ge f) then begin
  tmp_4=s
 endif
 if (tmp_5 lt 0) then begin
  tmp_5=0
 endif
 if (tmp_6 ge 8*f) then begin
  tmp_6=7*f+s
 endif 
 mask(0:r-1,tmp_3:tmp_4,tmp_5:tmp_6)=1.

 ;Make the extraction-mask. Note that it is made twice as large as needed to start and then is trimmed down. This is so that the user can specify
 ;an extraction width of f pixels without crashing the program. Note, extract and position are in arcsec.
 size_extract=floor((1./spectrograph_pixel)*(spectrograph_extract)/2)
 size_position=floor((1./spectrograph_pixel)*(spectrograph_position))
 tmp=fltarr(1,16*f)
 tmp(0,4*f+size_position-size_extract:4*f+size_position+size_extract-1)=1.
 extract_mask=tmp(0,4*f:12*f-1)
 
 ;This is just the total image. But now, mask off the slit.
 image=mask*image 
 image_psf=mask*psf
 image_background=mask*image_background

 ;Also mask off the perfect image.
 image_true=mask*image_true

 ;Also generate a mask of the illumination of the spectrograph.
 image_white=mask*image_white

 ;Generate spectra from what is in the slit. Note that we make the full array bigger than the spectrum. It is set to a size of 5200.   
 spectrum=fltarr(5200,8*f)
 spectrum_true=spectrum
 spectrum_psf=spectrum
 spectrum_background=spectrum
 correction=spectrum
 for i=0,s do begin  
  for j=0,r-1 do begin    

   ;The correction is the result of passing uniform white light through the slit in exactly the same manner as the galaxy light.
   correction(i+j,0:7*f+s)=correction(i+j,0:7*f+s)+image_white(j,i,0:7*f+s)

   ;The spectra.
   spectrum(i+j,0:7*f+s)=spectrum(i+j,0:7*f+s)+image(j,i,0:7*f+s)
   spectrum_true(i+j,0:7*f+s)=spectrum_true(i+j,0:7*f+s)+image_true(j,i,0:7*f+s)
   spectrum_psf(i+j,0:7*f+s)=spectrum_psf(i+j,0:7*f+s)+image_psf(j,i,0:7*f+s)
   spectrum_background(i+j,0:7*f+s)=spectrum_background(i+j,0:7*f+s)+image_background(j,i,0:7*f+s) 
 
  endfor
 endfor

 ;Correct the spectra for slit illumination.
 correction=correction/(max(correction))+0.00001
 spectrum=spectrum/correction
 spectrum_true=spectrum_true/correction
 spectrum_psf=spectrum_psf/correction
 spectrum_background=spectrum_background/correction

 ;Take the spectrum from the full spectrum. Remember, the resolution is r. The offset is half the size of the input image.
 blue=floor(f/2)
 red=blue+r-floor(f/2)
 tmp=spectrum
 spectrum=congrid(tmp(blue:red,0:7*f+s),r,8*f)
 tmp=spectrum_true
 spectrum_true=congrid(tmp(blue:red,0:7*f+s),r,8*f)
 tmp=spectrum_psf
 spectrum_psf=congrid(tmp(blue:red,0:7*f+s),r,8*f)
 tmp=spectrum_background
 spectrum_background=congrid(tmp(blue:red,0:7*f+s),r,8*f)

 ;Make background subtracted spectra.
 spectrum_subtracted=spectrum-spectrum_background
 
 ;Extract a slice perpendicular to the dispersion direction.
 spectrum_slice=fltarr(8*f)
 for i=0,7*f+s do begin
  spectrum_slice(i)=total(spectrum_subtracted(0:r-1,i))
 endfor

 ;Also, set up some display plots to show the position of the extraction region.
 peak_spectrum=extract_mask(0,0:7*f+s)*max(spectrum_slice)

 ;Extract the spectrum of the target.
 spectrum_extract=fltarr(r)
 spectrum_true_extract=spectrum_extract
 spectrum_psf_extract=spectrum_extract
 spectrum_background_extract=spectrum_extract
 for i=0,r-1 do begin
  correction=1./((telescope_mirror(i)^telescope_surfaces)*(spectrograph_mirror(i)^spectrograph_surfaces)*grating(i)*detector(i))
  if (correction eq 0.) then begin
   correction=1.
  endif
  if (correction eq 'Inf') then begin
   correction=1.
  endif
  if (transmission(i) eq 0.) then begin
   transmission(i)=1.
  endif
  spectrum_extract(i)=total(extract_mask(0,0:7*f+s)*(correction/transmission(i))*spectrum_subtracted(i,0:7*f+s))
  spectrum_true_extract(i)=total(extract_mask(0,0:7*f+s)*correction*spectrum_true(i,0:7*f+s))
  spectrum_psf_extract(i)=total(extract_mask(0,0:7*f+s)*spectrum_psf(i,0:7*f+s))
  spectrum_background_extract(i)=total(extract_mask(0,0:7*f+s)*correction*spectrum_background(i,0:7*f+s))
 endfor

 ;Now pass the light through an H filter.
 flux=0.
 flux_true=0.
 flux_background=0.
 tmp=congrid(filter_h,100)
 tmp_1=congrid(spectrum_extract,100)
 tmp_2=congrid(spectrum_true_extract,100)
 tmp_3=congrid(spectrum_background_extract,100)
 for i=0,99 do begin
  flux=flux+(float(r)/100.)*tmp(i)*tmp_1(i)
  flux_true=flux_true+(float(r)/100.)*tmp(i)*tmp_2(i)
  flux_background=flux_background+(float(r)/100.)*tmp(i)*tmp_3(i)  
 endfor

 ;Correct for system throughput and exposure time.
 flux=(1./(throughput_atmosphere*throughput_instrument))*flux/exposure_time
 flux_true=(1./throughput_instrument)*flux_true/exposure_time
 flux_background=(1./throughput_instrument)*flux_background/exposure_time

 ;Calculate H(AB).
 lambda=16000.
 dlambda=3500.
 c=299792458. ;m/s
 h=6.6260755e-34 ;Joule/s
 nu=c/(lambda*1.e-10) ;Hz
 dnu=c/(dlambda*1.e-10) ;Hz
 flux=flux*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
 flux_true=flux_true*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
 flux_background=flux_background*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)

 ;But, this is the flux in ergs/cm^2/second/Hz. We want it is in units of AB magnitudes. 
 photometry=-2.5*alog10(flux)-48.6
 photometry_true=-2.5*alog10(flux_true)-48.6
 photometry_background=-2.5*alog10(flux_background)-48.6

 ;Calculate the radius of the galaxy. We take the slice of the spectrum within the extraction region and count how many pixels are above the half
 ;maximum light of the galaxy.
 tmp=fltarr(8*f)
 for i=0,7*f+s do begin
  tmp(i)=spectrum_slice(i)*extract_mask(0,i)
 endfor

 ;Find the maximum.
 tmp_1=max(tmp)

 ;Ensure we do not divide by 0.
 if (max(tmp) le 0.) then begin
  tmp_1=1.
 endif
 tmp=tmp/max(tmp)

 ;Now, go along and count.
 tmp_2=0
 for i=0,7*f+s do begin
  if (tmp(i) ge 0.5) then begin
   tmp_2=tmp_2+1
  endif
 endfor

 ;Put this into arcsec.
 galaxy_radius_out=float(tmp_2)*spectrograph_pixel/2.

 ;Calculate the signal-to-noise ratio by using the true spectrum and finding the RMS of the fluctuations over 1.0 to 2.0 microns.
ratio=total(spectrum_extract(floor(0.333*r):floor(0.666*r-1)))/sqrt(total((spectrum_extract(floor(0.333*r):floor(0.666*r-1))-spectrum_true_extract(floor(0.333*r):floor(0.666*r-1)))^2))
 if (ratio lt 0.) then begin
  ratio=0.
 endif

 ;Find the delivered resolution. First, find the FWHM of the narrow spectral line.
 spectrum_psf_extract=spectrum_psf_extract/max(spectrum_psf_extract)
 fwhm=0.
 for i=0,r-1 do begin
  if (spectrum_psf_extract(i) ge 0.5) then begin
   fwhm=fwhm+1.
  endif
 endfor
 resolution_delivered=r/fwhm

 ;If this is the background reset the values.
 if (floor(galaxy_classification) eq 0) then begin
  photometry=photometry_background
  photometry_true=photometry_background
  galaxy_radius_out=0.
 endif

 ;Set up the display.
 wshow, window_id
 erase, 255
 !p.multi = [0,4,2]
 character_size=size_print*1.5

 ;Top row.

 ;Dummy plot.
 plot, spectrum_slice, spectrum_slice, min_value=0., background=255, color=255

 ;Display the field.
 tmp=fltarr(778,741)
 tmp=galaxies_telescope(157:934,283:1023)
 tmp_1=congrid(tmp,210,200)
 tv, tmp_1, 30, 427

 ;Labels.
 xyouts, 30, 657, 'Galaxy Field', charsize=size_print, color=0, /device
 xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

 ;Selected area.
 x_i=(x-157)*(210./778.)+30-3
 x_f=x_i+7
 y_i=(y-283)*(200./741.)+427-7
 y_f=y_i+14

 ;If this is not generating WWW code.
 if (www_background eq 0) then begin

  ;Draw a box around the selected area.
  arrow, x_i, y_i, x_f, y_i, /solid, hsize=0, color=255
  arrow, x_f, y_i, x_f, y_f, /solid, hsize=0, color=255
  arrow, x_f, y_f, x_i, y_f, /solid, hsize=0, color=255
  arrow, x_i, y_f, x_i, y_i, /solid, hsize=0, color=255

  ;Draw an arrow to the spectrograph display.

  ;Black.
  arrow, 307, 504, x_f, y_f, /solid, hsize=0, color=0
 
  ;White.
  arrow, 305, 502, x_f, y_f-1, /solid, hsize=0, color=255

 endif

 ;The spectra.

 ;The total flux.

 ;Generate an axis label.
 xlabel=fltarr(4*f)
 for i=0,3*f+s do begin
  xlabel(i)=spectrograph_pixel*i
 endfor
 ylabel=fltarr(r)
 for i=0,7*f+s do begin
  ylabel(i)=-2.+spectrograph_pixel*i
 endfor
 tmp=fltarr(4*f,8*f)
 tmp(2*f-floor(f/2):2*f-floor(f/2)+s,0:7*f+s)=mask(0,0:s,0:7*f+s)*image_total(0:s,0:7*f+s)/max(image_total(0:s,0:7*f+s))

 ;Plot.
 shade_surf, tmp(0:3*f+s-1,0:7*f+s), xlabel(0:3*f+s-1), ylabel(0:7*f+s), xmargin=[10,0], ymargin=[0,5], ax=70., az=10., min_value=0., charsize=size_print*2.5, xtitle='Field Width (arcsec)', ytitle='Declination (arcsec)', ztitle='Intensity', background=255, color=0

 ;The background subtracted spectrum.

 ;Generate an axis label.
 xlabel=fltarr(r)
 for i=0,r-1 do begin
  xlabel(i)=0.+(i/float(r))*3.
 endfor

 ;Plot.
 shade_surf, spectrum(0:r-1,0:7*f+s)/max(spectrum(0:r-1,0:7*f+s)), xlabel(0:r-1), ylabel(0:7*f+s), xmargin=[2.5,2.5], ymargin=[0,5], ax=70., az=10., min_value=0., charsize=size_print*2.5, ytitle='Declination (arcsec)', xtitle='Dispersion (micron)', ztitle='Intensity', background=255, color=0
 shade_surf, spectrum_subtracted(0:r-1,0:7*f+s)/max(spectrum_subtracted(0:r-1,0:7*f+s)), xlabel(0:r-1), ylabel(0:7*f+s), xmargin=[0,5], ymargin=[0,5], ax=70., az=10., min_value=0., charsize=size_print*2.5, ytitle='Declination (arcsec)', xtitle='Dispersion (micron)', ztitle='Intensity', background=255, color=0

 ;And labels.
 xyouts, 320, 655, 'Total Light', charsize=size_print, color=0, /device
 xyouts, 505, 655, 'Raw Spectrum', charsize=size_print, color=0, /device
 xyouts, 680, 655, 'Background-Subtracted', charsize=size_print, color=0, /device  
  
 ;Bottom row.

 ;Dummy plot.
 plot, spectrum_slice, spectrum_slice, min_value=0., background=255, color=255

 ;Determine properties of the galaxy.
 galaxy_magnitude=galaxies_magnitude(x,y)
 galaxy_redshift=galaxies_redshift(x,y)
 galaxy_classification=galaxies_classification(x,y)
 galaxy_radius=galaxies_radius(x,y)
 tmp_4=strarr(6)
 tmp_4(0)='background'
 tmp_4(1)='E/S0'
 tmp_4(2)='Sbc'
 tmp_4(3)='Scd'
 tmp_4(4)='Irr'
 tmp_4(5)='stellar'
 if (floor(galaxy_classification) eq 0) then begin
  galaxy_radius=0. 
 endif

 ;Print information to the screen.
 xyouts, 30, 397, 'MOS Slit', charsize=size_print, color=0, /device
 tmp_1=string(spectrograph_width)
 tmp_1=strtrim(tmp_1,2)
 tmp_1=strmid(tmp_1,0,4)
 tmp_2=string(spectrograph_length)
 tmp_2=strtrim(tmp_2,2)
 tmp_2=strmid(tmp_2,0,4)
 tmp_3='('+tmp_1+' arcsec X '+tmp_2+' arcsec)'
 xyouts, 30, 382, tmp_3, charsize=size_print, color=0, /device 
 xyouts, 30, 352, 'Centre of Slit', charsize=size_print, color=0, /device 
 tmp=string(galaxy_redshift)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)
 xyouts, 30, 337, 'z = ', charsize=size_print, color=0, /device 
 xyouts, 240, 337, tmp, alignment=1.0, charsize=size_print, color=0, /device 
 xyouts, 30, 322, 'H(AB) = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_magnitude)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,6)
 xyouts, 240, 322, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 307, 'Object type = ', charsize=size_print, color=0, /device 
 xyouts, 240, 307, tmp_4(galaxy_classification), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 292, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device 
 tmp=string(galaxy_radius)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)
 xyouts, 240, 292, tmp, alignment=1.0, charsize=size_print, color=0, /device

 ;Determine properties of the exposure.
 tmp=strarr(9)
 tmp(0)='open'
 tmp(1)='U'
 tmp(2)='B'
 tmp(3)='V'
 tmp(4)='R'
 tmp(5)='I'
 tmp(6)='J'
 tmp(7)='H'
 tmp(8)='K'
 completed_tmp=0

 ;Print information to the screen.
 xyouts, 30, 262, 'Exposure', charsize=size_print, color=0, /device 
 xyouts, 30, 247, 'Filter = ', charsize=size_print, color=0, /device 
 xyouts, 240, 247, tmp(0), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 232, 'Unit exposure (s) = ', charsize=size_print, color=0, /device 
 xyouts, 240, 232, spectrograph_exposure_unit, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 217, 'Number of exposures = ', charsize=size_print, color=0, /device 
 xyouts, 240, 217, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
 xyouts, 240, 202, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
 wait, 1

 ;Set the normalization.
 tmp=max(spectrum_slice)
 if (tmp le 0.) then begin
  tmp=1.
 endif

 ;The spectrum slice.

 ;Generate an axis label.
 xlabel=fltarr(r)
 for i=0,7*f+s do begin
  xlabel(i)=-2.+spectrograph_pixel*i
 endfor
 plot, spectrum_slice/tmp, xlabel, xstyle=1, ystyle=1., xrange=[0,1], yrange=[-2,2], xmargin=[15,0], ymargin=[6,6], charsize=character_size, thick=1, ytitle='Declination (arcsec)', xtitle='Intensity', title='Extraction Region', background=255, color=0
 oplot, peak_spectrum/tmp, xlabel, linestyle=2, color=0

 ;The extracted spectrum.

 ;Set the normalization.
 tmp=max(spectrum_true_extract)
 if (tmp le 0.) then begin
  tmp=1.
 endif

 ;Generate an axis label.
 xlabel=fltarr(r)
 for i=0,r-1 do begin
  xlabel(i)=0.+(i/float(r))*3.
 endfor
 plot, xlabel, spectrum_extract/tmp, xmargin=[10,-35], ymargin=[6,6], yrange=[0,1], charsize=character_size, thick=1, xtitle='Dispersion (micron)', ytitle='Intensity',title='Extracted Spectrum', color=0
 oplot, xlabel, spectrum_true_extract/tmp, linestyle=2, color=0

 ;Print information to the screen.

 ;And write to the screen.
 xyouts, 30, 172, 'Values for Slit', charsize=size_print, color=0, /device
 xyouts, 30, 157, 'S/N = ', charsize=size_print, color=0, /device
 xyouts, 240, 157, ratio, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 142, 'R delivered = ', charsize=size_print, color=0, /device
 xyouts, 240, 142, resolution_delivered, alignment=1.0, charsize=size_print, color=0, /device 
 xyouts, 30, 127, 'H(AB) observed = ', charsize=size_print, color=0, /device
 tmp=string(photometry)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,6)
 xyouts, 240, 127, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 112, 'H(AB) true = ', charsize=size_print, color=0, /device
 tmp=string(photometry_true)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,6)
 xyouts, 240, 112, tmp, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 97, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_radius_out)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)
 xyouts, 240, 97, tmp, alignment=1.0, charsize=size_print, color=0, /device 

 ;Wait a moment while the user views the image.
 wait, 3

 ;Print this information to a file. Take only those galaxies from the sample with known spectral classification and with good photometry.
 get_lun, unit
 openw, unit, './virtual_telescope_results/survey_logfile.dat', /append
 if (floor(galaxy_classification) le 5) then begin
  if ((photometry gt 20.) and (photometry lt 35.)) then begin
   printf, unit, float(size_width*2.)*spectrograph_pixel, galaxy_redshift, photometry, galaxy_radius_out, resolution_delivered, ratio
  endif
 endif
 close, unit
 free_lun, unit

 ;Save the screen to an image.
 if (www_background eq 1) then begin
 
  ;Save the screen output.
  screen_output=tvrd()
  file_gif=strcompress(string('./virtual_telescope_www/virtual_telescope_www_display_0.gif'), /remove_all)
  write_gif, file_gif, screen_output    

  ;Prepare the HTML form for the WWW interface.
  get_lun, unit
  openw, unit, './virtual_telescope_www/virtual_telescope_www_interface.html', /append
  tmp_1=string('<area shape="default" ')
  tmp_2=strcompress(string(' href="/~steinb/virtual_telescope_www/virtual_telescope_www_display_0.html"'), /remove_all)
  tmp_3=strcompress(string(' target="_top" alt="background, H(AB)= ', photometry, ', z=0.0000">'))
  tmp_4=strcompress(string(' src="/~steinb/virtual_telescope_www/virtual_telescope_www_display_0.gif"'), /remove_all)
  label=strcompress(string(tmp_1, tmp_2, tmp_3))
  printf, unit, label 
  close, unit
  free_lun, unit

  ;Prepare the HTML form for the WWW interface display of the image.
  file_html=strcompress(string('./virtual_telescope_www/virtual_telescope_www_display_0.html'), /remove_all)
  get_lun, unit
  openw, unit, file_html, /append
  printf, unit, '<html>'
  printf, unit, ' ' 
  printf, unit, '<head>'
  printf, unit, '<title>Virtual Telescope WWW Interface</title>'
  printf, unit, '</head>'
  printf, unit, ' '
  printf, unit, '<body bgcolor="#ffffff" link="#0000ff" vlink="#0000ff">'
  printf, unit, '<img ' 
  printf, unit, tmp_4
  printf, unit, '>'
  printf, unit, '</body>'
  printf, unit, ' '
  printf, unit, '</html>'  
  close, unit
  free_lun, unit

 endif

 ;Save the screen to an image.
 if (www eq 1) then begin
 
  ;Save the screen output.
  screen_output=tvrd()
 
 endif

 ;Finally, convert the output spectrum back to the original sampling of the images. Remember, the spectra right now are assuming sampling of 
 ;f X 2f pixels for 2 arcsec X 4 arcsec. We need to return to 0.075 arcsec/pixel sampling (27 X 53 pixels for the same 2 arcsec X 4 arcsec). We
 ;will use the background subtracted spectrum in the output spectrograph image.
 tmp=spectrum_subtracted
 spectrum=congrid(tmp,r,53)

 ;Place this in a larger image. This will make it easier to place into the total spectrum.
 tmp=spectrum
 spectrum=fltarr(r,1300)
 spectrum(0:r-1,y-26:y+26)=tmp(0:r-1,0:52)

 ;Set the toggle to 1.
 spectrum_single_done=1

 endif
 endif

end

;------------------------------------------------------------------------------
;Run the integral field unit simulation.
pro spectrograph_integral_field_unit_simulation

common  variables, $
        galaxy_bulge_radius, galaxy_disk_radius, galaxy_bulge_to_total_1, galaxy_bulge_to_total_2, galaxy_bulge_to_total_3, $
        galaxy_bulge_to_total_4, galaxy_cutoff, galaxy_faint, galaxy_multiple, galaxy_shift, galaxy_shrink, galaxy_correlation, $
        galaxy_line_width, $
        star_cutoff, star_faint, star_multiple, star_correlation, star_white_bright, star_white_fraction, star_surface_brightness, $
        star_distance_modulus, $
        telescope_temperature, telescope_primary, telescope_diameter, telescope_roughness, telescope_surfaces, telescope_error, $
        telescope_target, $
        optical_imager_filter, optical_imager_comparison, optical_imager_surfaces, optical_imager_detector, optical_imager_pixel, $
        optical_imager_readout, optical_imager_dark, optical_imager_gain, optical_imager_well, optical_imager_flag, optical_imager_exposure, $
        optical_imager_exposure_unit, $
        spectrograph_flag, spectrograph_resolution, spectrograph_slices, spectrograph_slits, spectrograph_length, spectrograph_width, $
        spectrograph_exposure, spectrograph_exposure_unit, spectrograph_position, spectrograph_extract, spectrograph_filter, $
        spectrograph_comparison, spectrograph_surfaces, spectrograph_detector, spectrograph_pixel, spectrograph_readout, spectrograph_dark, $
        spectrograph_gain, spectrograph_well, $
        target_flag, $
        pupil, aperture_hst, aperture_scaling, $
        mirror_coating_aluminum, mirror_coating_silver, mirror_coating_gold, grating_efficiency, filters, filter_bandpasses, $
        detector_efficiency_1, detector_efficiency_2, detector_efficiency_3, spectrum_1, spectrum_2, spectrum_3, spectrum_4, $
        colour_magnitude_1, colour_magnitude_2, $
        star_colour_shift_1, star_colour_shift_2, star_colour_shift_3, star_colour_shift_4, $
        background_total, atmospheric_transmission, $
        galaxy, galaxy_fake, galaxy_disk, galaxy_redshift, galaxy_magnitude, galaxy_classification, galaxy_radius, $
        galaxies, galaxies_redshift, galaxies_weight, galaxies_magnitude, galaxies_classification, galaxies_radius, galaxies_hst, $
        galaxies_telescope, galaxies_1, galaxies_2, galaxies_3, galaxies_4, galaxies_5, galaxies_list_x_pos, galaxies_list_y_pos, $
        galaxies_list_magnitude, galaxies_list_redshift, galaxies_list_classification, galaxies_list_radius, galaxies_list_rotate, $
        galaxies_list_ellipticity, galaxies_total_number, galaxies_total_number_hst, galaxies_number_counts, galaxies_number_counts_hst, $
        galaxies_number_counts_label, galaxies_distribution_magnitude, galaxies_distribution_redshift, galaxies_distribution_magnitude_hst, $
        galaxies_distribution_redshift_hst, galaxies_distribution_radius, galaxies_distribution_radius_hst, $
        star, star_fwhm, star_strehl, $
        stars, stars_hst, stars_telescope, stars_background, stars_list_magnitude, stars_list_x_pos, stars_list_y_pos, $
        stars_list_classification, stars_total_number, stars_total_number_hst, stars_number_counts, stars_number_counts_hst, $
        stars_number_counts_label, $
        spectrum, spectrum_extract, spectrum_true_extract, $
        x, y, $
        photometry, ratio, galaxy_radius_output, $
        statistics_magnitude, statistics_ratio, $
        colour_table, size_print, screen_output, $
        www, www_background, $
        initialize_field_done, initialize_telescope_done, optical_imager_done, infrared_camera_done,  $
        select_done, spectrum_integral_field_unit_done, spectrum_single_done, spectrum_multiplex_done, $
        field_running, telescope_running, oi_running, mos_running, $
        window_id

 ;Check that the telescope is pointing at the galaxy field.
 if (telescope_target eq 1) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must select the galaxy field.', charsize=size_print, color=0, /device
 endif
 if (telescope_target eq 0) then begin

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must select a target first.', charsize=size_print, color=0, /device
 endif
 if (select_done eq 1) then begin

 ;Set up the display.
 wshow, window_id
 erase, 255
 loadct, 3, /silent

 ;Display the field.
 tmp=fltarr(778,741)
 tmp=galaxies_telescope(157:934,283:1023)
 tmp_1=congrid(tmp,210,200)
 tv, tmp_1, 30, 427
 
 ;Labels.
 xyouts, 30, 657, 'Galaxy Field', charsize=size_print, color=0, /device
 xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

 ;Selected area.
 x_i=(x-157)*(210./778.)+30-3
 x_f=x_i+7
 y_i=(y-283)*(200./741.)+427-7
 y_f=y_i+14
 arrow, x_i, y_i, x_f, y_i, /solid, hsize=0, color=255
 arrow, x_f, y_i, x_f, y_f, /solid, hsize=0, color=255
 arrow, x_f, y_f, x_i, y_f, /solid, hsize=0, color=255
 arrow, x_i, y_f, x_i, y_i, /solid, hsize=0, color=255

 ;Determine properties of the galaxy.
 galaxy_magnitude=galaxies_magnitude(x,y)
 galaxy_redshift=galaxies_redshift(x,y)
 galaxy_classification=galaxies_classification(x,y)
 galaxy_radius=galaxies_radius(x,y)
 tmp_4=strarr(6)
 tmp_4(0)='background'
 tmp_4(1)='E/S0'
 tmp_4(2)='Sbc'
 tmp_4(3)='Scd'
 tmp_4(4)='Irr'
 tmp_4(5)='stellar'
 if (floor(galaxy_classification) eq 0) then begin
  galaxy_radius=0. 
 endif

 ;Print information to the screen.
 xyouts, 30, 397, 'MOS Integral Field Unit', charsize=size_print, color=0, /device
 tmp_1=string(2.)
 tmp_1=strtrim(tmp_1,2)
 tmp_1=strmid(tmp_1,0,4)
 tmp_2=string(4.)
 tmp_2=strtrim(tmp_2,2)
 tmp_2=strmid(tmp_2,0,4)
 tmp_3='('+tmp_1+' arcsec X '+tmp_2+' arcsec)'
 xyouts, 30, 382, tmp_3, charsize=size_print, color=0, /device 
 xyouts, 30, 352, 'Centre of Field', charsize=size_print, color=0, /device 
 tmp=string(galaxy_redshift)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,4)
 xyouts, 30, 337, 'z = ', charsize=size_print, color=0, /device 
 xyouts, 240, 337, tmp, alignment=1.0, charsize=size_print, color=0, /device 
 xyouts, 30, 322, 'H(AB) = ', charsize=size_print, color=0, /device
 tmp=string(galaxy_magnitude)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,6)
 xyouts, 240, 322, tmp, alignment=1.0,charsize=size_print, color=0, /device
 xyouts, 30, 307, 'Object type = ', charsize=size_print, color=0, /device 
 xyouts, 240, 307, tmp_4(galaxy_classification), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 292, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device 
 tmp=string(galaxy_radius)
 tmp=strtrim(tmp,2)
 tmp=strmid(tmp,0,5)
 xyouts, 240, 292, tmp, alignment=1.0, charsize=size_print, color=0, /device

 ;Determine properties of the exposure.
 tmp=strarr(9)
 tmp(0)='open'
 tmp(1)='U'
 tmp(2)='B'
 tmp(3)='V'
 tmp(4)='R'
 tmp(5)='I'
 tmp(6)='J'
 tmp(7)='H'
 tmp(8)='K'
 completed_tmp=0

 ;Print information to the screen.
 xyouts, 30, 262, 'Exposure', charsize=size_print, color=0, /device 
 xyouts, 30, 247, 'Filter = ', charsize=size_print, color=0, /device 
 xyouts, 240, 247, tmp(0), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 232, 'Unit exposure (s) = ', charsize=size_print, color=0, /device 
 xyouts, 240, 232, spectrograph_exposure_unit, alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 217, 'Number of exposures = ', charsize=size_print, color=0, /device 
 xyouts, 240, 217, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
 xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
 xyouts, 240, 202, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
 wait, 1

 ;Print a message to the screen.
 xyouts, 525, 365, 'Initializing ...', charsize=size_print, color=0, /device

 ;Initialize.
 f=floor(2./spectrograph_pixel)
 s=f-1
 r=floor(spectrograph_resolution)
 exposure_time=spectrograph_exposure*spectrograph_exposure_unit
 if ((telescope_primary eq 0) or (telescope_primary eq 2) or (telescope_primary eq 3)) then begin
  telescope_mirror=congrid(mirror_coating_aluminum(0:2999),r)
 endif
 if (telescope_primary eq 1) then begin
  telescope_mirror=congrid(mirror_coating_gold(0:2999),r)
 endif
 transmission=congrid(atmospheric_transmission(0:29999),r)
 spectrograph_mirror=congrid(mirror_coating_gold(0:2999),r)
 grating=congrid(grating_efficiency(0:2999),r)
 tmp=fltarr(3000)
 tmp=filters(7,0:2999)
 filter_h=fltarr(r)
 filter_h(0:r-1)=congrid(tmp(0:2999),r)
 if (spectrograph_detector eq 0) then begin
  detector=congrid(detector_efficiency_1(0:2999),r)
 endif
 if (spectrograph_detector eq 1) then begin
  detector=congrid(detector_efficiency_2(0:2999),r)
 endif
 if (spectrograph_detector eq 2) then begin
  detector=congrid(detector_efficiency_3(0:2999),r)
 endif

 ;Calculate the throughput. This is in e-/photon.
 tmp=fltarr(r)
 tmp=tmp+1.
 throughput_atmosphere=total(transmission*filter_h*tmp)/total(filter_h*tmp)
throughput_instrument=total((telescope_mirror^telescope_surfaces)*(spectrograph_mirror^spectrograph_surfaces)*grating*filter_h*detector*tmp)/total(filter_h*tmp)

 ;The detector.
 spectrum_total=fltarr(5200,4000)
 footprint_total=spectrum_total

 ;Take the spectra.
 tmp_1=congrid(galaxies_1(x-13:x+13,y-26:y+26),f,2*f)
 tmp_2=congrid(galaxies_2(x-13:x+13,y-26:y+26),f,2*f)
 tmp_3=congrid(galaxies_3(x-13:x+13,y-26:y+26),f,2*f)
 tmp_4=congrid(galaxies_4(x-13:x+13,y-26:y+26),f,2*f)
 tmp_5=congrid(galaxies_5(x-13:x+13,y-26:y+26),f,2*f)

 ;The galaxy weights.
 galaxy_weight=congrid(galaxies_weight(x-13:x+13,y-26:y+26),f,2*f) 

 ;Shift the spectra according to the given redshifts of the galaxies. Note that the input spectrum covers a range of 0.0 to 3.0 microns with 30000
 ;data points. Also, we renormalize each output spectrum to have a flux of 1 over H.
 
 ;E/S0.
 spectrum_1_tmp=fltarr(r,f,2*f)
 for i=0,s do begin
  for j=0,f+s do begin
   if (tmp_1(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_1(i,j)))-1      
    spectrum_1_tmp(0:r-1,i,j)=congrid(spectrum_1(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_1_tmp(0:r-1,i,j))
    spectrum_1_tmp(0:r-1,i,j)=spectrum_1_tmp(0:r-1,i,j)/tmp
   endif
  endfor
 endfor

 ;Sbc.
 spectrum_2_tmp=fltarr(r,f,2*f)
 for i=0,s do begin
  for j=0,f+s do begin
   if (tmp_2(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_2(i,j)))-1
    spectrum_2_tmp(0:r-1,i,j)=congrid(spectrum_2(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_2_tmp(0:r-1,i,j))
    spectrum_2_tmp(0:r-1,i,j)=spectrum_2_tmp(0:r-1,i,j)/tmp
   endif
  endfor
 endfor

 ;Scd.
 spectrum_3_tmp=fltarr(r,f,2*f)
 for i=0,s do begin
  for j=0,f+s do begin
   if (tmp_3(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_3(i,j)))-1
    spectrum_3_tmp(0:r-1,i,j)=congrid(spectrum_3(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_3_tmp(0:r-1,i,j))
    spectrum_3_tmp(0:r-1,i,j)=spectrum_3_tmp(0:r-1,i,j)/tmp 
   endif
  endfor
 endfor

 ;Irr.
 spectrum_4_tmp=fltarr(r,f,2*f)
 for i=0,s do begin
  for j=0,f+s do begin
   if (tmp_4(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_4(i,j)))-1
    spectrum_4_tmp(0:r-1,i,j)=congrid(spectrum_4(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_4_tmp(0:r-1,i,j))
    spectrum_4_tmp(0:r-1,i,j)=spectrum_4_tmp(0:r-1,i,j)/tmp 
   endif
  endfor
 endfor

 ;Stellar.
 spectrum_5_tmp=fltarr(r,f,2*f)
 for i=0,s do begin
  for j=0,f+s do begin
   if (tmp_5(i,j) gt 0.) then begin
    blue=0
    red=floor(30000./(1.+tmp_5(i,j)))-1
    spectrum_5_tmp(0:r-1,i,j)=congrid(spectrum_4(blue:red),r)
    tmp=total(filter_h(0:r-1)*spectrum_5_tmp(0:r-1,i,j))
    spectrum_5_tmp(0:r-1,i,j)=spectrum_5_tmp(0:r-1,i,j)/tmp 
   endif
  endfor
 endfor

 ;Combine them.
 spectrum=fltarr(r,f,2*f)
 for i=0,s do begin
  for j=0,f+s do begin
   spectrum(0:r-1,i,j)=spectrum_1_tmp(0:r-1,i,j)+spectrum_2_tmp(0:r-1,i,j)+spectrum_3_tmp(0:r-1,i,j)+spectrum_4_tmp(0:r-1,i,j)+spectrum_5_tmp(0:r-1,i,j)
  endfor
 endfor

 ;Now, if the galaxy weight is 0, that is, there is no galaxy, set it to 1. Now you won't divide by 0 when you correct for overlapping galaxies.
 for i=0,s do begin
  for j=0,f+s do begin
   if (galaxy_weight(i,j) eq 0.) then begin
    galaxy_weight(i,j)=1.
   endif
  endfor
 endfor

 ;We divide by the galaxy weight in order to average the spectrum whenever two galaxies overlap.
 for i=0,r-1 do begin
  spectrum(i,0:s,0:f+s)=spectrum(i,0:s,0:f+s)/galaxy_weight(0:s,0:f+s)
 endfor

 ;We generate a spectrum as if all the light were in a single emission line at 1 micron.
 spectrum_line=fltarr(r,f,2*f)
 spectrum_line(floor(0.333*r),0:s,0:f+s)=1.
 
 ;Generate the ideal artificial images by going along the dispersion axis.
 galaxy=fltarr(r,f,2*f)
 psf=galaxy
 psf_function=fltarr(f,2*f)

 ;Extract the smaller field. This is in photons/s.
 galaxy_tmp=congrid(aperture_scaling*galaxies(2*x-26:2*x+26,2*y-52:2*y+52),f,2*f)

 ;Make sure that flux is conserved.
 tmp=total(galaxy_tmp)
 if (tmp eq 0.) then begin
  tmp=1.
 endif
 galaxy_tmp=galaxy_tmp*total(aperture_scaling*galaxies(2*x-26:2*x+26,2*y-52:2*y+52))/tmp

 ;If this is the background.
 if (floor(galaxy_classification) eq 0) then begin
  galaxy_tmp=fltarr(f,2*f)
  galaxy_tmp=galaxy_tmp+1.
 endif 

 ;Calculate the PSFs. We want a 2.0 arcsec X 4.0 arcsec section.
 psf_function=fltarr(30,f,2*f)
 for i=0,29 do begin

  ;Extract the section.
  tmp=fltarr(200,400)
  tmp(0:199,100:299)=star(i,0:199,0:199)

  ;We rebin this to have the same pixel sampling as selected for the detector.
  psf_function(i,0:s,0:f+s)=congrid(tmp(0:199,0:399),f,2*f)

  ;Make sure this has a total flux of 1.
  psf_function(i,0:s,0:f+s)=psf_function(i,0:s,0:f+s)/total(psf_function(i,0:s,0:f+s))

 endfor

 ;Now, apply the PSF to the images.
 for i=0,r-1 do begin

  ;Now, convolve the images with the PSF.
  tmp=fltarr(f,2*f)

  ;Find what range in wavelength we are in and select the PSF.
  for j=0,28 do begin
   if ((i gt floor((float(j)/29.)*r)) and (i le floor(float(j+1)/29.*r))) then begin
     
    ;The PSF.
    tmp_1=tmp
    distance_from=(i-floor(0.0333333*j*r))/(0.0333333*r)
    if (distance_from gt 1.) then begin
     distance_from=1.
    endif
    distance_to=1.-distance_from
    tmp_1(0:s,0:f+s)=distance_to*psf_function(j,0:s,0:f+s)+distance_from*psf_function(j+1,0:s,0:f+s)
    tmp_1=tmp_1/total(tmp_1)

   endif
  endfor

  ;The galaxy image.
  tmp(0:s,0:f+s)=spectrum(i,0:s,0:f+s)*galaxy_tmp(0:s,0:f+s)
  galaxy(i,0:s,0:f+s)=convolve(tmp(0:s,0:f+s),tmp_1(0:s,0:f+s))

  ;The spectral line image.
  tmp(0:s,0:f+s)=spectrum_line(i,0:s,0:f+s)*galaxy_tmp(0:s,0:f+s)
  psf(i,0:s,0:f+s)=convolve(tmp(0:s,0:f+s),tmp_1(0:s,0:f+s)) 

 endfor

 ;Set image size.
 image=fltarr(r,f,2*f)
 image_true=image
 image_background=image
 image_white=image+1.
 image_total=fltarr(f,2*f)

 ;Make a perfect image. This is in e-/pixel.
 for i=0,r-1 do begin
image_true(i,0:s,0:f+s)=exposure_time*(telescope_mirror(i)^telescope_surfaces)*(spectrograph_mirror(i)^spectrograph_surfaces)*grating(i)*detector(i)*galaxy(i,0:s,0:f+s)
 endfor

 ;Make an image that does not have any background or noise added.  
 for i=0,r-1 do begin
  image(i,0:s,0:f+s)=transmission(i)*image_true(i,0:s,0:f+s)
 endfor

 ;Now, add background and noise. The noise is Poisson noise due to object signal, background and dark current. The background is scaled by the
 ;pixel size. Note, image and image_true are in units of e-/pixel. Also, the background is in units of photons/pixel/second. We want
 ;e-/pixel/second. We multiply by the quantum efficiency as well.  

 ;First, calculate the background.
 background=congrid(background_total,r)
 background=(spectrograph_pixel^2)*background*total(background_total)/total(background)/1000.

 ;Send this through the spectrograph. The output is in e-/pixel/s.
 for i=0,r-1 do begin
  background(i)=(telescope_mirror(i)^telescope_surfaces)*(spectrograph_mirror(i)^spectrograph_surfaces)*grating(i)*detector(i)*background(i)
 endfor

 ;Add the dark current, background, and Poisson noise.
 for i=0,r-1 do begin

  ;First, through the spectrgraph.
  image(i,0:s,0:f+s)=image(i,0:s,0:f+s)+exposure_time*(background(i)+spectrograph_dark)
  image_background(i,0:s,0:f+s)=image_background(i,0:s,0:f+s)+exposure_time*(background(i)+spectrograph_dark)
  
  ;Calculate and add the Poisson noise.
  image(i,0:s,0:f+s)=image(i,0:s,0:f+s)+randomn(seed,f,2*f)*sqrt(image(i,0:s,0:f+s))
  image_background(i,0:s,0:f+s)=image_background(i,0:s,0:f+s)+randomn(seed,f,2*f)*sqrt(image_background(i,0:s,0:f+s))
  
 endfor
 
 ;Generate readout noise. Note, this is in units of e-. Note, the exposures are taken in sub-exposures.
 readout_noise=fltarr(f,2*f)
 for i=1,spectrograph_exposure do begin
  readout_noise(0:s,0:f+s)=readout_noise(0:s,0:f+s)+spectrograph_readout*randomn(seed,f,2*f)
 endfor

 ;Add readout noise.
 for i=0,r-1 do begin
  image(i,0:s,0:f+s)=image(i,0:s,0:f+s)+readout_noise(0:s,0:f+s)*randomn(seed)
  image_background(i,0:s,0:f+s)=image_background(i,0:s,0:f+s)+readout_noise(0:s,0:f+s)*randomn(seed)
 endfor

 ;Now, set the number of completed exposures in the display.
 blank=fltarr(50,15)
 blank=blank+255
 tv, blank, 190, 202
 completed_tmp=floor(spectrograph_exposure)
 xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
 xyouts, 240, 202, completed_tmp, alignment=1.0, charsize=size_print, color=0, /device
 wait, 1

 ;Generate an image of the total light through the spectrograph that is registered by the detector if the aperture is wide open.
 for i=0,s do begin
  for j=0,f+s do begin
   image_total(i,j)=image_total(i,j)+total(image(0:r-1,i,j))
  endfor
 endfor

 ;Simulate a reconstructed image from the image slices and generate an H image.  
 image_out_h=fltarr(f,2*f)
 image_out_h_true=image_out_h
 image_out_h_background=image_out_h

 ;First, pass the light through an H filter.
 tmp=congrid(filter_h,100)
 tmp_1=congrid(image,100,f,2*f)
 tmp_2=congrid(image_true,100,f,2*f)
 tmp_3=congrid(image_background,100,f,2*f)
 for i=0,99 do begin
  image_out_h=image_out_h+(float(r)/100.)*tmp(i)*tmp_1(i,0:s,0:f+s)
  image_out_h_true=image_out_h_true+(float(r)/100.)*tmp(i)*tmp_2(i,0:s,0:f+s)
  image_out_h_background=image_out_h_background+(float(r)/100.)*tmp(i)*tmp_3(i,0:s,0:f+s) 
 endfor

 ;Correct for system throughput and exposure time. The output is in photons/s.
 image_out_h=(1./(throughput_atmosphere*throughput_instrument))*image_out_h/exposure_time
 image_out_h_true=(1./throughput_instrument)*image_out_h_true/exposure_time
 image_out_h_background=(1./throughput_instrument)*image_out_h_background/exposure_time

 ;Do photometry on this image. Note that the image has counts in e-. 

 ;Use a 1.0 arcsec aperture.
 aperture=floor(1.0/2/spectrograph_pixel)   

 ;Normalize to the radius of the image (f/2 pixels).
 aperture=aperture/float(f/2)      
 tmp_1=shift((dist(f)*2./f lt aperture and dist(f)*2./f ge 0.),float(f/2),float(f/2))
 tmp_cut=fltarr(f,2*f)
 tmp_cut(0:s,f-floor(f/2):f-floor(f/2)+s)=tmp_1

 ;Determine the flux through a 1.0 arcsec aperture.
 flux=total(tmp_cut*(image_out_h-image_out_h_background))
 flux_true=total(tmp_cut*image_out_h_true)
 flux_background=total(tmp_cut*image_out_h_background)

 ;Calculate H(AB).
 lambda=16000.
 dlambda=3500.
 c=299792458. ;m/s
 h=6.6260755e-34 ;Joule/s
 nu=c/(lambda*1.e-10) ;Hz
 dnu=c/(dlambda*1.e-10) ;Hz
 flux=flux*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
 flux_true=flux_true*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)
 flux_background=flux_background*(1e7)*nu*h/(dnu*aperture_scaling*aperture_hst*10000.)

 ;But, this is the flux in ergs/cm^2/second/Hz. We want it this in units of AB magnitudes. 
 photometry=-2.5*alog10(flux)-48.6
 photometry_true=-2.5*alog10(flux_true)-48.6
 photometry_background=-2.5*alog10(flux_background)-48.6

 ;Calculate the radius of the galaxy.
 tmp_1=fltarr(f,2*f)
 tmp_1=tmp_cut*(image_out_h)
 tmp=max(tmp_1)
 if (tmp le 0.) then begin
  tmp=1.
 endif
 tmp_1=tmp_1/tmp

 ;Count the number of pixels at half-light.
 tmp_2=0
 for j=0,s do begin
  for k=0,f+s do begin
   if (tmp_1(j,k) gt 0.5) then begin
    tmp_2=tmp_2+1
   endif
  endfor
 endfor

 ;Now this is an area. Assume it is circular and find the radius.
 galaxy_radius_out=spectrograph_pixel*sqrt(tmp_2/!dpi)

 ;If this is the background reset the values.
 if (floor(galaxy_classification) eq 0) then begin
  photometry=photometry_background
  photometry_true=photometry_background
  galaxy_radius_out=0.
 endif

 ;Copy the images.
 image_tmp=image
 image_true_tmp=image_true
 image_background_tmp=image_background
 image_white_tmp=image_white

 ;Now, we run the spectrograph simulation but with the slit in 10 different positions in the image.
 for k=0,spectrograph_slices do begin

  ;Make the slit-mask. Note, width and length are in milliarcsec. The aperture width is fixed at 2.0 arcsec and is divided into slices.
  size_width=floor((1./spectrograph_pixel)*2./2)
  size_length=floor((1./spectrograph_pixel)*4./2)
  mask=fltarr(r,f,2*f)

  ;Find the middle of the array
  tmp=float(f/2)-0.5
  tmp_1=float(f)-0.5

  ;Now, find the blue edge of the integral field unit.
  tmp_2=tmp-size_width

  ;And for this slit.
  slit_blue=floor(tmp_2+k*floor(float(f)/float(spectrograph_slices)))
  if (slit_blue le 0) then begin
   slit_blue=1
  endif

  ;The red end is then.
  slit_red=floor(slit_blue+floor(float(f)/float(spectrograph_slices)))-1
  if (slit_red ge f) then begin
   slit_red=f-1
  endif
  mask(0:r-1,slit_blue:slit_red,tmp_1-size_length+1:tmp_1+size_length-1)=1.
 
  ;Make the extraction-mask. Note that it is made twice as large as needed to start and then is trimmed down. This is so that the user can 
  ;specify an extraction width of f pixels without crashing the program. Note, extract and position are in milliseconds.
  size_extract=floor((1./spectrograph_pixel)*(spectrograph_extract)/2)
  size_position=floor((1./spectrograph_pixel)*(spectrograph_position))
  tmp=fltarr(1,4*f) 
  tmp(0,f+(size_position)-size_extract:f+(size_position)+size_extract)=1.
  extract_mask=tmp(0,f:3*f-1)

  ;This is just the total image. But now, mask off the slit.
  image=mask*image_tmp
  image_psf=mask*psf
  image_background=mask*image_background_tmp

  ;Also mask off the image as if there was no background light or noise.
  image_true=mask*image_true_tmp

  ;Also generate a mask of the illumination of the spectrograph.
  image_white=mask*image_white_tmp

  ;Generate spectra from what is in the slit. Note that we make the full array bigger than the spectrum. It is set to a size of 5200.   
  spectrum=fltarr(5200,2*f)
  spectrum_true=spectrum
  spectrum_psf=spectrum
  spectrum_background=spectrum
  correction=spectrum
  for i=0,s do begin
   for j=0,r-1 do begin    

    ;The correction is the result of passing uniform white light through the slit in exactly the same manner as the galaxy light.
    correction(i+j,0:f+s)=correction(i+j,0:f+s)+image_white(j,i,0:f+s)

    ;The spectra.
    spectrum(i+j,0:f+s)=spectrum(i+j,0:f+s)+image(j,i,0:f+s)
    spectrum_true(i+j,0:f+s)=spectrum_true(i+j,0:f+s)+image_true(j,i,0:f+s)
    spectrum_psf(i+j,0:f+s)=spectrum_psf(i+j,0:f+s)+image_psf(j,i,0:f+s)
    spectrum_background(i+j,0:f+s)=spectrum_background(i+j,0:f+s)+image_background(j,i,0:f+s)
  
   endfor
  endfor

  ;Correct the spectra for slit illumination.
  correction=correction/(max(correction))+0.00001
  spectrum=spectrum/correction
  spectrum_true=spectrum_true/correction
  spectrum_psf=spectrum_psf/correction
  spectrum_background=spectrum_background/correction

  ;Take the spectrum from the full spectrum. Remember, the resolution is r. The offset is half the size of the input image.
  blue=slit_blue
  red=blue+r-slit_blue
  tmp=spectrum
  spectrum=congrid(tmp(blue:red,0:f+s),r,2*f)
  tmp=spectrum_true
  spectrum_true=congrid(tmp(blue:red,0:f+s),r,2*f)
  tmp=spectrum_psf
  spectrum_psf=congrid(tmp(blue:red,0:f+s),r,2*f)
  tmp=spectrum_background
  spectrum_background=congrid(tmp(blue:red,0:f+s),r,2*f)

  ;Make background subtracted spectra.
  spectrum_subtracted=spectrum-spectrum_background

  ;Add the spectrum to the detector.
  if (k*2*size_length+4-1 lt 4000) then begin
   spectrum_total(5:r+5-1,k*2*size_length+4:k*2*size_length+2*size_length+4-1)=spectrum_total(5:r+5-1,k*2*size_length+4:k*2*size_length+2*size_length+4-1)+spectrum_subtracted(0:r-1,0:f+s)
   footprint_total(5:r+5-1,k*2*size_length+4:k*2*size_length+2*size_length+4-1)=1
  endif

  ;Extract a slice perpendicular to the dispersion direction.
  spectrum_slice=fltarr(2*f)
  for i=0,f+s do begin
   spectrum_slice(i)=total(spectrum_subtracted(0:r-1,i))
  endfor

  ;Also, set up some display plots to show the position of the extraction region.
  peak_spectrum=extract_mask(0,0:f+s)*max(spectrum_slice)

  ;Extract the spectrum of the target.
  spectrum_extract=fltarr(r)
  spectrum_true_extract=spectrum_extract
  spectrum_psf_extract=spectrum_extract
  for i=0,r-1 do begin
   correction=1./((telescope_mirror(i)^telescope_surfaces)*(spectrograph_mirror(i)^spectrograph_surfaces)*grating(i)*detector(i))
   if (correction eq 0.) then begin
    correction=1.
   endif
   if (correction eq 'Inf') then begin
    correction=1.
   endif
   if (transmission(i) eq 0.) then begin
    transmission(i)=1.
   endif
   spectrum_extract(i)=total(extract_mask(0,0:f+s)*(correction/transmission(i))*spectrum_subtracted(i,0:f+s))
   spectrum_true_extract(i)=total(extract_mask(0,0:f+s)*correction*spectrum_true(i,0:f+s))
   spectrum_psf_extract(i)=total(extract_mask(0,0:f+s)*spectrum_psf(i,0:f+s))
  endfor

  ;Calculate the signal-to-noise ratio by using the true spectrum and finding the RMS of the fluctuations over 1.0 to 2.0 microns.  ratio=total(spectrum_extract(floor(0.333*r):floor(0.666*r-1)))/sqrt(total((spectrum_extract(floor(0.333*r):floor(0.666*r-1))-spectrum_true_extract(floor(0.333*r):floor(0.666*r-1)))^2))
  if (ratio lt 0.) then begin
   ratio=0.
  endif

  ;Find the delivered resolution. First, find the FWHM of the narrow spectral line.
  spectrum_psf_extract=spectrum_psf_extract/max(spectrum_psf_extract)
  fwhm=0.
  for i=0,r-1 do begin
   if (spectrum_psf_extract(i) ge 0.5) then begin
    fwhm=fwhm+1.
   endif
  endfor
  resolution_delivered=r/fwhm

  ;Set up the display.
  wshow, window_id
  erase, 255
  !p.multi = [0,4,2]
  character_size=size_print*1.5

  ;Top row.

  ;Dummy plot.
  plot, spectrum_slice, spectrum_slice, min_value=0., color=255

  ;Display the field.
  tmp=fltarr(778,741)
  tmp=galaxies_telescope(157:934,283:1023)
  tmp_1=congrid(tmp,210,200)
  tv, tmp_1, 30, 427
 
  ;Labels.
  xyouts, 30, 657, 'Galaxy Field', charsize=size_print, color=0, /device
  xyouts, 30, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

  ;Selected area.
  x_i=(x-157)*(210./778.)+30-3
  x_f=x_i+7
  y_i=(y-283)*(200./741.)+427-7
  y_f=y_i+14

  ;Draw a box around the selected area.
  arrow, x_i, y_i, x_f, y_i, /solid, hsize=0, color=255
  arrow, x_f, y_i, x_f, y_f, /solid, hsize=0, color=255
  arrow, x_f, y_f, x_i, y_f, /solid, hsize=0, color=255
  arrow, x_i, y_f, x_i, y_i, /solid, hsize=0, color=255

  ;Draw an arrow to the spectrograph display.

  ;Black.
  arrow, 307, 504, x_f, y_f, /solid, hsize=0, color=0
 
  ;White.
  arrow, 305, 502, x_f, y_f-1, /solid, hsize=0, color=255

  ;The spectra.

  ;The total flux. 

  ;Generate an axis label.
  xlabel=fltarr(r)
  for i=0,s do begin
   xlabel(i)=spectrograph_pixel*i
  endfor
  ylabel=fltarr(r)
  for i=0,f+s do begin
   ylabel(i)=-2.+spectrograph_pixel*i
  endfor

  ;Plot
  shade_surf, mask(0,0:s,0:f+s)*image_total(0:s,0:f+s)/max(image_total(0:s,0:f+s)), xlabel(0:s), ylabel(0:f+s), xmargin=[10,0], ymargin=[0,5], ax=70., az=10., min_value=0., charsize=size_print*2.5, xtitle='Field Width (arcsec)', ytitle='Declination (arcsec)', ztitle='Intensity', color=0

  ;The background subtracted spectrum.

  ;Generate an axis label.
  xlabel=fltarr(r)
  for i=0,r-1 do begin
   xlabel(i)=0.+(i/float(r))*3.
  endfor

  ;Plot.
  shade_surf, spectrum(0:r-1,0:f+s-1)/max(spectrum(0:r-1,0:f+s-1)), xlabel(0:r-1), ylabel(0:f+s-1), xmargin=[2.5,2.5], ymargin=[0,5], ax=70., az=10., min_value=0., charsize=size_print*2.5, ytitle='Declination (arcsec)', xtitle='Dispersion (micron)', ztitle='Intensity', color=0
  shade_surf, spectrum_subtracted(0:r-1,0:f+s-1)/max(spectrum_subtracted(0:r-1,0:f+s-1)), xlabel(0:r-1), ylabel(0:f+s-1), xmargin=[0,5], ymargin=[0,5], ax=70., az=10., min_value=0., charsize=size_print*2.5, ytitle='Declination (arcsec)', xtitle='Dispersion (micron)', ztitle='Intensity', color=0

  ;And labels.
  xyouts, 320, 655, 'Total Light', charsize=size_print, color=0, /device
  xyouts, 505, 655, 'Raw Spectrum', charsize=size_print, color=0, /device 
  xyouts, 680, 655, 'Background-Subtracted', charsize=size_print, color=0, /device
  
  ;Bottom row.

  ;Dummy plot.
  plot, spectrum_slice, spectrum_slice, min_value=0., color=255

  ;Determine properties of the galaxy. 
  galaxy_magnitude=galaxies_magnitude(x,y)
  galaxy_redshift=galaxies_redshift(x,y)
  galaxy_classification=galaxies_classification(x,y)
  galaxy_radius=galaxies_radius(x,y)
  tmp_4=strarr(6)
  tmp_4(0)='background'
  tmp_4(1)='E/S0'
  tmp_4(2)='Sbc'
  tmp_4(3)='Scd'
  tmp_4(4)='Irr'
  tmp_4(5)='stellar'
  if (floor(galaxy_classification) eq 0) then begin
   galaxy_radius=0. 
  endif

  ;Print information to the screen.
  xyouts, 30, 397, 'MOS Integral Field Unit', charsize=size_print, color=0, /device
  tmp_1=string(2.)
  tmp_1=strtrim(tmp_1,2)
  tmp_1=strmid(tmp_1,0,4)
  tmp_2=string(4.)
  tmp_2=strtrim(tmp_2,2)
  tmp_2=strmid(tmp_2,0,4)
  tmp_3='('+tmp_1+' arcsec X '+tmp_2+' arcsec)'
  xyouts, 30, 382, tmp_3, charsize=size_print, color=0, /device 
  xyouts, 30, 352, 'Centre of Field', charsize=size_print, color=0, /device 
  tmp=string(galaxy_redshift)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 30, 337, 'z = ', charsize=size_print, color=0, /device 
  xyouts, 240, 337, tmp, alignment=1.0, charsize=size_print, color=0, /device 
  xyouts, 30, 322, 'H(AB) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_magnitude)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6)
  xyouts, 240, 322, tmp, alignment=1.0,charsize=size_print, color=0, /device
  xyouts, 30, 307, 'Object type = ', charsize=size_print, color=0, /device 
  xyouts, 240, 307, tmp_4(galaxy_classification), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 292, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device 
  tmp=string(galaxy_radius)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 292, tmp, alignment=1.0, charsize=size_print, color=0, /device

  ;Determine properties of the exposure.
  tmp=strarr(9)
  tmp(0)='open' 
  tmp(1)='U'
  tmp(2)='B'
  tmp(3)='V'
  tmp(4)='R'
  tmp(5)='I'
  tmp(6)='J'
  tmp(7)='H'
  tmp(8)='K'
  completed_tmp=0

  ;Print information to the screen.
  xyouts, 30, 262, 'Exposure', charsize=size_print, color=0, /device 
  xyouts, 30, 247, 'Filter = ', charsize=size_print, color=0, /device 
  xyouts, 240, 247, tmp(0), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 232, 'Unit exposure (s) = ', charsize=size_print, color=0, /device 
  xyouts, 240, 232, spectrograph_exposure_unit, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 217, 'Number of exposures = ', charsize=size_print, color=0, /device 
  xyouts, 240, 217, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 202, 'Number completed = ', charsize=size_print, color=0, /device 
  xyouts, 240, 202, floor(spectrograph_exposure), alignment=1.0, charsize=size_print, color=0, /device
  wait, 1

  ;Set the normalization.
  tmp=max(spectrum_slice)
  if (tmp le 0.) then begin
   tmp=1.
  endif

  ;The spectrum slice.

  ;Generate an axis label.
  xlabel=fltarr(r)
  for i=0,f+s do begin
  xlabel(i)=-2.+spectrograph_pixel*i
  endfor
  plot, spectrum_slice/tmp, xlabel, xstyle=1, ystyle=1., xrange=[0,1], yrange=[-2,2], xmargin=[15,0], ymargin=[6,6], charsize=character_size, thick=1, ytitle='Declination (arcsec)', xtitle='Intensity', title='Extraction Region', color=0
  oplot, peak_spectrum/tmp, xlabel, linestyle=2, color=0

  ;The extracted spectrum.

  ;Set the normalization.
  tmp=max(spectrum_true_extract)
  if (tmp le 0.) then begin
   tmp=1.
  endif

  ;Generate an axis label.
  xlabel=fltarr(r)
  for i=0,r-1 do begin
   xlabel(i)=0.+(i/float(r))*3.
  endfor
  plot, xlabel, spectrum_extract/tmp, xmargin=[10,-35], ymargin=[6,6], yrange=[0,1], charsize=character_size, thick=1, xtitle='Dispersion (micron)', ytitle='Intensity',title='Extracted Spectrum', color=0
  oplot, xlabel, spectrum_true_extract/tmp, min_value=0., max_value=1., linestyle=2, color=0

  ;And write to the screen.
  xyouts, 30, 172, 'Values for Field', charsize=size_print, color=0, /device
  xyouts, 30, 157, 'H(AB) observed = ', charsize=size_print, color=0, /device
  tmp=string(photometry)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6)
  xyouts, 240, 157, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 142, 'H(AB) true = ', charsize=size_print, color=0, /device
  tmp=string(photometry_true)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,6)
  xyouts, 240, 142, tmp, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 127, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device
  tmp=string(galaxy_radius_out)
  tmp=strtrim(tmp,2)
  tmp=strmid(tmp,0,4)
  xyouts, 240, 127, tmp, alignment=1.0, charsize=size_print, color=0, /device 

  ;And write to the screen.
  xyouts, 30, 97, 'Values for Slice', charsize=size_print, color=0, /device
  xyouts, 30, 82, 'S/N = ', charsize=size_print, color=0, /device
  xyouts, 240, 82, ratio, alignment=1.0, charsize=size_print, color=0, /device
  xyouts, 30, 67, 'R delivered = ', charsize=size_print, color=0, /device
  xyouts, 240, 67, resolution_delivered, alignment=1.0, charsize=size_print, color=0, /device 
  wait, 1

 endfor

 ;Write the spectrum to disk.
 writefits, './virtual_telescope_results/spectrum_slicer.fits', spectrum_total

 ;Rebin the footprint and write it to disk.
 tmp=footprint_total
 footprint_total=congrid(tmp,1040,800)
 writefits, './virtual_telescope_results/footprint_slicer.fits', footprint_total

 ;Set the toggle to 1.
 spectrum_integral_field_unit_done=1

 endif
 endif
end

;--------------------------------------------------------------------------------
;Take a spectroscopic survey of all galaxies of flag magnitude.
pro spectrograph_survey

common  variables, $
        galaxy_bulge_radius, galaxy_disk_radius, galaxy_bulge_to_total_1, galaxy_bulge_to_total_2, galaxy_bulge_to_total_3, $
        galaxy_bulge_to_total_4, galaxy_cutoff, galaxy_faint, galaxy_multiple, galaxy_shift, galaxy_shrink, galaxy_correlation, $
        galaxy_line_width, $
        star_cutoff, star_faint, star_multiple, star_correlation, star_white_bright, star_white_fraction, star_surface_brightness, $
        star_distance_modulus, $
        telescope_temperature, telescope_primary, telescope_diameter, telescope_roughness, telescope_surfaces, telescope_error, $
        telescope_target, $
        optical_imager_filter, optical_imager_comparison, optical_imager_surfaces, optical_imager_detector, optical_imager_pixel, $
        optical_imager_readout, optical_imager_dark, optical_imager_gain, optical_imager_well, optical_imager_flag, optical_imager_exposure, $
        optical_imager_exposure_unit, $
        spectrograph_flag, spectrograph_resolution, spectrograph_slices, spectrograph_slits, spectrograph_length, spectrograph_width, $
        spectrograph_exposure, spectrograph_exposure_unit, spectrograph_position, spectrograph_extract, spectrograph_filter, $
        spectrograph_comparison, spectrograph_surfaces, spectrograph_detector, spectrograph_pixel, spectrograph_readout, spectrograph_dark, $
        spectrograph_gain, spectrograph_well, $
        target_flag, $
        pupil, aperture_hst, aperture_scaling, $
        mirror_coating_aluminum, mirror_coating_silver, mirror_coating_gold, grating_efficiency, filters, filter_bandpasses, $
        detector_efficiency_1, detector_efficiency_2, detector_efficiency_3, spectrum_1, spectrum_2, spectrum_3, spectrum_4, $
        colour_magnitude_1, colour_magnitude_2, $
        star_colour_shift_1, star_colour_shift_2, star_colour_shift_3, star_colour_shift_4, $
        background_total, atmospheric_transmission, $
        galaxy, galaxy_fake, galaxy_disk, galaxy_redshift, galaxy_magnitude, galaxy_classification, galaxy_radius, $
        galaxies, galaxies_redshift, galaxies_weight, galaxies_magnitude, galaxies_classification, galaxies_radius, galaxies_hst, $
        galaxies_telescope, galaxies_1, galaxies_2, galaxies_3, galaxies_4, galaxies_5, galaxies_list_x_pos, galaxies_list_y_pos, $
        galaxies_list_magnitude, galaxies_list_redshift, galaxies_list_classification, galaxies_list_radius, galaxies_list_rotate, $
        galaxies_list_ellipticity, galaxies_total_number, galaxies_total_number_hst, galaxies_number_counts, galaxies_number_counts_hst, $
        galaxies_number_counts_label, galaxies_distribution_magnitude, galaxies_distribution_redshift, galaxies_distribution_magnitude_hst, $
        galaxies_distribution_redshift_hst, galaxies_distribution_radius, galaxies_distribution_radius_hst, $
        star, star_fwhm, star_strehl, $
        stars, stars_hst, stars_telescope, stars_background, stars_list_magnitude, stars_list_x_pos, stars_list_y_pos, $
        stars_list_classification, stars_total_number, stars_total_number_hst, stars_number_counts, stars_number_counts_hst, $
        stars_number_counts_label, $
        spectrum, spectrum_extract, spectrum_true_extract, $
        x, y, $
        photometry, ratio, galaxy_radius_output, $
        statistics_magnitude, statistics_ratio, $
        colour_table, size_print, screen_output, $
        www, www_background, $
        initialize_field_done, initialize_telescope_done, optical_imager_done, infrared_camera_done,  $
        select_done, spectrum_integral_field_unit_done, spectrum_single_done, spectrum_multiplex_done, $
        field_running, telescope_running, oi_running, mos_running, $
        window_id

 ;Check that the telescope is pointing at the galaxy field.
 if (telescope_target eq 1) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must select the galaxy field.', charsize=size_print, color=0, /device
 endif
 if (telescope_target eq 0) then begin

 ;Check for initialization.
 if (initialize_telescope_done eq 0) then begin
  wshow, window_id
  erase, 255
  xyouts, 350, 365, 'You must initialize the telescope first.', charsize=size_print, color=0, /device
 endif
 if (initialize_telescope_done eq 1) then begin

 ;Put forward display.
 wshow, window_id
 erase, 255
 loadct, 3, /silent
 
 ;Find out how many galaxies have H(AB) = flag.
 number_survey=0
 flag_range=1.

 ;If the program is generating WWW results go through all the galaxies. Ignore the set flag magnitude. We will only do the galaxies down to
 ;H(AB)=25 to limit the time it takes to run the program. We set 'flag_range' to be 10. Setting it to 19 would get galaxies down to H(AB)=35.
 if (www eq 1) then begin
  spectrograph_flag=15.
  flag_range=10.
 endif
 for l=1,galaxies_total_number do begin
  if (galaxies_list_magnitude(l) ge spectrograph_flag) then begin
   if (galaxies_list_magnitude(l) lt spectrograph_flag+flag_range) then begin
    ;Make sure it is within the display size.
    if ((galaxies_list_x_pos(l) lt 936-27) and (galaxies_list_x_pos(l) gt 157+27)) then begin
     if ((galaxies_list_y_pos(l) lt 1024-27) and (galaxies_list_y_pos(l) gt 283+27)) then begin
      number_survey=number_survey+1
     endif
    endif
   endif
  endif
 endfor

 ;If the program is generating WWW results provide enough slits for all the galaxies.
 if (www eq 1) then begin
  spectrograph_slits=number_survey
  print, spectrograph_slits

;  ;If this is a WWW test-run set the number of slits to 3.
;  spectrograph_slits=3
 
 endif

 ;Set the number of WWW interface galaxies. Note, it is assumed that galaxy 0 is, in fact, the observation of the background.
 if (www eq 1) then begin
  number_completed_www=1
 endif

 ;Make blank output images. We assume the sampling of the  detector is 0.075 arcsec/pixel for now, i.e., 742 X 5000. This is where the long edge
 ;is along the dispersion axis. The maximum dispersion is 5000, so the detector is set to be a little bigger.
 spectrum_slits=fltarr(5200,1300)
 spectrum_fibers=spectrum_slits
 footprint_slits=spectrum_slits
 footprint_fibers=spectrum_slits

 ;Generate the spectrograph focal plane masks for the different slit configuration cases. These are the same size as the images. The idea is to
 ;check if a galaxy will fall within an available slit in the mask. If it does the slit will be used and the mask 'blacked out' at this location.
 ;The masks are 'paved' with unit-sized "slit assemblies". The total area is 779 X 742 pixels. Note, the slit assemblies  are offset by 157 and
 ;283 pixels from the corner of the image. Remember, we are in 0.075 arcsec/pixel scale here.
 focal_mask_slits=fltarr(1100,1300)
 focal_mask_fibers=focal_mask_slits

 ;The masks are originally full open.
 focal_mask_slits(157:935,283:1024)=1
 focal_mask_fibers(157:935,283:1024)=1
 
 ;Put tick-marks where all the list galaxies are. Select those galaxies with H(AB) = flag. Do only as many as there are slits. Make temporary masks
 ;for 'blacking out' the used slits.
 focal_mask_slits_tmp=focal_mask_slits
 focal_mask_fibers_tmp=focal_mask_fibers
 statistics_magnitude=fltarr(20000)
 statistics_ratio=statistics_magnitude+1.
 statistics_number=0
 number_completed=0
 r=floor(spectrograph_resolution)
 for l=1,galaxies_total_number do begin
  if (galaxies_list_magnitude(l) ge spectrograph_flag) then begin
   if (galaxies_list_magnitude(l) lt spectrograph_flag+flag_range) then begin

    ;Make sure it is within the field. There is a margin of 2.0 arcsec or 27 pixels
    ;for 0.075 arcsec/pixel.
    if ((galaxies_list_x_pos(l) lt 935.-27.) and (galaxies_list_x_pos(l) gt 157.+27.)) then begin
     if ((galaxies_list_y_pos(l) lt 1024.-27.) and (galaxies_list_y_pos(l) gt 283.+27.)) then begin

      ;Keep going until you use up all the slits.
      if (number_completed lt spectrograph_slits) then begin

       ;Erase the display.
       erase, 255 

       ;Display the image.
       tmp=fltarr(778,741)
       tmp=galaxies_telescope(157:936,283:1023)
       tmp_1=congrid(tmp,630,600)
       tv, tmp_1, 23, 27
 
       ;Labels.
       xyouts, 23, 657, 'Galaxy Field', charsize=size_print, color=0, /device
       xyouts, 23, 642, '(58.4 arcsec X 55.7 arcsec)', charsize=size_print, color=0, /device

       ;Pick a galaxy for study.
       x_tmp=galaxies_list_x_pos(l)
       y_tmp=galaxies_list_y_pos(l)
       galaxy_redshift=galaxies_redshift(x_tmp,y_tmp)
       galaxy_radius=galaxies_radius(x_tmp,y_tmp)

       ;Set the coordinates.
       x=floor((x_tmp-157.)*(630./779.)+23.)
       y=floor((y_tmp-283.)*(600./742.)+27.)

       ;We have selected a target.
       select_done=1

       ;Selected area. This is a 4.0 arcsec X 4.0 arcsec box.
       arrow, x-22, y-22, x+22, y-22, /solid, hsize=0, color=255
       arrow, x+22, y-22, x+22, y+22, /solid, hsize=0, color=255
       arrow, x+22, y+22, x-22, y+22, /solid, hsize=0, color=255
       arrow, x-22, y+22, x-22, y-22, /solid, hsize=0, color=255

       ;Display the chosen image section. Select a 4.0 arcsec X 4.0 arcsec section of image. For scaling of 0.075 arcsec/pixel we would require an
       ;image of size 53.3 X 53.3 pixels. We select 53 X 53 pixels.

       ;Draw an arrow to the galaxy.

       ;Black.
       arrow, 676, 625, x+22, y+22, /solid, hsize=0, color=0
       ;arrow, 676, 426, x+22, y-22, /solid, hsize=0, color=0
 
       ;White.
       arrow, 676, 624, x+22, y+21, /solid, hsize=0, color=255
       ;arrow, 676, 427, x+22, y-21, /solid, hsize=0, color=255

       ;And display the section.
       tv, congrid(galaxies_telescope(x_tmp-27:x_tmp+27,y_tmp-27:y_tmp+27), 200, 200), 676, 426

       ;Put a cross-hairs in the displayed image.
       arrow, 776-15, 527, 776+15, 527, /solid, hsize=0, color=255
       arrow, 776, 527-15, 776, 527+15, /solid, hsize=0, color=255

       ;And draw the outline of the slit area. Note the image here is 200 pixels across and
       ;is 4.0 arcsec X 4.0 arcsec. 
       tmp_1=floor((1./0.02)*spectrograph_width/2.)-2
       tmp_2=floor((1./0.02)*spectrograph_length/2.)-2
       arrow, 776-tmp_1, 526-tmp_2, 776+tmp_1, 526-tmp_2, /solid, hsize=0, color=255
       arrow, 776+tmp_1, 526-tmp_2, 776+tmp_1, 526+tmp_2, /solid, hsize=0, color=255
       arrow, 776+tmp_1, 526+tmp_2, 776-tmp_1, 526+tmp_2, /solid, hsize=0, color=255
       arrow, 776-tmp_1, 526+tmp_2, 776-tmp_1, 526-tmp_2, /solid, hsize=0, color=255
       xyouts, 776-tmp_1-5, 442, 'Slit', orientation=90., charsize=size_print, color=255, /device
 
       ;Determine properties of the galaxy.
       galaxy_magnitude=galaxies_magnitude(x_tmp,y_tmp)
       galaxy_redshift=galaxies_redshift(x_tmp,y_tmp)
       galaxy_classification=galaxies_classification(x_tmp,y_tmp)
       galaxy_radius=galaxies_radius(x_tmp,y_tmp)
       tmp_1=strarr(6)
       tmp_1(0)='background'
       tmp_1(1)='E/S0'
       tmp_1(2)='Sbc'
       tmp_1(3)='Scd'
       tmp_1(4)='Irr'
       tmp_1(5)='stellar'

       ;If this is a background field set the radius to 0.
       if (floor(galaxy_classification) eq 0) then begin
        galaxy_radius=0. 
       endif

       ;Print information on the screen.
       xyouts, 676, 657, 'Selected Region', charsize=size_print, color=0, /device
       xyouts, 676, 642, '(4.0 arcsec X 4.0 arcsec)', charsize=size_print, color=0, /device
       xyouts, 676, 397, 'Centre of Selected Region', charsize=size_print, color=0, /device
       xyouts, 676, 382, 'z = ', charsize=size_print, color=0, /device
       tmp=string(galaxy_redshift)
       tmp=strtrim(tmp,2)
       tmp=strmid(tmp,0,4)
       xyouts, 877, 382, tmp, alignment=1.0, charsize=size_print, color=0, /device 
       xyouts, 676, 367, 'H(AB) = ', charsize=size_print, color=0, /device
       tmp=string(galaxy_magnitude)
       tmp=strtrim(tmp,2)
       tmp=strmid(tmp,0,6)
       xyouts, 877, 367, tmp, alignment=1.0,charsize=size_print, color=0, /device
       xyouts, 676, 352, 'Object type = ', charsize=size_print, color=0, /device 
       xyouts, 877, 352, tmp_1(floor(galaxy_classification)), alignment=1.0, charsize=size_print, color=0, /device
       xyouts, 676, 337, 'Object radius (arcsec) = ', charsize=size_print, color=0, /device
       tmp=string(galaxy_radius)
       tmp=strtrim(tmp,2)
       tmp=strmid(tmp,0,4)
       xyouts, 877, 337, tmp, alignment=1.0, charsize=size_print, color=0, /device
       xyouts, 677, 307, 'Survey', charsize=size_print, color=0, /device
       xyouts, 677, 292, 'Selected = ', charsize=size_print, color=0, /device
       xyouts, 877, 292, number_survey, alignment=1.0, charsize=size_print, color=0, /device
       xyouts, 677, 277, 'Available slits = ', charsize=size_print, color=0, /device
       xyouts, 877, 277, spectrograph_slits, alignment=1.0, charsize=size_print, color=0, /device
       xyouts, 677, 262, 'Completed = ', charsize=size_print, color=0, /device
       xyouts, 877, 262, number_completed, alignment=1.0, charsize=size_print, color=0, /device

       ;Wait a few seconds so that the user can view the image.
       wait, 3

       ;Set the positions in the mask.
       x=x_tmp
       y=y_tmp

       ;We also need to know what size to make the map circle in pixels
       ;for the WWW interface.
       galaxy_radius_www=(8.+0.01*(2.51^(30.-galaxy_magnitude)))/2.       

       ;Perform spectroscopy on this galaxy according to the set parameters.
       spectrograph_simulation

       ;Add this spectrum to the final output spectra of the slit and fiber array cases. Make sure there are no overlapping spectra. Calculate
       ;half the width and length of the slit in pixels. Ensure that the masks have some area blocked out no matter how narrow the slits are.
       tmp=floor((spectrograph_length)*13.)
       tmp_1=floor((spectrograph_width)*13./2.)
       if (tmp_1 lt 5) then begin
        tmp_1=5
       endif
       tmp_2=floor((spectrograph_length)*13./2.)
       if (tmp_2 lt 5) then begin
        tmp_2=5
       endif

       ;First, find out if the spectrum falls on the chip. Note, 27 X 53 pixels is now 2 arcsec X 4 arcsec.
       if ((x gt 13) and (y gt 26) and (y lt 1250)) then begin

        ;Make sure it doesn't overlap the previous spectra.
        if(total(footprint_fibers(5:5+r-1,y-tmp_2:y+tmp_2)) eq 0) then begin

         ;If not, lay down the spectrum on the detector.
         spectrum_fibers(5:5+r-1,y-26:y+26)=spectrum(0:r-1,y-26:y+26)
         footprint_fibers(5:5+r-1,y-tmp_2:y+tmp_2)=255

         ;If all of this was successful and a spectrum has been laid down on the
         ;detector block off this section of the mask.
         focal_mask_fibers_tmp(x-tmp_1:x+tmp_1,y-tmp_2:y+tmp_2)=0

        endif

        ;If the spectrum won't go off the end of the detector keep going.
        if (x lt 5000-r) then begin

         ;Also, for the slit case make sure it does not overlap any previous spectra.
         if (total(footprint_slits(x:x+r-1,y-tmp_2:y+tmp_2)) eq 0) then begin

          ;If not, lay down the spectrum on the detector.
          spectrum_slits(x:x+r-1,y-26:y+26)=spectrum(0:r-1,y-26:y+26)
          footprint_slits(x:x+r-1,y-tmp_2:y+tmp_2)=255

          ;If all of this was successful and a spectrum has been laid down on the detector block off this section of the mask.
          focal_mask_slits_tmp(x-tmp_1:x+tmp_1,y-tmp_2:y+tmp_2)=0

         endif
        endif
       endif

       ;Count the number of galaxies completed.
       number_completed=number_completed+1

       ;Record the signal-to-noise ratio. Include only those with known spectral classification and good photometry.
       if (floor(galaxy_classification) le 5) then begin
        if ((photometry gt 20.) and (photometry lt 35.)) then begin
         statistics_number=statistics_number+1
         statistics_magnitude(statistics_number)=photometry
         statistics_ratio(statistics_number)=ratio
        endif
       endif
    
       ;If the program is generating WWW results save the image of the screen to a file and generate the HTML files. Also, take an image with the
       ;optical imager and the infrared imager.
       if (www eq 1) then begin

        ;Save the image.
        file_gif=strcompress(string('./virtual_telescope_www/virtual_telescope_www_display_', number_completed, '.gif'), /remove_all)
        write_gif, file_gif, screen_output

        ;Take an exposure with the Optical Imager.
        optical_imager_simulation
        
        ;Save the image.
        file_gif=strcompress(string('./virtual_telescope_www/virtual_telescope_www_display_visible_', number_completed, '.gif'), /remove_all)
        write_gif, file_gif, screen_output

        ;Take an exposure with the infrared camera.
        infrared_camera_simulation
        
        ;Save the image.
        file_gif=strcompress(string('./virtual_telescope_www/virtual_telescope_www_display_infrared_', number_completed, '.gif'), /remove_all)
        write_gif, file_gif, screen_output

        ;The galaxy labels.
        tmp=strarr(6)
        tmp(0)='background'
        tmp(1)='E/S0'
        tmp(2)='Sbc'
        tmp(3)='Scd'
        tmp(4)='Irr'
        tmp(5)='stellar'   

        ;Prepare the HTML form for the WWW interface.
        get_lun, unit
        openw, unit, './virtual_telescope_www/virtual_telescope_www_interface.html', /append

        ;Note, the HTML map function has the zero point in the upper left-hand corner. 
        ;The zero point for IDL is in the lower left-hand corner.
        tmp_1=string('<area shape="circle" ')
        tmp_2=strcompress(string(' href="/~steinb/virtual_telescope_www/virtual_telescope_www_display_', number_completed_www, '.html"'), /remove_all)
        tmp_3=strcompress(string(' target="_top" coords="', floor((x-157.)*(630./779.)+23.), ',', floor(700.-((y-283.)*(600./742.)+27.)), ',', floor(2.*galaxy_radius_www), '" alt="', tmp(floor(galaxy_classification)), ', H(AB)=', galaxies_list_magnitude(l), ', z= ', galaxies_list_redshift(l), '">'))
        tmp_4=strcompress(string(' src="/~steinb/virtual_telescope_www/virtual_telescope_www_display_', number_completed_www, '.gif"'), /remove_all)  
        tmp_5=strcompress(string(' src="/~steinb/virtual_telescope_www/virtual_telescope_www_display_visible_', number_completed_www, '.gif"'), /remove_all)  
        tmp_6=strcompress(string(' src="/~steinb/virtual_telescope_www/virtual_telescope_www_display_infrared_', number_completed_www, '.gif"'), /remove_all)  
        label=strcompress(string(tmp_1, tmp_2, tmp_3))
        printf, unit, label 
        close, unit
        free_lun, unit

        ;Prepare the HTML form for the WWW interface display of each image.
        file_html=strcompress(string('./virtual_telescope_www/virtual_telescope_www_display_', number_completed_www, '.html'), /remove_all)
        get_lun, unit
        openw, unit, file_html, /append
        printf, unit, '<html>'
        printf, unit, ' ' 
        printf, unit, '<head>'
        printf, unit, '<title>Virtual Telescope WWW Interface</title>'
        printf, unit, '</head>'
        printf, unit, ' '
        printf, unit, '<body bgcolor="#ffffff" link="#0000ff" vlink="#0000ff">'
        printf, unit, '<img ' 
        printf, unit, tmp_5
        printf, unit, '>'
        printf, unit, '<img ' 
        printf, unit, tmp_6
        printf, unit, '>'
        printf, unit, '<img ' 
        printf, unit, tmp_4
        printf, unit, '>'
        printf, unit, '</body>'
        printf, unit, ' '
        printf, unit, '</html>'  
        close, unit
        free_lun, unit

        ;Update the number of completed galaxies for the WWW interface.
        number_completed_www=number_completed_www+1
        print, number_completed_www
       endif          

      endif
     endif
    endif
   endif
  endif
 endfor

 ;Finally, save the focal plane masks. These are the masks with the used slit areas blocked out. For the case of slits and fibers these are only
 ;0.5 arcsec X 2.0 arcsec areas, but for the bands and shutters these would be the entire slit assembly areas. For the case of bands only a 0.5
 ;arcsec X 3.0 arcsec slit is blocked out. The footprint masks have covered areas set to 1. Spectra are positive on a black background.
 focal_mask_slits_out=focal_mask_slits_tmp
 focal_mask_fibers_out=focal_mask_fibers_tmp 

 ;Write out the images. We will shut this off for the WWW case.
 if (www eq 0) then begin

  ;The focal plane masks.
  writefits, './virtual_telescope_results/focal_mask_slits.fits', focal_mask_slits
  writefits, './virtual_telescope_results/focal_mask_fibers.fits', focal_mask_fibers

  ;The masks that were used.
  writefits, './virtual_telescope_results/focal_mask_slits_out.fits', focal_mask_slits_out
  writefits, './virtual_telescope_results/focal_mask_fibers_out.fits', focal_mask_fibers_out

  ;The footprints on the detector.
  writefits, './virtual_telescope_results/footprint_slits.fits', footprint_slits
  writefits, './virtual_telescope_results/footprint_fibers.fits', footprint_fibers

  ;The spectra.
  writefits, './virtual_telescope_results/spectrum_slits.fits', spectrum_slits
  writefits, './virtual_telescope_results/spectrum_fibers.fits', spectrum_fibers
 
 endif
 
 ;Set the toggle to 1.
 spectrum_multiplex_done=1

 endif
 endif
end
;----------------------------------------------------------------------------
